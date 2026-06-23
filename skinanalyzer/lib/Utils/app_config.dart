// -----------------------------------------------
// Project: Skin Health Analyzer
// File: app_config.dart
// OPTIMIZED VERSION (Enhanced 23-Class Model Integration)
// -----------------------------------------------

class AppConfig {
  AppConfig._();

  static const String supabaseUrl = 'https://linyyumczsneiiuwcirk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxpbnl5dW1jenNuZWlpdXdjaXJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MTEwMDUsImV4cCI6MjA4MzE4NzAwNX0.7xsKyi1KYdUCyEs66T-etErY4IlgOML8jRlB99cmlgA';

  static const String scanResultsTable = 'skin_results';
  static const String n8nWebhookUrl =
      'https://n8n.ddukan.pk/webhook/SHA-recommendations';

  // Updated target asset path for the new dynamic range quantized model
  static const String tfliteModelPath = 'assets/model/model_dr_quant.tflite';
  static const int inputSize = 300; // EfficientNetB3 base target image resolution
  static const int numClasses = 23; // Expanded target matrix capacity

  // Strict PyTorch ImageFolder alphabetical label map array
  static const List<String> classLabels = [
    'Acne and Rosacea Photos',
    'Actinic Keratosis Basal Cell Carcinoma and other Malignant Lesions',
    'Atopic Dermatitis Photos',
    'Bullous Disease Photos',
    'Cellulitis Impetigo and other Bacterial Infections',
    'Eczema Photos',
    'Exanthems and Drug Eruptions',
    'Hair Loss Photos Alopecia and other Hair Diseases',
    'Herpes HPV and other STDs Photos',
    'Light Diseases and Disorders of Pigmentation',
    'Lupus and other Connective Tissue diseases',
    'Melanoma Skin Cancer Nevi and Moles',
    'Nail Fungus and other Nail Disease',
    'Poison Ivy Photos and other Contact Dermatitis',
    'Psoriasis pictures Lichen Planus and related diseases',
    'Scabies Lyme Disease and other Infestations and Bites',
    'Seborrheic Keratoses and other Benign Tumors',
    'Systemic Disease',
    'Tinea Ringworm Candidiasis and other Fungal Infections',
    'Urticaria Hives',
    'Vascular Tumors',
    'Vasculitis Photos',
    'Warts Molluscum and other Viral Infections',
  ];

  static const String labelDiseaseUndetected = 'Condition Undetected';
  static const double confidenceThreshold = 0.50; // Aligned with the model validation curve threshold
  static const int maxRecommendations = 10;

  static const Map<String, String> conditionDescriptions = {
    'Acne and Rosacea Photos': 'Inflammatory face or skin conditions displaying pimples, redness, or bumps.',
    'Actinic Keratosis Basal Cell Carcinoma and other Malignant Lesions': 'Pre-cancerous or malignant growths. Medical evaluation is highly recommended.',
    'Atopic Dermatitis Photos': 'Flaky, intensely itchy skin conditions linked to immune reactivity.',
    'Bullous Disease Photos': 'Blistering conditions affecting skin surfaces or delicate tissue areas.',
    'Cellulitis Impetigo and other Bacterial Infections': 'Bacterial skin surface invasions causing swelling, pain, or crusted areas.',
    'Eczema Photos': 'Irritated, scaling, or dry skin patches reactive to structural or environmental triggers.',
    'Exanthems and Drug Eruptions': 'Widespread systemic rashes or reactions linked to viral states or medications.',
    'Hair Loss Photos Alopecia and other Hair Diseases': 'Follicle thinning, localized structural hair loss, or scalp irritation.',
    'Herpes HPV and other STDs Photos': 'Viral manifestations causing distinct surface sores or raised viral lesions.',
    'Light Diseases and Disorders of Pigmentation': 'UV-induced skin changes or irregularities in localized melanin production.',
    'Lupus and other Connective Tissue diseases': 'Autoimmune skin changes, including distinct facial or geometric target rashes.',
    'Melanoma Skin Cancer Nevi and Moles': 'Atypical pigmented moles or direct structural skin malignancies requiring professional review.',
    'Nail Fungus and other Nail Disease': 'Fungal infections causing thick, brittle, or discolored nail plates.',
    'Poison Ivy Photos and other Contact Dermatitis': 'Localized acute inflammation or micro-blisters triggered by contact allergens.',
    'Psoriasis pictures Lichen Planus and related diseases': 'Accelerated skin renewal causing thick silver plaques or purple-toned bumps.',
    'Scabies Lyme Disease and other Infestations and Bites': 'Eruptions triggered by parasitic skin mites, insect vectors, or ticks.',
    'Seborrheic Keratoses and other Benign Tumors': 'Non-cancerous raised surface lesions, often waxy or deeply colored.',
    'Systemic Disease': 'Cutaneous markers indicating broader internal organ or metabolic system conditions.',
    'Tinea Ringworm Candidiasis and other Fungal Infections': 'Superficial fungal conditions showing ring-like configurations or raw friction areas.',
    'Urticaria Hives': 'Transient, raised red wheals or systemic hives from allergic triggers.',
    'Vascular Tumors': 'Benign structural clusters of blood vessels close to the skin surface.',
    'Vasculitis Photos': 'Inflamed blood vessels presenting as distinct purple spots or patches.',
    'Warts Molluscum and other Viral Infections': 'Highly contagious localized viral skin anomalies causing firm nodules or warts.',
  };
}