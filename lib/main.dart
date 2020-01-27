import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customersupport/SignInPage/OtpScreen.dart';
import 'package:customersupport/Config/config.dart';
import 'package:customersupport/VerifyPage/landingPage.dart';
import 'package:customersupport/VerifyPage/landingPageUI.dart';
import 'package:customersupport/PersonalInformation/namephoto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   ChatApp.sharedPreferences = await SharedPreferences.getInstance();
   ChatApp.auth = FirebaseAuth.instance;
   ChatApp.firestore = Firestore.instance;
   runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.red
      ),
      home:
      //PersonalInfo()
      LandingPage()
    );
  }
}