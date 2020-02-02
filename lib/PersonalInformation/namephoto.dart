import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customersupport/Chat/chat.dart';
import 'package:customersupport/Config/config.dart';
import 'package:customersupport/Dialogs/loadingDialog.dart';
import 'package:customersupport/WIdgets/redButton.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../Dialogs/errorDialog.dart';
import '../openChat.dart';

const String adminIDCustom = 'pMnJ6bGY3DO5UqK3Pf57mOf6LJL2';

class PersonalInfo extends StatefulWidget {
  @override
  _PersonalInfoState createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  @override
  Widget build(BuildContext context) {
    return PersonalInfoScreen();
  }
}

class PersonalInfoScreen extends StatefulWidget {
  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  String userPhotoUrl = "";
  File _image;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Stack(
              children: <Widget>[
                InkWell(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: _screenWidth * 0.15,
                      backgroundColor: Colors.white,
                      child: _image == null
                          ? Icon(
                              Icons.person_add,
                              size: _screenWidth * 0.15,
                              color: Colors.grey,
                            )
                          : Image.file(_image),
//                        backgroundImage: _image == null
//                            ? AssetImage('assets/images/loading.png')
//                            : FileImage(_image)
                    )),
                Positioned(
                    top: _screenWidth * 0.20,
                    left: _screenWidth * 0.20,
                    child: IconButton(
                        icon: Icon(
                          Icons.camera_enhance,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: _pickImage))
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _nameController,
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: Icon(
                      Icons.edit,
                      color: Theme.of(context).primaryColor,
                    ),
                    focusColor: Theme.of(context).primaryColor,
                    hintText: ChatApp.enterName),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50),
              child: RedButton(
                  title: ChatApp.done,
                  screenWidth: _screenWidth * 0.9,
                  onTap: uploadImage),
            ),
            Flexible(child: Container()),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(ChatApp.version),
              ),
            ),
            //RaisedButton(onPressed: uploadImage)
          ],
        ),
      ),
    );
  }

  Future<void> uploadImage() async {
    if (_image == null) {
      showDialog(
          context: context,
          builder: (v) {
            return ErrorAlertDialog(
              message: "Please pick an photo",
            );
          });
    } else if (_nameController.text == '') {
      showDialog(
          context: context,
          builder: (v) {
            return ErrorAlertDialog(
              message: "Please add your name",
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (_) {
            return LoadingAlertDialog();
          });
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      StorageReference reference =
          FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = reference.putFile(_image);
      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
      await storageTaskSnapshot.ref.getDownloadURL().then((url) {
        userPhotoUrl = url;
        print(userPhotoUrl);
        _completeRegister();
      });
    }
  }

  Future<void> _completeRegister() async {
    String lastSeen = DateTime.now().millisecondsSinceEpoch.toString();
    await ChatApp.sharedPreferences.setString(ChatApp.userLastSeen, lastSeen);
    await ChatApp.sharedPreferences
        .setString(ChatApp.userName, _nameController.text);
    await ChatApp.sharedPreferences
        .setString(ChatApp.userPhotoUrl, userPhotoUrl);
    ChatApp.firestore
        .collection(ChatApp.collectionUser)
        .document(ChatApp.sharedPreferences.getString(ChatApp.userUID))
        .updateData({
      ChatApp.userLastSeen: lastSeen,
      ChatApp.userName: _nameController.text,
      ChatApp.userPhotoUrl: userPhotoUrl,
      ChatApp.isOnline: true
    }).then((_) async {
//      String adminUID;
//      QuerySnapshot snapshot = await Firestore.instance
//          .collection('admin')
//          .orderBy('lastPersonHandlingtime', descending: true)
//          .where('isWorking', isEqualTo: false)
//          .getDocuments();
//      if(snapshot.documents.length==0){
//          adminUID = null;
//      }
//      else{
//        adminUID = snapshot.documents[0].documentID;
//      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (builder) => StartChat(
                    // TODO Change peerID with admin ID
                    //user: ChatApp.sharedPreferences.getString("Uid")
                  )));
    });
  }

  Future<void> _pickImage() async {
    _image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }
}
