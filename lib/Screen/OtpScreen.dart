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
          SizedBox(height: 50,),
          Text("Verify +91 7973268843",style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: RichText(
               // text: "",
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "Waiting to automatically detect an SMS sent to Verify ",
                style: TextStyle(color: Colors.black),
                children: [TextSpan(
                  text: "Verify +91 7973268843",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                )]

              ),
            )

            //Text("Waiting to automatically detect an SMS sent to Verify +91 7973268843",textAlign: TextAlign.center,),
          ),
          Container(
           // height: 70,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: PinEntryTextField(
                showFieldAsBox: true,
                fields: 6,
                onSubmit: (String pin){

                },
              ),
            ),
          ),
          Text("Enter 6-digit code",style: TextStyle(color: Colors.grey),),
          Container(
            width: _screenWidth * 0.9,
            margin: EdgeInsets.only(top: 50),
            height: 50,
            color: Colors.red,
            child: Center(
              child: Text(ChatApp.signIn),
            ),
          ),
          Flexible(child: Container()),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Version 1.0.0'),
            ),
          )
//          Container(
//            width: _screenWidth*0.8,
//            height: 60,
//            child: Center(child: Text(ChatApp.signIn),),
//          )
        ],
      ),
    );
  }
}
