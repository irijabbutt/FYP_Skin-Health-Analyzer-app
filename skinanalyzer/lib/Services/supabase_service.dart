// -----------------------------------------------
// Project: Skin Health Analyzer
// File: supabase_service.dart
// Description: Supabase auth + scan result storage
// -----------------------------------------------

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/scan_result.dart';
import '../Utils/app_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  // ── Auth ──────────────────────────────────────
  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  String get userId => currentUser?.id ?? '';

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ── Upload image to Supabase Storage ─────────
  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _client.storage.from('skin-scans').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: false),
          );

      final url = _client.storage.from('skin-scans').getPublicUrl(fileName);
      return url;
    } catch (e) {
      print('[Supabase] Image upload error: $e');
      return null;
    }
  }

  // ── Save scan result ──────────────────────────
  Future<ScanResult?> saveScanResult(ScanResult result) async {
    try {
      final payload = result.toJson();
      payload['user_id'] = userId;

      final response = await _client
          .from(AppConfig.scanResultsTable)
          .insert(payload)
          .select()
          .single();

      return ScanResult.fromJson(response);
    } catch (e) {
      print('[Supabase] Save error: $e');
      return null;
    }
  }

  // ── Fetch user scan history ───────────────────
  Future<List<ScanResult>> getScanHistory({int limit = 20}) async {
    try {
      final response = await _client
          .from(AppConfig.scanResultsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => ScanResult.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[Supabase] Fetch history error: $e');
      return [];
    }
  }

  // ── Delete a scan result ──────────────────────
  Future<bool> deleteScanResult(String id) async {
    try {
      await _client
          .from(AppConfig.scanResultsTable)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('[Supabase] Delete error: $e');
      return false;
    }
  }

  // ── Get stats for home screen ─────────────────
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final results = await getScanHistory(limit: 100);
      if (results.isEmpty) {
        return {'totalScans': 0, 'lastScan': null, 'mostCommon': '-'};
      }

      final conditionCounts = <String, int>{};
      for (final r in results) {
        conditionCounts[r.conditionName] =
            (conditionCounts[r.conditionName] ?? 0) + 1;
      }
      final mostCommon = conditionCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      return {
        'totalScans': results.length,
        'lastScan': results.first.createdAt,
        'mostCommon': mostCommon,
        'avgConfidence':
            results.map((r) => r.confidence).reduce((a, b) => a + b) /
                results.length,
      };
    } catch (e) {
      return {'totalScans': 0, 'lastScan': null, 'mostCommon': '-'};
    }
  }
}
