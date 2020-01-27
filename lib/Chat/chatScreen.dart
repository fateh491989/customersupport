import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customersupport/Config/config.dart';
import 'package:customersupport/Theme/colors.dart';
import 'package:customersupport/WIdgets/myMessageBox.dart';
import 'package:customersupport/WIdgets/peerMessageBox.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dialogflow/flutter_dialogflow.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

List<Asset> images1 = List<Asset>();
List<Asset> imagesTemp = List<Asset>();
List<String> imageUrls = <String>[];

class ChatScreen extends StatefulWidget {
  final String adminId, userID;

  ChatScreen({Key key, @required this.userID, @required this.adminId})
      : super(key: key);

  @override
  State createState() => new ChatScreenState(adminId: adminId, userID: userID);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key key, @required this.adminId, @required this.userID});

  bool isUploading = false, isLoading;
  String adminId, userID, groupChatId, imageUrl;
  var listMessage;
  int currentPageIndex = 0;
  File imageFile;
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  PageController _pageController, p2;
  List<String> _timeOfUploading = <String>[];

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    _pageController = PageController();
    p2 = PageController();
    groupChatId = '';
    isLoading = false;
    imageUrl = '';
    readLocal();
    initialisingData();
// TODO define these methods in your homepage
    registerNotification();
    configLocalNotification();
  } //initState()

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      ChatApp.firestore
          .collection(ChatApp.collectionUser)
          .document(ChatApp.sharedPreferences.getString(ChatApp.userUID))
          .updateData({ChatApp.userToken: token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(

      // Change package name
      Platform.isAndroid
          ? 'com.example.customersupport'
          : 'com.duytq.flutterchatdemo',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {}
  }

  readLocal() async {
    //id = ChatApp.sharedPreferences.getString("Uid") ?? "";
    if (userID.hashCode <= adminId.hashCode) {
      groupChatId = '$userID-$adminId';
    } else {
      groupChatId = '$adminId-$userID';
    }
    ChatApp.firestore
        .collection(ChatApp.collectionUser)
        .document(userID)
        .updateData({ChatApp.userChattingWith: userID});
    setState(() {});
  }

  // TODO Upcoming feature
  void response(query) async {
    setState(() {
      isLoading = false;
    });
    //onSendMessage(imageUrl, 1);
    Dialogflow dialogFlow =
        // TODO: Replace token
        Dialogflow(token: "7ae4e179083945389585f082f6435536");
    AIResponse response = await dialogFlow.sendQuery(query).catchError((e) {
      print("error ${e}");
    });
    print("Query ${response.getMessageResponse()}");
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
          'idTo': userID,
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          'content': response.getMessageResponse(),
          'type': int.parse('0')
        },
      );
    });
  }

  Future<void> onSendMessage(String content, int type, [String time,bool updating=true]) async {

    print('Dste $time');
    String dateTime = time ?? DateTime.now().millisecondsSinceEpoch.toString();
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();
      await Firestore.instance
          .collection(ChatApp.collectionAdmin)
          .document(adminId)
          .get().then((snapshot) async {
        print(snapshot.data);
         if(snapshot.data[ChatApp.userChattingWith]==userID){

         }
         else{
           DocumentSnapshot snapshot = await Firestore.instance
               .collection(ChatApp.collectionMessage)
               .document(groupChatId)
               .collection(adminId)
               .document(adminId)
               .get()
               .then((snapshot) {
             print(snapshot.documentID);
             print(!snapshot.exists);

             print(snapshot.documentID);
             print(snapshot.data[UserMessage.count]);
             var documentReference1 = Firestore.instance
                 .collection(ChatApp.collectionMessage)
                 .document(groupChatId)
                 .collection(adminId)
                 .document(adminId);
//print('Upd value $updating');
             if(updating){
               Firestore.instance.runTransaction((transaction) async {
                 await transaction.update(
                   documentReference1,
                   {
                     UserMessage.count: (snapshot.data[UserMessage.count] + 1)
                   },
                 );
               });
             }
             return snapshot;
           });
         }

      });


//      print(snapshot.data['count']);

      var documentReference = Firestore.instance
          .collection(ChatApp.collectionMessage)
          .document(groupChatId)
          .collection(groupChatId)
          .document(dateTime);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            UserMessage.idFrom: userID,
            UserMessage.idTo: adminId,
            UserMessage.timestamp: dateTime,
            UserMessage.content: content,
            UserMessage.type: type
          },
        );
      }).catchError((e) {
        print("Eroor strart");
        print(e.toString());
      });

      //response(content);
      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      print(content);
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Future<bool> onBackPress() {
    print('Backing...');
    ChatApp.firestore
        .collection('users')
        .document(ChatApp.sharedPreferences.getString(ChatApp.userUID))
        .updateData({ChatApp.userChattingWith: null});
    Navigator.pop(context);
    return Future.value(false);
  }

  Future<dynamic> postImage(Asset imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask =
        reference.putData((await imageFile.getByteData()).buffer.asUint8List());
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    print(storageTaskSnapshot.ref.getDownloadURL());
    return storageTaskSnapshot.ref.getDownloadURL();
  }

  void uploadImages() async {
    images1.forEach((f) {
      String time = DateTime.now().millisecondsSinceEpoch.toString();
      onSendMessage('Image', 1, time,false);
      _timeOfUploading.add(time);
      if (_timeOfUploading.length == images1.length) {
        setState(() {
          //images = [];
          //imageUrls = [];
          imagesTemp = [];
          //_timeOfUploading=[];
          isUploading = false;
        });
      }
    });

    print('opploading......');

    images1.forEach((imageFile) {
      postImage(imageFile).then((downloadUrl) {
        onSendMessage(downloadUrl, 1, _timeOfUploading[imageUrls.length],true);
        imageUrls.add(downloadUrl.toString());
        if (imageUrls.length == images1.length) {
          setState(() {
            images1 = [];
            imageUrls = [];
            _timeOfUploading = [];
            isUploading = false;
          });
        }
      }).catchError((err) {
        print(err);
      });
    });
//    for ( var imageFile in images) {
//      postImage(imageFile).then((downloadUrl) {
//        imageUrls.add(downloadUrl.toString());
//        onSendMessage(downloadUrl, 1);
//        if(imageUrls.length==images.length) {
//          setState(() {
//            images = [];
//            imageUrls = [];
//            isUploading=false;
//          });
//        }
//      }).catchError((err) {
//        print(err);
//      });
//    }
  }

  Future loadAssets() async {
    print('d');
    List<Asset> resultList = List<Asset>();

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images1,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Upload Image",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {}
    if (!mounted) return;
    setState(() {
      images1 = resultList;
      imagesTemp = resultList;
      // _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
//          (images.length == 0)
//              ?
          Container(
            color: backgroundf,
            child: Column(
              children: <Widget>[
                // List of messages
                buildListMessage(),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
//                    border: Border(
//                      top: BorderSide(
//                        color: Colors.red
//                      )
//                    )
                      ),
                  child: StreamBuilder<DocumentSnapshot>(
                      stream: ChatApp.firestore
                          .collection(ChatApp.collectionMessage)
                          .document(groupChatId)
                          .collection(adminId)
                          .document(adminId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        } else {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 25.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    snapshot.data.data[UserMessage.count] == 0
                                        ? Icon(Icons.remove_red_eye)
                                        : Container(),
                                    snapshot.data.data[UserMessage.count] == 0
                                        ? Text("Seen")
                                        : Text("Delivered"),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                ),
                (imagesTemp.length == 0)
                    ? Container()
                    : Container(
                        height: 100,
                        child: buildGridView(),
                      ),
                (imagesTemp.length == 0) ? buildInput() : buildSendImage(),
              ],
            ),
          )
//              : Stack(
//                  alignment: Alignment.bottomCenter,
//                  children: <Widget>[
//                    PageView.builder(
//                      itemCount: images.length,
//                      onPageChanged: (index){
//                        p2.jumpToPage(index);
//                          currentPageIndex=index;
//
////                          setState(() {
////
////                          });
//                        //});
//                      },
//                      controller: _pageController,
//                      itemBuilder: (c, index) {
//                        return Container(
//                          color: Colors.black,
//                          child: AssetThumb(
//                            asset: images[currentPageIndex],
//                            width: MediaQuery.of(context).size.width.toInt(),
//                            height: MediaQuery.of(context).size.height.toInt(),
//                            quality: 50,
//                          ),
//                        );
//                      },
//                    ),
//                    Container(
//                      alignment: Alignment.bottomCenter,
//                      height: 120,
//                      padding: EdgeInsets.only(top:10),
//                      color: Colors.grey.withOpacity(0.5),
//                      child: buildGridView(),
//                    ),
//                  ],
//                ),
          // Loading
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildGridView() {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 1,
      controller: p2,
      addAutomaticKeepAlives: true,
      children: List.generate(images1.length, (index) {
        Asset asset = images1[index];
        print(asset.getByteData(quality: 100));
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              _pageController.jumpToPage(index);
              //_pageController.animateTo(index.toDouble(), duration: Duration(milliseconds: 500), curve: Curves.easeIn);
            },
            child: Container(
              decoration: currentPageIndex == index
                  ? BoxDecoration(
                      color: Colors.black,
                      border: Border.all(
                        width: 2,
                        color: Colors.red,
                      ),
                    )
                  : null,
              child: AssetThumb(
                asset: asset,
                width: 300,
                height: 300,
                quality: 50,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document[UserMessage.idFrom] == userID) {
      // Right (my message)
      return MyMessages(
        document: document,
        index: index,
        id: userID,
        listMessage: listMessage,
      );
    } else {
      // Left (peer message)
      return PeerMessageBox(
        document: document,
        index: index,
        id: userID,
        listMessage: listMessage,
      );
    }
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
          : StreamBuilder(
              stream: ChatApp.firestore
                  .collection(ChatApp.collectionMessage)
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy(UserMessage.timestamp, descending: true)
                  .limit(1000)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: Icon(
                    Icons.blur_circular,
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
                  Icons.image,
                  color: Colors.red,
                ),
                onPressed: () {
                  loadAssets();
                }),
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

  Widget buildSendImage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          Flexible(child: Container()),
          Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
              icon: new Icon(
                Icons.cancel,
                color: Colors.red,
              ),
              onPressed: () {
                images1 = [];
                setState(() {});
              },
            ),
          ),
          Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: isUploading
                ? Text('')
                : IconButton(
                    icon: Icon(
                      Icons.send,
                      color: Colors.red,
                    ),
                    onPressed: isUploading
                        ? null
                        : () {
                            uploadImages();
                            //onSendMessage(textEditingController.text, 0);
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

  void initialisingData() async{

    DocumentSnapshot snapshot = await Firestore.instance
        .collection(ChatApp.collectionMessage)
        .document(groupChatId)
        .collection(adminId)
        .document(adminId)
        .get()
        .then((snapshot) {
      print(snapshot.documentID);
      print(!snapshot.exists);
      if (!snapshot.exists){
        Firestore.instance
            .collection(ChatApp.collectionMessage)
            .document(groupChatId)
            .collection(adminId)
            .document(adminId)
            .setData({UserMessage.count: 0}).catchError((error) {
          print('Hello');
          print(error);
        });
      }
      return snapshot;
    });
  }
}
