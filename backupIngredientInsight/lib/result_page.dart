import 'package:flutter/material.dart';
import '../data/saved_prod.dart';
import 'package:text_recognition/dashboard_page.dart';
import '../data/intermediate_data.dart';

class ResultPage extends StatefulWidget {
  final String scannedText;
  final Map<String, double> metrics;
  final Map<String, String> ingredientCategory;
  final Map<String, dynamic> prediction;
  final List<dynamic> trueLabels;
  final SurveyController surveyController;

  ResultPage({
    required this.scannedText,
    required this.metrics,
    required this.ingredientCategory,
    required this.prediction,
    required this.trueLabels,
    required this.surveyController,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _showFullIngredients = false;
  late bool isSuitable;
  late String suitabilityMessage;

  @override
  void initState() {
    super.initState();
    _calculateSuitability();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showMockAdDialog());
  }

  void _calculateSuitability() {
    final alertBF = widget.prediction['alertBF'] as List<dynamic>;
    final alertAll = widget.prediction['alertAll'] as List<dynamic>;
    final predictions = (widget.prediction['predictions'] as Map<String, dynamic>).map((key, value) => MapEntry(key, value as bool));
    final allConcerns = [
      'uneven_texture', 'elasticity', 'dullness', 'darkspot', 'pores',
      'puffiness', 'wrinkles', 'acne', 'redness'
    ];
    final trueLabels = widget.trueLabels.cast<bool>();

    // Create a map of trueLabels similar to predictions
    final trueLabelsMap = Map.fromIterables(allConcerns, trueLabels);

    print('AlertBF: $alertBF');
    print('AlertAll: $alertAll');
    print('Predictions: $predictions');
    print('True Labels Map: $trueLabelsMap'); // Updated

    List<String> matchedConcerns = [];
    List<String> unmatchedConcerns = [];

    if (alertBF.isNotEmpty || alertAll.isNotEmpty) {
      isSuitable = false;
      suitabilityMessage = "This product is not suitable for you.";
    } else {
      for (var concern in allConcerns) {
        if (trueLabelsMap[concern] == true) {
          if (predictions[concern] == true) {
            matchedConcerns.add(concern);
          } else {
            unmatchedConcerns.add(concern);
          }
        }
      }

      if (matchedConcerns.isNotEmpty) {
        isSuitable = true;
        if (matchedConcerns.length == 1) {
          suitabilityMessage = "This product matches your skin concern: ${matchedConcerns[0]}.";
        } else {
          final last = matchedConcerns.removeLast();
          suitabilityMessage = "This product matches your skin concerns: ${matchedConcerns.join(', ')} and $last.";
        }
      } else {
        isSuitable = false;
        if (unmatchedConcerns.length == 1) {
          suitabilityMessage = "This product does not match your skin concern: ${unmatchedConcerns[0]}.";
        } else if (unmatchedConcerns.length > 1) {
          final last = unmatchedConcerns.removeLast();
          suitabilityMessage = "This product does not match your skin concerns: ${unmatchedConcerns.join(', ')} and $last.";
        } else {
          suitabilityMessage = "This product does not match your skin concerns.";
        }
      }
    }

    print('Matched Concerns: $matchedConcerns');
    print('Unmatched Concerns: $unmatchedConcerns');
    print('Suitability: $isSuitable');
    print('Suitability Message: $suitabilityMessage');
  }

  void _showMockAdDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 400,  // Adjust height as needed
                child: Image.asset(
                  'assets/interstitials_ads.png', // Replace with your image path
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('Ingredient categories: ${widget.ingredientCategory}');  // Add this line

    return Scaffold(
      appBar: AppBar(
        title: Text('Result Page'),
        backgroundColor: Color(0xFF155C2A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIngredientsCard(),
              SizedBox(height: 16),
              _buildSuitabilityCard(),
              if (widget.prediction['alertAll'].isNotEmpty) SizedBox(height: 16),
              if (widget.prediction['alertAll'].isNotEmpty) _buildAlertCard(
                title: 'Allergy Alert',
                items: widget.prediction['alertAll'],
                alertColor: Colors.red[100]!,
                noAlertMessage: 'Contains No Allergens for you',
              ),
              if (widget.prediction['alertBF'].isNotEmpty) SizedBox(height: 16),
              if (widget.prediction['alertBF'].isNotEmpty) _buildAlertCard(
                title: 'Breastfeeding Alert',
                items: widget.prediction['alertBF'],
                alertColor: Colors.red[100]!,
                noAlertMessage: 'Contains No Harmful Ingredients for breastfeeding woman',
              ),
              SizedBox(height: 16),
              _buildSaveButton(),
              SizedBox(height: 16),
              _buildMetricScore(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsCard() {
    final ingredientsList = widget.scannedText
        .replaceAll('\n', ', ') // Ensure newlines are replaced with commas
        .split(RegExp(r',\s+'));

    print('Ingredients list: $ingredientsList');  // Add this line

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'List Ingredients',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            _buildIngredientsList(ingredientsList),
            if (ingredientsList.length > 5)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showFullIngredients = !_showFullIngredients;
                    print('Result Page (line92): $_showFullIngredients ');
                  });
                },
                child: Text(_showFullIngredients ? 'Show Less' : 'Read more...'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsList(List<String> ingredients) {
    final displayIngredients = _showFullIngredients ? ingredients : ingredients.take(5).toList();
    Map<String, List<String>> categorizedIngredients = {};
    print('result page (line 106): $ingredients');  // Debugging line

    for (var ingredient in displayIngredients) {
      // Trim and clean up the ingredient
      var cleanedIngredient = ingredient.trim().replaceAll(RegExp(r'[^\w\s]+'), '').toLowerCase().replaceAll(RegExp(r'\s+'), '_');
      var category = widget.ingredientCategory[cleanedIngredient];
      print('Checking ingredient: $cleanedIngredient, Category: $category');  // Debugging line
      if (category != null && category.isNotEmpty && category != 'Unknown') {
        if (!categorizedIngredients.containsKey(category)) {
          categorizedIngredients[category] = [];
        }
        categorizedIngredients[category]!.add(ingredient.trim());
      }
    }

    print('Categorized ingredients: $categorizedIngredients');  // Debugging line

    List<Widget> ingredientWidgets = [];
    categorizedIngredients.forEach((category, ingredients) {
      ingredientWidgets.add(Text(
        '$category:',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ));
      ingredientWidgets.add(SizedBox(height: 5));
      ingredientWidgets.addAll(
        ingredients.map((ingredient) {
          return Tooltip(
            message: 'Description', // You can update this with actual descriptions if available
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                ingredient,
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }).toList(),
      );
      ingredientWidgets.add(SizedBox(height: 10));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredientWidgets,
    );
  }

  Widget _buildAlertCard({
    required String title,
    required List<dynamic> items,
    required Color alertColor,
    required String noAlertMessage,
  }) {
    bool hasItems = items.isNotEmpty;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: hasItems ? alertColor : Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hasItems ? title : noAlertMessage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: hasItems ? Colors.red : Colors.black,
              ),
            ),
            if (hasItems) ...[
              SizedBox(height: 10),
              ...items.map((item) => Text(
                item,
                style: TextStyle(fontSize: 16, color: Colors.red),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuitabilityCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suitability Result',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              suitabilityMessage,
              style: TextStyle(
                fontSize: 16,
                color: isSuitable ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: () {
        _showSaveDialog();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF155C2A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.save, color: Colors.white),
          SizedBox(width: 8),
          Text("SAVE", style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  void _showSaveDialog() {
    final TextEditingController _productNameController = TextEditingController();
    final TextEditingController _productTypeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Save Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Product Name'),
                controller: _productNameController,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Product Type'),
                controller: _productTypeController,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _saveProductToDatabase(
                  _productNameController.text,
                  _productTypeController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF155C2A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _saveProductToDatabase(String name, String type) {
  final product = SavedProduct(
    name: name,
    type: type,
    date: DateTime.now(),
    result: {
      'scannedText': widget.scannedText,
      'metrics': widget.metrics ?? {},
      'ingredientCategory': widget.ingredientCategory ?? {},
      'prediction': widget.prediction ?? {},
      'trueLabels': widget.trueLabels ?? [],
    },
  );

  // Use SurveyData from SurveyController
  final surveyData = widget.surveyController.getSurveyData();

  // Navigate to Dashboard Page with saved product
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => DashboardPage(
        surveyData: surveyData,
        savedProducts: [product],
        surveyController: widget.surveyController, // Pass SurveyController
      ),
    ),
  );
}



  Widget _buildMetricScore() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Metrics:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'F1-Micro Score: ${widget.metrics['f1_micro']?.toStringAsFixed(2) ?? 'N/A'}%',
            style: TextStyle(fontSize: 16),
          ),
          // Add other metrics if needed
        ],
      ),
    );
  }
}
