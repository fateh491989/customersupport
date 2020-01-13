import 'dart:io';

import 'package:customersupport/Chat/chat.dart';
import 'package:customersupport/Config/config.dart';
import 'package:customersupport/Screen/landingPageUI.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../Screen/OtpScreen.dart';

class SignIn extends StatefulWidget {
  final String verificationId;
  SignIn(this.verificationId);

  @override
  _SignInState createState() => _SignInState();
}
class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: OtpScreen(verificationID: widget.verificationId,),
      ),
    );
  }
}

