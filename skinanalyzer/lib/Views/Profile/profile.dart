// -----------------------------------------------
// Project: Skin Health Analyzer
// File: profile.dart
// Description: User profile with account management
// -----------------------------------------------

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Services/supabase_service.dart';
import '../../Utils/values/color.dart';
import '../First Screen/get_started.dart';
import '../Log In/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = SupabaseService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!_supabase.isLoggedIn) {
      setState(() => _isLoading = false);
      return;
    }
    final stats = await _supabase.getUserStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  String get _displayName {
    final meta = _supabase.currentUser?.userMetadata;
    if (meta != null && meta['full_name'] != null) {
      return meta['full_name'].toString();
    }
    return _supabase.currentUser?.email?.split('@').first ?? 'Guest User';
  }

  String get _email => _supabase.currentUser?.email ?? '';

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign Out',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    await _supabase.signOut();
    Get.offAll(() => const SkinDiscoverScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.LightLightLavender,
      body: CustomScrollView(
        slivers: [
          // ── Curved Header ─────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [MyColors.PastelRose, Color(0xFFDDB8C6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24,
                right: 24,
                bottom: 32,
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _supabase.isLoggedIn
                            ? _displayName.isNotEmpty
                                ? _displayName[0].toUpperCase()
                                : 'U'
                            : '?',
                        style: const TextStyle(
                            fontSize: 36,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _supabase.isLoggedIn ? _displayName : 'Guest User',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  if (_supabase.isLoggedIn && _email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _email,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.85)),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Stats Row ────────────────────
                  if (_supabase.isLoggedIn && !_isLoading)
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            '${_stats['totalScans'] ?? 0}',
                            'Total Scans',
                            Icons.camera_alt_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(
                            _stats['mostCommon'] != null &&
                                    _stats['mostCommon'] != '-'
                                ? (_stats['mostCommon'] as String)
                                    .split(' ')
                                    .first
                                : '-',
                            'Most Common',
                            Icons.analytics_rounded,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // ── Settings Section ─────────────
                  _sectionHeader('Account'),
                  _tile(
                    Icons.person_outline_rounded,
                    'Edit Profile',
                    onTap: () {},
                  ),
                  _tile(
                    Icons.notifications_outlined,
                    'Notifications',
                    onTap: () {},
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeColor: MyColors.PastelRose,
                    ),
                  ),
                  _tile(
                    Icons.lock_outline_rounded,
                    'Change Password',
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),
                  _sectionHeader('App'),
                  _tile(
                    Icons.info_outline_rounded,
                    'About',
                    subtitle: 'Version 2.0.0',
                    onTap: () {},
                  ),
                  _tile(
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    onTap: () {},
                  ),
                  _tile(
                    Icons.description_outlined,
                    'Terms of Service',
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),

                  // ── Auth Buttons ──────────────────
                  if (!_supabase.isLoggedIn) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.to(() => const LoginScreen()),
                        icon: const Icon(Icons.login_rounded,
                            color: Colors.white),
                        label: const Text('Sign In',
                            style: TextStyle(color: Colors.white, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.PastelRose,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ] else ...[
                    _tile(
                      Icons.logout_rounded,
                      'Sign Out',
                      textColor: Colors.red.shade400,
                      iconColor: Colors.red.shade400,
                      onTap: _signOut,
                    ),
                  ],

                  const SizedBox(height: 30),

                  // ── Disclaimer ────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.medical_information_outlined,
                            color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This app is for educational purposes only. Results are not a substitute for professional medical diagnosis.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade800,
                                height: 1.5),
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
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon) => Container(
        padding: const EdgeInsets.all(14),
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
        child: Column(
          children: [
            Icon(icon, color: MyColors.PastelRose, size: 26),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      );

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.grey.shade500),
          ),
        ),
      );

  Widget _tile(
    IconData icon,
    String title, {
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
    Color? iconColor,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: ListTile(
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? MyColors.PastelRose).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: iconColor ?? MyColors.PastelRose, size: 18),
          ),
          title: Text(
            title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor ?? MyColors.black),
          ),
          subtitle: subtitle != null
              ? Text(subtitle,
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade400))
              : null,
          trailing: trailing ??
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey.shade400, size: 18),
          onTap: onTap,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      );
}
