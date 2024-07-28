import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import './authentication/authpage.dart';
// import 'package:animated_emoji/animated_emoji.dart';
import 'package:text_recognition/main.dart';
import 'package:text_recognition/scanPage.dart';
import 'survey.dart'; // Ensure this import is correct

class Splash extends StatefulWidget {
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(Duration(seconds: 5), () {
      // Pass the mock userID here
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SkinSurvey(userID: 'mockUserID')),
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green[900],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //  AnimatedEmoji(
            //   AnimatedEmojis.loveLetter,
            //   size: 128,
            //   repeat: true,
            // ),
            Image.asset(
              'assets/logo.png', // Replace with the actual path to your image
              width: 250,
              height: 250,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Ingredient Insight",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
