import 'package:customersupport/Chat/chatScreen.dart';
import 'package:flutter/material.dart';

Color bg = Colors.black;
// TODO Change bg color
class Chat extends StatelessWidget {
  final String peerId, userID;

  Chat({
    Key key,
    @required this.peerId,
    @required this.userID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Customer Support'),
          centerTitle: false,
//          leading: Container(
//            height: 0,
//            width: 0,
//          ),
        ),
        backgroundColor: bg,
        body: ChatScreen(
          userID: userID,
          adminId: peerId,
        ),
      ),
    );
  }
}
