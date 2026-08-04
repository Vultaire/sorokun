import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class VoicevoxPaths {
  final String dictDir;
  final String vvmDir;

  VoicevoxPaths({required this.dictDir, required this.vvmDir});
}

Future<VoicevoxPaths> extractVoicevoxAssets() async {
  final docsDir = await getApplicationDocumentsDirectory();
  final voicevoxDir = '${docsDir.path}/voicevox';

  final dictDest = '$voicevoxDir/dict/open_jtalk_dic_utf_8-1.11';
  final vvmDest = '$voicevoxDir/models/vvms';

  // Skip if already extracted
  if (Directory(dictDest).existsSync() && Directory(vvmDest).existsSync()) {
    return VoicevoxPaths(dictDir: dictDest, vvmDir: vvmDest);
  }

  const dictFiles = [
    'matrix.bin',
    'right-id.def',
    'sys.dic',
    'char.bin',
    'left-id.def',
    'rewrite.def',
    'pos-id.def',
    'unk.dic',
  ];
  for (final file in dictFiles) {
    await _extractAsset(
      'assets/dict/open_jtalk_dic_utf_8-1.11/$file',
      '$dictDest/$file',
    );
  }

  const vvmFiles = ['s0.vvm'];
  for (final file in vvmFiles) {
    await _extractAsset('assets/models/vvms/$file', '$vvmDest/$file');
  }

  return VoicevoxPaths(dictDir: dictDest, vvmDir: vvmDest);
}

Future<void> _extractAsset(String assetPath, String destPath) async {
  final file = File(destPath);
  if (file.existsSync()) return;
  await file.parent.create(recursive: true);
  final data = await rootBundle.load(assetPath);
  await file.writeAsBytes(data.buffer.asUint8List());
}
