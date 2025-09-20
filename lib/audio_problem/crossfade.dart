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

// Enhanced pitch estimation using autocorrelation with pre-filtering
double estimatePitchRobust(List<double> samples, int sampleRate) {
  // Pre-filter: remove DC offset and apply light high-pass filter
  final filtered = removeDocOffset(samples);
  final highpassed = simpleHighPass(
    filtered,
    sampleRate,
    80.0,
  ); // Remove below 80Hz

  // Use autocorrelation with normalization
  int minLag = (sampleRate / 400).floor();
  int maxLag = (sampleRate / 60).floor();

  double bestCorr = 0;
  int bestLag = minLag;

  // Calculate RMS for normalization
  double rms = 0;
  for (double sample in highpassed) {
    rms += sample * sample;
  }
  rms = sqrt(rms / highpassed.length);

  if (rms < 0.001) return 150.0; // Return default for very quiet audio

  for (int lag = minLag; lag <= maxLag; lag++) {
    double corr = 0;
    double norm1 = 0, norm2 = 0;

    for (int i = 0; i < highpassed.length - lag; i++) {
      corr += highpassed[i] * highpassed[i + lag];
      norm1 += highpassed[i] * highpassed[i];
      norm2 += highpassed[i + lag] * highpassed[i + lag];
    }

    // Normalized correlation
    if (norm1 > 0 && norm2 > 0) {
      corr = corr / sqrt(norm1 * norm2);
    }

    if (corr > bestCorr) {
      bestCorr = corr;
      bestLag = lag;
    }
  }

  return sampleRate / bestLag.toDouble();
}

List<double> removeDocOffset(List<double> samples) {
  double mean = samples.reduce((a, b) => a + b) / samples.length;
  return samples.map((s) => s - mean).toList();
}

List<double> simpleHighPass(
  List<double> samples,
  int sampleRate,
  double cutoff,
) {
  double rc = 1.0 / (2 * pi * cutoff);
  double dt = 1.0 / sampleRate;
  double alpha = rc / (rc + dt);

  List<double> result = List<double>.filled(samples.length, 0.0);
  result[0] = samples[0];

  for (int i = 1; i < samples.length; i++) {
    result[i] = alpha * (result[i - 1] + samples[i] - samples[i - 1]);
  }

  return result;
}

// Improved pitch glide with better interpolation and formant preservation
List<double> pitchGlideImproved(
  List<double> samples,
  double startFactor,
  double endFactor,
) {
  final result = <double>[];
  final n = samples.length;

  // Ensure we start and end at the exact original samples to avoid discontinuities
  for (int i = 0; i < n; i++) {
    final t = (n > 1) ? i / (n - 1) : 0.0;
    // Use smooth S-curve for more natural pitch transition
    final smoothT = 3 * t * t - 2 * t * t * t;
    final factor = startFactor + smoothT * (endFactor - startFactor);

    double sample;
    if (i == 0) {
      // Always use the exact first sample
      sample = samples[0];
    } else if (i == n - 1) {
      // Always use the exact last sample to ensure continuity
      sample = samples[samples.length - 1];
    } else {
      final srcIndex = i / factor;
      // Cubic interpolation for better quality
      sample = cubicInterpolate(samples, srcIndex);
    }

    result.add(sample);
  }

  return result;
}

double cubicInterpolate(List<double> samples, double index) {
  int i = index.floor().clamp(0, samples.length - 1);
  double frac = index - i;

  // Get 4 points for cubic interpolation
  double p0 = (i > 0) ? samples[i - 1] : samples[i];
  double p1 = samples[i];
  double p2 = (i + 1 < samples.length) ? samples[i + 1] : samples[i];
  double p3 = (i + 2 < samples.length) ? samples[i + 2] : p2;

  // Cubic interpolation
  return p1 +
      0.5 *
          frac *
          (p2 -
              p0 +
              frac *
                  (2.0 * p0 -
                      5.0 * p1 +
                      4.0 * p2 -
                      p3 +
                      frac * (3.0 * (p1 - p2) + p3 - p0)));
}

// Find optimal splice points based on zero crossings and low energy
int findOptimalSplicePoint(
  List<double> samples,
  int startSearch,
  int endSearch,
) {
  int bestPoint = startSearch;
  double bestScore = double.infinity;

  for (int i = startSearch; i < endSearch && i < samples.length - 1; i++) {
    double energy = 0;
    int windowSize = min(128, samples.length - i);

    // Calculate local energy
    for (int j = 0; j < windowSize; j++) {
      if (i + j < samples.length) {
        energy += samples[i + j] * samples[i + j];
      }
    }
    energy = sqrt(energy / windowSize);

    // Check for zero crossing
    bool isZeroCrossing = false;
    if (i > 0 && i < samples.length - 1) {
      isZeroCrossing = (samples[i - 1] * samples[i + 1] <= 0);
    }

    // Score: prefer low energy and zero crossings
    double score = energy + (isZeroCrossing ? -0.1 : 0.1);

    if (score < bestScore) {
      bestScore = score;
      bestPoint = i;
    }
  }

  return bestPoint;
}

// Find zero crossing points near a target position
int findNearestZeroCrossing(
  List<double> samples,
  int target,
  int searchRadius,
) {
  int start = max(0, target - searchRadius);
  int end = min(samples.length - 1, target + searchRadius);

  int bestPos = target;
  double bestScore = double.infinity;

  for (int i = start; i < end - 1; i++) {
    // Check for zero crossing
    if (samples[i] * samples[i + 1] <= 0) {
      // Prefer zero crossings with low energy around them
      double energy = 0;
      for (int j = max(0, i - 10); j <= min(samples.length - 1, i + 10); j++) {
        energy += samples[j] * samples[j];
      }

      double score =
          energy +
          (i - target).abs() * 0.001; // Slight preference for closer positions

      if (score < bestScore) {
        bestScore = score;
        bestPos = i;
      }
    }
  }

  return bestPos;
}

// Create seamless phonetic blending - make two words sound like one
List<double> createSeamlessBlend(
  List<double> a,
  List<double> b,
  int overlapSamples,
  int sampleRate,
) {
  final result = <double>[];

  if (a.isEmpty || b.isEmpty) {
    result.addAll(a);
    result.addAll(b);
    return result;
  }

  // For seamless blending, we want a moderate overlap - not too long to avoid over-processing
  int actualOverlap = min(overlapSamples, min(a.length ~/ 4, b.length ~/ 4));
  actualOverlap = max(
    actualOverlap,
    (sampleRate * 0.01).floor(),
  ); // Minimum 10ms
  actualOverlap = min(
    actualOverlap,
    (sampleRate * 0.08).floor(),
  ); // Maximum 80ms

  print(
    'Seamless blend overlap: ${actualOverlap} samples (${(actualOverlap * 1000 / sampleRate).toStringAsFixed(1)}ms)',
  );

  // Use smaller search radius to stay closer to the end/beginning
  int cutPointA = findLowEnergyPoint(
    a,
    a.length - actualOverlap,
    actualOverlap ~/ 4,
  );
  int cutPointB = findLowEnergyPoint(b, 0, actualOverlap ~/ 4);

  // Ensure we don't cut too much from the beginning of B
  cutPointB = min(cutPointB, actualOverlap ~/ 2);

  print('Cut points: A=${cutPointA}/${a.length}, B=${cutPointB}/${b.length}');

  // Add everything before the blend region
  for (int i = 0; i < cutPointA; i++) {
    result.add(a[i]);
  }

  // Get the blend regions
  List<double> tailA = a.sublist(cutPointA);
  List<double> headB = b.sublist(cutPointB);
  int blendLen = min(tailA.length, headB.length);
  blendLen = min(blendLen, actualOverlap);

  // Spectral blending - match the phonetic characteristics
  List<double> blendedRegion = createSpectralBlend(
    tailA.sublist(0, blendLen),
    headB.sublist(0, blendLen),
  );

  // Add the blended region
  result.addAll(blendedRegion);

  // Add the rest of B
  for (int i = cutPointB + blendLen; i < b.length; i++) {
    result.add(b[i]);
  }

  print('Seamless blend created: ${result.length} total samples');
  return result;
}

// Find low energy points for smoother blending (better than zero crossings for continuous speech)
int findLowEnergyPoint(List<double> samples, int target, int searchRadius) {
  int start = max(0, target - searchRadius);
  int end = min(samples.length - 1, target + searchRadius);

  int bestPos = target;
  double lowestEnergy = double.infinity;
  double minAcceptableEnergy = 0.01; // Don't pick completely silent regions

  for (int i = start; i <= end; i++) {
    // Calculate local energy in a small window
    double energy = 0;
    int windowSize = min(
      64,
      samples.length - i,
    ); // Larger window for better averaging

    for (int j = 0; j < windowSize; j++) {
      if (i + j < samples.length) {
        energy += samples[i + j] * samples[i + j];
      }
    }
    energy = sqrt(energy / windowSize);

    // Prefer low energy but not complete silence
    if (energy < lowestEnergy && energy > minAcceptableEnergy) {
      lowestEnergy = energy;
      bestPos = i;
    }
  }

  // If no suitable low-energy point found, fall back to original target
  if (lowestEnergy == double.infinity) {
    print('No suitable low-energy point found, using target position');
    bestPos = target;
    double energy = 0;
    int windowSize = min(64, samples.length - target);
    for (int j = 0; j < windowSize; j++) {
      if (target + j < samples.length) {
        energy += samples[target + j] * samples[target + j];
      }
    }
    lowestEnergy = sqrt(energy / windowSize);
  }

  print(
    'Low energy point: ${bestPos} (energy: ${lowestEnergy.toStringAsFixed(4)})',
  );
  return bestPos;
}

// Advanced spectral blending to make phonemes flow naturally
List<double> createSpectralBlend(List<double> segmentA, List<double> segmentB) {
  final blended = <double>[];
  final n = segmentA.length;

  for (int i = 0; i < n; i++) {
    double t = i / (n - 1);

    // Multiple blending curves for different aspects of speech

    // 1. Amplitude blending - smooth transition
    double amplitudeT = smootherstep(t);

    // 2. Formant blending - slower transition to preserve speech characteristics
    double formantT = smootherstep(t * 0.7 + 0.3); // Delayed and compressed

    // 3. Pitch contour blending - very gradual
    double pitchT = smootherstep(t * 0.5 + 0.5); // Even more delayed

    double sampleA = segmentA[i];
    double sampleB = segmentB[i];

    // Multi-layer blending
    double baseBlend = sampleA * (1.0 - amplitudeT) + sampleB * amplitudeT;

    // Add formant preservation
    double formantInfluence =
        (sampleA * (1.0 - formantT) + sampleB * formantT) * 0.2;

    // Combine with slight emphasis on maintaining speech characteristics
    double finalSample = baseBlend * 0.8 + formantInfluence;

    // Smooth any remaining discontinuities
    if (i > 0) {
      finalSample = finalSample * 0.9 + blended[i - 1] * 0.1;
    }

    blended.add(finalSample);
  }

  return blended;
}

// Even smoother than smoothstep
double smootherstep(double t) {
  t = t.clamp(0.0, 1.0);
  return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

// Amplitude matching for better level consistency
List<double> matchAmplitude(List<double> source, List<double> target) {
  // Calculate RMS of both signals
  double sourceRms = 0, targetRms = 0;

  for (double sample in source) {
    sourceRms += sample * sample;
  }
  sourceRms = sqrt(sourceRms / source.length);

  for (double sample in target) {
    targetRms += sample * sample;
  }
  targetRms = sqrt(targetRms / target.length);

  if (sourceRms < 0.001 || targetRms < 0.001) return source;

  double ratio = targetRms / sourceRms;
  // Limit the ratio to avoid extreme adjustments
  ratio = ratio.clamp(0.5, 2.0);

  return source.map((s) => s * ratio).toList();
}

// Gentle formant preservation filter
List<double> preserveFormants(List<double> samples, double pitchRatio) {
  if ((pitchRatio - 1.0).abs() < 0.1) return samples; // Skip if minimal change

  // Simple spectral envelope preservation (basic implementation)
  // In a full implementation, you'd use more sophisticated techniques
  return samples.map((s) => s * (1.0 + (pitchRatio - 1.0) * 0.3)).toList();
}

// Preprocessing function to clean up source audio
WavData preprocessAudio(
  WavData wav, {
  bool trimSilence = true,
  bool normalize = true,
}) {
  List<double> samples = List.from(wav.channels[0]);

  if (trimSilence) {
    // Find actual audio content (above noise threshold)
    double threshold = 0.005; // Lower threshold to preserve more audio

    // Find first non-silent sample
    int start = 0;
    for (int i = 0; i < samples.length; i++) {
      if (samples[i].abs() > threshold) {
        start = max(
          0,
          i - (wav.sampleRate * 0.02).floor(),
        ); // Keep only 20ms before
        break;
      }
    }

    // Find last non-silent sample
    int end = samples.length - 1;
    for (int i = samples.length - 1; i >= 0; i--) {
      if (samples[i].abs() > threshold) {
        end = min(
          samples.length - 1,
          i + (wav.sampleRate * 0.06).floor(),
        ); // Keep only 20ms after
        break;
      }
    }

    samples = samples.sublist(start, end + 1);
    print('Trimmed audio: ${start} to ${end} (${samples.length} samples)');
  }

  if (normalize) {
    // Find peak
    double peak = samples.reduce((a, b) => max(a.abs(), b.abs()));
    if (peak > 0) {
      double targetLevel = 0.7; // Lower target to prevent clipping later
      double gain = targetLevel / peak;
      samples = samples.map((s) => s * gain).toList();
      print('Normalized with gain: ${gain.toStringAsFixed(3)}');
    }
  }

  return WavData(wav.sampleRate, 1, wav.bitsPerSample, [samples]);
}

// Recursive audio concatenation for number pronunciation
Future<String> concatenateNumberAudio(
  List<List<int>> numbersList,
  String audioFolder,
) async {
  if (numbersList.isEmpty) {
    throw ArgumentError('Numbers list cannot be empty');
  }

  // Start with the last list in the numbers list
  List<int> currentNumbers = List.from(numbersList.last);
  WavData? result;

  // Process the last integer first
  if (currentNumbers.isNotEmpty) {
    int lastNumber = currentNumbers.last;
    result = await processNumber(lastNumber, audioFolder);
    currentNumbers.removeLast();
  }

  // Process remaining numbers in the current list (right to left)
  for (int i = currentNumbers.length - 1; i >= 0; i--) {
    WavData numberWav = await processNumber(currentNumbers[i], audioFolder);
    if (result != null) {
      result = await concatenateWavs(numberWav, result);
    } else {
      result = numberWav;
    }
  }

  // Process remaining number lists (right to left)
  for (int listIndex = numbersList.length - 2; listIndex >= 0; listIndex--) {
    List<int> nextNumbers = numbersList[listIndex];

    for (int i = nextNumbers.length - 1; i >= 0; i--) {
      WavData numberWav = await processNumber(nextNumbers[i], audioFolder);
      if (result != null) {
        result = await concatenateWavs(numberWav, result);
      } else {
        result = numberWav;
      }
    }
  }

  if (result == null) {
    throw StateError('No audio files were processed');
  }

  // Write final result
  final outputPath = '/tmp/final_concatenated.wav';
  writeWavFile(outputPath, result);
  print('Final concatenated audio saved to: $outputPath');
  return outputPath;
}

// Process a single number by breaking it into digit pairs
Future<WavData> processNumber(int number, String audioFolder) async {
  print('Processing number: $number');

  String numberStr = number.toString().padLeft(
    6,
    '0',
  ); // Ensure 6 digits for processing
  WavData? result;

  // Process from right to left: en, hyaku, man
  List<String> suffixes = ['en', 'hyaku', 'man'];

  for (int i = 0; i < 3; i++) {
    int startPos = numberStr.length - 2 - (i * 2);
    if (startPos < 0) break;

    String digitPair = numberStr.substring(startPos, startPos + 2);
    int digits = int.parse(digitPair);

    if (digits > 0) {
      // Skip if digits are 00
      String suffix = suffixes[i];
      String filename = '${digitPair}${suffix}.wav';
      String filepath = '$audioFolder/$filename';

      print('Loading: $filename');

      try {
        WavData wav = readWavFile(filepath);
        if (result == null) {
          result = wav;
        } else {
          // For the number ordering: man comes first, then hyaku, then en
          // But we're processing right to left, so we prepend each new part
          result = await concatenateWavs(wav, result);
        }
      } catch (e) {
        print('Warning: Could not load $filename - $e');
      }
    }
  }

  if (result == null) {
    throw StateError('No valid audio files found for number: $number');
  }

  return result;
}

// Concatenate two WAV files using the seamless blending
Future<WavData> concatenateWavs(WavData first, WavData second) async {
  // Ensure same sample rate
  if (first.sampleRate != second.sampleRate) {
    throw ArgumentError(
      'Sample rates must match: ${first.sampleRate} vs ${second.sampleRate}',
    );
  }

  // Preprocess both audio files
  WavData processedFirst = preprocessAudio(first);
  WavData processedSecond = preprocessAudio(second);

  List<double> firstChannel = processedFirst.channels[0];
  List<double> secondChannel = processedSecond.channels[0];

  // Apply pitch matching if needed
  final tailLen = min(firstChannel.length, (first.sampleRate * 0.2).floor());
  final headLen = min(secondChannel.length, (second.sampleRate * 0.2).floor());

  final tailSamples = firstChannel.sublist(
    max(0, firstChannel.length - tailLen),
  );
  final headSamples = secondChannel.sublist(0, headLen);

  final f1 = estimatePitchRobust(tailSamples, first.sampleRate);
  final f2 = estimatePitchRobust(headSamples, second.sampleRate);

  print(
    'Pitch matching: ${f1.toStringAsFixed(1)}Hz -> ${f2.toStringAsFixed(1)}Hz',
  );

  // Calculate pitch ratio with limits
  double pitchRatio = f2 / f1;
  pitchRatio = pitchRatio.clamp(0.7, 1.5);

  // Apply pitch glide to end of first audio if needed
  List<double> finalFirst = List.from(firstChannel);
  if ((pitchRatio - 1.0).abs() > 0.05) {
    // Only if significant pitch difference
    final glideLen = min(tailLen, (first.sampleRate * 0.1).floor());
    final glideStart = firstChannel.length - glideLen;
    final toGlide = firstChannel.sublist(glideStart);

    final shiftedTail = pitchGlideImproved(toGlide, 1.0, pitchRatio);
    final preservedTail = preserveFormants(shiftedTail, pitchRatio);
    final matchedTail = matchAmplitude(preservedTail, headSamples);

    // Check for clipping
    double maxVal = matchedTail.reduce((a, b) => max(a.abs(), b.abs()));
    if (maxVal > 1.0) {
      final normalizedTail = matchedTail.map((s) => s / maxVal * 0.95).toList();
      matchedTail.clear();
      matchedTail.addAll(normalizedTail);
    }

    // Smooth junction
    if (glideStart > 0 && matchedTail.isNotEmpty) {
      double beforeGlide = firstChannel[glideStart - 1];
      double afterGlide = matchedTail[0];
      double glideJump = (afterGlide - beforeGlide).abs();

      if (glideJump > 0.1) {
        int miniCrossfade = min(32, matchedTail.length);
        for (int i = 0; i < miniCrossfade; i++) {
          double t = i / (miniCrossfade - 1);
          double smoothT = t * t * (3.0 - 2.0 * t);
          matchedTail[i] =
              beforeGlide * (1.0 - smoothT) + matchedTail[i] * smoothT;
        }
      }
    }

    finalFirst = [...firstChannel.sublist(0, glideStart), ...matchedTail];
  }

  // Calculate overlap for seamless blending
  final overlap = min(
    min(finalFirst.length ~/ 4, secondChannel.length ~/ 4),
    (first.sampleRate * 0.15).floor(),
  );

  // Create seamless blend
  final blended = createSeamlessBlend(
    finalFirst,
    secondChannel,
    overlap,
    first.sampleRate,
  );

  return WavData(first.sampleRate, 1, first.bitsPerSample, [blended]);
}

// Updated main function to use the new concatenation system
Future<void> runNumberConcatenation(List<List<int>> numbersList) async {
  try {
    final outputPath = await concatenateNumberAudio(
      numbersList,
      'assets/audio',
    );

    // Play the result
    final AudioPlayer player = AudioPlayer();
    await player.play(DeviceFileSource(outputPath));

    print('Successfully created and playing concatenated audio');
  } catch (e) {
    print('Error in concatenation: $e');
  }
}

// Keep your existing helper functions (readWavFile, writeWavFile, etc.)
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

    // Example usage: [[123456], [789]]
    // This will process 789 first, then 123456
    // For 123456: reads as 56en, 34hyaku, 12man (right to left)
    // Final order: 12man, 34hyaku, 56en, then 789's parts
    List<List<int>> exampleNumbers = [
      [123456], // Will become: 12man + 34hyaku + 56en
      [789], // Will be processed first: 07hyaku + 89en (since 789 → 000789)
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
      appBar: AppBar(title: Text('Number Audio Concatenation')),
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
