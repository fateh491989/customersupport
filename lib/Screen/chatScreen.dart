import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customersupport/Config/config.dart';
import 'package:customersupport/Theme/colors.dart';
import 'package:customersupport/WIdgets/myMessageBox.dart';
import 'package:customersupport/WIdgets/peerMessageBox.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/flutter_dialogflow.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String adminId, user;
  ChatScreen({Key key, @required this.user, @required this.adminId})
      : super(key: key);

  @override
  State createState() => new ChatScreenState(adminId: adminId, user: user);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.adminId, @required this.user});

  String adminId, user, read_Icon_ColorS;
  Color read_Icon_Color;
  String id;
  var listMessage;
  String groupChatId;

  var _connectionStatus = 'Unknown';

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    groupChatId = '';
    isLoading = false;
    isShowSticker = false;
    imageUrl = '';
    readLocal();
  } //initState()

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    id = ChatApp.sharedPreferences.getString("Uid") ?? "";
    if (id == '')
      print(id);
    else
      print(id);

    if (id.hashCode <= adminId.hashCode) {
      groupChatId = '$id-$adminId';
    } else {
      groupChatId = '$adminId-$id';
    }
    setState(() {});
  }

  Future getImageFromCamera() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        imageFile = image;
        isLoading = true;
        image = null;
      });
    }
    uploadFile();
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imageFile = image;
        image = null;
        isLoading = true;
      });
    }
    uploadFile();
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    print("testCompressAndGetFile");
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 90,
      minWidth: 1024,
      minHeight: 1024,
      rotate: 90,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask =
    reference.putFile((await testCompressAndGetFile(imageFile, "")));
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    imageUrl = dowurl.toString();
  }

  void response(query) async {
    setState(() {
      isLoading = false;
    });
    onSendMessage(imageUrl, 1);
    Dialogflow dialogFlow =
    // TODO: Replace token
    Dialogflow(token: "7ae4e179083945389585f082f6435536");
    AIResponse response = await dialogFlow.sendQuery(query);

    var documentReference = Firestore.instance
        .collection(ChatApp.collectionMessage)
        .document(groupChatId)
        .collection(groupChatId)
        .document(DateTime.now().millisecondsSinceEpoch.toString());
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        {
          'idFrom': adminId,
          'idTo': id,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': response.getMessageResponse(),
          'type': int.parse('0')
        },
      );
    });
  }

  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      var documentReference = Firestore.instance
          .collection(ChatApp.collectionMessage)
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': adminId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      }).catchError((e) {
        print("Eroor strart");
        print(e.toString());
      });
      Firestore.instance.collection(ChatApp.collectionMessage).document(id).updateData({
        'updateList': DateTime.now().millisecondsSinceEpoch.toString(),
        'readed': "false",
      });
      response(content);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }


  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      Navigator.pop(context);
    }
    return Future.value(false);
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      // Right (my message)
      return MyMessages(
        document: document,
        index: index,
        id: id,
        listMessage: listMessage,
      );
    } else {
      // Left (peer message)
      return PeerMessageBox(
        document: document,
        index: index,
        id: id,
        listMessage: listMessage,
      );
    }
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor)),
        ),
        color: Colors.white.withOpacity(0.8),
      )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          Flexible(
            child: new TextField(
              controller: textEditingController,
              //onSubmitted: _handleSubmitted,
              decoration:
              new InputDecoration.collapsed(hintText: "Send a message"),
            ),
          ),
          Container(
            margin: new EdgeInsets.symmetric(horizontal: 2.0),
            child: new IconButton(
                icon: new Icon(
                  Icons.camera_enhance,
                  color: Colors.red,
                ),
                onPressed: () {
                  print(user);
                }
              //getImageFromCamera
            ),
          ),
          Container(
            margin: new EdgeInsets.symmetric(horizontal: 2.0),
            child: new IconButton(
                icon: new Icon(
                  Icons.image,
                  color: Colors.red,
                ),
                onPressed: getImage),
          ),
          Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
              icon: new Icon(
                Icons.send,
                color: Colors.red,
              ),
              onPressed: () {
                onSendMessage(textEditingController.text, 0);
                if (isLoading)
                  print("true");
                else
                  print("false");
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
        stream: Firestore.instance
            .collection('messages')
            .document(groupChatId)
            .collection(groupChatId)
            .orderBy('timestamp', descending: true)
            .limit(1000)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Icon(
                  Icons.file_download,
                  color: Colors.red,
                ));
          } else {
            listMessage = snapshot.data.documents;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(index, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
              reverse: true,
              controller: listScrollController,
            );
          }
        },
      ),
    );
  }

  Widget buildSticker() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('mimi1', 2),
                child: new Image.asset(
                  'images/ambulancep.png',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi2', 2),
                child: new Image.asset(
                  'images/firebrigade.png',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('mimi3', 2),
                child: new Image.asset(
                  'images/firebrigade.png',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
//          Row(
//            children: <Widget>[
//              FlatButton(
//                onPressed: () => onSendMessage('mimi4', 2),
//                child: new Image.asset(
//                  'images/mimi4.gif',
//                  width: 50.0,
//                  height: 50.0,
//                  fit: BoxFit.cover,
//                ),
//              ),
//              FlatButton(
//                onPressed: () => onSendMessage('mimi5', 2),
//                child: new Image.asset(
//                  'images/mimi5.gif',
//                  width: 50.0,
//                  height: 50.0,
//                  fit: BoxFit.cover,
//                ),
//              ),
//              FlatButton(
//                onPressed: () => onSendMessage('mimi6', 2),
//                child: new Image.asset(
//                  'images/mimi6.gif',
//                  width: 50.0,
//                  height: 50.0,
//                  fit: BoxFit.cover,
//                ),
//              )
//            ],
//            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          ),
//          Row(
//            children: <Widget>[
//              FlatButton(
//                onPressed: () => onSendMessage('mimi7', 2),
//                child: new Image.asset(
//                  'images/mimi7.gif',
//                  width: 50.0,
//                  height: 50.0,
//                  fit: BoxFit.cover,
//                ),
//              ),
//              FlatButton(
//                onPressed: () => onSendMessage('mimi8', 2),
//                child: new Image.asset(
//                  'images/mimi8.gif',
//                  width: 50.0,
//                  height: 50.0,
//                  fit: BoxFit.cover,
//                ),
//              ),
//              FlatButton(
//                onPressed: () => onSendMessage('mimi9', 2),
//                child: new Image.asset(
//                  'images/mimi9.gif',
//                  width: 50.0,
//                  height: 50.0,
//                  fit: BoxFit.cover,
//                ),
//              )
//            ],
//            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
          new Border(top: new BorderSide(color: greyColor2, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    Firestore.instance
        .collection('users')
        .document(id)
        .get()
        .then((DocumentSnapshot a) {
      setState(() {
        read_Icon_Color = a['readed'] == "false" ? Colors.pink : Colors.green;
        read_Icon_ColorS = a['readed'] == "false" ? "Delivered" : "Read";
      });
    });

    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),
              InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text("💖"),
                    Icon(Icons.done_all, color: read_Icon_Color),
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Text(read_Icon_ColorS ?? "Wait"),
                    ),
                  ],
                ),
              ),
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }


}

Widget showContainer(BuildContext context) {
  return Container(
    color: Colors.black,
    height: 100.0,
    width: 100.0,
  );
}

class Hello extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(10.0, 13.0);
    path.lineTo(10, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
