import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatApp{
  static SharedPreferences sharedPreferences;
  static FirebaseUser user;
  static FirebaseAuth auth;
  static Firestore firestore ;





  //  Note: If you change values here,, then you also have to change in cloud functions
  // Firebase Collection name
  static String collectionUser = "allUsers";
  static String collectionMessage = "messages";
  static String collectionAdmin = "admin";


  // App Info
  static String version = 'Version 1.0.0';
  //Strings
  static String signInText = "Sign in using Phone Number";
  static String signIn = "Sign In";
  static String next = "Next";
  static String tapButton  = "Tap Next to verify your account with phone number. "
      "You don`t need to enter verification code manually if number is installed in your phone";
  static String enterPhoneNumber  = "Enter your phone number";
  static String sendSMS  = "We will send an SMS message to verify your phone number.";
  static String enterName  = "Enter your name";
  static String done  = "Done";
//  static String enterPhoneNumber  = "Enter your phone number";
//  static String enterPhoneNumber  = "Enter your phone number";
//  static String enterPhoneNumber  = "Enter your phone number";
//  static String enterPhoneNumber  = "Enter your phone number";
//  static String enterPhoneNumber  = "Enter your phone number";
//  static String enterPhoneNumber  = "Enter your phone number";


  //  Note: If you change values here,, then you also have to change in cloud functions
 // User Detail
  static final String userName = 'name';
  static final String userPhoneNumber = 'phoneNumber';
  static final String userPhotoUrl = 'photoUrl';
  static final String userUID = 'uid';
  static final String userLastSeen = 'lastseen';
  static final String isTyping = 'isTyping';
  static final String isOnline = 'isOnline';
  static final String userToken = 'userToken';
  static final String userChattingWith = 'chattingWith';
}




class UserMessage{
  //  Note: If you change values here,, then you also have to change in cloud functions
  static final String count = 'count';
  static final String idFrom = 'idFrom';
  static final String idTo = 'idTo';
  static final String timestamp = 'timestamp';
  static final String content = 'content';
  static final String type = 'type';


}
