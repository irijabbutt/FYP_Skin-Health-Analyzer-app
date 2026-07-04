// -----------------------------------------------
// Project: Skin Health Analyzer
// File: scan_result.dart
// UPDATED: Synchronized isSpecialClass categories 
//          with scan.dart interface boundaries
// -----------------------------------------------

// ignore_for_file: no_leading_underscores_for_local_identifiers

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
  final bool seeDoctor;
  final String? doctorTimeline;
  final List<String> skincareDo;
  final List<String> skincareAvoid;
  final List<String> morningRoutine;
  final List<String> eveningRoutine;
  final List<String> keyIngredients;
  final List<String> avoidIngredients;
  final List<String> lifestyleTips;
  final List<String> warningSigns;
  final List<OtcProduct> otcProducts;
  final String? disclaimer;

  const N8nRecommendation({
    this.urgencyNote,
    this.seeDoctor = false,
    this.doctorTimeline,
    this.skincareDo = const [],
    this.skincareAvoid = const [],
    this.morningRoutine = const [],
    this.eveningRoutine = const [],
    this.keyIngredients = const [],
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
    // n8n's "Extract recommendations" code node emits flat, no-underscore
    // keys (e.g. "morningroutine", "otcproducts"). Accept BOTH that style
    // and a snake_case style so this keeps working if the workflow's key
    // casing ever changes again — first match wins.
    dynamic pick(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k];
      }
      return null;
    }

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

    bool _bool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      final s = val.toString().toLowerCase();
      return s == 'true' || s.contains('yes');
    }

    return N8nRecommendation(
      urgencyNote: pick(['urgencynote', 'urgency_note'])?.toString(),
      seeDoctor: _bool(pick(['seedoctor', 'see_doctor'])),
      doctorTimeline: pick(['doctortimeline', 'doctor_timeline'])?.toString(),
      skincareDo: _strings(pick(['skincaredo', 'skincare_do'])),
      skincareAvoid: _strings(pick(['skincareavoid', 'skincare_avoid'])),
      morningRoutine: _strings(pick(['morningroutine', 'morning_routine'])),
      eveningRoutine: _strings(pick(['eveningroutine', 'evening_routine'])),
      keyIngredients: _strings(pick(['keyingredients', 'key_ingredients'])),
      avoidIngredients:
          _strings(pick(['avoidingredients', 'avoid_ingredients'])),
      lifestyleTips: _strings(pick(['lifestyletips', 'lifestyle_tips'])),
      warningSigns: _strings(pick(['warningsigns', 'warning_signs'])),
      otcProducts: _products(pick(['otcproducts', 'otc_products'])),
      disclaimer: pick(['disclaimer'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'urgency_note': urgencyNote,
        'see_doctor': seeDoctor,
        'doctor_timeline': doctorTimeline,
        'skincare_do': skincareDo,
        'skincare_avoid': skincareAvoid,
        'morning_routine': morningRoutine,
        'evening_routine': eveningRoutine,
        'key_ingredients': keyIngredients,
        'avoid_ingredients': avoidIngredients,
        'lifestyle_tips': lifestyleTips,
        'warning_signs': warningSigns,
        'otc_products': otcProducts.map((p) => p.toJson()).toList(),
        'disclaimer': disclaimer,
      };

  /// Also keep raw Map for Supabase jsonb storage
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
  final String imagePath; // local device path
  final String? imageUrl; // supabase storage url
  final String conditionName;
  final double confidence;
  final String description;
  final String urgency;
  final List<TopPrediction> topPredictions;
  final DateTime createdAt;
  final bool synced;
  final Map<String, dynamic>? recommendations; // raw json for supabase
  final N8nRecommendation? parsedRecommendations; // typed object for UI

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

  /// Whether this result is for a special non-disease class
  /// UPDATED: Matches target runtime strings completely
  bool get isSpecialClass =>
      conditionName == 'Conditions Undetected' ||
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

  ScanResult copyWith({N8nRecommendation? parsedRecommendations, Map<String, dynamic>? recommendations}) {
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
      parsedRecommendations: parsedRecommendations ?? this.parsedRecommendations,
      createdAt: createdAt,
      synced: synced,
    );
  }
}