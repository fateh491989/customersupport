import 'package:flutter/material.dart';

import 'Chat/chat.dart';
import 'Config/config.dart';
import 'PersonalInformation/namephoto.dart';

class StartChat extends StatefulWidget {
  @override
  _StartChatState createState() => _StartChatState();
}

class _StartChatState extends State<StartChat> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: RaisedButton(onPressed: (){

          Route route = MaterialPageRoute(
              builder: (builder) => Chat(
                // TODO Change peerID with admin ID
                peerId: adminIDCustom,
                userID: ChatApp.sharedPreferences.getString(ChatApp.userUID),
              ));
          Navigator.push(context, route);
        }),
      ),
    );
  }
}
