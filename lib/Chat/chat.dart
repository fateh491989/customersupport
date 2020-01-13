import 'package:customersupport/Screen/chatScreen.dart';
import 'package:flutter/material.dart';

Color bg = Colors.black;
// TODO Change bg color
class Chat extends StatelessWidget {
  final String peerId, user;

  Chat({
    Key key,
    @required this.peerId,
    @required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Scaffold(
        backgroundColor: bg,
        body: new ChatScreen(
          user: user,
          adminId: peerId,
        ),
      ),
    );
  }
}
