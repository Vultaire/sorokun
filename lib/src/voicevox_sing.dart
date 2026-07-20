import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:soroban_app/models/singer_config.dart';
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

class VoicevoxTTS {
  final VoicevoxCore _bindings;
  late Pointer<VoicevoxSynthesizer> _synthesizer;

  VoicevoxTTS()
    : _bindings = VoicevoxCore(DynamicLibrary.open('libvoicevox_core.so'));

  String _getOnnxruntimePath() {
    final execDir = File(Platform.resolvedExecutable).parent.path;
    return '$execDir/lib/libvoicevox_onnxruntime.so.1.17.3';
  }

  void initialize({required String dictDir, required String vvmsDir}) {
    // Load ONNX runtime
    final loadOptions = _bindings
        .voicevox_make_default_load_onnxruntime_options();
    final onnxPath = _getOnnxruntimePath().toNativeUtf8();
    loadOptions.filename = onnxPath.cast();
    final onnxruntimePtr = calloc<Pointer<VoicevoxOnnxruntime>>();
    _check(
      _bindings.voicevox_onnxruntime_load_once(loadOptions, onnxruntimePtr),
    );
    final onnxruntime = onnxruntimePtr.value;
    calloc.free(onnxruntimePtr);
    calloc.free(onnxPath);

    // Open JTalk
    final dictPath = dictDir.toNativeUtf8();
    final openjtalkPtr = calloc<Pointer<OpenJtalkRc>>();
    _check(_bindings.voicevox_open_jtalk_rc_new(dictPath.cast(), openjtalkPtr));
    final openjtalk = openjtalkPtr.value;
    calloc.free(openjtalkPtr);
    calloc.free(dictPath);

    // Create synthesizer
    final initOptions = _bindings.voicevox_make_default_initialize_options();
    final synthPtr = calloc<Pointer<VoicevoxSynthesizer>>();
    _check(
      _bindings.voicevox_synthesizer_new(
        onnxruntime,
        openjtalk,
        initOptions,
        synthPtr,
      ),
    );
    _synthesizer = synthPtr.value;
    calloc.free(synthPtr);
    _bindings.voicevox_open_jtalk_rc_delete(openjtalk);

    // Load all .vvm models from directory
    final dir = Directory(vvmsDir);
    print('Looking for vvms in: ${dir.path}');
    print('Directory exists: ${dir.existsSync()}');

    for (final entry in dir.listSync()) {
      print('Found file: ${entry.path}');
      if (entry is File && entry.path.endsWith('.vvm')) {
        print('Loading vvm: ${entry.path}');
        final vvmPath = entry.path.toNativeUtf8();
        final modelPtr = calloc<Pointer<VoicevoxVoiceModelFile>>();
        _check(
          _bindings.voicevox_voice_model_file_open(vvmPath.cast(), modelPtr),
        );
        final model = modelPtr.value;
        calloc.free(vvmPath);
        calloc.free(modelPtr);
        _check(
          _bindings.voicevox_synthesizer_load_voice_model(_synthesizer, model),
        );
        print('Loaded successfully');
        _bindings.voicevox_voice_model_file_delete(model);
      }
    }
  }

  Uint8List tts({
    required String text,
    required int styleId,
    double speedScale = 1.0,
    double pitchScale = 0.0,
    double intonationScale = 1.0,
  }) {
    // Step 1: Create accent phrases
    final textPtr = text.toNativeUtf8();
    final accentPhrasesPtr = calloc<Pointer<Char>>();
    _check(
      _bindings.voicevox_synthesizer_create_accent_phrases(
        _synthesizer,
        textPtr.cast(),
        styleId,
        accentPhrasesPtr,
      ),
    );
    calloc.free(textPtr);
    final accentPhrasesJson = accentPhrasesPtr.value
        .cast<Utf8>()
        .toDartString();
    _bindings.voicevox_json_free(accentPhrasesPtr.value);
    calloc.free(accentPhrasesPtr);

    // Step 2: Modify accent phrases if needed
    final modifiedAccentPhrasesJson = _modifyAccentPhrasesPitch(
      accentPhrasesJson,
    );

    // Step 3: Create audio query from accent phrases
    final accentPtr = modifiedAccentPhrasesJson.toNativeUtf8();
    final audioQueryPtr = calloc<Pointer<Char>>();
    _check(
      _bindings.voicevox_audio_query_create_from_accent_phrases(
        accentPtr.cast(),
        audioQueryPtr,
      ),
    );
    calloc.free(accentPtr);
    final audioQueryJson = audioQueryPtr.value.cast<Utf8>().toDartString();
    _bindings.voicevox_json_free(audioQueryPtr.value);
    calloc.free(audioQueryPtr);

    // Step 4: Modify audio query parameters
    final audioQuery = jsonDecode(audioQueryJson) as Map<String, dynamic>;
    audioQuery['speedScale'] = speedScale;
    audioQuery['pitchScale'] = pitchScale;
    audioQuery['intonationScale'] = intonationScale;
    audioQuery['outputStereo'] = true;
    final modifiedAudioQueryJson = jsonEncode(audioQuery);

    // Step 5: Synthesize
    final queryPtr = modifiedAudioQueryJson.toNativeUtf8();
    final wavLengthPtr = calloc<UintPtr>();
    final wavPtr = calloc<Pointer<Uint8>>();
    _check(
      _bindings.voicevox_synthesizer_synthesis(
        _synthesizer,
        queryPtr.cast(),
        styleId,
        _bindings.voicevox_make_default_synthesis_options(),
        wavLengthPtr,
        wavPtr,
      ),
    );
    calloc.free(queryPtr);
    final wavBytes = Uint8List.fromList(
      wavPtr.value.asTypedList(wavLengthPtr.value),
    );
    _bindings.voicevox_wav_free(wavPtr.value);
    calloc.free(wavLengthPtr);
    calloc.free(wavPtr);
    return wavBytes;
  }

  String _modifyAccentPhrasesPitch(String accentPhrasesJson) {
    const double lowPitch = 5.50;
    const double highPitch = 5.65;

    final accentPhrases = jsonDecode(accentPhrasesJson) as List;
    for (final phrase in accentPhrases) {
      final moras = phrase['moras'] as List;
      final int downstep = (phrase['accent'] as num).toInt();

      for (int i = 0; i < moras.length; i++) {
        final bool isHigh;
        if (downstep == 1) {
          isHigh = i == 0;
        } else {
          isHigh = i > 0 && i < downstep;
        }
        moras[i]['pitch'] = isHigh ? highPitch : lowPitch;
      }
    }
    return jsonEncode(accentPhrases);
  }

  void dispose() {
    _bindings.voicevox_synthesizer_delete(_synthesizer);
  }

  void _check(int resultCode) {
    if (resultCode != VoicevoxResultCode.VOICEVOX_RESULT_OK.value) {
      final msgPtr = _bindings.voicevox_error_result_to_message(resultCode);
      final msg = msgPtr.cast<Utf8>().toDartString();
      throw Exception('Voicevox error: $msg');
    }
  }
}
