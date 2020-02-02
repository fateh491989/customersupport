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
    // TODO Replace this button with your own button
    return Material(
      child: Center(
        child: RaisedButton(onPressed: (){
          ChatApp.firestore.collection(ChatApp.collectionAdmin).getDocuments().then((document){
            print(document.documents[0].data[ChatApp.userUID]);
          Route route = MaterialPageRoute(
              builder: (builder) => Chat(
                // TODO Change peerID with admin ID
                peerId: document.documents[0].data[ChatApp.userUID],
                userID: ChatApp.sharedPreferences.getString(ChatApp.userUID),
              ));
          Navigator.push(context, route);
          });
        },
          child: Text('Chat'),
        ),
      ),
    );
  }
}
