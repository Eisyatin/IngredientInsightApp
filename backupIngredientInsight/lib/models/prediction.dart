import 'package:flutter/material.dart';
import 'api_service.dart';

class PredictScreen extends StatefulWidget {
  @override
  _PredictScreenState createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final ApiService apiService = ApiService();
  bool isLoading = false;
  String result = '';
  bool breastfeeding = false;
  List<String> allergicIngre = [];

  final TextEditingController skinTypeController = TextEditingController();
  final TextEditingController skinConcernsController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  final TextEditingController allergicIngreController = TextEditingController();

  void predict() async {
    setState(() {
      isLoading = true;
      result = '';
    });

    try {
      final skinType = skinTypeController.text;
      final skinConcerns = skinConcernsController.text.split(',');
      final ingredients = ingredientsController.text;
      allergicIngre = allergicIngreController.text.split(',');

      print('Sending prediction request...');
      print('Skin Type: $skinType');
      print('Skin Concerns: $skinConcerns');
      print('Ingredients: $ingredients');
      print('Breastfeeding: $breastfeeding');
      print('Allergic Ingredients: $allergicIngre');

      final response = await apiService.predictSkinCare(
        skinType: skinType,
        skinConcerns: skinConcerns,
        ingredients: ingredients,
        breastfeeding: breastfeeding,
        allergicIngre: allergicIngre,
      );

      print('Received response: $response');

      setState(() {
        result = response.toString();
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        result = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predict Skincare'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: skinTypeController,
              decoration: InputDecoration(labelText: 'Skin Type'),
            ),
            TextField(
              controller: skinConcernsController,
              decoration: InputDecoration(labelText: 'Skin Concerns (comma separated)'),
            ),
            TextField(
              controller: ingredientsController,
              decoration: InputDecoration(labelText: 'Ingredients (comma separated)'),
            ),
            TextField(
              controller: allergicIngreController,
              decoration: InputDecoration(labelText: 'Allergic Ingredients (comma separated)'),
            ),
            SwitchListTile(
              title: Text("Breastfeeding"),
              value: breastfeeding,
              onChanged: (bool value) {
                setState(() {
                  breastfeeding = value;
                });
              },
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: predict,
                    child: Text('Predict'),
                  ),
            SizedBox(height: 20),
            if (result.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(result),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
