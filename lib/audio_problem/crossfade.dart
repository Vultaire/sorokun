import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class WavData {
  final int sampleRate;
  final int numChannels;
  final int bitsPerSample;
  final List<List<double>> channels;

  WavData(this.sampleRate, this.numChannels, this.bitsPerSample, this.channels);
}

WavData readWavFile(String path) {
  final bytes = File(path).readAsBytesSync();
  final data = ByteData.sublistView(bytes);

  if (String.fromCharCodes(bytes.sublist(0, 4)) != 'RIFF' ||
      String.fromCharCodes(bytes.sublist(8, 12)) != 'WAVE') {
    throw FormatException('Not a valid WAV file');
  }

  int fmtOffset = -1, dataOffset = -1, dataLength = -1;
  int offset = 12;

  while (offset + 8 < bytes.length) {
    final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final chunkSize = data.getUint32(offset + 4, Endian.little);
    if (chunkId == 'fmt ') fmtOffset = offset + 8;
    if (chunkId == 'data') {
      dataOffset = offset + 8;
      dataLength = chunkSize;
    }
    offset += 8 + chunkSize;
  }

  if (fmtOffset == -1 || dataOffset == -1) {
    throw FormatException('Invalid WAV: missing fmt or data chunk');
  }

  final audioFormat = data.getUint16(fmtOffset, Endian.little);
  final numChannels = data.getUint16(fmtOffset + 2, Endian.little);
  final sampleRate = data.getUint32(fmtOffset + 4, Endian.little);
  final bitsPerSample = data.getUint16(fmtOffset + 14, Endian.little);

  final numFrames = (dataLength / (bitsPerSample ~/ 8) / numChannels).floor();
  final channels = List.generate(
    numChannels,
    (_) => List<double>.filled(numFrames, 0.0),
  );

  int pos = dataOffset;
  for (int frame = 0; frame < numFrames; frame++) {
    for (int ch = 0; ch < numChannels; ch++) {
      double sample;
      if (audioFormat == 1) {
        // PCM int
        if (bitsPerSample == 16) {
          sample = data.getInt16(pos, Endian.little) / 32768.0;
          pos += 2;
        } else if (bitsPerSample == 8) {
          sample = (data.getUint8(pos) - 128) / 128.0;
          pos += 1;
        } else {
          throw FormatException('Unsupported PCM depth: $bitsPerSample bits');
        }
      } else if (audioFormat == 3) {
        // IEEE float
        if (bitsPerSample == 32) {
          sample = data.getFloat32(pos, Endian.little);
          pos += 4;
        } else {
          throw FormatException(
            'Unsupported float PCM depth: $bitsPerSample bits',
          );
        }
      } else {
        throw FormatException('Unsupported audioFormat: $audioFormat');
      }
      channels[ch][frame] = sample;
    }
  }

  return WavData(sampleRate, numChannels, bitsPerSample, channels);
}

void writeWavFile(String path, WavData wav) {
  final numFrames = wav.channels[0].length;
  final bytesPerSample = 2;
  final byteRate = wav.sampleRate * wav.numChannels * bytesPerSample;
  final blockAlign = wav.numChannels * bytesPerSample;
  final dataSize = numFrames * blockAlign;
  final fileSize = 36 + dataSize;

  final buffer = BytesBuilder();

  buffer.add('RIFF'.codeUnits);
  buffer.add(_le32(fileSize));
  buffer.add('WAVE'.codeUnits);

  buffer.add('fmt '.codeUnits);
  buffer.add(_le32(16));
  buffer.add(_le16(1));
  buffer.add(_le16(wav.numChannels));
  buffer.add(_le32(wav.sampleRate));
  buffer.add(_le32(byteRate));
  buffer.add(_le16(blockAlign));
  buffer.add(_le16(16));

  buffer.add('data'.codeUnits);
  buffer.add(_le32(dataSize));

  for (int i = 0; i < numFrames; i++) {
    for (int ch = 0; ch < wav.numChannels; ch++) {
      final v = (wav.channels[ch][i] * 32767.0).clamp(-32768, 32767).toInt();
      buffer.add(_le16(v));
    }
  }

  File(path).writeAsBytesSync(buffer.toBytes());
}

List<int> _le16(int v) => [v & 0xff, (v >> 8) & 0xff];
List<int> _le32(int v) => [
  v & 0xff,
  (v >> 8) & 0xff,
  (v >> 16) & 0xff,
  (v >> 24) & 0xff,
];

// Simple preprocessing - just trim silence
WavData preprocessAudio(WavData wav, {bool trimSilence = true}) {
  List<double> samples = List.from(wav.channels[0]);

  if (trimSilence) {
    double threshold = 0.01;

    // Find first non-silent sample
    int start = 0;
    for (int i = 0; i < samples.length; i++) {
      if (samples[i].abs() > threshold) {
        start = max(0, i - (wav.sampleRate * 0.001).floor());
        break;
      }
    }

    // Find last non-silent sample
    int end = samples.length - 1;
    for (int i = samples.length - 1; i >= 0; i--) {
      if (samples[i].abs() > threshold) {
        end = min(samples.length - 1, i + (wav.sampleRate * 0.001).floor());
        break;
      }
    }

    samples = samples.sublist(start, end + 1);
    print('Trimmed audio: $start to $end}(${samples.length} samples)');
  }

  return WavData(wav.sampleRate, 1, wav.bitsPerSample, [samples]);
}

// Simple concatenation
WavData concatenateWavs(List<WavData> wavList) {
  if (wavList.isEmpty) {
    throw ArgumentError('WAV list cannot be empty');
  }

  if (wavList.length == 1) {
    return wavList[0];
  }

  // Ensure all have same sample rate
  int sampleRate = wavList[0].sampleRate;
  for (WavData wav in wavList) {
    if (wav.sampleRate != sampleRate) {
      throw ArgumentError('All WAV files must have same sample rate');
    }
  }

  // Concatenate all channels
  List<double> result = [];
  for (WavData wav in wavList) {
    result.addAll(wav.channels[0]);
  }

  print('Concatenated ${wavList.length} files into ${result.length} samples');

  return WavData(sampleRate, 1, wavList[0].bitsPerSample, [result]);
}

// Process a single number by breaking it into digit pairs
WavData processNumber(int number, String audioFolder) {
  print('Processing number: $number');

  String numberStr = number.toString().padLeft(6, '0');
  List<WavData> parts = [];

  // Process from right to left: en, hyaku, man
  List<String> suffixes = ['en', 'hyaku', 'man'];

  for (int i = 0; i < 3; i++) {
    int startPos = numberStr.length - 2 - (i * 2);
    if (startPos < 0) break;

    String digitPair = numberStr.substring(startPos, startPos + 2);
    int digits = int.parse(digitPair);

    if (digits > 0) {
      String suffix = suffixes[i];
      String filename = '$digitPair$suffix.wav';
      String filepath = '$audioFolder/$filename';

      print('Loading: $filename');

      try {
        WavData wav = readWavFile(filepath);
        WavData processed = preprocessAudio(wav, trimSilence: true);
        // Insert at beginning to get correct order: man, hyaku, en
        parts.insert(0, processed);
      } catch (e) {
        print('Warning: Could not load $filename - $e');
      }
    }
  }

  if (parts.isEmpty) {
    throw StateError('No valid audio files found for number: $number');
  }

  return concatenateWavs(parts);
}

// Main concatenation function
Future<String> concatenateNumberAudio(
  List<List<int>> numbersList,
  String audioFolder,
) async {
  if (numbersList.isEmpty) {
    throw ArgumentError('Numbers list cannot be empty');
  }

  List<WavData> allNumbers = [];

  // Process each list in order
  for (int listIndex = 0; listIndex < numbersList.length; listIndex++) {
    List<int> currentNumbers = numbersList[listIndex];

    // Process each number in the list in order
    for (int numIndex = 0; numIndex < currentNumbers.length; numIndex++) {
      int number = currentNumbers[numIndex];
      WavData numberWav = processNumber(number, audioFolder);
      allNumbers.add(numberWav);
    }
  }

  if (allNumbers.isEmpty) {
    throw StateError('No audio files were processed');
  }

  // Simple concatenation
  WavData result = concatenateWavs(allNumbers);

  final outputPath = '/tmp/final_concatenated.wav';
  writeWavFile(outputPath, result);
  print('Final concatenated audio saved to: $outputPath');
  return outputPath;
}

// Updated main function
Future<void> runNumberConcatenation(List<List<int>> numbersList) async {
  try {
    final outputPath = await concatenateNumberAudio(
      numbersList,
      'assets/audio',
    );

    final AudioPlayer player = AudioPlayer();
    await player.play(DeviceFileSource(outputPath));

    print('Successfully created and playing concatenated audio');
  } catch (e) {
    print('Error in concatenation: $e');
  }
}

void main() {
  runApp(MaterialApp(home: AudioDemo()));
}

class AudioDemo extends StatefulWidget {
  @override
  _AudioDemoState createState() => _AudioDemoState();
}

class _AudioDemoState extends State<AudioDemo> {
  final AudioPlayer player = AudioPlayer();
  String? outputPath;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    runExample();
  }

  Future<void> runExample() async {
    setState(() => isProcessing = true);

    // Example: [[123456, 789]]

    List<List<int>> exampleNumbers = [
      [123456, 789],
    ];

    try {
      await runNumberConcatenation(exampleNumbers);
      setState(() {
        outputPath = '/tmp/final_concatenated.wav';
        isProcessing = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() => isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Audio Concatenation')),
      body: Center(
        child: isProcessing
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing audio files...'),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    outputPath != null
                        ? 'Audio created: $outputPath'
                        : 'No audio created',
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: outputPath != null
                        ? () => player.play(DeviceFileSource(outputPath!))
                        : null,
                    child: Text('Play Audio'),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => player.stop(),
                    child: Text('Stop'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: runExample,
                    child: Text('Run Again'),
                  ),
                ],
              ),
      ),
    );
  }
}
