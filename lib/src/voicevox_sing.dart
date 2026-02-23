import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'voicevox_core_bindings.dart';

class VoicevoxSing {
  final VoicevoxCore _bindings;
  final String _dictDir;
  final String _vvmPath;

  late Pointer<VoicevoxSynthesizer> _synthesizer;
  late Pointer<OpenJtalkRc> _openjtalk;
  late Pointer<VoicevoxVoiceModelFile> _model;
  late Pointer<VoicevoxOnnxruntime> _onnxruntime;

  VoicevoxSing({required String dictDir, required String vvmPath})
    : _dictDir = dictDir,
      _vvmPath = vvmPath,
      _bindings = VoicevoxCore(DynamicLibrary.open('libvoicevox_core.so'));

  String _getOnnxruntimePath() {
    final execDir = File(Platform.resolvedExecutable).parent.path;
    return '$execDir/lib/libvoicevox_onnxruntime.so.1.17.3';
  }

  void initialize() {
    // Load ONNX runtime
    final loadOptions = _bindings
        .voicevox_make_default_load_onnxruntime_options();
    final onnxPath = _getOnnxruntimePath().toNativeUtf8();
    loadOptions.filename = onnxPath.cast();

    final onnxruntimePtr = calloc<Pointer<VoicevoxOnnxruntime>>();
    _check(
      _bindings.voicevox_onnxruntime_load_once(loadOptions, onnxruntimePtr),
    );
    _onnxruntime = onnxruntimePtr.value;
    calloc.free(onnxruntimePtr);
    calloc.free(onnxPath);

    // Open JTalk
    final dictPath = _dictDir.toNativeUtf8();
    final openjtalkPtr = calloc<Pointer<OpenJtalkRc>>();
    _check(_bindings.voicevox_open_jtalk_rc_new(dictPath.cast(), openjtalkPtr));
    _openjtalk = openjtalkPtr.value;
    calloc.free(openjtalkPtr);
    calloc.free(dictPath);

    // Create synthesizer
    final initOptions = _bindings.voicevox_make_default_initialize_options();
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

  /// Returns WAV bytes for the given score JSON
  Uint8List synthesize({
    required String scoreJson,
    required int singingTeacherStyleId,
    required int singerStyleId,
  }) {
    final scorePtr = scoreJson.toNativeUtf8();

    // Create frame audio query
    final queryPtr = calloc<Pointer<Char>>();
    _check(
      _bindings.voicevox_synthesizer_create_sing_frame_audio_query(
        _synthesizer,
        scorePtr.cast(),
        singingTeacherStyleId,
        queryPtr,
      ),
    );
    calloc.free(scorePtr);

    // Frame synthesis
    final wavLengthPtr = calloc<UintPtr>();
    final wavPtr = calloc<Pointer<Uint8>>();
    _check(
      _bindings.voicevox_synthesizer_frame_synthesis(
        _synthesizer,
        queryPtr.value,
        singerStyleId,
        wavLengthPtr,
        wavPtr,
      ),
    );

    // Copy wav data to Dart before freeing
    final wavBytes = Uint8List.fromList(
      wavPtr.value.asTypedList(wavLengthPtr.value),
    );

    _bindings.voicevox_wav_free(wavPtr.value);
    _bindings.voicevox_json_free(queryPtr.value);
    calloc.free(queryPtr);
    calloc.free(wavLengthPtr);
    calloc.free(wavPtr);

    return wavBytes;
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
