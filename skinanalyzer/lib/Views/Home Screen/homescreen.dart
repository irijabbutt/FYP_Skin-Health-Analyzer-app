/*
    ---------------------------------------
    Project: Skin Analyzer
    Date: Jan 08, 2026
    Developer:  Rijab Butt
    ---------------------------------------
    Description: Home Screen
*/
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:skinanalyzer/Utils/values/color.dart';

import '../../Utils/Extension/Widget/widget.dart';
import '../../Utils/values/my_images.dart';

class SkinHomeScreen extends StatefulWidget {
  SkinHomeScreen({super.key});

  @override
  State<SkinHomeScreen> createState() => _SkinHomeScreenState();
}

class _SkinHomeScreenState extends State<SkinHomeScreen> {
  List<String> Images = <String>[
    MyImages.SkinCare,
    MyImages.SkinCare1,
    MyImages.SkinCare,
    MyImages.SkinCare1,
    MyImages.SkinCare,
    MyImages.SkinCare1,
  ];
  List<String> tittles = <String>[
    "Morning Routine",
    "Night Routine",
    "Anti-Aging Tips",
    "Morning Routine",
    "Night Routine",
    "Anti-Aging Tips",
  ];
  List<String> Subtittles = <String>[
    "Start your day fresh",
    "Reduce wrinkles",
    "Start your day fresh",
    "Reduce wrinkles",
    "Start your day fresh",
    "Reduce wrinkles",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.LightLightLavender,
      appBar: AppBar(
        backgroundColor: MyColors.LightLightLavender,
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: MyColors.PastelRose,
              child: Icon(Icons.face_retouching_natural, color: MyColors.white),
            ),
            SizedBox(width: 10),
            Text(
              "Skin Health Analyzer",
              style: TextStyle(
                color: MyColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: MyColors.grayscale50),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Welcome Section
            Center(
              child: Text(
                "Welcome, Sarah",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 6),
            Center(
              child: Text(
                "How is your skin today?",
                style: TextStyle(color: MyColors.grayscale40, fontSize: 16),
              ),
            ),

            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MyColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Row(
                    children: const [
                      Icon(Icons.trending_up, color: Color(0xFFFFC1CC)),
                      SizedBox(width: 8),
                      Text(
                        "Skin Score Progress",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B4E57),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Line Chart
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        minY: 72,
                        maxY: 82,
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(show: false),

                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: Color(0xFFFFC1CC),
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Color(0xFFFFE4E8).withOpacity(0.6),
                            ),
                            spots: const [
                              FlSpot(0, 79),
                              FlSpot(1, 79),
                              FlSpot(2, 74),
                              FlSpot(3, 74),
                              FlSpot(4, 78),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            /// Skin Summary
            Text(
              "Your Skin Summary",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  topPill(
                    icon: Icons.star,
                    iconColor: const Color(0xFFFF8FA3),
                    number: "90",
                    label: "Skin Score",
                  ),
                  topPill(
                    icon: Icons.calendar_today,
                    iconColor: const Color(0xFF4A90E2),
                    number: "22",
                    label: "Skin Age",
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: progressCard(title: "Hydration", value: 85)),
                SizedBox(width: 10),
                Expanded(child: progressCard(title: "Texture", value: 88)),
              ],
            ),

            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "View Full Report →",
                  style: TextStyle(fontSize: 16, color: MyColors.black),
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// Skin Care Tips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Skin Care Tips",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: Images.length,
                itemBuilder: (BuildContext context, int index) {
                  return tipsCard(
                    tittles[index],
                    Subtittles[index],
                    Images[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
