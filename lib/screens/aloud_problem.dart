import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:soroban_app/src/voicevox_paths.dart';
import 'package:soroban_app/src/voicevox_sing.dart';

class AloudProblemScreen extends StatefulWidget {
  const AloudProblemScreen({super.key, required this.paths});
  final VoicevoxPaths paths;

  @override
  State<AloudProblemScreen> createState() => _AloudProblemScreenState();
}

class _AloudProblemScreenState extends State<AloudProblemScreen> {
  late final VoicevoxSing _singer;
  SoundHandle? _soundHandle;
  bool _isPlaying = false;
  late final Future<Uint8List> _wavFuture;

  static const _score = '''
{
  "notes": [
    { "key": null, "frame_length": 15, "lyric": "" },
    { "key": 60, "frame_length": 45, "lyric": "ド" },
    { "key": 62, "frame_length": 45, "lyric": "レ" },
    { "key": 64, "frame_length": 45, "lyric": "ミ" },
    { "key": null, "frame_length": 15, "lyric": "" }
  ]
}
''';

  @override
  void initState() {
    super.initState();
    _singer = VoicevoxSing(
      dictDir: widget.paths.dictDir,
      vvmPath: '${widget.paths.vvmDir}/s0.vvm',
    );
    _wavFuture = Future(() {
      _singer.initialize();
      return _singer.synthesize(
        scoreJson: _score,
        singingTeacherStyleId: 6000,
        singerStyleId: 3000,
      );
    });
  }

  @override
  void dispose() {
    _singer.dispose();
    super.dispose();
  }

  Future<void> _play(Uint8List wavBytes) async {
    if (_isPlaying) {
      await SoLoud.instance.stop(_soundHandle!);
      setState(() => _isPlaying = false);
      return;
    }

    final source = await SoLoud.instance.loadMem(
      'voicevox_out.wav',
      wavBytes,
      mode: LoadMode.memory,
    );
    final handle = await SoLoud.instance.play(source);
    setState(() {
      _soundHandle = handle;
      _isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aloud Problem')),
      body: Center(
        child: FutureBuilder<Uint8List>(
          future: _wavFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final wavBytes = snapshot.data!;
            return IconButton(
              iconSize: 64,
              icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
              onPressed: () => _play(wavBytes),
            );
          },
        ),
      ),
    );
  }
}
