// ignore_for_file: curly_braces_in_flow_control_structures, avoid_print

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
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

  Future<void> loadModel() async {
    if (_isLoaded) return;
    try {
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        AppConfig.tfliteModelPath,
        options: options,
      );
      _interpreter?.allocateTensors();
      _isLoaded = true;
      print(
          '[TFLite] Dynamic Range Quantized 23-Class model successfully initialized.');
    } catch (e) {
      print('[TFLite] Initialization breakdown: $e');
      rethrow;
    }
  }

  Future<List<TopPrediction>> predict(File imageFile) async {
    if (!_isLoaded) await loadModel();
    if (_interpreter == null)
      throw Exception("Interpreter allocated with null state");

    try {
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null)
        throw Exception('Image decoding engine failed');

      // 1. Structural resize conforming to the EfficientNetB3 target canvas
      final resized = img.copyResize(
        originalImage,
        width: AppConfig.inputSize,
        height: AppConfig.inputSize,
        interpolation: img.Interpolation.linear,
      );

// 2. Get input tensor and validate shape
      final inputTensor = _interpreter!.getInputTensor(0);
      final shape = inputTensor.shape;

      print('[TFLite] Input tensor shape: $shape');

      if (shape.isEmpty) {
        throw Exception('Invalid tensor shape: empty');
      }

      bool isNCHW = false;
      if (shape.length >= 4) {
        isNCHW = (shape[1] == 3);
      }

      const List<double> mean = [0.485, 0.456, 0.406];
      const List<double> std = [0.229, 0.224, 0.225];

      // 3. Build a FLAT Float32List, then reshape — this is the robust
      //    tflite_flutter pattern that avoids nested List/Float32List
      //    type-casting issues at native call time.
      final flatInput =
          Float32List(1 * AppConfig.inputSize * AppConfig.inputSize * 3);

      if (isNCHW) {
        // NCHW: channel-major layout [1, 3, H, W]
        const channelSize = AppConfig.inputSize * AppConfig.inputSize;
        for (var y = 0; y < AppConfig.inputSize; y++) {
          for (var x = 0; x < AppConfig.inputSize; x++) {
            final pixel = resized.getPixel(x, y);
            final idx = y * AppConfig.inputSize + x;
            flatInput[idx] = ((pixel.r / 255.0) - mean[0]) / std[0];
            flatInput[channelSize + idx] =
                ((pixel.g / 255.0) - mean[1]) / std[1];
            flatInput[2 * channelSize + idx] =
                ((pixel.b / 255.0) - mean[2]) / std[2];
          }
        }
      } else {
        // NHWC: pixel-major layout [1, H, W, 3]
        var i = 0;
        for (var y = 0; y < AppConfig.inputSize; y++) {
          for (var x = 0; x < AppConfig.inputSize; x++) {
            final pixel = resized.getPixel(x, y);
            flatInput[i++] = ((pixel.r / 255.0) - mean[0]) / std[0];
            flatInput[i++] = ((pixel.g / 255.0) - mean[1]) / std[1];
            flatInput[i++] = ((pixel.b / 255.0) - mean[2]) / std[2];
          }
        }
      }

      final inputStructure = isNCHW
          ? flatInput.reshape([1, 3, AppConfig.inputSize, AppConfig.inputSize])
          : flatInput.reshape([1, AppConfig.inputSize, AppConfig.inputSize, 3]);

      // 4. Flat output, reshaped
      final flatOutput = Float32List(AppConfig.numClasses);
      final output = flatOutput.reshape([1, AppConfig.numClasses]);

      // 5. Run interpreter inference
      try {
        _interpreter!.run(inputStructure, output);
        print('[TFLite] Inference completed successfully');
      } catch (e) {
        print('[TFLite] Direct run failed: $e');
        rethrow;
      }

      // 6. Map logit array positions via Softmax computation
      List<double> rawScores = List<double>.from(output[0] as List);
      List<double> probabilities = _softmax(rawScores);

      List<TopPrediction> predictions = [];
      for (int i = 0; i < probabilities.length; i++) {
        predictions.add(TopPrediction(
          label: AppConfig.classLabels[i],
          confidence: probabilities[i],
        ));
      }

      predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

      // Fallback if the top-ranked score fails to clear the threshold boundary
      if (predictions.isNotEmpty &&
          predictions.first.confidence < AppConfig.confidenceThreshold) {
        return [
          TopPrediction(
            label: AppConfig.labelDiseaseUndetected,
            confidence: predictions.first.confidence,
          )
        ];
      }

      return predictions.take(5).toList();
    } catch (e) {
      print('[TFLite] Runtime inference extraction failure: $e');
      rethrow;
    }
  }

  List<double> _softmax(List<double> logits) {
    double maxLogit = logits.reduce(math.max);
    List<double> exps = logits.map((l) => math.exp(l - maxLogit)).toList();
    double sumExps = exps.fold(0, (a, b) => a + b);
    return exps.map((e) => e / sumExps).toList();
  }
}
