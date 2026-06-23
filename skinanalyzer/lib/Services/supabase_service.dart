// -----------------------------------------------
// Project: Skin Health Analyzer
// File: supabase_service.dart
// FIX: signUp now saves age + full_name; added profile helpers;
//      getUserStats returns avgConfidence properly.
// -----------------------------------------------

// ignore_for_file: avoid_print

import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Models/scan_result.dart';
import '../Utils/app_config.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  // ── Auth getters ──────────────────────────────
  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;
  String get userId => currentUser?.id ?? '';
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  String get displayName {
    final meta = currentUser?.userMetadata;
    if (meta?['full_name'] != null && (meta!['full_name'] as String).isNotEmpty) {
      return meta['full_name'] as String;
    }
    return currentUser?.email?.split('@').first ?? 'User';
  }

  int get userAge {
    final meta = currentUser?.userMetadata;
    if (meta?['age'] != null) {
      return int.tryParse(meta!['age'].toString()) ?? 0;
    }
    return 0;
  }

  // ── Sign Up ───────────────────────────────────
  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    String? fullName,
    int? age,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName ?? '',
          'age': age ?? 0,
        },
      );

      // Also write to profiles table for reliable reads
      if (response.user != null) {
        try {
          await _client.from('profiles').upsert({
            'id': response.user!.id,
            'full_name': fullName ?? '',
            'age': age ?? 0,
            'email': email,
            'created_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          print('[Supabase] Profile upsert (non-fatal): $e');
        }
      }
      return response;
    } on SocketException {
      print('[Supabase] No internet');
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // ── Sign In ───────────────────────────────────
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ── Sign Out ──────────────────────────────────
  Future<void> signOut() async => await _client.auth.signOut();

  // ── Profile ───────────────────────────────────
  Future<Map<String, dynamic>?> fetchProfile() async {
    if (!isLoggedIn) return null;
    try {
      return await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      print('[Supabase] fetchProfile: $e');
      return null;
    }
  }

  Future<void> updateProfile({String? fullName, int? age}) async {
    if (!isLoggedIn) return;
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (age != null) updates['age'] = age;
      if (updates.isEmpty) return;

      await _client.auth.updateUser(UserAttributes(data: updates));
      await _client.from('profiles').upsert({
        'id': userId,
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('[Supabase] updateProfile: $e');
    }
  }

  // ── Image Upload ──────────────────────────────
  Future<String?> uploadImage(File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      await _client.storage.from('skin-scans').upload(
            fileName, imageFile,
            fileOptions: const FileOptions(upsert: false),
          );
      return _client.storage.from('skin-scans').getPublicUrl(fileName);
    } catch (e) {
      print('[Supabase] Image upload: $e');
      return null;
    }
  }

  // ── Save scan result ──────────────────────────
  Future<ScanResult?> saveScanResult(ScanResult result) async {
    try {
      final payload = result.toJson();
      payload['user_id'] = userId;
      print('[Supabase] Saving: ${result.conditionName}');
      final response = await _client
          .from(AppConfig.scanResultsTable)
          .insert(payload)
          .select()
          .single();
      print('[Supabase] Saved id: ${response['id']}');
      return ScanResult.fromJson(response);
    } catch (e) {
      print('[Supabase] Save error: $e');
      return null;
    }
  }

  // ── Fetch history ─────────────────────────────
  Future<List<ScanResult>> getScanHistory({int limit = 20}) async {
    try {
      final response = await _client
          .from(AppConfig.scanResultsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);
      return (response as List)
          .map((j) => ScanResult.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('[Supabase] getScanHistory: $e');
      return [];
    }
  }

  // ── Delete ────────────────────────────────────
  Future<bool> deleteScanResult(String id) async {
    try {
      await _client
          .from(AppConfig.scanResultsTable)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('[Supabase] delete: $e');
      return false;
    }
  }

  // ── Stats ─────────────────────────────────────
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final results = await getScanHistory(limit: 100);
      if (results.isEmpty) {
        return {'totalScans': 0, 'lastScan': null, 'mostCommon': '-', 'avgConfidence': null};
      }
      final counts = <String, int>{};
      for (final r in results) {
        counts[r.conditionName] = (counts[r.conditionName] ?? 0) + 1;
      }
      return {
        'totalScans': results.length,
        'lastScan': results.first.createdAt,
        'mostCommon': counts.entries.reduce((a, b) => a.value > b.value ? a : b).key,
        'avgConfidence':
            results.map((r) => r.confidence).reduce((a, b) => a + b) / results.length,
      };
    } catch (e) {
      print('[Supabase] getUserStats: $e');
      return {'totalScans': 0, 'lastScan': null, 'mostCommon': '-', 'avgConfidence': null};
    }
  }
}
