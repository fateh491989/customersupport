import 'package:customersupport/Config/config.dart';
import 'package:customersupport/Dialogs/errorDialog.dart';
import 'package:customersupport/Dialogs/loadingDialog.dart';
import 'package:customersupport/WIdgets/redButton.dart';
import 'package:customersupport/PersonalInformation/namephoto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import '../Chat/chat.dart';

class OtpScreen extends StatefulWidget {
  final String verificationID;

  const OtpScreen({Key key, this.verificationID}) : super(key: key);

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _smsController = TextEditingController();
  String _message;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Text(
            "Verify ${ChatApp.sharedPreferences.getString(ChatApp.userPhoneNumber)}",
            style: TextStyle(
                color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: RichText(
                // text: "",
                textAlign: TextAlign.center,
                text: TextSpan(
                    text:
                        "Waiting to automatically detect an SMS sent to Verify ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text:
                            "Verify ${ChatApp.sharedPreferences.getString(ChatApp.userPhoneNumber)}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      )
                    ]),
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
                onSubmit: (String pin) {
                  _smsController.text = pin;
                },
              ),
            ),
          ),
          Text(
            "Enter 6-digit code",
            style: TextStyle(color: Colors.grey),
          ),
          Container(
            margin: EdgeInsets.only(top: 50),
            child: RedButton(
              title: ChatApp.signIn,
              screenWidth: _screenWidth * 0.9,
              onTap: _signInWithPhoneNumber,
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

  void _signInWithPhoneNumber() async {
    showDialog(
        context: context,
        builder: (_) {
          return LoadingAlertDialog();
        });
    print(widget.verificationID);
    print(_smsController.text);
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: widget.verificationID,
      smsCode: _smsController.text,
    );
    FirebaseUser user;
    await ChatApp.auth.signInWithCredential(credential).then((u) async {
      user = u.user;
      final FirebaseUser currentUser = await ChatApp.auth.currentUser();
      assert(user.uid == currentUser.uid);
      if (user != null) {
        _message = 'Successfully signed in, uid: ' + user.uid;
        //TODO
        print(_message);
        // Writing data  to database
        ChatApp.firestore
            .collection(ChatApp.collectionUser)
            .document(user.uid)
            .setData({
          ChatApp.userUID: user.uid,
          ChatApp.userPhoneNumber:
              ChatApp.sharedPreferences.getString(ChatApp.userPhoneNumber),
        });
        Navigator.push(
            context, MaterialPageRoute(builder: (builder) => PersonalInfo()));
      } else {
        _message = 'Sign in failed';
      }
    }).catchError((error) {
      print("bh");
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (v) {
            return ErrorAlertDialog(
              message: 'Phone number verification failed.',
            );
          });
    });
  }
}
