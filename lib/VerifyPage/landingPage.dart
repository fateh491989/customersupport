import 'package:customersupport/Chat/chat.dart';
import 'package:customersupport/Config/config.dart';
import 'package:customersupport/VerifyPage/landingPageUI.dart';
import 'package:flutter/material.dart';

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
          builder: (builder) => Chat(
            // TODO Change peerID with admin ID
            peerId: '8mNiz9rQGHRLzNabKhBzT6emC762',
            userID: ChatApp.sharedPreferences.getString(ChatApp.userUID),
          ));
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

