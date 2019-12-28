import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatApp{
  static SharedPreferences sharedPreferences;
  static FirebaseUser user;
  static FirebaseAuth auth;
  static String signInText = "Sign in using Phone Number";
  static String tapButton = "Tap Next to verify your account with phone number. "
      "You don`t need to enter verification code manually if number is installed in your phone";

}
