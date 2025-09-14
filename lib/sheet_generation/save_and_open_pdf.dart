import 'dart:io';
import 'dart:typed_data';

import 'package:open_document/open_document.dart';
import 'package:path_provider/path_provider.dart';

Future<void> savePdfFile(String fileName, Uint8List bytelist) async {
  final output = await getTemporaryDirectory();
  var filePath = "${output.path}/$fileName.pdf";
  final file = File(filePath);
  await file.writeAsBytes(bytelist);

  // Platform-specific opening
  if (Platform.isAndroid || Platform.isIOS) {
    await OpenDocument.openDocument(filePath: filePath);
  } else if (Platform.isWindows) {
    Process.run('start', [filePath], runInShell: true);
  } else if (Platform.isMacOS) {
    Process.run('open', [filePath], runInShell: true);
  } else if (Platform.isLinux) {
    Process.run('xdg-open', [filePath], runInShell: true);
  }
}
