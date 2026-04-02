// -----------------------------------------------
// Project: Skin Health Analyzer
// File: results.dart
// Description: Detailed scan results with confidence bars
// -----------------------------------------------

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Models/scan_result.dart';
import '../../Utils/values/color.dart';

class ResultsScreen extends StatelessWidget {
  final ScanResult result;
  const ResultsScreen({super.key, required this.result});

  Color get _urgencyColor {
    switch (result.urgency) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.orange.shade400;
      default:
        return Colors.green.shade400;
    }
  }

  IconData get _urgencyIcon {
    switch (result.urgency) {
      case 'high':
        return Icons.warning_rounded;
      case 'medium':
        return Icons.info_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String get _urgencyLabel {
    switch (result.urgency) {
      case 'high':
        return 'Seek Medical Attention';
      case 'medium':
        return 'Monitor & Consult';
      default:
        return 'Low Risk — Self-Care';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.LightLightLavender,
      body: CustomScrollView(
        slivers: [
          // ── App Bar with image ──────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: MyColors.PastelRose,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {
                  Get.snackbar('Share', 'Sharing result...',
                      backgroundColor: MyColors.PastelRose,
                      colorText: Colors.white);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Scan Result',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  result.imagePath.isNotEmpty && File(result.imagePath).existsSync()
                      ? Image.file(
                          File(result.imagePath),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: MyColors.WhiteRose,
                          child: const Icon(Icons.image_not_supported_outlined,
                              size: 60, color: Colors.white60),
                        ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Urgency Banner ───────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _urgencyColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: _urgencyColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(_urgencyIcon, color: _urgencyColor),
                        const SizedBox(width: 10),
                        Text(
                          _urgencyLabel,
                          style: TextStyle(
                              color: _urgencyColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Condition Name ───────────
                  Text(
                    result.conditionName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: MyColors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM d, yyyy • h:mm a')
                        .format(result.createdAt),
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500),
                  ),

                  const SizedBox(height: 16),

                  // ── Confidence Score ─────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Confidence Score',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: MyColors.PastelRose.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${(result.confidence * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                    color: Color(0xFFAD6579),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: result.confidence,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                MyColors.PastelRose),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          result.confidence > 0.7
                              ? 'High confidence — reliable result'
                              : result.confidence > 0.4
                                  ? 'Moderate confidence — consider retaking'
                                  : 'Low confidence — please retake with better lighting',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Description ──────────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: MyColors.PastelRose, size: 20),
                            SizedBox(width: 8),
                            Text('About This Condition',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          result.description,
                          style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Top Predictions ──────────
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bar_chart_rounded,
                                color: MyColors.PastelRose, size: 20),
                            SizedBox(width: 8),
                            Text('All Predictions',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ...result.topPredictions.asMap().entries.map(
                              (e) => _predictionBar(
                                  e.key + 1, e.value.label, e.value.confidence,
                                  isTop: e.key == 0),
                            ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Medical Disclaimer ───────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.medical_services_outlined,
                                color: Colors.blue.shade600, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Medical Disclaimer',
                              style: TextStyle(
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This AI analysis is for educational purposes only and does not constitute a medical diagnosis. '
                          'Please consult a qualified dermatologist for professional evaluation and treatment.',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Action Buttons ───────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Scan Again'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: MyColors.PastelRose,
                            side: const BorderSide(
                                color: MyColors.PastelRose, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Get.offAllNamed('/'),
                          icon: const Icon(Icons.home_rounded,
                              color: Colors.white),
                          label: const Text('Dashboard',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColors.PastelRose,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _predictionBar(
      int rank, String label, double confidence, {bool isTop = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isTop
                      ? MyColors.PastelRose
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: isTop ? Colors.white : Colors.grey.shade600,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isTop ? FontWeight.w600 : FontWeight.normal,
                    color: isTop ? MyColors.black : Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: isTop
                      ? const Color(0xFFAD6579)
                      : Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 6,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isTop ? MyColors.PastelRose : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
