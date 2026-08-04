import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.buildCodeAssets) return;

    final os = input.config.code.targetOS;

    // iOS: the xcframework is vendored and embedded via CocoaPods
    // (see ios/VoicevoxCore.podspec). No CodeAsset registration needed —
    // DynamicLibrary.process() picks up the already-loaded symbols at
    // runtime, and voicevox_onnxruntime_load_once() takes an explicit
    // path resolved at runtime instead of a build-time asset.
    if (os == OS.iOS) {
      return;
    }

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
