// -----------------------------------------------
// Project: Skin Health Analyzer
// File: scan.dart
// Developer: Mirza Ibtisam
// Description: Camera/gallery scan + TFLite inference
// -----------------------------------------------

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../Models/scan_result.dart';
import '../../Services/n8n_service.dart';
import '../../Services/supabase_service.dart';
import '../../Services/tflite_service.dart';
import '../../Utils/app_config.dart';
import '../../Utils/values/color.dart';
import '../../Utils/values/my_images.dart';
import '../Results Screen/results.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  bool _isAnalyzing = false;
  String _statusText = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final _picker = ImagePicker();
  final _tflite = TFLiteService();
  final _supabase = SupabaseService();
  final _n8n = N8nService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (file != null) {
      setState(() {
        _image = File(file.path);
        _statusText = '';
      });
    }
  }

  // ── Run full analysis pipeline ────────────────
  Future<void> _analyzeImage() async {
    if (_image == null) {
      _showSnack('Please select an image first', isError: true);
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _statusText = 'Loading AI model…';
    });

    try {
      // 1. TFLite inference
      await _tflite.loadModel();
      setState(() => _statusText = 'Analyzing skin condition…');
      final predictions = await _tflite.predict(_image!);

      if (predictions.isEmpty) {
        throw Exception('No predictions returned');
      }

      final topPrediction = predictions.first;
      final condition = topPrediction.label;
      final confidence = topPrediction.confidence;
      final description = AppConfig.conditionDescriptions[condition] ??
          'Consult a dermatologist for a professional diagnosis.';
      final urgency = AppConfig.conditionUrgency[condition] ?? 'low';

      // 2. Upload image to Supabase Storage
      setState(() => _statusText = 'Saving results…');
      String? imageUrl;
      if (_supabase.isLoggedIn) {
        imageUrl = await _supabase.uploadImage(_image!);
      }

      // 3. Build result object
      final result = ScanResult(
        userId: _supabase.userId,
        imagePath: _image!.path,
        imageUrl: imageUrl,
        conditionName: condition,
        confidence: confidence,
        description: description,
        urgency: urgency,
        topPredictions: predictions,
        createdAt: DateTime.now(),
      );

      // 4. Save to Supabase DB
      ScanResult? savedResult = result;
      if (_supabase.isLoggedIn) {
        savedResult = await _supabase.saveScanResult(result) ?? result;
      }

      // 5. Fire n8n webhook (non-blocking)
      _n8n.sendScanResult(savedResult).then((_) {
        if (urgency == 'high') _n8n.sendUrgencyAlert(savedResult!);
      });

      setState(() => _isAnalyzing = false);

      // 6. Navigate to results
      if (mounted) {
        Get.to(
          () => ResultsScreen(result: savedResult!),
          transition: Transition.rightToLeft,
        );
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      _showSnack('Analysis failed: ${e.toString()}', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade600 : MyColors.PastelRose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.LightLightLavender,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Header ───────────────────────
                const Text(
                  'Analyze Your Skin',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: MyColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Take a photo or upload an image\nto detect skin conditions instantly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),

                // ── Image Preview ─────────────────
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _isAnalyzing ? _pulseAnim.value : 1.0,
                    child: child,
                  ),
                  child: Container(
                    height: Get.height * 0.42,
                    width: Get.height * 0.42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isAnalyzing
                            ? MyColors.PastelRose
                            : MyColors.white,
                        width: 5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.PastelRose.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                      image: DecorationImage(
                        image: _image != null
                            ? FileImage(_image!) as ImageProvider
                            : AssetImage(MyImages.FrontImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: _isAnalyzing
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.45),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: MyColors.PastelRose,
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _statusText,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),

                const SizedBox(height: 24),

                // ── Action Buttons ────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionBtn(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: MyColors.PastelRose,
                      onTap: _isAnalyzing
                          ? null
                          : () => _pickImage(ImageSource.camera),
                    ),
                    _actionBtn(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: const Color(0xFFB39DDB),
                      onTap: _isAnalyzing
                          ? null
                          : () => _pickImage(ImageSource.gallery),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Analyze Button ────────────────
                if (_image != null && !_isAnalyzing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _analyzeImage,
                      icon: const Icon(Icons.analytics_rounded,
                          color: Colors.white),
                      label: const Text(
                        'Analyze Now',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.PastelRose,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: MyColors.PastelRose.withOpacity(0.5),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // ── Disclaimer ────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'For informational purposes only. Always consult a dermatologist for medical advice.',
                          style: TextStyle(
                              fontSize: 11, color: Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
