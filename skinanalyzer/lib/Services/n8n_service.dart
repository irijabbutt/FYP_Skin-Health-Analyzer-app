// -----------------------------------------------
// Project: Skin Health Analyzer
// File: n8n_service.dart
// Description: Sends scan results to n8n webhook
// -----------------------------------------------

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

  // ── Send scan result to n8n ───────────────────
  Future<bool> sendScanResult(ScanResult result) async {
    try {
      final user = _supabase.currentUser;
      final payload = {
        'event': 'skin_scan_completed',
        'timestamp': DateTime.now().toIso8601String(),
        'user_id': user?.id ?? 'anonymous',
        'user_email': user?.email ?? 'unknown',
        'scan': {
          'id': result.id,
          'condition': result.conditionName,
          'confidence': result.confidence,
          'confidence_pct': '${(result.confidence * 100).toStringAsFixed(1)}%',
          'urgency': result.urgency,
          'description': result.description,
          'image_url': result.imageUrl,
          'top_predictions': result.topPredictions
              .map((p) => {
                    'label': p.label,
                    'confidence': p.confidence,
                    'confidence_pct':
                        '${(p.confidence * 100).toStringAsFixed(1)}%',
                  })
              .toList(),
          'created_at': result.createdAt.toIso8601String(),
        },
        // App metadata
        'app': {
          'name': 'Skin Health Analyzer',
          'version': '2.0.0',
          'platform': 'Flutter',
        },
      };

      final response = await http
          .post(
            Uri.parse(AppConfig.n8nWebhookUrl),
            headers: {
              'Content-Type': 'application/json',
              // Optional: add a shared secret for security
              // 'X-Webhook-Secret': 'your_secret',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('[n8n] Webhook sent successfully: ${response.statusCode}');
        return true;
      } else {
        print('[n8n] Webhook failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('[n8n] Webhook error: $e');
      // Don't throw — n8n failure shouldn't break the app
      return false;
    }
  }

  // ── Send high-urgency alert ───────────────────
  Future<void> sendUrgencyAlert(ScanResult result) async {
    if (result.urgency != 'high') return;
    try {
      final payload = {
        'event': 'high_urgency_alert',
        'user_id': _supabase.userId,
        'user_email': _supabase.currentUser?.email,
        'condition': result.conditionName,
        'confidence': result.confidence,
        'urgency': result.urgency,
        'timestamp': DateTime.now().toIso8601String(),
        'message':
            'ALERT: High-urgency skin condition detected — ${result.conditionName}. '
                'Please seek medical advice promptly.',
      };

      await http
          .post(
            Uri.parse(AppConfig.n8nWebhookUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      print('[n8n] Alert error: $e');
    }
  }
}
