// -----------------------------------------------
// Project: Skin Health Analyzer
// File: navigation.dart
// Description: Bottom navigation bar
// -----------------------------------------------

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../Utils/values/color.dart';
import '../Home Screen/homescreen.dart';
import '../Scan Screen/scan.dart';
import '../History Screen/history.dart';
import '../Profile/profile.dart';

class SkinNavigationBar extends StatefulWidget {
  const SkinNavigationBar({super.key});

  @override
  State<SkinNavigationBar> createState() => _SkinNavigationBarState();
}

class _SkinNavigationBarState extends State<SkinNavigationBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    SkinHomeScreen(),
    ScanScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          indicatorColor: MyColors.PastelRose.withOpacity(0.2),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFFAD6579)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_alt_outlined),
              selectedIcon:
                  Icon(Icons.camera_alt_rounded, color: Color(0xFFAD6579)),
              label: 'Scan',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon:
                  Icon(Icons.history_rounded, color: Color(0xFFAD6579)),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon:
                  Icon(Icons.person_rounded, color: Color(0xFFAD6579)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
