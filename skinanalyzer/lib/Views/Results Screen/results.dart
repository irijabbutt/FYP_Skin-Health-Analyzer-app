// -----------------------------------------------
// Project: Skin Health Analyzer
// File: results.dart
// UPDATED: Added Image.network fallback + synchronized special class routing
// -----------------------------------------------

// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Models/scan_result.dart';
import '../../Utils/app_config.dart';
import '../../Utils/values/color.dart';

class ResultsScreen extends StatelessWidget {
  final ScanResult result;
  const ResultsScreen({super.key, required this.result});

  Color get _urgencyColor {
    if (result.conditionName == AppConfig.labelDiseaseUndetected) {
      return Colors.grey.shade500;
    }
    switch (result.urgency) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.orange.shade400;
      case 'none':
        return Colors.green.shade500;
      default:
        return Colors.green.shade400;
    }
  }

  IconData get _urgencyIcon {
    if (result.conditionName == AppConfig.labelDiseaseUndetected) {
      return Icons.search_off_rounded;
    }
    switch (result.urgency) {
      case 'high':
        return Icons.warning_rounded;
      case 'medium':
        return Icons.info_rounded;
      case 'none':
        return Icons.check_circle_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String get _urgencyLabel {
    if (result.conditionName == AppConfig.labelDiseaseUndetected) {
      return 'No Disease Detected';
    }
    switch (result.urgency) {
      case 'high':
        return 'Seek Medical Attention';
      case 'medium':
        return 'Monitor & Consult';
      case 'none':
        return 'Healthy — No Issue';
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
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: MyColors.PastelRose,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () => Get.snackbar('Share', 'Sharing result...',
                    backgroundColor: MyColors.PastelRose, colorText: Colors.white),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Scan Result',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Three-tier robust verification loop resolving the visibility fallback bug
                  result.imagePath.isNotEmpty && File(result.imagePath).existsSync()
                      ? Image.file(File(result.imagePath), fit: BoxFit.cover)
                      : (result.imageUrl != null && result.imageUrl!.isNotEmpty)
                          ? Image.network(
                              result.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: MyColors.WhiteRose,
                                child: const Icon(Icons.image_not_supported_outlined, size: 60, color: Colors.white60),
                              ),
                            )
                          : Container(
                              color: MyColors.WhiteRose,
                              child: const Icon(Icons.image_not_supported_outlined, size: 60, color: Colors.white60)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _urgencyColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _urgencyColor.withOpacity(0.4), width: 1.5),
                    ),
                    child: Row(children: [
                      Icon(_urgencyIcon, color: _urgencyColor),
                      const SizedBox(width: 10),
                      Text(_urgencyLabel,
                          style: TextStyle(color: _urgencyColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text(result.conditionName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: MyColors.black)),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM d, yyyy • h:mm a').format(result.createdAt),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  _card(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Confidence Score', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: MyColors.PastelRose.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${(result.confidence * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(color: Color(0xFFAD6579), fontWeight: FontWeight.bold, fontSize: 16),
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
                          valueColor: const AlwaysStoppedAnimation<Color>(MyColors.PastelRose),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.confidence > 0.7
                            ? 'High confidence — reliable result'
                            : result.confidence > 0.4
                                ? 'Moderate confidence — consider retaking'
                                : 'Low confidence — please retake with better lighting',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  )),
                  const SizedBox(height: 14),
                  if (result.isSpecialClass)
                    _card(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Icon(
                          result.conditionName == AppConfig.labelDiseaseUndetected
                              ? Icons.search_off_rounded
                              : Icons.check_circle_outline_rounded,
                          color: result.conditionName == AppConfig.labelDiseaseUndetected
                              ? Colors.grey.shade400
                              : Colors.green.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            result.conditionName == AppConfig.labelDiseaseUndetected
                                ? 'No recognisable skin condition was detected. Try retaking the photo in natural light, closer to the affected area.'
                                : 'Your skin appears healthy! No specific recommendations needed. Keep up your current skincare routine.',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
                          ),
                        ),
                      ]),
                    ))
                  else
                    _buildRecommendationsCard(result.parsedRecommendations),
                  const SizedBox(height: 14),
                  _card(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.info_outline_rounded, color: MyColors.PastelRose, size: 20),
                        SizedBox(width: 8),
                        Text('About This Condition', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ]),
                      const SizedBox(height: 10),
                      Text(result.description,
                          style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade700)),
                    ],
                  )),
                  const SizedBox(height: 14),
                  if (result.topPredictions.isNotEmpty && result.conditionName != AppConfig.labelDiseaseUndetected)
                    _card(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.bar_chart_rounded, color: MyColors.PastelRose, size: 20),
                          SizedBox(width: 8),
                          Text('All Predictions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        ]),
                        const SizedBox(height: 14),
                        ...result.topPredictions.asMap().entries.map(
                              (e) => _predictionBar(e.key + 1, e.value.label, e.value.confidence, isTop: e.key == 0),
                            ),
                      ],
                    )),
                  const SizedBox(height: 14),
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
                        Row(children: [
                          Icon(Icons.medical_services_outlined, color: Colors.blue.shade600, size: 18),
                          const SizedBox(width: 8),
                          Text('Medical Disclaimer',
                              style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 13)),
                        ]),
                        const SizedBox(height: 8),
                        Text(
                          'This AI analysis is for educational purposes only and does not constitute a medical diagnosis. Please consult a qualified dermatologist for professional evaluation and treatment.',
                          style: TextStyle(fontSize: 12, color: Colors.blue.shade700, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Scan Again'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MyColors.PastelRose,
                          side: const BorderSide(color: MyColors.PastelRose, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.offAllNamed('/'),
                        icon: const Icon(Icons.home_rounded, color: Colors.white),
                        label: const Text('Dashboard', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.PastelRose,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(N8nRecommendation? rec) {
    if (rec == null) {
      return _card(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(Icons.cloud_off_rounded, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'AI recommendations could not be loaded. Check your connection and try scanning again.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
          ),
        ]),
      ));
    }

    if (rec.isEmpty) {
      return _card(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Icon(Icons.info_outline_rounded, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No specific recommendations were returned for this condition.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
          ),
        ]),
      ));
    }

    return _card(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: MyColors.PastelRose.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: MyColors.PastelRose, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Analysis & Guidance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Powered by Gemini via n8n', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ]),
        ]),
        const SizedBox(height: 16),
        if (rec.urgencyNote != null)
          _recSection(
            icon: Icons.priority_high_rounded,
            iconColor: Colors.amber.shade700,
            title: 'Urgency Note',
            bgColor: const Color(0xFFFFF8E1),
            child: Text(rec.urgencyNote!, style: const TextStyle(fontSize: 13, height: 1.5)),
          ),
        if (rec.skincareDo.isNotEmpty)
          _recSection(
            icon: Icons.check_circle_outline_rounded,
            iconColor: Colors.green.shade600,
            title: 'Skincare Do\'s',
            bgColor: const Color(0xFFE8F5E9),
            child: _recBullets(rec.skincareDo, Colors.green.shade600),
          ),
        if (rec.skincareAvoid.isNotEmpty)
          _recSection(
            icon: Icons.do_not_disturb_on_outlined,
            iconColor: Colors.red.shade400,
            title: 'Skincare Avoid',
            bgColor: const Color(0xFFFFEBEE),
            child: _recBullets(rec.skincareAvoid, Colors.red.shade400),
          ),
        if (rec.morningRoutine.isNotEmpty)
          _recSection(
            icon: Icons.wb_sunny_outlined,
            iconColor: Colors.orange.shade600,
            title: 'Morning Routine',
            bgColor: const Color(0xFFFFF3E0),
            child: _recNumbered(rec.morningRoutine, Colors.orange.shade600),
          ),
        if (rec.eveningRoutine.isNotEmpty)
          _recSection(
            icon: Icons.nightlight_round,
            iconColor: const Color(0xFF7B68EE),
            title: 'Evening Routine',
            bgColor: const Color(0xFFEDE7F6),
            child: _recNumbered(rec.eveningRoutine, const Color(0xFF7B68EE)),
          ),
        if (rec.avoidIngredients.isNotEmpty)
          _recSection(
            icon: Icons.science_outlined,
            iconColor: Colors.pink.shade400,
            title: 'Avoid Ingredients',
            bgColor: const Color(0xFFFCE4EC),
            child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: rec.avoidIngredients
                    .map((i) => Chip(
                          label: Text(i, style: TextStyle(fontSize: 11, color: Colors.pink.shade700)),
                          backgroundColor: Colors.pink.shade50,
                          padding: EdgeInsets.zero,
                        ))
                    .toList()),
          ),
        if (rec.lifestyleTips.isNotEmpty)
          _recSection(
            icon: Icons.self_improvement_outlined,
            iconColor: Colors.teal.shade600,
            title: 'Lifestyle Tips',
            bgColor: const Color(0xFFE0F2F1),
            child: _recBullets(rec.lifestyleTips, Colors.teal.shade600),
          ),
        if (rec.warningSigns.isNotEmpty)
          _recSection(
            icon: Icons.warning_amber_rounded,
            iconColor: Colors.deepOrange.shade400,
            title: 'Warning Signs',
            bgColor: const Color(0xFFFFF3E0),
            child: _recBullets(rec.warningSigns, Colors.deepOrange.shade400),
          ),
        if (rec.otcProducts.isNotEmpty)
          _recSection(
            icon: Icons.local_pharmacy_outlined,
            iconColor: Colors.purple.shade400,
            title: 'Recommended Products',
            bgColor: const Color(0xFFF3E5F5),
            child: Column(
                children: rec.otcProducts
                    .map((p) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(children: [
                            const Icon(Icons.local_pharmacy_outlined, color: MyColors.PastelRose, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(p.reason, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                            ])),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                              child: Text(p.category, style: const TextStyle(fontSize: 10)),
                            ),
                          ]),
                        ))
                    .toList()),
          ),
        if (rec.disclaimer != null) ...[
          const SizedBox(height: 12),
          Text(rec.disclaimer!,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic, height: 1.5)),
        ],
      ],
    ));
  }

  Widget _recSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color bgColor,
    required Widget child,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 7),
            Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: iconColor)),
          ]),
          const SizedBox(height: 8),
          child,
        ]),
      );

  Widget _recBullets(List<String> items, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 5, right: 8),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 13, height: 1.4))),
                  ]),
                ))
            .toList(),
      );

  Widget _recNumbered(List<String> items, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .asMap()
            .entries
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                      child: Center(
                          child: Text('${e.key + 1}',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color))),
                    ),
                    Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13, height: 1.4))),
                  ]),
                ))
            .toList(),
      );

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: child,
      );

  Widget _predictionBar(int rank, String label, double confidence, {bool isTop = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 22,
              height: 22,
              decoration:
                  BoxDecoration(color: isTop ? MyColors.PastelRose : Colors.grey.shade300, shape: BoxShape.circle),
              child: Center(
                  child: Text('$rank',
                      style: TextStyle(
                          color: isTop ? Colors.white : Colors.grey.shade600,
                          fontSize: 11,
                          fontWeight: FontWeight.bold))),
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: isTop ? FontWeight.w600 : FontWeight.normal,
                        color: isTop ? MyColors.black : Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis)),
            Text('${(confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                    fontSize: 12,
                    color: isTop ? const Color(0xFFAD6579) : Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: confidence,
                minHeight: 6,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(isTop ? MyColors.PastelRose : Colors.grey.shade300),
              ),
            ),
          ),
        ]),
      );
}