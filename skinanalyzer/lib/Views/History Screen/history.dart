// -----------------------------------------------
// Project: Skin Health Analyzer
// File: history.dart
// UPDATED: Shows image from device path (local file)
//          Falls back to imageUrl then icon if not available
// -----------------------------------------------

// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../Models/scan_result.dart';
import '../../Services/supabase_service.dart';
import '../../Utils/values/color.dart';
import '../Results Screen/results.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _supabase = SupabaseService();
  List<ScanResult> _results = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase.getScanHistory(limit: 50);
      setState(() {
        _results = data;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load history';
      });
    }
  }

  Future<void> _deleteResult(ScanResult result) async {
    if (result.id == null) return;
    final confirmed = await _showDeleteDialog();
    if (!confirmed) return;
    final ok = await _supabase.deleteScanResult(result.id!);
    if (ok) {
      setState(() => _results.removeWhere((r) => r.id == result.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Scan deleted'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  Future<bool> _showDeleteDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Scan'),
            content: const Text(
                'Are you sure you want to delete this scan result?'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.LightLightLavender,
      appBar: AppBar(
        backgroundColor: MyColors.LightLightLavender,
        elevation: 0,
        title: const Text('Scan History',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _fetchHistory),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_supabase.isLoggedIn) {
      return _emptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Sign in to view history',
        subtitle: 'Your scan history is saved securely to your account',
      );
    }
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: MyColors.PastelRose));
    }
    if (_error != null) {
      return _emptyState(
        icon: Icons.error_outline_rounded,
        title: 'Error loading history',
        subtitle: _error!,
        action: ElevatedButton(
          onPressed: _fetchHistory,
          style:
              ElevatedButton.styleFrom(backgroundColor: MyColors.PastelRose),
          child:
              const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      );
    }
    if (_results.isEmpty) {
      return _emptyState(
        icon: Icons.history_rounded,
        title: 'No scans yet',
        subtitle:
            'Your scan history will appear here after your first analysis',
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchHistory,
      color: MyColors.PastelRose,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _results.length,
        itemBuilder: (_, i) => _historyCard(_results[i]),
      ),
    );
  }

  Widget _historyCard(ScanResult result) {
    final urgencyColor = _urgencyColor(result.urgency);
    return Dismissible(
      key: Key(result.id ?? result.createdAt.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
      ),
      confirmDismiss: (_) async {
        await _deleteResult(result);
        return false;
      },
      child: GestureDetector(
        onTap: () => Get.to(() => ResultsScreen(result: result)),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // ── Scan Image Thumbnail ─────────────────────
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: _buildThumbnail(result),
              ),
              const SizedBox(width: 14),

              // ── Info ──────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Urgency badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: urgencyColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_urgencyIcon(result.urgency),
                                    size: 11, color: urgencyColor),
                                const SizedBox(width: 3),
                                Text(
                                  _urgencyLabel(result.urgency),
                                  style: TextStyle(
                                      fontSize: 9,
                                      color: urgencyColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        result.conditionName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: MyColors.black),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a')
                            .format(result.createdAt),
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Confidence Badge ─────────────────────────
              Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: MyColors.PastelRose.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${(result.confidence * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Color(0xFFAD6579),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Icon(Icons.chevron_right_rounded,
                        color: Colors.grey, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows image from local file → network url → icon fallback
  Widget _buildThumbnail(ScanResult result) {
    const double size = 80;

    // 1. Try local device path
    if (result.imagePath.isNotEmpty) {
      final localFile = File(result.imagePath);
      if (localFile.existsSync()) {
        return Image.file(
          localFile,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _thumbFallback(result, size),
        );
      }
    }

    // 2. Try Supabase storage URL
    if (result.imageUrl != null && result.imageUrl!.isNotEmpty) {
      return Image.network(
        result.imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            width: size,
            height: size,
            color: MyColors.WhiteRose,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: MyColors.PastelRose, strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _thumbFallback(result, size),
      );
    }

    // 3. Fallback icon
    return _thumbFallback(result, size);
  }

  Widget _thumbFallback(ScanResult result, double size) {
    final color = _urgencyColor(result.urgency);
    return Container(
      width: size,
      height: size,
      color: color.withOpacity(0.12),
      child: Icon(_urgencyIcon(result.urgency), color: color, size: 30),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            if (action != null) ...[const SizedBox(height: 16), action],
          ],
        ),
      ),
    );
  }

  Color _urgencyColor(String u) {
    switch (u) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.orange.shade400;
      case 'none':
        return Colors.green.shade400;
      case 'info':
        return Colors.blue.shade400;
      default:
        return Colors.green.shade400;
    }
  }

  IconData _urgencyIcon(String u) {
    switch (u) {
      case 'high':
        return Icons.warning_rounded;
      case 'medium':
        return Icons.info_rounded;
      case 'none':
        return Icons.check_circle_rounded;
      case 'info':
        return Icons.brush_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String _urgencyLabel(String u) {
    switch (u) {
      case 'high':
        return 'HIGH';
      case 'medium':
        return 'MEDIUM';
      case 'none':
        return 'HEALTHY';
      case 'info':
        return 'INFO';
      default:
        return 'LOW';
    }
  }
}
