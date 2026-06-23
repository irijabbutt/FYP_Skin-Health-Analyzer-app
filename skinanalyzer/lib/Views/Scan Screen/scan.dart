// -----------------------------------------------
// Project: Skin Health Analyzer
// File: scan.dart
// UPDATED: Synchronized special class parsing criteria
//          + Permanent local-only image persistence implementation
// -----------------------------------------------

// ignore_for_file: deprecated_member_use, avoid_print

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
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

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
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (picked != null) setState(() => _image = File(picked.path));
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;
    setState(() {
      _isAnalyzing = true;
      _statusText = 'Analyzing skin condition...';
    });

    try {
      final topPredictions = await _tflite.predict(_image!);
      if (topPredictions.isEmpty) throw Exception('No results from model');

      final top = topPredictions.first;
      final conditionName = top.label;
      final confidence = top.confidence;

      final description = conditionName == AppConfig.labelDiseaseUndetected
          ? 'The AI model could not identify a recognisable skin condition with '
              'sufficient confidence. This may be due to image quality, lighting, '
              'or the condition being outside the model\'s training classes. '
              'Try retaking the photo in natural light, closer to the affected area.'
          : (AppConfig.conditionDescriptions[conditionName] ??
              'No description available.');

      final urgency = conditionName == AppConfig.labelDiseaseUndetected
          ? 'none'
          : (conditionName.contains('Malignant') ? 'high' : 'low');

      setState(() => _statusText = 'Getting AI recommendations...');

      N8nRecommendation? recs;
      if (!_isSpecialClass(conditionName)) {
        recs = await _n8n.getRecommendations(
          condition: conditionName,
          confidence: confidence,
          description: description,
          urgency: urgency,
          allPredictions: topPredictions,
        );
      }

      setState(() => _statusText = 'Saving to history...');

      // PERSIST IMAGE LOCALLY: Save to permanent app documents directory 
      // instead of volatile device cache folder so it never gets deleted.
      String savedLocalPath = _image!.path;
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(_image!.path); // image_picker names are already unique strings
        final permanentImage = await _image!.copy('${appDir.path}/$fileName');
        savedLocalPath = permanentImage.path;
      } catch (e) {
        print('[Scan] Local image persistence fallback failed: $e');
      }

      final scanResult = ScanResult(
        userId: _supabase.userId,
        imagePath: savedLocalPath, // Pass the safe permanent local path here
        conditionName: conditionName,
        urgency: urgency,
        confidence: confidence,
        imageUrl: '', 
        description: description,
        topPredictions: topPredictions,
        recommendations: recs?.toJson(),
        parsedRecommendations: recs,
        createdAt: DateTime.now(),
      );

      if (_supabase.isLoggedIn) {
        await _supabase.saveScanResult(scanResult);
      }

      _n8n.logScanEvent(scanResult);

      setState(() => _isAnalyzing = false);
      Get.to(() => ResultsScreen(result: scanResult));
    } catch (e) {
      setState(() => _isAnalyzing = false);
      print('[Scan] Error: $e');
      Get.snackbar(
        'Analysis Failed',
        'Something went wrong. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Unified utility mapping matching scan_result properties perfectly
  bool _isSpecialClass(String name) =>
      name == AppConfig.labelDiseaseUndetected ||
      name == 'Normal Skin' ||
      name == 'Healthy Skin' ||
      name == 'No Skin Issue Detected' ||
      name == 'Ink / Henna on Skin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.LightLightLavender,
      appBar: AppBar(
        title: const Text('New Analysis',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isAnalyzing ? null : () => _pickImage(ImageSource.gallery),
                  child: ScaleTransition(
                    scale: _isAnalyzing ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: MyColors.PastelRose.withOpacity(0.3), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: MyColors.PastelRose.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.file(_image!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(MyImages.Picture, height: 80, color: MyColors.PastelRose),
                                const SizedBox(height: 16),
                                const Text('Tap to Upload Image',
                                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_isAnalyzing) ...[
                  const CircularProgressIndicator(color: MyColors.PastelRose),
                  const SizedBox(height: 16),
                  Text(_statusText, style: const TextStyle(fontWeight: FontWeight.w600, color: MyColors.black)),
                  const SizedBox(height: 8),
                  Text('Analyzing with AI — this may take a moment',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _actionBtn(
                        icon: Icons.camera_alt_rounded,
                        label: 'Camera',
                        color: MyColors.PastelRose,
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                      _actionBtn(
                        icon: Icons.photo_library_rounded,
                        label: 'Gallery',
                        color: const Color(0xFF658BAD),
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _image == null ? null : _analyzeImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.PastelRose,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Start Analysis',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade800, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'For informational purposes only. Always consult a dermatologist for medical advice.',
                          style: TextStyle(fontSize: 11, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
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
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}