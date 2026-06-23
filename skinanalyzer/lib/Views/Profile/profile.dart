// -----------------------------------------------
// Project: Skin Health Analyzer
// File: profile.dart
// FIX: Shows age from metadata; real stats; Edit Profile dialog
// -----------------------------------------------

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
    setState(() => _isLoading = true);
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

  String get _displayName => _supabase.displayName;
  String get _email => _supabase.currentUser?.email ?? '';
  int get _age => _supabase.userAge;

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    await _supabase.signOut();
    Get.offAll(() => const SkinDiscoverScreen());
  }

  void _showEditDialog() {
    final nameCtrl = TextEditingController(text: _displayName);
    final ageCtrl = TextEditingController(text: _age > 0 ? '$_age' : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline, color: MyColors.PastelRose),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ageCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
              decoration: InputDecoration(
                labelText: 'Age',
                prefixIcon: const Icon(Icons.cake_outlined, color: MyColors.PastelRose),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _supabase.updateProfile(
                fullName: nameCtrl.text.trim(),
                age: int.tryParse(ageCtrl.text.trim()),
              );
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: MyColors.PastelRose),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.LightLightLavender,
      body: CustomScrollView(
        slivers: [
          // Header
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
                left: 24, right: 24, bottom: 32,
              ),
              child: Column(
                children: [
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _supabase.isLoggedIn && _displayName.isNotEmpty
                            ? _displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _supabase.isLoggedIn ? _displayName : 'Guest User',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (_supabase.isLoggedIn && _email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(_email,
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85))),
                  ],
                  // Age pill
                  if (_supabase.isLoggedIn && _age > 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cake_outlined, color: Colors.white, size: 14),
                          const SizedBox(width: 5),
                          Text('Age $_age',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
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
                  // Stats
                  if (_supabase.isLoggedIn && !_isLoading)
                    Row(
                      children: [
                        Expanded(child: _statCard('${_stats['totalScans'] ?? 0}', 'Total Scans', Icons.camera_alt_rounded)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _statCard(
                            _stats['avgConfidence'] != null
                                ? '${((_stats['avgConfidence'] as double) * 100).toStringAsFixed(0)}%'
                                : '-',
                            'Avg Confidence',
                            Icons.trending_up_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: _statCard(_age > 0 ? '$_age yrs' : '-', 'Age', Icons.cake_outlined)),
                      ],
                    ),

                  if (_isLoading && _supabase.isLoggedIn)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: MyColors.PastelRose, strokeWidth: 2),
                    ),

                  const SizedBox(height: 20),

                  _sectionHeader('Account'),
                  _tile(Icons.person_outline_rounded, 'Edit Profile',
                      subtitle: 'Update name and age',
                      onTap: _supabase.isLoggedIn ? _showEditDialog : null),
                  _tile(Icons.notifications_outlined, 'Notifications',
                      onTap: () {},
                      trailing: Switch(value: true, onChanged: (_) {}, activeColor: MyColors.PastelRose)),
                  _tile(Icons.lock_outline_rounded, 'Change Password', onTap: () {}),

                  const SizedBox(height: 16),
                  _sectionHeader('App'),
                  _tile(Icons.info_outline_rounded, 'About', subtitle: 'Version 2.0.0', onTap: () {}),
                  _tile(Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () {}),
                  _tile(Icons.description_outlined, 'Terms of Service', onTap: () {}),

                  const SizedBox(height: 16),
                  if (!_supabase.isLoggedIn) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.to(() => const LoginScreen()),
                        icon: const Icon(Icons.login_rounded, color: Colors.white),
                        label: const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 15)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyColors.PastelRose,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ] else ...[
                    _tile(Icons.logout_rounded, 'Sign Out',
                        textColor: Colors.red.shade400,
                        iconColor: Colors.red.shade400,
                        onTap: _signOut),
                  ],

                  const SizedBox(height: 30),
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
                        Icon(Icons.medical_information_outlined, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'This app is for educational purposes only. Results are not a substitute for professional medical diagnosis.',
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade800, height: 1.5),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Icon(icon, color: MyColors.PastelRose, size: 22),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(label,
                style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey.shade500)),
        ),
      );

  Widget _tile(IconData icon, String title, {
    String? subtitle, VoidCallback? onTap, Widget? trailing, Color? textColor, Color? iconColor,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: ListTile(
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (iconColor ?? MyColors.PastelRose).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor ?? MyColors.PastelRose, size: 18),
          ),
          title: Text(title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor ?? MyColors.black)),
          subtitle: subtitle != null
              ? Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade400))
              : null,
          trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 18),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
}
