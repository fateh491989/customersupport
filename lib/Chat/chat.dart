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
        backgroundColor: bg,
        body: new ChatScreen(
          userID: userID,
          adminId: peerId,
        ),
      ),
    );
  }
}
