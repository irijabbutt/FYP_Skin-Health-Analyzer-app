// -----------------------------------------------
// Project: Skin Health Analyzer
// File: scan_result.dart
// UPDATED: Standardized special classes across the architecture
// -----------------------------------------------

// ignore_for_file: no_leading_underscores_for_local_identifiers

import '../../Utils/app_config.dart';

// ── OTC Product ────────────────────────────────
class OtcProduct {
  final String name;
  final String category;
  final String reason;

  const OtcProduct({
    required this.name,
    required this.category,
    required this.reason,
  });

  factory OtcProduct.fromJson(Map<String, dynamic> json) => OtcProduct(
        name: json['name']?.toString() ?? '',
        category: json['category']?.toString() ?? '',
        reason: json['reason']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category,
        'reason': reason,
      };
}

// ── N8n Recommendation (strongly typed) ────────
class N8nRecommendation {
  final String? urgencyNote;
  final List<String> skincareDo;
  final List<String> skincareAvoid;
  final List<String> morningRoutine;
  final List<String> eveningRoutine;
  final List<String> avoidIngredients;
  final List<String> lifestyleTips;
  final List<String> warningSigns;
  final List<OtcProduct> otcProducts;
  final String? disclaimer;

  const N8nRecommendation({
    this.urgencyNote,
    this.skincareDo = const [],
    this.skincareAvoid = const [],
    this.morningRoutine = const [],
    this.eveningRoutine = const [],
    this.avoidIngredients = const [],
    this.lifestyleTips = const [],
    this.warningSigns = const [],
    this.otcProducts = const [],
    this.disclaimer,
  });

  bool get isEmpty =>
      urgencyNote == null &&
      skincareDo.isEmpty &&
      skincareAvoid.isEmpty &&
      morningRoutine.isEmpty &&
      eveningRoutine.isEmpty &&
      otcProducts.isEmpty;

  factory N8nRecommendation.fromJson(Map<String, dynamic> json) {
    List<String> _strings(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    List<OtcProduct> _products(dynamic val) {
      if (val == null) return [];
      if (val is List) {
        return val
            .whereType<Map<String, dynamic>>()
            .map((e) => OtcProduct.fromJson(e))
            .toList();
      }
      return [];
    }

    return N8nRecommendation(
      urgencyNote: json['urgency_note']?.toString(),
      skincareDo: _strings(json['skincare_do']),
      skincareAvoid: _strings(json['skincare_avoid']),
      morningRoutine: _strings(json['morning_routine']),
      eveningRoutine: _strings(json['evening_routine']),
      avoidIngredients: _strings(json['avoid_ingredients']),
      lifestyleTips: _strings(json['lifestyle_tips']),
      warningSigns: _strings(json['warning_signs']),
      otcProducts: _products(json['otc_products']),
      disclaimer: json['disclaimer']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'urgency_note': urgencyNote,
        'skincare_do': skincareDo,
        'skincare_avoid': skincareAvoid,
        'morning_routine': morningRoutine,
        'evening_routine': eveningRoutine,
        'avoid_ingredients': avoidIngredients,
        'lifestyle_tips': lifestyleTips,
        'warning_signs': warningSigns,
        'otc_products': otcProducts.map((p) => p.toJson()).toList(),
        'disclaimer': disclaimer,
      };

  static N8nRecommendation? fromRawJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return N8nRecommendation.fromJson(json);
  }
}

// ── Top Prediction ─────────────────────────────
class TopPrediction {
  final String label;
  final double confidence;

  const TopPrediction({required this.label, required this.confidence});

  Map<String, dynamic> toJson() => {'label': label, 'confidence': confidence};

  factory TopPrediction.fromJson(Map<String, dynamic> json) => TopPrediction(
        label: json['label']?.toString() ?? '',
        confidence: (json['confidence'] ?? 0.0).toDouble(),
      );
}

// ── Scan Result ────────────────────────────────
class ScanResult {
  final String? id;
  final String userId;
  final String imagePath;
  final String? imageUrl;
  final String conditionName;
  final double confidence;
  final String description;
  final String urgency;
  final List<TopPrediction> topPredictions;
  final DateTime createdAt;
  final bool synced;
  final Map<String, dynamic>? recommendations;
  final N8nRecommendation? parsedRecommendations;

  const ScanResult({
    this.id,
    required this.userId,
    required this.imagePath,
    this.imageUrl,
    required this.conditionName,
    required this.confidence,
    required this.description,
    required this.urgency,
    required this.topPredictions,
    this.recommendations,
    this.parsedRecommendations,
    required this.createdAt,
    this.synced = false,
  });

  /// Unified matching array handling both undetected threshold state and standard clear variants
  bool get isSpecialClass =>
      conditionName == AppConfig.labelDiseaseUndetected ||
      conditionName == 'Normal Skin' ||
      conditionName == 'Healthy Skin' ||
      conditionName == 'No Skin Issue Detected' ||
      conditionName == 'Ink / Henna on Skin';

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'image_url': imageUrl,
        'condition_name': conditionName,
        'confidence': confidence,
        'description': description,
        'urgency': urgency,
        'top_predictions': topPredictions.map((p) => p.toJson()).toList(),
        'recommendations': parsedRecommendations?.toJson() ?? recommendations,
        'created_at': createdAt.toIso8601String(),
      };

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final rawRecs = json['recommendations'] as Map<String, dynamic>?;
    return ScanResult(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      imagePath: '',
      imageUrl: json['image_url']?.toString(),
      conditionName: json['condition_name']?.toString() ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      description: json['description']?.toString() ?? '',
      urgency: json['urgency']?.toString() ?? 'low',
      topPredictions: (json['top_predictions'] as List<dynamic>? ?? [])
          .map((p) => TopPrediction.fromJson(p as Map<String, dynamic>))
          .toList(),
      recommendations: rawRecs,
      parsedRecommendations: N8nRecommendation.fromRawJson(rawRecs),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      synced: true,
    );
  }

  ScanResult copyWith(
      {N8nRecommendation? parsedRecommendations,
      Map<String, dynamic>? recommendations}) {
    return ScanResult(
      id: id,
      userId: userId,
      imagePath: imagePath,
      imageUrl: imageUrl,
      conditionName: conditionName,
      confidence: confidence,
      description: description,
      urgency: urgency,
      topPredictions: topPredictions,
      recommendations: recommendations ?? this.recommendations,
      parsedRecommendations:
          parsedRecommendations ?? this.parsedRecommendations,
      createdAt: createdAt,
      synced: synced,
    );
  }
}
