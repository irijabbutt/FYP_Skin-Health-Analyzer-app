// -----------------------------------------------
// Project: Skin Health Analyzer
// File: scan_result.dart
// Description: Data model for a skin scan result
// -----------------------------------------------

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

  ScanResult({
    this.id,
    required this.userId,
    required this.imagePath,
    this.imageUrl,
    required this.conditionName,
    required this.confidence,
    required this.description,
    required this.urgency,
    required this.topPredictions,
    required this.createdAt,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'image_url': imageUrl,
        'condition_name': conditionName,
        'confidence': confidence,
        'description': description,
        'urgency': urgency,
        'top_predictions': topPredictions.map((p) => p.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };

  factory ScanResult.fromJson(Map<String, dynamic> json) => ScanResult(
        id: json['id'],
        userId: json['user_id'] ?? '',
        imagePath: '',
        imageUrl: json['image_url'],
        conditionName: json['condition_name'] ?? '',
        confidence: (json['confidence'] ?? 0.0).toDouble(),
        description: json['description'] ?? '',
        urgency: json['urgency'] ?? 'low',
        topPredictions: (json['top_predictions'] as List<dynamic>? ?? [])
            .map((p) => TopPrediction.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(
            json['created_at'] ?? DateTime.now().toIso8601String()),
        synced: true,
      );
}

class TopPrediction {
  final String label;
  final double confidence;

  TopPrediction({required this.label, required this.confidence});

  Map<String, dynamic> toJson() => {
        'label': label,
        'confidence': confidence,
      };

  factory TopPrediction.fromJson(Map<String, dynamic> json) => TopPrediction(
        label: json['label'] ?? '',
        confidence: (json['confidence'] ?? 0.0).toDouble(),
      );
}
