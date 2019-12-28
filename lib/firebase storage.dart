//import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_database/firebase_database.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:fluttertoast/fluttertoast.dart';
//import 'package:shared_preferences/shared_preferences.dart';
//import 'package:cached_network_image/cached_network_image.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'dart:async';
//import 'dart:io';
//
//import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:image_picker/image_picker.dart';
//
//class Chat extends StatelessWidget {
//  final String peerId;
//  final String peerAvatar;
//  final String displayName;
//  FirebaseUser user;
//  Chat({Key key, @required this.peerId, @required this.peerAvatar,@required this.displayName,@required this.user }) : super(key: key);
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      appBar: new AppBar(
//        title: new Text(
//          'HYPER SUPPORT',
//          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//        ),
//        centerTitle: true,
//      ),
//      body: new ChatScreen(///////calling chat screen
//        user: user,
//        peerId: peerId,
//        peerAvatar: peerAvatar,
//      ),
//    );
//  }
//}
/////Chat SCREEN
//class ChatScreen extends StatefulWidget {
//  final String peerId;
//  final String peerAvatar;
//  final FirebaseUser user;
//  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar,@required this.user}) : super(key: key);
//
//  @override
//  State createState() => new ChatScreenState(peerId: peerId, peerAvatar: peerAvatar,user: user);
//}
///////////////////////////////////////////////Chat ScreenState
//class ChatScreenState extends State<ChatScreen> {
//  ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar,@required this.user});
//  String peerId;
//  String peerAvatar;
//  String id;
//  FirebaseUser user;
//  var listMessage;
//  String groupChatId;
//  SharedPreferences prefs;
//  File imageFile;
//  bool isLoading;
//  bool isShowSticker;
//  String imageUrl;
//  final TextEditingController textEditingController = new TextEditingController();
//  final ScrollController listScrollController = new ScrollController();
//  final FocusNode focusNode = new FocusNode();
//  @override
//  void initState() {
//    super.initState();
//    focusNode.addListener(onFocusChange);
//    groupChatId = '';
//    isLoading = false;
//    isShowSticker = false;
//    imageUrl = '';
//    readLocal();
//  }//initState()
////////////////////////////////////////////////////////////////////////not for me
//  void onFocusChange() {
//    if (focusNode.hasFocus) {
//      // Hide sticker when keyboard appear
//      setState(() {
//        isShowSticker = false;
//      });
//    }
//  }
//////////////////////////////////////////////////////////////////////////////
//  readLocal() async {
//    prefs = await SharedPreferences.getInstance();
//    id = prefs.getString('id') ?? '';
//    if (id.hashCode <= peerId.hashCode) {
//      groupChatId = '$id-$peerId';
//    } else {
//      groupChatId = '$peerId-$id';
//    }
//
//    setState(() {});
//  }
//
//  Future getImageFromCamera() async {
//    File image = await ImagePicker.pickImage(source: ImageSource.camera);
//    if (image != null) {
//      setState(() {
//        imageFile = image;
//        isLoading = true;
//        image=null;
//      });
//    }
//    uploadFile();
//  }
//
//  Future getImage() async {
//    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
//    if (image != null) {
//      setState(() {
//        imageFile = image;
//        image=null;
//        isLoading = true;
//      });
//    }
//    uploadFile();
//  }
//
//  void getSticker() {
//    // Hide keyboard when sticker appear
//    focusNode.unfocus();
//    setState(() {
//      isShowSticker = !isShowSticker;
//    });
//  }
//
//  Future uploadFile() async {
//    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
//    StorageUploadTask uploadTask = reference.putFile(imageFile);
//    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
////   Uri  downloadUrl;
////    downloadUrl= (await uploadTask.).downloadUrl ;
//    imageUrl = dowurl.toString();
//    setState(() {
//      isLoading = false;
//    });
//    onSendMessage(imageUrl, 1);
//  }
//
//  void onSendMessage(String content, int type) {
//    // type: 0 = text, 1 = image, 2 = sticker
//    if (content.trim() != '') {
//      textEditingController.clear();
//      var documentReference = Firestore.instance
//          .collection('messages')
//          .document(groupChatId)
//          .collection(groupChatId)
//          .document(DateTime.now().millisecondsSinceEpoch.toString());
//      Firestore.instance.runTransaction((transaction) async {
//        await transaction.set(
//          documentReference,
//          {
//            'idFrom': id,
//            'idTo': peerId,
//            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
//            'content': content,
//            'type': type
//          },
//        );
//      });
//      Firestore.instance.collection('users').document(user.uid).setData(
//          {
//            'nickname': user.displayName,
//            'photoUrl': user.photoUrl,
//            'id': user.uid,
//            'isTyping': false,
//            'updateList': DateTime.now().millisecondsSinceEpoch.toString()
//          });
//      Firestore.instance.collection('users').document(user.uid).collection('readColor').document('readColor').setData(
//          {
//            'read':false
//          });
//      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
//    } else {
//      Fluttertoast.showToast(msg: 'Nothing to send');
//    }
//  }
//
//  Widget buildItem(int index, DocumentSnapshot document) {
//    if (document['idFrom'] == id) {
//      // Right (my message)
//      return Row(
//        children: <Widget>[
//          document['type'] == 0
//          // Text
//              ? Container(
//            child: Text(
//              document['content'],
//              style: TextStyle(color: Colors.black),
//            ),
//            padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
//            width: 200.0,
//            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8.0)),
//            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
//          )
//              : document['type'] == 1
//          // Image
//              ? Container(
//            child: Material(
//              child: CachedNetworkImage(
//                placeholder: Container(
//                  child: CircularProgressIndicator(
//                    //valueColor: AlwaysStoppedAnimation<Color>(themeColor),
//
//                  ),
//                  width: 200.0,
//                  height: 200.0,
//                  padding: EdgeInsets.all(70.0),
//                  decoration: BoxDecoration(
//                    //color: greyColor2,
//                    borderRadius: BorderRadius.all(
//                      Radius.circular(8.0),
//                    ),
//                  ),
//                ),
//                errorWidget: Material(
//                  child: Image.asset(
//                    'images/a12.jpg',
//                    width: 200.0,
//                    height: 200.0,
//                    fit: BoxFit.cover,
//                  ),
//                  borderRadius: BorderRadius.all(
//                    Radius.circular(8.0),
//                  ),
//                ),
//                imageUrl: document['content'],
//                width: 200.0,
//                height: 200.0,
//                fit: BoxFit.cover,
//              ),
//              borderRadius: BorderRadius.all(Radius.circular(8.0)),
//            ),
//            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
//          )
//          // Sticker
//              : Container(
//            child: new Image.asset(
//              'images/${document['content']}.gif',
//              width: 100.0,
//              height: 100.0,
//              fit: BoxFit.cover,
//            ),
//            margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
//          ),
//        ],
//        mainAxisAlignment: MainAxisAlignment.end,
//      );
//    } else {
//      // Left (peer message)
//      return Container(
//        child: Column(
//          children: <Widget>[
//            Row(
//              children: <Widget>[
//                isLastMessageLeft(index)
//                    ? Material(
//                  child: CachedNetworkImage(
//                    placeholder: Container(
//                      child: CircularProgressIndicator(
//                        strokeWidth: 1.0,
//                        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
//                      ),
//                      width: 35.0,
//                      height: 35.0,
//                      padding: EdgeInsets.all(10.0),
//                    ),
//                    imageUrl: peerAvatar,
//                    width: 35.0,
//                    height: 35.0,
//                    fit: BoxFit.cover,
//                  ),
//                  borderRadius: BorderRadius.all(
//                    Radius.circular(18.0),
//                  ),
//                )
//                    : Container(width: 35.0),
//                document['type'] == 0
//                    ? Container(
//                  child: Text(
//                    document['content'],
//                    style: TextStyle(color: Colors.white),
//                  ),
//                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
//                  width: 200.0,
//                  decoration: BoxDecoration(color: Colors.grey , borderRadius: BorderRadius.circular(8.0)),
//                  margin: EdgeInsets.only(left: 10.0),
//                )
//                    : document['type'] == 1
//                    ? Container(
//                  child: Material(
//                    child: CachedNetworkImage(
//                      placeholder: Container(
//                        child: CircularProgressIndicator(
//                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
//                        ),
//                        width: 200.0,
//                        height: 200.0,
//                        padding: EdgeInsets.all(70.0),
//                        decoration: BoxDecoration(
//                          color: Colors.grey,
//                          borderRadius: BorderRadius.all(
//                            Radius.circular(8.0),
//                          ),
//                        ),
//                      ),
//                      errorWidget: Material(
//                        child: Image.asset(
//                          'images/img_not_available.jpeg',
//                          width: 200.0,
//                          height: 200.0,
//                          fit: BoxFit.cover,
//                        ),
//                        borderRadius: BorderRadius.all(
//                          Radius.circular(8.0),
//                        ),
//                      ),
//                      imageUrl: document['content'],
//                      width: 200.0,
//                      height: 200.0,
//                      fit: BoxFit.cover,
//                    ),
//                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                  ),
//                  margin: EdgeInsets.only(left: 10.0),
//                )
//                    : Container(
//                  child: new Image.asset(
//                    'images/${document['content']}.gif',
//                    width: 100.0,
//                    height: 100.0,
//                    fit: BoxFit.cover,
//                  ),
//                  margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
//                ),
//              ],
//            ),
//
//            // Time
//            isLastMessageLeft(index)
//                ? Container(
//              child: Text(
//                "fdd"
//              ),
//              margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
//            )
//                : Container()
//          ],
//          crossAxisAlignment: CrossAxisAlignment.start,
//        ),
//        margin: EdgeInsets.only(bottom: 10.0),
//      );
//    }
//  }
//
//  bool isLastMessageLeft(int index) {
//    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] == id) || index == 0) {
//      return true;
//    } else {
//      return false;
//    }
//  }
//
//  bool isLastMessageRight(int index) {
//    if ((index > 0 && listMessage != null && listMessage[index - 1]['idFrom'] != id) || index == 0) {
//      return true;
//    } else {
//      return false;
//    }
//  }
//
//  Future<bool> onBackPress() {
//    if (isShowSticker) {
//      setState(() {
//        isShowSticker = false;
//      });
//    } else {
//      Navigator.pop(context);
//    }
//
//    return Future.value(false);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return WillPopScope(
//      child: Stack(
//        children: <Widget>[
//          Column(
//            children: <Widget>[
//              // List of messages
//              buildListMessage(),
//
//              // Sticker
//              // (isShowSticker ? buildSticker() : Container()),
//
//              // Input content
//              buildInput(),
//            ],
//          ),
//
//          // Loading
//          buildLoading()
//        ],
//      ),
//      onWillPop: onBackPress,
//    );
//  }
//
////  Widget buildSticker() {
////    return Container(
////      child: Column(
////        children: <Widget>[
////          Row(
////            children: <Widget>[
////              FlatButton(
////                onPressed: () => onSendMessage('mimi1', 2),
////                child: new Image.asset(
////                  'images/mimi1.gif',
////                  width: 50.0,
////                  height: 50.0,
////                  fit: BoxFit.cover,
////                ),
////              ),
////              FlatButton(
////                onPressed: () => onSendMessage('mimi2', 2),
////                child: new Image.asset(
////                  'images/mimi2.gif',
////                  width: 50.0,
////                  height: 50.0,
////                  fit: BoxFit.cover,
////                ),
////              ),
////              FlatButton(
////                onPressed: () => onSendMessage('mimi3', 2),
////                child: new Image.asset(
////                  'images/mimi3.gif',
////                  width: 50.0,
////                  height: 50.0,
////                  fit: BoxFit.cover,
////                ),
////              )
////            ],
////            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
////          ),
////          Row(
////            children: <Widget>[
////              FlatButton(
////                onPressed: () => onSendMessage('mimi4', 2),
////                child: new Image.asset(
////                  'images/mimi4.gif',
////                  width: 50.0,
////                  height: 50.0,
////                  fit: BoxFit.cover,
////                ),
////              ),
////              FlatButton(
////                onPressed: () => onSendMessage('mimi5', 2),
////                child: new Image.asset(
////                  'images/mimi5.gif',
////                  width: 50.0,
////                  height: 50.0,
////                  fit: BoxFit.cover,
////                ),
////              ),
////              FlatButton(
////                onPressed: () => onSendMessage('mimi6', 2),
////                child: new Image.asset(
////                  'images/mimi6.gif',
////                  width: 50.0,
////                  height: 50.0,
////                  fit: BoxFit.cover,
////                ),
////              )
////            ],
////            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
////          ),
////          Row(
////            children: <Widget>[
////              FlatButton(
////                onPressed: () => onSendMessage('mimi7', 2),
////                child: new Image.asset(
////                  'images/mimi7.gif',
////                  width: 50.0,
////                  height: 50.0,
////                  fit: BoxFit.cover,
////                ),
////              ),
////              FlatButton(
////                onPressed: () => onSendMessage('mimi8', 2),
////                child: new Image.asset(
////                  'images/mimi8.gif',
////                  width: 50.0,
////                  height: 50.0,
////                  fit: BoxFit.cover,
////                ),
////              ),
////              FlatButton(
////                onPressed: () => onSendMessage('mimi9', 2),
////                child: new Image.asset(
////                  'images/mimi9.gif',
////                  width: 50.0,
////                  height: 50.0,
////                  fit: BoxFit.cover,
////                ),
////              )
////            ],
////            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
////          )
////        ],
////        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
////      ),
////      decoration: new BoxDecoration(
////          border: new Border(top: new BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
////      padding: EdgeInsets.all(5.0),
////      height: 180.0,
////    );
////  }
//
//  Widget buildLoading() {
//    return Positioned(
//      child: isLoading
//          ? Container(
//        child: Center(
//          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
//        ),
//        color: Colors.white.withOpacity(0.8),
//      )
//          : Container(),
//    );
//  }
//
//  Widget buildInput() {
//    return Container(
//      child: Row(
//        children: <Widget>[
//          // Button send image
//          Material(
//            child: new Container(
//              margin: new EdgeInsets.symmetric(horizontal: 1.0),
//              child: new IconButton(
//                icon: new Icon(Icons.image),
//                onPressed: getImage,
//                color: Colors.black,
//              ),
//            ),
//            color: Colors.white,
//          ),
//          Material(
//            child: new Container(
//              margin: new EdgeInsets.symmetric(horizontal: 1.0),
//              child: new IconButton(
//                icon: new Icon(Icons.camera_enhance),
//                onPressed: getImageFromCamera,
//                color: Colors.black,
//              ),
//            ),
//            color: Colors.white,
//          ),
//          Material(
//            child: new Container(
//              margin: new EdgeInsets.symmetric(horizontal: 1.0),
//              child: new IconButton(
//                icon: new Icon(Icons.insert_emoticon),
//                onPressed: getSticker,
//                color: Colors.black,
//              ),
//            ),
//            color: Colors.white,
//          ),
//
//          // Edit text
//          Flexible(
//            child: Container(
//              child: TextField(
//                style: TextStyle(color:  Colors.black,, fontSize: 15.0),
//                controller: textEditingController,
//                onChanged: (text){
//                  Firestore.instance.collection('users').document(user.uid).collection('typingStatus')
//                      .document(user.uid).setData(
//                      {
//                        'isTyping': true,
//                      });
//                },
//                decoration: InputDecoration.collapsed(
//                  hintText: 'Type your message...',
//
//                  hintStyle: TextStyle(color: Colors.grey),
//                ),
//                focusNode: focusNode,
//              ),
//            ),
//          ),
//
//          // Button send message
//          Material(
//            child: new Container(
//              margin: new EdgeInsets.symmetric(horizontal: 8.0),
//              child: new IconButton(
//                icon: new Icon(Icons.send),
//                onPressed: () => onSendMessage(textEditingController.text, 0),
//                color: Colors.black,
//              ),
//            ),
//            color: Colors.white,
//          ),
//        ],
//      ),
//      width: double.infinity,
//      height: 50.0,
//      decoration: new BoxDecoration(
//          border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)), color: Colors.white),
//    );
//  }
//
//
//
//
//  Widget buildListMessage() {
//    return Flexible(
//      child: groupChatId == ''
//          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red))
//          : StreamBuilder(
//        stream: Firestore.instance
//            .collection('messages')
//            .document(groupChatId)
//            .collection(groupChatId)
//            .orderBy('timestamp', descending: true)
//            .limit(1000)
//            .snapshots(),
//        builder: (context, snapshot) {
//          if (!snapshot.hasData) {
//            return Center(
//                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(themeColor)));
//          } else {
//            listMessage = snapshot.data.documents;
//            return ListView.builder(
//              padding: EdgeInsets.all(10.0),
//              itemBuilder: (context, index) => buildItem(index, snapshot.data.documents[index]),
//              itemCount: snapshot.data.documents.length,
//              reverse: true,
//              controller: listScrollController,
//            );
//          }
//        },
//      ),
//    )
//  }
//
//
//
//
//}
