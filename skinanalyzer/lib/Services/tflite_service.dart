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
  bool _usingGpu = false;

  /// Whether the currently loaded interpreter is running on the GPU delegate.
  /// Useful for surfacing in debug UI / logs if predictions look off.
  bool get isUsingGpu => _usingGpu;

  Future<void> loadModel() async {
    if (_isLoaded) return;

    // 1. Try GPU delegate first (Android only — tflite_flutter's GpuDelegateV2
    //    wraps the Android NNAPI/OpenGL GPU delegate; there is no supported
    //    Metal/iOS delegate in this package version).
    //    isPrecisionLossAllowed is explicitly set to FALSE. The library's own
    //    default already forces max-precision, fast-single-answer inference
    //    (see GpuDelegateOptionsV2 defaults), which is what we want — but
    //    the default GPU delegate on some devices/driver versions still
    //    allows FP16 math for speed. Forcing this explicitly keeps GPU
    //    output numerically consistent with the CPU path the threshold
    //    (0.50) was actually calibrated against, instead of shifting
    //    borderline scores below it and surfacing a false
    //    "Condition Undetected" result.
    if (Platform.isAndroid) {
      try {
        final gpuDelegate = GpuDelegateV2(
          options: GpuDelegateOptionsV2(
            isPrecisionLossAllowed: false,
          ),
        );
        final gpuOptions = InterpreterOptions()..addDelegate(gpuDelegate);
        _interpreter = await Interpreter.fromAsset(
          AppConfig.tfliteModelPath,
          options: gpuOptions,
        );
        _interpreter?.allocateTensors();
        _usingGpu = true;
        _isLoaded = true;
        print('[TFLite] GPU delegate initialized (full precision).');
        return;
      } catch (e) {
        // Common causes: device has no compatible GPU driver, or the
        // customized EfficientNet-B3 graph contains an op the GPU delegate
        // doesn't support (delegate creation can fail outright in that
        // case). Either way we must NOT let this bubble up as a broken
        // interpreter — fall back to CPU.
        print('[TFLite] GPU delegate unavailable, falling back to CPU: $e');
        _interpreter = null;
        _usingGpu = false;
      }
    }

    // 2. CPU fallback (also the only path on iOS/desktop in this setup).
    try {
      final cpuOptions = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        AppConfig.tfliteModelPath,
        options: cpuOptions,
      );
      _interpreter?.allocateTensors();
      _isLoaded = true;
      _usingGpu = false;
      print(
          '[TFLite] CPU interpreter initialized (4 threads, full precision).');
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

      if (predictions.isNotEmpty) {
        print('[TFLite] delegate=${_usingGpu ? "GPU" : "CPU"} '
            'top1=${predictions.first.label} '
            'conf=${predictions.first.confidence.toStringAsFixed(4)} '
            'threshold=${AppConfig.confidenceThreshold}');
      }

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