// -----------------------------------------------
// Project: Skin Health Analyzer
// File: n8n_service.dart
// FIX: Extracts nested outer['recommendations'] map before fromJson.
//      Also splits comma-separated string fields into proper lists.
// -----------------------------------------------

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/scan_result.dart';
import '../Utils/app_config.dart';
import 'supabase_service.dart';

class N8nService {
  static final N8nService _instance = N8nService._internal();
  factory N8nService() => _instance;
  N8nService._internal();

  final _supabase = SupabaseService();

  Future<N8nRecommendation?> getRecommendations({
    required String condition,
    required double confidence,
    required String description,
    String urgency = 'low',
    List<TopPrediction>? allPredictions,
  }) async {
    // Skip AI recommendations for undetected / special labels
    if (condition == AppConfig.labelDiseaseUndetected ||
        condition == 'Healthy Skin' ||
        condition == 'Normal Skin' ||
        condition == 'No Skin Issue Detected' ||
        condition == 'Ink / Henna on Skin') {
      return null;
    }

    try {
      final user = _supabase.currentUser;
      final meta = user?.userMetadata;

      final filteredPredictions = (allPredictions ?? [])
          .where((p) => p.confidence >= AppConfig.confidenceThreshold)
          .take(AppConfig.maxRecommendations)
          .map((p) => {
                'condition': p.label,
                'confidence_pct': '${(p.confidence * 100).toStringAsFixed(1)}%',
              })
          .toList();

      final payload = {
        'event': 'get_skincare_recommendations',
        'timestamp': DateTime.now().toIso8601String(),
        'user': {
          'user_id': user?.id ?? 'anonymous',
          'full_name': meta?['full_name'] ?? '',
          'age': meta?['age'] ?? 0,
          'email': user?.email ?? '',
        },
        'primary_condition': condition,
        'primary_confidence_pct': '${(confidence * 100).toStringAsFixed(1)}%',
        'urgency': urgency,
        'description': description,
        'all_predictions': filteredPredictions,
      };

      print(
          '[n8n] → $condition | user: ${meta?['full_name']} age:${meta?['age']}');

      final response = await http
          .post(
            Uri.parse(AppConfig.n8nWebhookUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.trim();
        if (body.isEmpty) return null;

        dynamic decoded;
        try {
          decoded = jsonDecode(body);
        } catch (e) {
          print('[n8n] JSON parse error: $e');
          return null;
        }

        // ── Step 1: unwrap array ──────────────────────────────────────
        // n8n always returns a List: [{ "status": ..., "recommendations": {...} }]
        Map<String, dynamic>? outer;
        if (decoded is Map<String, dynamic>) {
          outer = decoded;
        } else if (decoded is List && decoded.isNotEmpty) {
          outer = decoded.first as Map<String, dynamic>;
        }
        if (outer == null) {
          print('[n8n] Could not unwrap outer object');
          return null;
        }

        // ── Step 2: extract the nested recommendations map ────────────
        // Response shape: { "status": "success", "recommendations": { ... } }
        Map<String, dynamic> recMap;
        if (outer['recommendations'] is Map<String, dynamic>) {
          recMap = outer['recommendations'] as Map<String, dynamic>;
        } else {
          // Fallback: root itself may be the rec object
          recMap = outer;
        }

        print('[n8n] ✓ Rec keys: ${recMap.keys.toList()}');
        return N8nRecommendation.fromJson(recMap);
      } else {
        print('[n8n] Failed ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[n8n] Error: $e');
      return null;
    }
  }

  /// Non-blocking scan event log
  Future<void> logScanEvent(ScanResult result) async {
    try {
      final user = _supabase.currentUser;
      final meta = user?.userMetadata;

      await http
          .post(
            Uri.parse(AppConfig.n8nWebhookUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'event': 'skin_scan_logged',
              'user_id': user?.id,
              'email': user?.email ?? '',
              'full_name': meta?['full_name'] ?? '',
              'age': meta?['age'] ?? 0,
              'condition': result.conditionName,
              'confidence': '${(result.confidence * 100).toStringAsFixed(1)}%',
              'urgency': result.urgency,
              'created_at': result.createdAt.toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }
}
