import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:soroban_app/models/singer_config.dart';
import 'voicevox_core_bindings.dart';

DynamicLibrary loadVoicevoxCoreLib() {
  if (Platform.isIOS) {
    final bundleDir = File(Platform.resolvedExecutable).parent.path;
    final path = '$bundleDir/Frameworks/voicevox_core.framework/voicevox_core';
    return DynamicLibrary.open(path);
  } else if (Platform.isMacOS) {
    return DynamicLibrary.process();
  } else if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('libvoicevox_core.so');
  } else if (Platform.isWindows) {
    return DynamicLibrary.open('voicevox_core.dll');
  }
  throw UnsupportedError('Unsupported platform');
}

class VoicevoxSing {
  final VoicevoxCore _bindings;
  final String _dictDir;
  final String _vvmPath;

  late Pointer<VoicevoxSynthesizer> _synthesizer;
  late Pointer<OpenJtalkRc> _openjtalk;
  late Pointer<VoicevoxVoiceModelFile> _model;
  late Pointer<VoicevoxOnnxruntime> _onnxruntime;
  final void Function(String)? onLog;

  VoicevoxSing({required String dictDir, required String vvmPath, this.onLog})
    : _dictDir = dictDir,
      _vvmPath = vvmPath,
      _bindings = VoicevoxCore(loadVoicevoxCoreLib());

  String _getOnnxruntimePath() {
    if (Platform.isIOS) {
      final bundleDir = File(Platform.resolvedExecutable).parent.path;
      final path =
          '$bundleDir/Frameworks/voicevox_onnxruntime.framework/voicevox_onnxruntime';
      final exists = File(path).existsSync();
      onLog?.call('onnxruntime path: $path\nexists: $exists');
      if (!exists) {
        final frameworksDir = Directory('$bundleDir/Frameworks');
        if (frameworksDir.existsSync()) {
          final contents = frameworksDir
              .listSync()
              .map((e) => e.path.split('/').last)
              .join(', ');
          onLog?.call('NOT FOUND. Frameworks/ contains: $contents');
        } else {
          onLog?.call(
            'Frameworks/ dir missing entirely at: ${frameworksDir.path}',
          );
        }
      }
      return path;
    } else if (Platform.isLinux) {
      final execDir = File(Platform.resolvedExecutable).parent.path;
      return '$execDir/lib/libvoicevox_onnxruntime.so.1.17.3';
    }
    throw UnsupportedError('Unsupported platform for onnxruntime path');
  }

  Uint8List synthesizeWithF0({
    required String scoreJson,
    required Character character,
  }) {
    // Adjust note keys in score
    final adjustedScoreJson = character.keyRangeAdjustment == 0
        ? scoreJson
        : _adjustScoreKeys(scoreJson, character.keyRangeAdjustment);

    // Get audio query
    final scorePtr = adjustedScoreJson.toNativeUtf8();
    final queryPtr = calloc<Pointer<Char>>();
    _check(
      _bindings.voicevox_synthesizer_create_sing_frame_audio_query(
        _synthesizer,
        scorePtr.cast(),
        6000,
        queryPtr,
      ),
    );
    calloc.free(scorePtr);
    final queryJson = queryPtr.value.cast<Utf8>().toDartString();
    _bindings.voicevox_json_free(queryPtr.value);
    calloc.free(queryPtr);

    // Smooth F0, compensate for key adjustment, and re-encode
    final query = jsonDecode(queryJson) as Map<String, dynamic>;
    final rawF0 = (query['f0'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    final smoothed = smoothF0(rawF0);
    final f0Multiplier = pow(2.0, character.keyRangeAdjustment / 12.0);
    query['f0'] = smoothed.map((f0) => f0 * f0Multiplier).toList();
    final modifiedQueryJson = jsonEncode(query);

    // Synthesize
    final modifiedQueryPtr = modifiedQueryJson.toNativeUtf8();
    final wavLengthPtr = calloc<UintPtr>();
    final wavPtr = calloc<Pointer<Uint8>>();
    _check(
      _bindings.voicevox_synthesizer_frame_synthesis(
        _synthesizer,
        modifiedQueryPtr.cast(),
        character.singerId,
        wavLengthPtr,
        wavPtr,
      ),
    );
    calloc.free(modifiedQueryPtr);
    final wavBytes = Uint8List.fromList(
      wavPtr.value.asTypedList(wavLengthPtr.value),
    );
    _bindings.voicevox_wav_free(wavPtr.value);
    calloc.free(wavLengthPtr);
    calloc.free(wavPtr);
    return wavBytes;
  }

  String _adjustScoreKeys(String scoreJson, int keyRangeAdjustment) {
    final score = jsonDecode(scoreJson) as Map<String, dynamic>;
    final notes = (score['notes'] as List).map((note) {
      final noteMap = Map<String, dynamic>.from(note as Map);
      if (noteMap['key'] != null) {
        noteMap['key'] = (noteMap['key'] as int) - keyRangeAdjustment;
      }
      return noteMap;
    }).toList();
    score['notes'] = notes;
    return jsonEncode(score);
  }

  // Load ONNX runtime
  void initialize() {
    final onnxruntimePtr = calloc<Pointer<VoicevoxOnnxruntime>>();

    if (Platform.isIOS) {
      _check(_bindings.voicevox_onnxruntime_init_once(onnxruntimePtr));
    } else {
      final loadOptions = _bindings
          .voicevox_make_default_load_onnxruntime_options();
      final onnxPath = _getOnnxruntimePath().toNativeUtf8();
      loadOptions.filename = onnxPath.cast();
      _check(
        _bindings.voicevox_onnxruntime_load_once(loadOptions, onnxruntimePtr),
      );
      calloc.free(onnxPath);
    }

    _onnxruntime = onnxruntimePtr.value;
    calloc.free(onnxruntimePtr);
    // Open JTalk
    final dictPath = _dictDir.toNativeUtf8();
    final openjtalkPtr = calloc<Pointer<OpenJtalkRc>>();
    _check(_bindings.voicevox_open_jtalk_rc_new(dictPath.cast(), openjtalkPtr));
    _openjtalk = openjtalkPtr.value;
    calloc.free(openjtalkPtr);
    calloc.free(dictPath);

    // Create synthesizer
    final initOptions = _bindings.voicevox_make_default_initialize_options();
    initOptions.acceleration_mode =
        VoicevoxAccelerationMode.VOICEVOX_ACCELERATION_MODE_CPU.value;
    initOptions.cpu_num_threads = Platform.numberOfProcessors;

    final synthPtr = calloc<Pointer<VoicevoxSynthesizer>>();
    _check(
      _bindings.voicevox_synthesizer_new(
        _onnxruntime,
        _openjtalk,
        initOptions,
        synthPtr,
      ),
    );
    _synthesizer = synthPtr.value;
    calloc.free(synthPtr);

    // Load voice model
    final vvmPath = _vvmPath.toNativeUtf8();
    final modelPtr = calloc<Pointer<VoicevoxVoiceModelFile>>();
    _check(_bindings.voicevox_voice_model_file_open(vvmPath.cast(), modelPtr));
    _model = modelPtr.value;
    calloc.free(vvmPath);
    calloc.free(modelPtr);

    _check(
      _bindings.voicevox_synthesizer_load_voice_model(_synthesizer, _model),
    );
  }

  List<double> smoothF0(List<double> f0, {int windowSize = 10}) {
    final smoothed = List<double>.filled(f0.length, 0.0);
    for (int i = 0; i < f0.length; i++) {
      int count = 0;
      double sum = 0.0;
      for (int j = i - windowSize ~/ 2; j <= i + windowSize ~/ 2; j++) {
        if (j >= 0 && j < f0.length && f0[j] > 0.0) {
          sum += f0[j];
          count++;
        }
      }
      smoothed[i] = count > 0 ? sum / count : 0.0;
    }
    return smoothed;
  }

  void dispose() {
    _bindings.voicevox_voice_model_file_delete(_model);
    _bindings.voicevox_synthesizer_delete(_synthesizer);
    _bindings.voicevox_open_jtalk_rc_delete(_openjtalk);
  }

  void _check(int resultCode) {
    if (resultCode != VoicevoxResultCode.VOICEVOX_RESULT_OK.value) {
      final msgPtr = _bindings.voicevox_error_result_to_message(resultCode);
      final msg = msgPtr.cast<Utf8>().toDartString();
      throw Exception('Voicevox error: $msg');
    }
  }
}
