import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:text_recognition/data/skincare_prod.dart';
import 'package:text_recognition/prod_saved.dart';
import 'dart:math';
import 'result_page.dart';
import './models/preprocess_ingredient.dart';
import './data/intermediate_data.dart'; // Import the intermediate_data.dart

class EditIngredientsPage extends StatefulWidget {
  final String initialIngredients;

  const EditIngredientsPage({Key? key, required this.initialIngredients})
      : super(key: key);

  @override
  _EditIngredientsPageState createState() => _EditIngredientsPageState();
}

class _EditIngredientsPageState extends State<EditIngredientsPage> {
  late TextEditingController _ingredientsController;

  @override
  void initState() {
    super.initState();
    _ingredientsController =
        TextEditingController(text: widget.initialIngredients);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Ingredients", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 21, 92, 42),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: TextField(
                controller: _ingredientsController,
                maxLines: null, // Allow unlimited lines
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Ingredient List",
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Save edited ingredients and pop the page
                final editedIngredients = _ingredientsController.text;
                Navigator.pop(context, editedIngredients);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 21, 92, 42),
              ),
              child: const Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScanPage extends StatefulWidget {
  final SurveyController surveyController;

  const ScanPage({Key? key, required this.surveyController}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool textScanning = false;
  XFile? imageFile;
  String scannedText = "";
  final TextEditingController _productNameController = TextEditingController();
  String selectedProductType = 'Cleanser';
  String productName = '';
  final fb = FirebaseDatabase.instance;
  bool isLoading = false; // Add loading state


  @override
  Widget build(BuildContext context) {
    var rng = Random();
    var k = rng.nextInt(10000);
    final ref = fb.ref().child('skincareProd/$k');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Scan Ingredients",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 21, 92, 42),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //_buildProductInfoInput(),
                //const SizedBox(height: 20),
                if (textScanning) const CircularProgressIndicator(),
                const SizedBox(height: 20),
                _buildImageContainer(),
                const SizedBox(height: 20),
                _buildActionButtons(),                   
                const SizedBox(height: 20),
                _buildScannedTextContainer(),
                const SizedBox(height: 20),
                _buildBannerAd(), // Add the banner ad here
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          setState(() {
            isLoading = true; // Start loading
          });
          final prediction = await widget.surveyController.predict();

          setState(() {
            isLoading = false; // Stop loading
          });

          await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ResultPage(
                      scannedText: widget.surveyController.surveyData.ingredients,
                      metrics: (prediction['metrics'] as Map<String, dynamic>).cast<String, double>(), // Cast metrics correctly
                      ingredientCategory: (prediction['ingredientCategory'] as Map<String, dynamic>).cast<String, String>(), // Cast categories correctly
                      prediction: prediction['prediction'],
                      trueLabels: prediction['true_labels'],
                      surveyController: widget.surveyController, // Pass true_labels
                    ),
                  ),
                );

        },
        backgroundColor: Color.fromARGB(255, 21, 92, 42),
        icon: isLoading 
          ? CircularProgressIndicator(color: Colors.white) // Show loading indicator when loading
          : Icon(Icons.search, color: Colors.white),
        label: isLoading 
          ? Text("Analyzing...", style: TextStyle(color: Colors.white)) // Show analyzing text when loading
          : Text("Analyze", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildProductInfoInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _productNameController,
          onChanged: (value) {
            setState(() {
              productName = value;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Product Name",
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedProductType,
          onChanged: (newValue) {
            setState(() {
              selectedProductType = newValue!;
            });
          },
          items: [
            'Cleanser', 'Toner', 'Serum', 'Moisturizer', 'Sunscreen', 'Other'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Product Type",
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    super.dispose();
  }

  Widget _buildImageContainer() {
    return Container(
      height: scannedText.isNotEmpty ? 50 : 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.7)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (imageFile != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(imageFile!.path),
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Icon(
              Icons.image,
              size: 80,
              color: Colors.grey,
            ),
          if (imageFile != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  setState(() {
                    imageFile = null;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton("Gallery", Icons.image, () {
          getImage(ImageSource.gallery);
        }),
        const SizedBox(width: 16),
        _buildActionButton("Camera", Icons.camera_alt, () {
          getImage(ImageSource.camera);
        }),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 21, 92, 42),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedTextContainer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.7)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              scannedText.isNotEmpty
                  ? "Ingredient List:\n$scannedText"
                  : "Scan an image to get ingredients.",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 12),
            if (scannedText.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  _navigateToEditIngredients(scannedText);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 21, 92, 42),
                ),
                child: const Text(
                  "Edit Ingredients",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  void _navigateToEditIngredients(String initialIngredients) async {
    final editedIngredients = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditIngredientsPage(
          initialIngredients: initialIngredients,
        ),
      ),
    );

    if (editedIngredients != null && editedIngredients != scannedText) {
      setState(() {
        scannedText = editedIngredients;
        widget.surveyController.updateIngredients(editedIngredients); // Update the controller with edited ingredients
      });
    }
  }
     



  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        textScanning = true;
        imageFile = pickedImage;
        setState(() {});

        await _cropImage(XFile(pickedImage.path));

        getRecognisedText(XFile(imageFile!.path));
      }
    } catch (e) {
      textScanning = false;
      imageFile = null;
      scannedText = "Error occurred while scanning";
      setState(() {});
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textDetector = GoogleMlKit.vision.textRecognizer();

    try {
      RecognizedText recognisedText =
          await textDetector.processImage(inputImage);

      scannedText = "";
      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          scannedText = scannedText + line.text + "\n";
        }
      }
      widget.surveyController.updateIngredients(scannedText);
    setState(() {});
    } catch (e) {
      scannedText = "Error occurred while processing the image.";
    } finally {
      textScanning = false;
      await textDetector.close();
      setState(() {});
    }
  }

  Future<void> _cropImage(XFile imgFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imgFile.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "Crop Image",
          toolbarColor: Color.fromARGB(255, 21, 92, 42),
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: "Crop Image",
        ),
      ],
    );
    if (croppedFile != null) {
      imageCache.clear();
      setState(() {
        imageFile = XFile(croppedFile.path);
      });
    }
  }

  //bannerAd (Monetization Strategy)
  Widget _buildBannerAd() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.7)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/watson_promotion.png', // Adjust the path as needed
          fit: BoxFit.cover,
        ),
      ),
    );
  }


}




