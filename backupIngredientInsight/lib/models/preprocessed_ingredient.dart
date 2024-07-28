import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:string_similarity/string_similarity.dart';

// Read Excel file
Map<String, String> readExcelFile(String path) {
  final file = File(path).readAsBytesSync();
  final excel = Excel.decodeBytes(file);
  final Map<String, String> ingredientCategoryDict = {};
  for (var table in excel.tables.keys) {
    for (var row in excel.tables[table]!.rows.skip(1)) {
      final ingredient = row[0]?.value?.toString() ?? '';
      final category = row[1]?.value?.toString() ?? '';
      ingredientCategoryDict[ingredient] = category;
    }
  }
  return ingredientCategoryDict;
}

// Fuzzy match ingredient
String fuzzyMatchIngredient(String token, Map<String, String> ingredientDict, double threshold) {
  double highestScore = 0.0;
  String bestMatch = token;
  ingredientDict.forEach((ingredient, category) {
    final score = token.similarityTo(ingredient);
    print('Comparing "$token" with "$ingredient": $score'); // Debug print
    if (score > highestScore && score >= threshold) {
      highestScore = score;
      bestMatch = ingredient;
    }
  });
  return bestMatch;
}

// Preprocess ingredients
Map<String, dynamic> preprocessIngredients(
    String ingredients, Map<String, String> ingredientDict, Map<String, String> ingredientCategoryDict,
    {double thresholdInitial = 0.75, double thresholdSecond = 0.65}) {
  ingredients = ingredients.toLowerCase().replaceAll(RegExp(r'[0-9.*]'), '');
  final ingredientList = ingredients.split(',').map((e) => e.trim().replaceAll(' ', '_')).toList();

  final processedIngredients = <String>[];
  final categories = <String>[];
  final matchStatus = <Map<String, dynamic>>[];

  for (var token in ingredientList) {
    var processedToken = fuzzyMatchIngredient(token, ingredientDict, thresholdInitial);
    var category = ingredientCategoryDict[processedToken] ?? 'Unknown';
    var matched = token.similarityTo(processedToken) >= thresholdInitial;

    if (!matched) {
      processedToken = fuzzyMatchIngredient(token, ingredientDict, thresholdSecond);
      category = ingredientCategoryDict[processedToken] ?? 'Unknown';
      matched = token.similarityTo(processedToken) >= thresholdSecond;
    }

    processedIngredients.add(processedToken);
    categories.add(category);
    matchStatus.add({'Original_Ingredient': token, 'Processed_Ingredient': processedToken, 'Category': category, 'Match_Status': matched});
  }

  return {'Processed_Ingredients': processedIngredients, 'Categories': categories, 'Match_Status': matchStatus};
}

void main() {
  // File paths
  final ingredientDictPath = 'lib/data/Ingredient_Dictionary.xlsx';

  // Read ingredient dictionary
  final ingredientCategoryDict = readExcelFile(ingredientDictPath);

  // Example JSON input
  final jsonString = '''
  {
    "skin_type": "oily",
    "skin_concerns": ["acne", "wrinkles"],
    "ingredients": "water/aqua/eu, glycerol, butylene glycol, salicilic acid",
    "alertBF": 1
  }
  ''';

  // Parse JSON input
  final input = jsonDecode(jsonString);

  // Preprocess ingredients
  final result = preprocessIngredients(input['ingredients'], ingredientCategoryDict, ingredientCategoryDict);

  // Print results
  print("Processed Ingredients: ${result['Processed_Ingredients']}");
  print("Categories: ${result['Categories']}");
  print("Match Status: ${result['Match_Status']}");
}
