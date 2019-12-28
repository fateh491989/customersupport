import 'package:customersupport/config.dart';
import 'package:flutter/material.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PinEntryTextField(
              showFieldAsBox: true,
              fields: 6,
              onSubmit: (String pin){

              },
            ),
          ),
          Container(
            width: _screenWidth*0.8,
            height: 60,
            child: Center(child: Text(ChatApp.signIn),),
          )
        ],
      ),
    );
  }
}
