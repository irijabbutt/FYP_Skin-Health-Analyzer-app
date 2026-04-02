// -----------------------------------------------
// Project: Skin Health Analyzer
// File: tflite_service.dart
// Description: On-device TFLite skin condition inference
// -----------------------------------------------

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../Utils/app_config.dart';
import '../Models/scan_result.dart';

class TFLiteService {
  static final TFLiteService _instance = TFLiteService._internal();
  factory TFLiteService() => _instance;
  TFLiteService._internal();

  Interpreter? _interpreter;
  bool _isLoaded = false;

  // ── Load model ────────────────────────────────
  Future<void> loadModel() async {
    if (_isLoaded) return;
    try {
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        AppConfig.tfliteModelPath,
        options: options,
      );
      _isLoaded = true;
      print('[TFLite] Model loaded successfully');
      print('[TFLite] Input: ${_interpreter!.getInputTensor(0).shape}');
      print('[TFLite] Output: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      print('[TFLite] Error loading model: $e');
      rethrow;
    }
  }

  // ── Run inference ─────────────────────────────
  Future<List<TopPrediction>> predict(File imageFile) async {
    if (!_isLoaded) await loadModel();

    try {
      // 1. Load & preprocess image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Could not decode image');

      final resized = img.copyResize(
        image,
        width: AppConfig.inputSize,
        height: AppConfig.inputSize,
      );

      // 2. Convert to Float32 input tensor [1, 224, 224, 3]
      //    EfficientNetB0 in Keras expects raw [0–255] float values
      final inputBuffer = Float32List(
          1 * AppConfig.inputSize * AppConfig.inputSize * 3);
      int idx = 0;
      for (int y = 0; y < AppConfig.inputSize; y++) {
        for (int x = 0; x < AppConfig.inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          inputBuffer[idx++] = pixel.r.toDouble();
          inputBuffer[idx++] = pixel.g.toDouble();
          inputBuffer[idx++] = pixel.b.toDouble();
        }
      }
      final input = inputBuffer
          .reshape([1, AppConfig.inputSize, AppConfig.inputSize, 3]);

      // 3. Output buffer [1, 23]
      final outputBuffer =
          List.filled(AppConfig.numClasses, 0.0).reshape([1, AppConfig.numClasses]);

      // 4. Run inference
      _interpreter!.run(input, outputBuffer);

      // 5. Parse probabilities (model has softmax, values sum to 1)
      final probabilities = List<double>.from(
          (outputBuffer as List)[0] as List);

      // 6. Build sorted predictions
      final predictions = <TopPrediction>[];
      for (int i = 0; i < AppConfig.classLabels.length; i++) {
        predictions.add(TopPrediction(
          label: AppConfig.classLabels[i],
          confidence: probabilities[i],
        ));
      }
      predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

      return predictions.take(5).toList();
    } catch (e) {
      print('[TFLite] Inference error: $e');
      rethrow;
    }
  }

  void dispose() {
    _interpreter?.close();
    _isLoaded = false;
  }
}
