import 'package:customersupport/Chat/chat.dart';
import 'package:customersupport/Config/config.dart';
import 'package:customersupport/PersonalInformation/namephoto.dart';
import 'package:customersupport/VerifyPage/landingPageUI.dart';
import 'package:flutter/material.dart';

import '../openChat.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}
class _LandingPageState extends State<LandingPage> {

  @override
  void initState() {
    super.initState();
    readLocal();
  }
  readLocal() async {
    if(await ChatApp.auth.currentUser()!= null){
      Route route = MaterialPageRoute(
          builder: (builder) => StartChat());
      Navigator.push(context, route);
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PhoneAuthScreen(),
      ),
    );
  }
}

