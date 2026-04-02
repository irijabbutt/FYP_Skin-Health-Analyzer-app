// -----------------------------------------------
// Project: Skin Health Analyzer
// File: homescreen.dart
// Description: Dashboard with live stats from Supabase
// -----------------------------------------------

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Models/scan_result.dart';
import '../../Services/supabase_service.dart';
import '../../Utils/values/color.dart';
import '../../Utils/values/my_images.dart';
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

  final List<String> _tipTitles = [
    'Morning Routine', 'Sun Protection', 'Night Routine',
    'Stay Hydrated', 'Balanced Diet', 'Anti-Aging Tips',
  ];
  final List<String> _tipSubtitles = [
    'Start your day fresh', 'Protect from UV rays',
    'Restore while you sleep', 'Drink 8 glasses daily',
    'Vitamins A, C & E help', 'Retinol & antioxidants',
  ];
  final List<String> _tipImages = [
    MyImages.SkinCare, MyImages.SkinCare1, MyImages.SkinCare,
    MyImages.SkinCare1, MyImages.SkinCare, MyImages.SkinCare1,
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!_supabase.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final stats = await _supabase.getUserStats();
      final recents = await _supabase.getScanHistory(limit: 3);
      setState(() {
        _stats = stats;
        _recentScans = recents;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  String get _userName {
    final email = _supabase.currentUser?.email ?? '';
    final meta = _supabase.currentUser?.userMetadata;
    if (meta != null && meta['full_name'] != null) {
      return meta['full_name'].toString().split(' ').first;
    }
    return email.isNotEmpty ? email.split('@').first : 'there';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.LightLightLavender,
      appBar: AppBar(
        backgroundColor: MyColors.LightLightLavender,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: MyColors.PastelRose,
              ),
              child: const Icon(Icons.face_retouching_natural,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'Skin Health AI',
              style: TextStyle(
                  color: MyColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ],
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: MyColors.PastelRose, strokeWidth: 2),
              ),
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
              // ── Welcome ────────────────────────────
              Center(
                child: Text(
                  'Welcome, ${_userName.capitalizeFirst}! 👋',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'How is your skin today?',
                  style: TextStyle(
                      color: MyColors.grayscale40, fontSize: 15),
                ),
              ),
              const SizedBox(height: 20),

              // ── Stats Row ──────────────────────────
              if (_supabase.isLoggedIn) ...[
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        icon: Icons.camera_alt_rounded,
                        value: '${_stats['totalScans'] ?? 0}',
                        label: 'Total Scans',
                        color: MyColors.PastelRose,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statCard(
                        icon: Icons.trending_up_rounded,
                        value: _stats['avgConfidence'] != null
                            ? '${((_stats['avgConfidence'] as double) * 100).toStringAsFixed(0)}%'
                            : '-',
                        label: 'Avg Confidence',
                        color: const Color(0xFF9C88C4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // ── Skin Score Chart ───────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MyColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up_rounded,
                            color: Color(0xFFFFC1CC)),
                        SizedBox(width: 8),
                        Text(
                          'Skin Score Progress',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B4E57)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: LineChart(
                        LineChartData(
                          minY: 60,
                          maxY: 100,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => const FlLine(
                              color: Color(0xFFF0F0F0),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (v, _) => Text(
                                  '${v.toInt()}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (v, _) {
                                  const labels = [
                                    'W1', 'W2', 'W3', 'W4', 'W5'
                                  ];
                                  final idx = v.toInt();
                                  if (idx < 0 || idx >= labels.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(labels[idx],
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.grey));
                                },
                              ),
                            ),
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
                                color: const Color(0xFFFFE4E8)
                                    .withOpacity(0.5),
                              ),
                              spots: const [
                                FlSpot(0, 72),
                                FlSpot(1, 78),
                                FlSpot(2, 75),
                                FlSpot(3, 82),
                                FlSpot(4, 79),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Skin Summary ───────────────────────
              const Text(
                'Your Skin Summary',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    topPill(
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFFF8FA3),
                      number: '90',
                      label: 'Skin Score',
                    ),
                    topPill(
                      icon: Icons.calendar_today_rounded,
                      iconColor: const Color(0xFF4A90E2),
                      number: '22',
                      label: 'Skin Age',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: progressCard(title: 'Hydration', value: 85)),
                  const SizedBox(width: 10),
                  Expanded(child: progressCard(title: 'Texture', value: 88)),
                ],
              ),

              const SizedBox(height: 20),

              // ── Recent Scans ───────────────────────
              if (_supabase.isLoggedIn && _recentScans.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Scans',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('View All',
                          style: TextStyle(color: MyColors.PastelRose)),
                    ),
                  ],
                ),
                ..._recentScans.map((r) => _recentScanTile(r)),
                const SizedBox(height: 10),
              ],

              // ── Skin Care Tips ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Skin Care Tips',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ],
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: _tipTitles.length,
                  itemBuilder: (_, index) => tipsCard(
                    _tipTitles[index],
                    _tipSubtitles[index],
                    _tipImages[index],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }

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
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: urgencyColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                result.conditionName,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              DateFormat('MMM d').format(result.createdAt),
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade400),
            ),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: MyColors.PastelRose.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${(result.confidence * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAD6579),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
