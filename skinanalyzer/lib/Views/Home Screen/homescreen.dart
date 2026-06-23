// -----------------------------------------------
// Project: Skin Health Analyzer
// File: homescreen.dart
// UPDATED: "Personalized AI Recommendations" section with
//          full popup cards for every n8n field
// -----------------------------------------------

// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use, no_leading_underscores_for_local_identifiers

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Models/scan_result.dart';
import '../../Services/supabase_service.dart';
import '../../Utils/values/color.dart';
import '../../Utils/Extension/Widget/widget.dart';
import '../Results Screen/results.dart';

class SkinHomeScreen extends StatefulWidget {
  const SkinHomeScreen({super.key});

  @override
  State<SkinHomeScreen> createState() => _SkinHomeScreenState();
}

class _SkinHomeScreenState extends State<SkinHomeScreen> {
  final _supabase = SupabaseService();

  Map<String, dynamic> _stats = {};
  List<ScanResult> _recentScans = [];
  bool _isLoading = true;

  // Static fallback tips
  final _staticTips = const [
    {
      'title': 'Morning Routine',
      'sub': 'Cleanse, tone, moisturise',
      'icon': Icons.wb_sunny_outlined,
      'color': Color(0xFFFFF3E0)
    },
    {
      'title': 'Sun Protection',
      'sub': 'SPF 30+ every day',
      'icon': Icons.wb_sunny_rounded,
      'color': Color(0xFFFFECB3)
    },
    {
      'title': 'Night Routine',
      'sub': 'Repair while you sleep',
      'icon': Icons.nightlight_round,
      'color': Color(0xFFEDE7F6)
    },
    {
      'title': 'Stay Hydrated',
      'sub': 'Drink 8 glasses daily',
      'icon': Icons.water_drop_outlined,
      'color': Color(0xFFE3F2FD)
    },
    {
      'title': 'Balanced Diet',
      'sub': 'Vitamins A, C & E help',
      'icon': Icons.eco_outlined,
      'color': Color(0xFFE8F5E9)
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    if (!_supabase.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final results = await Future.wait(
          [_supabase.getUserStats(), _supabase.getScanHistory(limit: 3)]);
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _recentScans = results[1] as List<ScanResult>;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String get _userName {
    final meta = _supabase.currentUser?.userMetadata;
    if (meta?['full_name'] != null &&
        (meta!['full_name'] as String).isNotEmpty) {
      return (meta['full_name'] as String).split(' ').first;
    }
    return _supabase.currentUser?.email?.split('@').first ?? 'there';
  }

  int get _totalScans => (_stats['totalScans'] as int?) ?? 0;
  double? get _avgConf => _stats['avgConfidence'] as double?;
  int get _skinScore =>
      _avgConf == null ? 0 : (100 - (_avgConf! * 60)).clamp(40, 100).toInt();
  int? get _skinAge {
    final age = _supabase.userAge;
    if (age <= 0) return null;
    if (_avgConf == null) return age;
    if (_avgConf! > 0.65) return age + 2;
    if (_avgConf! < 0.25) return (age - 1).clamp(1, 120);
    return age;
  }

  /// Latest scan that has a recommendation (skip undetected/special labels)
  N8nRecommendation? get _latestRec {
    const _skipLabels = {'Disease Undetected', 'Healthy Skin'};
    for (final s in _recentScans) {
      if (_skipLabels.contains(s.conditionName)) continue;
      if (s.parsedRecommendations != null &&
          !s.parsedRecommendations!.isEmpty) {
        return s.parsedRecommendations;
      }
    }
    return null;
  }

  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.LightLightLavender,
      appBar: AppBar(
        backgroundColor: MyColors.LightLightLavender,
        elevation: 0,
        title: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: MyColors.PastelRose),
            child: const Icon(Icons.face_retouching_natural,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 10),
          const Text('Skin Health AI',
              style: TextStyle(
                  color: MyColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ]),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: MyColors.PastelRose, strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh_rounded,
                  color: MyColors.grayscale50),
              onPressed: _loadData,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: MyColors.PastelRose,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              Center(
                child: Text('Welcome, ${_userName.capitalizeFirst}! 👋',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text('How is your skin today?',
                    style:
                        TextStyle(color: MyColors.grayscale40, fontSize: 15)),
              ),
              const SizedBox(height: 20),

              // Stats
              if (_supabase.isLoggedIn) ...[
                Row(children: [
                  Expanded(
                      child: _statCard(
                          icon: Icons.camera_alt_rounded,
                          value: '$_totalScans',
                          label: 'Total Scans',
                          color: MyColors.PastelRose)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _statCard(
                          icon: Icons.trending_up_rounded,
                          value: _avgConf != null
                              ? '${(_avgConf! * 100).toStringAsFixed(0)}%'
                              : '-',
                          label: 'Avg Confidence',
                          color: const Color(0xFF9C88C4))),
                ]),
                const SizedBox(height: 20),
              ],

              // Chart
              _buildChart(),
              const SizedBox(height: 20),

              // Skin Summary
              const Text('Your Skin Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildSkinSummary(),
              const SizedBox(height: 20),

              // Recent Scans
              if (_supabase.isLoggedIn && _recentScans.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Scans',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                        onPressed: () {},
                        child: const Text('View All',
                            style: TextStyle(color: MyColors.PastelRose))),
                  ],
                ),
                ..._recentScans.map(_recentScanTile),
                const SizedBox(height: 10),
              ],

              // ── Personalized AI Recommendations ────────────────
              _buildAiRecommendationsSection(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Personalized AI Recommendations Section ──────────────────────
  Widget _buildAiRecommendationsSection() {
    final rec = _latestRec;
    final condName =
        _recentScans.isNotEmpty ? _recentScans.first.conditionName : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            const Expanded(
              child: Text('Personalized AI Recommendations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            if (rec != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [MyColors.PastelRose, Color(0xFFDDB8C6)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome_rounded,
                        size: 11, color: Colors.white),
                    SizedBox(width: 3),
                    Text('AI',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),

        if (condName != null && rec != null) ...[
          const SizedBox(height: 4),
          Text('Based on: $condName',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
        const SizedBox(height: 12),

        if (rec == null) ...[
          // No recommendations yet
          _staticTipsRow(),
        ] else ...[
          // Horizontal scrollable recommendation cards
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (rec.urgencyNote != null)
                  _recCard(
                    title: 'Urgency Note',
                    content: rec.urgencyNote!,
                    icon: Icons.priority_high_rounded,
                    cardColor: const Color(0xFFFFF8E1),
                    iconColor: Colors.amber.shade700,
                    onTap: () => _showPopup(
                      title: '⚠️ Urgency Note',
                      icon: Icons.priority_high_rounded,
                      iconColor: Colors.amber.shade700,
                      bgColor: const Color(0xFFFFF8E1),
                      child: _textBlock(rec.urgencyNote!),
                    ),
                  ),
                if (rec.skincareDo.isNotEmpty)
                  _recCard(
                    title: 'Skincare Do\'s',
                    content: rec.skincareDo.take(2).join(' • '),
                    icon: Icons.check_circle_outline_rounded,
                    cardColor: const Color(0xFFE8F5E9),
                    iconColor: Colors.green.shade600,
                    onTap: () => _showPopup(
                      title: '✅ Skincare Do\'s',
                      icon: Icons.check_circle_outline_rounded,
                      iconColor: Colors.green.shade600,
                      bgColor: const Color(0xFFE8F5E9),
                      child: _bulletList(rec.skincareDo, Colors.green.shade600),
                    ),
                  ),
                if (rec.skincareAvoid.isNotEmpty)
                  _recCard(
                    title: 'Skincare Avoid',
                    content: rec.skincareAvoid.take(2).join(' • '),
                    icon: Icons.do_not_disturb_on_outlined,
                    cardColor: const Color(0xFFFFEBEE),
                    iconColor: Colors.red.shade400,
                    onTap: () => _showPopup(
                      title: '🚫 Skincare Avoid',
                      icon: Icons.do_not_disturb_on_outlined,
                      iconColor: Colors.red.shade400,
                      bgColor: const Color(0xFFFFEBEE),
                      child:
                          _bulletList(rec.skincareAvoid, Colors.red.shade400),
                    ),
                  ),
                if (rec.morningRoutine.isNotEmpty)
                  _recCard(
                    title: 'Morning Routine',
                    content: rec.morningRoutine.take(2).join(' → '),
                    icon: Icons.wb_sunny_outlined,
                    cardColor: const Color(0xFFFFF3E0),
                    iconColor: Colors.orange.shade600,
                    onTap: () => _showPopup(
                      title: '🌅 Morning Routine',
                      icon: Icons.wb_sunny_outlined,
                      iconColor: Colors.orange.shade600,
                      bgColor: const Color(0xFFFFF3E0),
                      child: _numberedList(
                          rec.morningRoutine, Colors.orange.shade600),
                    ),
                  ),
                if (rec.eveningRoutine.isNotEmpty)
                  _recCard(
                    title: 'Evening Routine',
                    content: rec.eveningRoutine.take(2).join(' → '),
                    icon: Icons.nightlight_round,
                    cardColor: const Color(0xFFEDE7F6),
                    iconColor: const Color(0xFF7B68EE),
                    onTap: () => _showPopup(
                      title: '🌙 Evening Routine',
                      icon: Icons.nightlight_round,
                      iconColor: const Color(0xFF7B68EE),
                      bgColor: const Color(0xFFEDE7F6),
                      child: _numberedList(
                          rec.eveningRoutine, const Color(0xFF7B68EE)),
                    ),
                  ),
                if (rec.avoidIngredients.isNotEmpty)
                  _recCard(
                    title: 'Avoid Ingredients',
                    content: rec.avoidIngredients.take(3).join(', '),
                    icon: Icons.science_outlined,
                    cardColor: const Color(0xFFFCE4EC),
                    iconColor: Colors.pink.shade400,
                    onTap: () => _showPopup(
                      title: '🧪 Avoid Ingredients',
                      icon: Icons.science_outlined,
                      iconColor: Colors.pink.shade400,
                      bgColor: const Color(0xFFFCE4EC),
                      child:
                          _chipList(rec.avoidIngredients, Colors.pink.shade400),
                    ),
                  ),
                if (rec.lifestyleTips.isNotEmpty)
                  _recCard(
                    title: 'Lifestyle Tips',
                    content: rec.lifestyleTips.take(2).join(' • '),
                    icon: Icons.self_improvement_outlined,
                    cardColor: const Color(0xFFE0F2F1),
                    iconColor: Colors.teal.shade600,
                    onTap: () => _showPopup(
                      title: '🌿 Lifestyle Tips',
                      icon: Icons.self_improvement_outlined,
                      iconColor: Colors.teal.shade600,
                      bgColor: const Color(0xFFE0F2F1),
                      child:
                          _bulletList(rec.lifestyleTips, Colors.teal.shade600),
                    ),
                  ),
                if (rec.warningSigns.isNotEmpty)
                  _recCard(
                    title: 'Warning Signs',
                    content: rec.warningSigns.take(2).join(' • '),
                    icon: Icons.warning_amber_rounded,
                    cardColor: const Color(0xFFFFF3E0),
                    iconColor: Colors.deepOrange.shade400,
                    onTap: () => _showPopup(
                      title: '⚠️ Warning Signs',
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.deepOrange.shade400,
                      bgColor: const Color(0xFFFFF3E0),
                      child: _bulletList(
                          rec.warningSigns, Colors.deepOrange.shade400),
                    ),
                  ),
                if (rec.otcProducts.isNotEmpty)
                  _recCard(
                    title: 'Recommended Products',
                    content:
                        rec.otcProducts.map((p) => p.name).take(2).join(' • '),
                    icon: Icons.local_pharmacy_outlined,
                    cardColor: const Color(0xFFF3E5F5),
                    iconColor: Colors.purple.shade400,
                    onTap: () => _showPopup(
                      title: '🛍️ Recommended Products',
                      icon: Icons.local_pharmacy_outlined,
                      iconColor: Colors.purple.shade400,
                      bgColor: const Color(0xFFF3E5F5),
                      child: _productList(rec.otcProducts),
                    ),
                  ),
                if (rec.disclaimer != null)
                  _recCard(
                    title: 'Disclaimer',
                    content: rec.disclaimer!,
                    icon: Icons.gavel_rounded,
                    cardColor: const Color(0xFFECEFF1),
                    iconColor: Colors.blueGrey.shade500,
                    onTap: () => _showPopup(
                      title: 'ℹ️ Disclaimer',
                      icon: Icons.gavel_rounded,
                      iconColor: Colors.blueGrey.shade500,
                      bgColor: const Color(0xFFECEFF1),
                      child: _textBlock(rec.disclaimer!),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap any card to see full details',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ],
    );
  }

  Widget _staticTipsRow() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _staticTips.length,
        itemBuilder: (_, i) {
          final tip = _staticTips[i];
          return _recCard(
            title: tip['title'] as String,
            content: tip['sub'] as String,
            icon: tip['icon'] as IconData,
            cardColor: tip['color'] as Color,
            iconColor: Colors.grey.shade600,
            onTap: null,
          );
        },
      ),
    );
  }

  // ── Recommendation Card (horizontal scroll item) ─────────────────
  Widget _recCard({
    required String title,
    required String content,
    required IconData icon,
    required Color cardColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: iconColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                if (onTap != null) ...[
                  const Spacer(),
                  Icon(Icons.open_in_new_rounded,
                      size: 12, color: iconColor.withOpacity(0.5)),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: iconColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Expanded(
              child: Text(content,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade700, height: 1.3),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  // ── Full-detail Popup ─────────────────────────────────────────────
  void _showPopup({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Widget child,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        builder: (_, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close_rounded,
                          color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Popup Content Widgets ─────────────────────────────────────────
  Widget _textBlock(String text) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14, height: 1.6)),
      );

  Widget _bulletList(List<String> items, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 5, right: 10),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(item,
                            style: const TextStyle(fontSize: 14, height: 1.4)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );

  Widget _numberedList(List<String> items, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${e.key + 1}',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color)),
                  ),
                ),
                Expanded(
                  child: Text(e.value,
                      style: const TextStyle(fontSize: 14, height: 1.4)),
                ),
              ],
            ),
          );
        }).toList(),
      );

  Widget _chipList(List<String> items, Color color) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map((item) => Chip(
                  label:
                      Text(item, style: TextStyle(fontSize: 12, color: color)),
                  backgroundColor: color.withOpacity(0.1),
                  side: BorderSide(color: color.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ))
            .toList(),
      );

  Widget _productList(List<OtcProduct> products) => Column(
        children: products
            .map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: MyColors.PastelRose.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_pharmacy_outlined,
                            color: MyColors.PastelRose, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(p.reason,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(p.category,
                            style: const TextStyle(fontSize: 10)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );

  // ── Chart ─────────────────────────────────────────────────────────
  Widget _buildChart() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.trending_up_rounded, color: Color(0xFFFFC1CC)),
              SizedBox(width: 8),
              Text('Skin Score Progress',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B4E57))),
            ]),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: _totalScans == 0
                  ? Center(
                      child: Text('Complete your first scan to see progress',
                          style: TextStyle(
                              color: Colors.grey.shade400, fontSize: 13),
                          textAlign: TextAlign.center))
                  : LineChart(LineChartData(
                      minY: 60,
                      maxY: 100,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                            color: Color(0xFFF0F0F0), strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (v, _) => Text('${v.toInt()}',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey)))),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  const labels = ['W1', 'W2', 'W3', 'W4', 'W5'];
                                  final i = v.toInt();
                                  if (i < 0 || i >= labels.length)
                                    return const SizedBox.shrink();
                                  return Text(labels[i],
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey));
                                })),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: const Color(0xFFFFC1CC),
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFFFFE4E8).withOpacity(0.5)),
                          spots: const [
                            FlSpot(0, 72),
                            FlSpot(1, 78),
                            FlSpot(2, 75),
                            FlSpot(3, 82),
                            FlSpot(4, 79),
                          ],
                        ),
                      ],
                    )),
            ),
          ],
        ),
      );

  // ── Skin Summary ──────────────────────────────────────────────────
  Widget _buildSkinSummary() {
    if (_isLoading) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
            color: const Color(0xFFFFE4E8),
            borderRadius: BorderRadius.circular(24)),
        child: const Center(
            child: CircularProgressIndicator(
                color: MyColors.PastelRose, strokeWidth: 2)),
      );
    }
    if (_totalScans == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFFFFE4E8),
            borderRadius: BorderRadius.circular(24)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.camera_alt_outlined,
              color: Colors.pink.shade300, size: 22),
          const SizedBox(width: 10),
          Text('Scan your skin to see your summary',
              style: TextStyle(
                  color: Colors.pink.shade400,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
        ]),
      );
    }
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFFFFE4E8),
              borderRadius: BorderRadius.circular(24)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              topPill(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFF8FA3),
                  number: '$_skinScore',
                  label: 'Skin Score'),
              topPill(
                  icon: Icons.calendar_today_rounded,
                  iconColor: const Color(0xFF4A90E2),
                  number: _skinAge != null ? '$_skinAge' : '--',
                  label: 'Skin Age'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: progressCard(
                    title: 'Avg Confidence',
                    value: _avgConf != null
                        ? (_avgConf! * 100).toInt().clamp(0, 100)
                        : 0)),
            const SizedBox(width: 10),
            Expanded(
                child: progressCard(
                    title: 'Total Scans',
                    value: (_totalScans * 5).clamp(0, 100))),
          ],
        ),
      ],
    );
  }

  // ── Stat Card ─────────────────────────────────────────────────────
  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ]),
        ]),
      );

  // ── Recent Scan Tile ──────────────────────────────────────────────
  Widget _recentScanTile(ScanResult result) {
    final urgencyColor = result.urgency == 'high'
        ? Colors.red.shade400
        : result.urgency == 'medium'
            ? Colors.orange.shade400
            : Colors.green.shade400;
    return GestureDetector(
      onTap: () => Get.to(() => ResultsScreen(result: result)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(children: [
          Container(
              width: 10,
              height: 10,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: urgencyColor)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(result.conditionName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis)),
          Text(DateFormat('MMM d').format(result.createdAt),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: MyColors.PastelRose.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Text('${(result.confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAD6579),
                    fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }
}
