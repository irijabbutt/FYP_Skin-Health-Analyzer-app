// -----------------------------------------------
// Project: Skin Health Analyzer
// File: app_config.dart
// Description: Central configuration for all services
// -----------------------------------------------

class AppConfig {
  AppConfig._();

  // ── Supabase ──────────────────────────────────
  // Replace with your actual Supabase project URL and anon key
  static const String supabaseUrl = 'https://linyyumczsneiiuwcirk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxpbnl5dW1jenNuZWlpdXdjaXJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc2MTEwMDUsImV4cCI6MjA4MzE4NzAwNX0.7xsKyi1KYdUCyEs66T-etErY4IlgOML8jRlB99cmlgA';

  // Supabase table name
  static const String scanResultsTable = 'scan_results';

  // ── n8n Webhook ───────────────────────────────
  // Replace with your n8n webhook URL
  // Example: https://your-n8n-instance.com/webhook/skin-analyzer
  static const String n8nWebhookUrl =
      'https://n8n.ddukan.pk/webhook/SHA-recommendations';

  // ── TFLite Model ─────────────────────────────
  static const String tfliteModelPath =
      'assets/model/finetune_skin_analyzer_model_keras.tflite';
  static const int inputSize = 224;
  static const int numClasses = 23;

  // ── DermNet 23 Class Labels ───────────────────
  static const List<String> classLabels = [
    'Acne and Rosacea',
    'Actinic Keratosis & Malignant Lesions',
    'Atopic Dermatitis',
    'Bullous Disease',
    'Cellulitis & Bacterial Infections',
    'Eczema',
    'Exanthems and Drug Eruptions',
    'Hair Loss & Alopecia',
    'Herpes, HPV & STDs',
    'Light Diseases & Pigmentation',
    'Lupus & Connective Tissue',
    'Melanoma, Nevi & Moles',
    'Nail Fungus & Nail Disease',
    'Poison Ivy & Contact Dermatitis',
    'Psoriasis & Lichen Planus',
    'Scabies & Infestations',
    'Seborrheic Keratoses & Benign Tumors',
    'Systemic Disease',
    'Tinea, Ringworm & Fungal Infections',
    'Urticaria (Hives)',
    'Vascular Tumors',
    'Vasculitis',
    'Warts, Molluscum & Viral Infections',
  ];

  // ── Condition descriptions ────────────────────
  static const Map<String, String> conditionDescriptions = {
    'Acne and Rosacea':
        'Common skin conditions causing pimples, redness, and inflammation. Often treatable with topical medications.',
    'Actinic Keratosis & Malignant Lesions':
        'Pre-cancerous rough patches caused by sun exposure. May require medical treatment.',
    'Atopic Dermatitis':
        'Chronic eczema causing itchy, inflamed skin. Often linked to allergies and immune response.',
    'Bullous Disease':
        'Blistering conditions that form fluid-filled sacs on skin. May require systemic treatment.',
    'Cellulitis & Bacterial Infections':
        'Bacterial skin infections causing redness, swelling, and pain. Usually treated with antibiotics.',
    'Eczema':
        'Inflammatory skin condition causing redness and itching. Often managed with moisturizers and steroids.',
    'Exanthems and Drug Eruptions':
        'Widespread rash often caused by viral infections or medication reactions.',
    'Hair Loss & Alopecia':
        'Conditions causing partial or complete hair loss. Multiple types exist with different treatments.',
    'Herpes, HPV & STDs':
        'Viral skin infections. Requires medical evaluation and appropriate treatment.',
    'Light Diseases & Pigmentation':
        'Skin conditions affecting pigmentation, often triggered by sun exposure.',
    'Lupus & Connective Tissue':
        'Autoimmune conditions affecting skin and connective tissues. Requires specialist care.',
    'Melanoma, Nevi & Moles':
        'Pigmented skin lesions. Melanoma is serious — seek medical evaluation urgently.',
    'Nail Fungus & Nail Disease':
        'Fungal or structural nail infections. Usually treated with antifungal medications.',
    'Poison Ivy & Contact Dermatitis':
        'Allergic skin reaction from contact with irritants or allergens.',
    'Psoriasis & Lichen Planus':
        'Chronic inflammatory skin conditions causing scaly patches and plaques.',
    'Scabies & Infestations':
        'Parasitic skin infestations causing intense itching. Treated with prescription medications.',
    'Seborrheic Keratoses & Benign Tumors':
        'Benign skin growths. Usually harmless but can be removed for cosmetic reasons.',
    'Systemic Disease':
        'Skin manifestations of internal diseases. Requires comprehensive medical evaluation.',
    'Tinea, Ringworm & Fungal Infections':
        'Fungal skin infections. Usually treated with topical or oral antifungal medications.',
    'Urticaria (Hives)':
        'Itchy welts on skin, often caused by allergic reactions. Usually temporary.',
    'Vascular Tumors':
        'Blood vessel abnormalities in skin. Range from benign birthmarks to conditions needing treatment.',
    'Vasculitis':
        'Inflammation of blood vessels in skin. Requires medical investigation.',
    'Warts, Molluscum & Viral Infections':
        'Viral skin conditions causing growths or lesions. Many resolve on their own.',
  };

  // ── Urgency levels ────────────────────────────
  static const Map<String, String> conditionUrgency = {
    'Acne and Rosacea': 'low',
    'Actinic Keratosis & Malignant Lesions': 'high',
    'Atopic Dermatitis': 'medium',
    'Bullous Disease': 'high',
    'Cellulitis & Bacterial Infections': 'high',
    'Eczema': 'low',
    'Exanthems and Drug Eruptions': 'medium',
    'Hair Loss & Alopecia': 'low',
    'Herpes, HPV & STDs': 'high',
    'Light Diseases & Pigmentation': 'low',
    'Lupus & Connective Tissue': 'high',
    'Melanoma, Nevi & Moles': 'high',
    'Nail Fungus & Nail Disease': 'low',
    'Poison Ivy & Contact Dermatitis': 'low',
    'Psoriasis & Lichen Planus': 'medium',
    'Scabies & Infestations': 'medium',
    'Seborrheic Keratoses & Benign Tumors': 'low',
    'Systemic Disease': 'high',
    'Tinea, Ringworm & Fungal Infections': 'low',
    'Urticaria (Hives)': 'medium',
    'Vascular Tumors': 'medium',
    'Vasculitis': 'high',
    'Warts, Molluscum & Viral Infections': 'low',
  };
}
