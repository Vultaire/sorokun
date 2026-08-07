import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:soroban_app/main.dart';
import 'package:soroban_app/models/singer_config.dart';
import 'package:soroban_app/src/voicevox_sing.dart';

class VoicevoxSynthWorker {
  VoicevoxSynthWorker._();
  static final VoicevoxSynthWorker instance = VoicevoxSynthWorker._();

  SendPort? _workerSendPort;
  StreamQueue<dynamic>? _events;
  Completer<void>? _initCompleter;
  int _refCount = 0;

  final ValueNotifier<String> debugStatus = ValueNotifier('idle');

  /// Call from initState() of any screen that needs the worker alive.
  Future<void> acquire() async {
    _refCount++;
    await _ensureInitialized();
  }

  /// Call from dispose() of any screen that acquired it.
  void release() {
    _refCount--;
    if (_refCount <= 0) {
      _refCount = 0;
      _shutdown();
    }
  }

  Future<void> _ensureInitialized() async {
    if (_workerSendPort != null) return;
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return;
    }
    _initCompleter = Completer<void>();

    final mainReceivePort = ReceivePort();
    final errorPort = ReceivePort();
    errorPort.listen((error) => debugStatus.value = '[isolate onError] $error');

    await Isolate.spawn(
      _synthWorkerEntry,
      mainReceivePort.sendPort,
      onError: errorPort.sendPort,
    );
    _events = StreamQueue<dynamic>(mainReceivePort);

    debugStatus.value = 'Waiting for isolate handshake...';
    final workerSendPort =
        await _nextNonLog(
              _events!,
              timeout: const Duration(seconds: 10),
              label: 'Isolate handshake',
            )
            as SendPort;
    _workerSendPort = workerSendPort;

    debugStatus.value = 'Sending init args...';
    workerSendPort.send([
      VoicevoxService.paths.dictDir,
      '${VoicevoxService.paths.vvmDir}/s0.vvm',
    ]);

    debugStatus.value = 'Waiting for init confirmation...';
    final initResult = await _nextNonLog(
      _events!,
      timeout: const Duration(seconds: 15),
      label: 'VOICEVOX initialize()',
    );
    if (initResult is _SynthError) {
      debugStatus.value = 'INIT FAILED: ${initResult.message}';
      final err = Exception(initResult.message);
      _initCompleter!.completeError(err);
      _initCompleter = null;
      throw err;
    }
    debugStatus.value = 'Init OK — worker ready';
    _initCompleter!.complete();
  }

  Future<dynamic> _nextNonLog(
    StreamQueue events, {
    required Duration timeout,
    required String label,
  }) async {
    while (true) {
      final msg = await events.next.timeout(
        timeout,
        onTimeout: () => throw TimeoutException('$label timed out'),
      );
      if (msg is _SynthLog) {
        debugStatus.value = msg.message;
        continue;
      }
      return msg;
    }
  }

  Stream<Uint8List> synthesizeChunks(
    List<String> scores,
    Character character,
  ) async* {
    await _ensureInitialized();
    final events = _events!;
    final workerSendPort = _workerSendPort!;

    for (final score in scores) {
      workerSendPort.send(
        _SynthRequest(scoreJson: score, character: character),
      );
      final result = await _nextNonLog(
        events,
        timeout: const Duration(seconds: 15),
        label: 'Synth worker',
      );
      if (result is _SynthError) {
        debugStatus.value = 'SYNTH FAILED: ${result.message}';
        throw Exception(result.message);
      }
      debugStatus.value = 'Got chunk (${(result as Uint8List).length} bytes)';
      yield result;
    }
  }

  void _shutdown() {
    _workerSendPort?.send(const _WorkerShutdown());
    _workerSendPort = null;
    _events?.cancel();
    _events = null;
    _initCompleter = null;
    debugStatus.value = 'idle';
  }
}

class _SynthRequest {
  final String scoreJson;
  final Character character;
  const _SynthRequest({required this.scoreJson, required this.character});
}

class _WorkerShutdown {
  const _WorkerShutdown();
}

class _SynthError {
  final String message;
  const _SynthError(this.message);
}

class _SynthLog {
  final String message;
  const _SynthLog(this.message);
}

void _synthWorkerEntry(SendPort mainSendPort) async {
  final workerReceivePort = ReceivePort();
  mainSendPort.send(workerReceivePort.sendPort);
  VoicevoxSing? singer;
  workerReceivePort.listen((message) async {
    if (singer == null && message is List<String>) {
      final dictDir = message[0];
      final vvmPath = message[1];
      try {
        singer = VoicevoxSing(
          dictDir: dictDir,
          vvmPath: vvmPath,
          onLog: (msg) => mainSendPort.send(_SynthLog(msg)),
        );
        singer!.initialize();
        mainSendPort.send('INIT_OK');
      } catch (e, st) {
        mainSendPort.send(_SynthError('init failed: $e\n$st'));
      }
      return;
    }
    if (message is _SynthRequest) {
      try {
        final wav = singer!.synthesizeWithF0(
          scoreJson: message.scoreJson,
          character: message.character,
        );
        mainSendPort.send(wav);
      } catch (e, st) {
        mainSendPort.send(_SynthError('synth failed: $e\n$st'));
      }
    } else if (message is _WorkerShutdown) {
      singer?.dispose();
      workerReceivePort.close();
      Isolate.exit();
    }
  });
}
