//import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:google_ml_kit/google_ml_kit.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:text_recognition/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../models/prediction.dart';
import '../testing/result_test.dart';
import 'dashboard_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Splash(),
    );
  }

  
}

