import 'package:flutter/material.dart';
import 'package:text_recognition/result_page.dart';
import '../data/intermediate_data.dart';

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: TestResultPage(),
      ),
    );
  }
}

class TestResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sampleScannedText = 'Aqua, Glycerin, Myristic Acid, Palmitic Acid, Stearic Acid, Potassium Hydroxide, Lauric Acid, Glyceryl Stearate, Kaolin, PEG-14M, CI 42090 / Blue 1 Lake, CI 77492, CI 77499 / Iron Oxides, Linalool, Geraniol, Camellia Sinensis Leaf Extract, Parfum / Fragrance, Salicylic Acid, Alumina, Phenoxyethanol, Limonene, Ascorbyl Glucoside, Tetrasodium EDTA, Menthol, Dextrin, Hexyl Cinnamal';
    
    final samplePrediction = {
      'predictions': {
        'uneven_texture': false,
        'elasticity': false,
        'dullness': true,
        'darkspot': false,
        'pores': false,
        'puffiness': false,
        'wrinkles': true,
        'acne': false,
        'redness': false
      },
      'suitable': false,
      'categories': {
        'Aqua': 'solvent',
        'Glycerin': 'humectant',
        'Myristic Acid': 'surfactant',
        'Palmitic Acid': 'emollient',
        'Stearic Acid': 'emollient',
        'Potassium Hydroxide': 'pH adjuster',
        'Lauric Acid': 'surfactant',
        'Glyceryl Stearate': 'emulsifier',
        'Kaolin': 'absorbent',
        'PEG-14M': 'thickener',
        'CI 42090 / Blue 1 Lake': 'colorant',
        'CI 77492': 'colorant',
        'CI 77499 / Iron Oxides': 'colorant',
        'Linalool': 'fragrance',
        'Geraniol': 'fragrance',
        'Camellia Sinensis Leaf Extract': 'antioxidant',
        'Parfum / Fragrance': 'fragrance',
        'Salicylic Acid': 'exfoliant',
        'Alumina': 'abrasive',
        'Phenoxyethanol': 'preservative',
        'Limonene': 'fragrance',
        'Ascorbyl Glucoside': 'antioxidant',
        'Tetrasodium EDTA': 'chelating agent',
        'Menthol': 'cooling agent',
        'Dextrin': 'binding agent',
        'Hexyl Cinnamal': 'fragrance'
      },
      'alertBF': [
        'Linalool',
        'Geraniol',
        'Parfum / Fragrance',
        'Limonene',
        'Hexyl Cinnamal'
      ],
      'alertAll': []
    };

    final sampleConfidenceScores = {
      'uneven_texture': 0.8,
      'elasticity': 0.6,
      'dullness': 0.7,
      'darkspot': 0.5,
      'pores': 0.9,
      'puffiness': 0.4,
      'wrinkles': 0.6,
      'acne': 0.3,
      'redness': 0.5,
      'f1_micro': 0.8
    };

    // Extract categories from samplePrediction and cast to Map<String, String>
    final Map<String, String> ingredientCategories = (samplePrediction['categories'] as Map<dynamic, dynamic>).map((key, value) => MapEntry(key.toString(), value.toString()));

    // Create a sample SurveyController with sample data
    final surveyController = SurveyController(
      surveyData: SurveyData(
        skinType: 'dry',
        skinConcerns: ['uneven_texture', 'elasticity'],
        breastfeeding: false,
        allergicIngre: ['Parfum / Fragrance', 'Phenoxyethanol'],
      ),
    );

    return ResultPage(
      scannedText: sampleScannedText,
      metrics: sampleConfidenceScores,
      ingredientCategory: ingredientCategories,
      prediction: samplePrediction,
      trueLabels: [],
      surveyController: surveyController,
    );
  }
}
