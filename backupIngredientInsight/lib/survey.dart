import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'scanPage.dart';
// import 'package:text_recognition/authentication/component/auth_service.dart';
// import 'package:text_recognition/authentication/authpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './data/intermediate_data.dart'; // Import the intermediate_data.dart


class SkinSurveyApp extends StatelessWidget {
  // For testing purposes, we can use a static user ID
  // Uncomment the following lines and implement authentication when ready
  // final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<User?>(
        // For testing, we comment out the sign-in process
        // future: _authService.signInWithGoogle(),
        future: Future.value(FirebaseAuth.instance.currentUser), // Mocked for testing
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              // Pass the userID from the authentication result
              return SkinSurvey(userID: snapshot.data!.uid);
            } else {
              // If no user is signed in, you can handle the UI accordingly
              return Center(child: Text('Failed to sign in'));
            }
          } else {
            // While the future is resolving, show a loading spinner
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class SkinSurvey extends StatefulWidget {
  final String userID;
  SkinSurvey({required this.userID});

  @override
  _SkinSurveyState createState() => _SkinSurveyState();
}

class _SkinSurveyState extends State<SkinSurvey> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // Variables to store selected answers
  int? selectedSkinType;
  List<int> selectedSkinConcerns = [];
  int? selectedBreastfeeding;
  List<String> selectedAllergies = [];

  // Firestore service instance
  final FirestoreService _firestoreService = FirestoreService();
  // final AuthService _authService = AuthService();
  // Survey controller instance
  late SurveyController surveyController;

  @override
void initState() {
  super.initState();
  surveyController = SurveyController(
    surveyData: SurveyData(
      skinType: '',
      skinConcerns: [],
      breastfeeding: false,
      allergicIngre: [],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Intelligent Skin Survey'),
        backgroundColor: Color.fromARGB(78, 233, 30, 98), // Title background color
        actions: [
          // Uncomment this part when implementing authentication
          // IconButton(
          //   icon: Icon(Icons.logout),
          //   onPressed: () async {
          //     await _authService.signOut();
          //     Navigator.of(context).pushAndRemoveUntil(
          //       MaterialPageRoute(builder: (context) => AuthPage()),
          //       (Route<dynamic> route) => false
          //     );
          //   }
          // ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                IntroCard(onContinue: _nextPage),
                SurveyCard(
                  question: "What is your skin type?",
                  options: ["Dry", "Oily", "Combination", "Normal", "Sensitive"],
                  selectedIndex: selectedSkinType,
                  onOptionSelected: (index) {
                    setState(() {
                      selectedSkinType = index;
                    });
                    _nextPage();
                  },
                ),
                MultiSelectSurveyCard(
                  question: "What is your skin concern?",
                  options: ["Uneven texture", "Elasticity", "Dullness", "Darkspot", "Pores", "Puffiness", "Wrinkles", "Acne", "Redness"],
                  selectedIndexes: selectedSkinConcerns,
                  onOptionsSelected: (indexes) {
                    setState(() {
                      selectedSkinConcerns = indexes;
                    });
                    _nextPage();
                  },
                ),
                SurveyCard(
                  question: "Are you breastfeeding?",
                  options: ["Yes", "No"],
                  selectedIndex: selectedBreastfeeding,
                  onOptionSelected: (index) {
                    setState(() {
                      selectedBreastfeeding = index;
                    });
                    _nextPage();
                  },
                ),
                AllergyCard(
                  question: "Write any allergies (optional)",
                  selectedAllergies: selectedAllergies,
                  onTextSubmitted: (allergies) {
                    setState(() {
                      selectedAllergies = allergies;
                    });
                    _nextPage();
                  },
                ),
                FinishCard(onFinish: _saveData),
              ],
            ),
          ),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      // Handle survey completion
    }
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            width: _currentPage == index ? 12.0 : 8.0,
            height: _currentPage == index ? 12.0 : 8.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index ? Colors.teal : Colors.grey,
            ),
          );
        }),
      ),
    );
  }

  // void _saveData() async {
  //   try {
  //     await _firestoreService.createSkinData(
  //       widget.userID,
  //       selectedSkinType != null ? ["Dry", "Oily", "Combination", "Normal"][selectedSkinType!] : "Unknown",
  //       selectedSkinConcerns.map((index) => ["Uneven texture", "Elasticity", "Dullness", "Darkspot", "Pores", "Puffiness", "Wrinkles", "Acne", "Redness"][index]).toList(),
  //       selectedBreastfeeding == 0, // Assuming 0 = Yes, 1 = No
  //       selectedAllergies,
  //     );
  //     print("Data saved successfully!");
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => ScanPage()),
  //     );
  //   } catch (e) {
  //     print("Error saving data: $e");
  //   }
  // }

  void _saveData() {
  surveyController.surveyData.skinType = selectedSkinType != null
      ? ["dry", "oily", "combination", "normal", "sensitive"][selectedSkinType!]
      : "Unknown";
  surveyController.surveyData.skinConcerns = selectedSkinConcerns
      .map((index) => ["uneven_texture", "elasticity", "dullness", "darkspot", "pores", "puffiness", "wrinkles", "acne", "redness"][index])
      .toList();
  surveyController.surveyData.breastfeeding = selectedBreastfeeding == 0; // Assuming 0 = Yes, 1 = No
  surveyController.surveyData.allergicIngre = selectedAllergies;

  // Debug print statements
  print('Saved Skin Type: ${surveyController.surveyData.skinType}');
  print('Saved Skin Concerns: ${surveyController.surveyData.skinConcerns}');
  print('Saved Breastfeeding: ${surveyController.surveyData.breastfeeding}');
  print('Saved Allergic Ingredients: ${surveyController.surveyData.allergicIngre}');

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ScanPage(
        surveyController: surveyController,
      ),
    ),
  );
}


}

class IntroCard extends StatelessWidget {
  final VoidCallback onContinue;

  IntroCard({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        color: Colors.green, // Card background color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Intelligent Skin Survey',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'To get the most accurate product analytics, please answer the following questions. This will help us provide the best recommendations for your skin type and concerns.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onContinue,
                child: Text('Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink, // Button color
                  padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SurveyCard extends StatelessWidget {
  final String question;
  final List<String>? options;
  final bool isTextInput;
  final String? additionalInfo;
  final int? selectedIndex;
  final Function(int)? onOptionSelected;

  SurveyCard({
    required this.question,
    this.options,
    this.isTextInput = false,
    this.additionalInfo,
    this.selectedIndex,
    this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          color: Colors.green, // Card background color
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  question,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                if (additionalInfo != null) ...[
                  SizedBox(height: 10),
                  Text(
                    additionalInfo!,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 20),
                if (isTextInput)
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter your answer',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (value) {
                      if (onOptionSelected != null) {
                        onOptionSelected!(0);
                      }
                    },
                  )
                else
                  ...?options?.asMap().entries.map((entry) {
                    int index = entry.key;
                    String option = entry.value;
                    bool isSelected = selectedIndex == index;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          if (onOptionSelected != null) {
                            onOptionSelected!(index);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: isSelected ? Colors.white : Colors.black,
                          backgroundColor: isSelected ? Colors.pink : Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(option),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MultiSelectSurveyCard extends StatefulWidget {
  final String question;
  final List<String> options;
  final List<int> selectedIndexes;
  final Function(List<int>) onOptionsSelected;

  MultiSelectSurveyCard({
    required this.question,
    required this.options,
    required this.selectedIndexes,
    required this.onOptionsSelected,
  });

  @override
  _MultiSelectSurveyCardState createState() => _MultiSelectSurveyCardState();
}

class _MultiSelectSurveyCardState extends State<MultiSelectSurveyCard> {
  late List<int> selectedIndexes;

  @override
  void initState() {
    super.initState();
    selectedIndexes = widget.selectedIndexes;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          color: Colors.green, // Card background color
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.question,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ...widget.options.asMap().entries.map((entry) {
                  int index = entry.key;
                  String option = entry.value;
                  bool isSelected = selectedIndexes.contains(index);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: CheckboxListTile(
                      title: Text(option, style: TextStyle(color: Colors.white)),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedIndexes.add(index);
                          } else {
                            selectedIndexes.remove(index);
                          }
                        });
                        widget.onOptionsSelected(selectedIndexes);
                      },
                      checkColor: Colors.white,
                      activeColor: Colors.pink,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AllergyCard extends StatefulWidget {
  final String question;
  final List<String> selectedAllergies;
  final Function(List<String>) onTextSubmitted;

  AllergyCard({required this.question, required this.selectedAllergies, required this.onTextSubmitted});

  @override
  _AllergyCardState createState() => _AllergyCardState();
}

class _AllergyCardState extends State<AllergyCard> {
  late List<String> selectedAllergies;

  final List<String> allergyOptions = [
    'Fragrance',
    'Paraben',
    'Sulfate',
    'Silicon',
  ];

  @override
  void initState() {
    super.initState();
    selectedAllergies = widget.selectedAllergies;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          color: Colors.green, // Card background color
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.question,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: allergyOptions.map((option) {
                    bool isSelected = selectedAllergies.contains(option);
                    return FilterChip(
                      label: Text(option),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedAllergies.add(option);
                          } else {
                            selectedAllergies.remove(option);
                          }
                        });
                      },
                      selectedColor: Colors.pink,
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Text(
                  'None',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Switch(
                  value: selectedAllergies.contains('None'),
                  onChanged: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedAllergies = ['None'];
                      } else {
                        selectedAllergies.remove('None');
                      }
                    });
                  },
                  activeColor: Colors.red,
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter other allergies',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        selectedAllergies.add(value);
                      }
                    });
                    widget.onTextSubmitted(selectedAllergies);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FinishCard extends StatelessWidget {
  final VoidCallback onFinish;

  FinishCard({required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          color: Colors.green, // Card background color
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Thank you for completing the survey!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: onFinish,
                  child: Text('Finish'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, // Button color
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    textStyle: TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
