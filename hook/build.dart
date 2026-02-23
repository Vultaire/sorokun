import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) return;

    final os = input.config.code.targetOS;

    // Register the main library
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'libvoicevox_core',
        linkMode: DynamicLoadingBundled(),
        file: input.packageRoot.resolve('assets/voicevox/lib/${_libName(os)}'),
      ),
    );

    // Register the ONNX runtime
    output.assets.code.add(
      CodeAsset(
        package: input.packageName,
        name: 'libvoicevox_onnxruntime',
        linkMode: DynamicLoadingBundled(),
        file: input.packageRoot.resolve(
          'assets/voicevox/onnxruntime/lib/${_onnxName(os)}',
        ),
      ),
    );
  });
}

String _libName(OS os) => switch (os) {
  OS.windows => 'voicevox_core.dll',
  OS.macOS => 'libvoicevox_core.dylib',
  _ => 'libvoicevox_core.so',
};

String _onnxName(OS os) => switch (os) {
  OS.windows => 'voicevox_onnxruntime.dll',
  OS.macOS => 'libvoicevox_onnxruntime.dylib',
  _ => 'libvoicevox_onnxruntime.so.1.17.3',
};
