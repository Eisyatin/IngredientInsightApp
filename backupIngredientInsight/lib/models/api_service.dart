import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.62.8.39:5000";

  Future<Map<String, dynamic>> predictSkinCare({
    required String skinType,
    required List<String> skinConcerns,
    required String ingredients,
    bool breastfeeding = false,
    List<String> allergicIngre = const [],
    List<bool> trueLabels = const [],
  }) async {
    final url = Uri.parse("$baseUrl/predict");
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'skin_type': skinType,
      'skin_concerns': skinConcerns,
      'ingredients': ingredients,
      'breastfeeding': breastfeeding,
      'allergicIngre': allergicIngre,
      'true_labels': trueLabels,
    });

    print('Sending request to: $url');
    print('Request body: $body');

    final response = await http.post(url, headers: headers, body: body);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print('Response data: $responseData');  // Add this line
      return responseData;
    } else {
      throw Exception("Failed to predict skincare: ${response.body}");
    }
  }
}


