import 'package:customersupport/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/flutter_dialogflow.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'colors.dart';

Color bg = Colors.black;

class Chat extends StatelessWidget {
  final String peerId, user;

  Chat({
    Key key,
    @required this.peerId,
    @required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: bg,
      body: new ChatScreen(
        ///////calling chat screen
        user: user,
        peerId: peerId,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId, user;

  ChatScreen({Key key, @required this.user, @required this.peerId})
      : super(key: key);

  @override
  State createState() => new ChatScreenState(peerId: peerId, user: user);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.peerId, @required this.user});

  String peerId, user, read_Icon_ColorS;
  Color read_Icon_Color;
  String id;
  var listMessage;
  String groupChatId;

  var _connectionStatus = 'Unknown';

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

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
    id = await ChatApp.sharedPreferences.getString("Uid") ?? "";
    if (id == '')
      print(id);
    else
      print(id);

    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
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

  void Response(query) async {
    setState(() {
      isLoading = false;
    });
    onSendMessage(imageUrl, 1);
    Dialogflow dialogflow =
        Dialogflow(token: "7ae4e179083945389585f082f6435536");
    AIResponse response = await dialogflow.sendQuery(query);

    var documentReference = Firestore.instance
        .collection('messages')
        .document(groupChatId)
        .collection(groupChatId)
        .document(DateTime.now().millisecondsSinceEpoch.toString());
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(
        documentReference,
        {
          'idFrom': peerId,
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
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'type': type
          },
        );
      }).catchError((e) {
        print("Eroor strart");
        print(e.toString());
      });
      Firestore.instance.collection('users').document(id).updateData({
        'updateList': DateTime.now().millisecondsSinceEpoch.toString(),
        'readed': "false",
      });
      Response(content);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document['idFrom'] == id) {
      // Right (my message)
      return Column(children: <Widget>[
        Row(
          children: <Widget>[
            document['type'] == 0
                // Text
                ? Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${document['content']} ",
                          style: TextStyle(color: primaryColor),
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              child: Text(
                                DateFormat('dd MMM kk:mm').format(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(document['timestamp']))),
                                style: TextStyle(
                                    color: greyColor,
                                    fontSize: 12.0,
                                    fontStyle: FontStyle.italic),
                              ),
                              margin: EdgeInsets.only(top: 3.0),
                            ),
                            Flexible(
                              child: Container(),
                            ),
                          ],
                        )
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.0)),
                    margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                        right: 10.0),
                  )
                : document['type'] == 1
                    // Image
                    ? Container(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (c, s) {
                              return Container(
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(themeColor),
                                ),
                                width: 200.0,
                                height: 200.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: greyColor2,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              );
                            },
                            errorWidget: (c, s, o) {
                              return Material(
                                  child: Image.asset(
                                    'images/a12.jpg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ));
                            },
                            imageUrl: document['content'],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                            right: 10.0),
                      )
                    // Sticker
                    : Container(
                        child: new Image.asset(
                          'images/${document['content']}.gif',
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                        margin: EdgeInsets.only(
                            bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                            right: 10.0),
                      ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        )
      ]);
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                document['type'] == 0
                    ? Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${document['content']} ",
                              style: TextStyle(color: primaryColor),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    DateFormat('dd MMM kk:mm').format(
                                        DateTime.fromMillisecondsSinceEpoch(
                                            int.parse(document['timestamp']))),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontStyle: FontStyle.italic),
                                  ),
                                  margin:
                                      EdgeInsets.only(top: 3.0, left: 100.0),
                                ),
                                Flexible(
                                  child: Container(),
                                ),
                              ],
                            )
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : (document['type'] == 1
                        ? Container(
                            child: Material(
                              child: CachedNetworkImage(
                                placeholder: (c, m) {
                                  return Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          themeColor),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: greyColor2,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  );
                                },
                                errorWidget: (c, s, o) {
                                  return Material(
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  );
                                },
                                imageUrl: document['content'],
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(
                            child: Text("Error"),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ))
              ],
            ),

            // Time
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
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
}

Widget showContainer(BuildContext context) {
  return Container(
    color: Colors.black,
    height: 100.0,
    width: 100.0,
  );
}

class hello extends CustomClipper<Path> {
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
