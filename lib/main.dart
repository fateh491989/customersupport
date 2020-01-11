import 'package:customersupport/Screen/OtpScreen.dart';
import 'package:customersupport/Config/config.dart';
import 'package:customersupport/VerifyPage/landingPage.dart';
import 'package:customersupport/Screen/landingPageUI.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   ChatApp.sharedPreferences = await SharedPreferences.getInstance();
   ChatApp.auth = FirebaseAuth.instance;
   runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage()
    );
  }
}