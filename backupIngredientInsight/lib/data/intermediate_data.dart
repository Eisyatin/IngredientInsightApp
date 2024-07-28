import 'package:flutter/material.dart';
import '../models/api_service.dart';

class SurveyData {
  String skinType;
  List<String> skinConcerns;
  bool breastfeeding;
  List<String> allergicIngre;
  String ingredients;

  SurveyData({
    required this.skinType,
    required this.skinConcerns,
    required this.breastfeeding,
    required this.allergicIngre,
    this.ingredients = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'skin_type': skinType,
      'skin_concerns': skinConcerns,
      'breastfeeding': breastfeeding,
      'allergicIngre': allergicIngre,
      'ingredients': ingredients,
    };
  }
}

class SurveyController extends ChangeNotifier {
  final ApiService apiService = ApiService();
  SurveyData surveyData;

  SurveyController({required this.surveyData});

  SurveyData getSurveyData() {
    return surveyData;
  }

  void updateIngredients(String ingredients) {
    surveyData.ingredients = ingredients;
    print('Updated ingredients: $ingredients'); // Debug print statement
    notifyListeners();
  }

  Future<Map<String, dynamic>> predict() async {
    final List<String> allConcerns = [
      'uneven_texture', 'elasticity', 'dullness', 'darkspot', 'pores',
      'puffiness', 'wrinkles', 'acne', 'redness'
    ];

    final trueLabels = allConcerns.map((concern) => surveyData.skinConcerns.contains(concern)).toList();

    print('Entering predict function');
    print('Sending data to API: ${surveyData.toJson()}'); // Debug print statement

    final response = await apiService.predictSkinCare(
      skinType: surveyData.skinType,
      skinConcerns: surveyData.skinConcerns,
      ingredients: surveyData.ingredients,
      breastfeeding: surveyData.breastfeeding,
      allergicIngre: surveyData.allergicIngre,
      trueLabels: trueLabels,
    );

    print('Received response from API: $response'); // Debug print statement

    final metrics = {
      'f1_micro': response['metrics']['f1_micro'] ?? 0.0,
      // Add other metrics if needed
    };

    final Map<String, String> ingredientCategory = Map<String, String>.from(response['categories']);
    print( 'intermediate_data (line 70): $ingredientCategory');

    return {
      'prediction': response,
      'metrics': metrics,
      'ingredientCategory': ingredientCategory, 
      'true_labels': trueLabels, // Include true_labels in the result
    };
  }
}
