import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:excel/excel.dart';
import 'package:string_similarity/string_similarity.dart';

Future<List<Map<String, String>>> preprocessAndMatchIngredients(String inputIngredient) async {
  // Load the Excel file from assets
  ByteData data = await rootBundle.load('assets/ingredient_dictionary.xlsx');
  var bytes = data.buffer.asUint8List();
  var excel = Excel.decodeBytes(bytes);

  // Assume the ingredients are in the first column and the IDs are in the second column
  List<Map<String, String>> ingredientDictionary = [];
  for (var table in excel.tables.keys) {
    if (excel.tables[table] != null) {
      for (var row in excel.tables[table]!.rows) {
        var ingredient = row[0]?.value.toString() ?? '';
        var id = row[1]?.value.toString() ?? '';
        ingredientDictionary.add({'ingredient': ingredient, 'id': id});
      }
    }
  }

  // Function to preprocess ingredients
  String preprocess(String ingredient) {
    ingredient = ingredient.toLowerCase();
    ingredient = ingredient.replaceAll(RegExp(r'[0-9.*]'), '');
    ingredient = ingredient.split(',').map((e) => e.trim().replaceAll(' ', '_')).join(',');
    return ingredient;
  }

  // Function to find the best match for a given ingredient and get the corresponding ID
  Map<String, String> findBestMatch(String ingredient, List<Map<String, String>> dictionary) {
    List<String> ingredients = dictionary.map((entry) => entry['ingredient']!).toList();
    var bestMatch = ingredient.bestMatch(ingredients);
    var matchedIngredient = bestMatch.bestMatch.target ?? '';
    var id = dictionary.firstWhere((entry) => entry['ingredient'] == matchedIngredient)['id']!;
    return {'ingredient': matchedIngredient, 'id': id};
  }

  // Preprocess the input ingredient
  String preprocessedIngredient = preprocess(inputIngredient);
  List<String> ingredientsToMatch = preprocessedIngredient.split(',');

  // Find matches and save the IDs
  List<Map<String, String>> matchedIngredients = [];
  for (var ingredient in ingredientsToMatch) {
    var match = findBestMatch(ingredient, ingredientDictionary);
    matchedIngredients.add(match);
  }

  return matchedIngredients;
}
