//import 'package:flutter_dialogflow/flutter_dialogflow.dart';
//
//import 'colors.dart';
//import 'package:flutter/material.dart';
//var local;
//var localStart;
//bool x = true, y = true;
//
//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return new MaterialApp(
//      title: 'Example Dialogflow Flutter',
////      theme: new ThemeData(
////        primarySwatch: Colors.deepOrange,
////      ),
//      home: new MyHomePage(title: 'Flutter Demo Dialogflow'),
//    );
//  }
//}
//
//class MyHomePage extends StatefulWidget {
//  MyHomePage({Key key, this.title}) : super(key: key);
//
//  final String title;
//
//  @override
//  _MyHomePageState createState() => new _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  final List<ChatMessage> _messages = <ChatMessage>[];
//  final TextEditingController _textController = new TextEditingController();
//
//  Widget _buildTextComposer() {
//    return new IconTheme(
//      data: new IconThemeData(color: Theme.of(context).accentColor),
//      child: new Container(
//        margin: const EdgeInsets.symmetric(horizontal: 8.0),
//        child: new Row(
//          children: <Widget>[
//            Container(
//              margin: new EdgeInsets.symmetric(horizontal: 2.0),
//              child: new IconButton(
//                  icon: new Icon(Icons.insert_emoticon, color: Colors.red,),
//                onPressed: (){},
//                ),
//            ),
//             Flexible(
//              child: new TextField(
//                controller: _textController,
//                onSubmitted: _handleSubmitted,
//                decoration:
//                new InputDecoration.collapsed(hintText: "Send a message"),
//              ),
//            ),
//            Container(
//              margin: new EdgeInsets.symmetric(horizontal: 4.0),
//              child: new IconButton(
//                icon: new Icon(Icons.attachment, color: Colors.red,),
//                onPressed: (){},
//              ),
//            ),
//             Container(
//              margin: new EdgeInsets.symmetric(horizontal: 4.0),
//              child: new IconButton(
//                  icon: new Icon(Icons.send,color: Colors.red,),
//                  onPressed: () => _handleSubmitted(_textController.text)),
//            ),
//          ],
//        ),
//      ),
//    );
//  }
//
//  void Response(query) async {
//    _textController.clear();
//    Dialogflow dialogflow =Dialogflow(token: "7ae4e179083945389585f082f6435536");
//    AIResponse response = await dialogflow.sendQuery(query);
//    ChatMessage message = new ChatMessage(
//      text: response.getMessageResponse(),
//      name: "Bot",
//      type: false,
//    );
//    setState(() {
//      _messages.insert(0, message);
//    });
//  }
//
//  void _handleSubmitted(String text) {
//    _textController.clear();
//    ChatMessage message = new ChatMessage(
//      text: text,
//      name: "Rances",
//      type: true,
//    );
//    setState(() {
//      _messages.insert(0, message);
//    });
//    Response(text);
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//    return new Scaffold(
//      backgroundColor: backgroundf,
//      appBar: new AppBar(
//        title: new Text(widget.title),
//      ),
//
//      body: new Column(children: <Widget>[
//        new Flexible(
//            child: new ListView.builder(
//              padding: new EdgeInsets.all(8.0),
//              reverse: true,
//              itemBuilder: (_, int index) => _messages[index],
//              itemCount: _messages.length,
//            )),
//        new Divider(height: 1.0),
//        new Container(
//          decoration: new BoxDecoration(color: Theme.of(context).cardColor),
//          child: _buildTextComposer(),
//        ),
//      ]),
//    );
//  }
//}
//
//class ChatMessage extends StatefulWidget {
//  ChatMessage({this.text, this.name, this.type});
//
//  final String text;
//  final String name;
//  final bool type;
//  @override
//  _ChatMessageState createState() => _ChatMessageState();
//}
//
//class _ChatMessageState extends State<ChatMessage> {
//  _ChatMessageState({this.text, this.name, this.type});
//
//  final String text;
//  final String name;
//  final bool type;
//
//  List<Widget> otherMessage(context) {
//    return <Widget>[
//      GestureDetector(
//
//        onHorizontalDragStart: (DragStartDetails start) =>
//            _onDragStart(context, start),
//        onHorizontalDragUpdate: (DragUpdateDetails update) =>
//            _onDragUpdate(context, update),
//        onHorizontalDragEnd: (DragEndDetails stfiot)=>_onDragEnd(context, stfiot),
//        child: Container(
//          decoration: BoxDecoration(
//              color: Colors.white,
//              borderRadius: BorderRadius.circular(10.0)
//          ),
//          width: MediaQuery.of(context).size.width*0.6,
//          padding: const EdgeInsets.all(5.0),
//          margin: const EdgeInsets.only(top: 5.0,right: 16.0,),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            children: <Widget>[
//              Text("Customer Support",  style: TextStyle(
//                  color: Colors.red,
//                  fontWeight: FontWeight.w500
//              ),),
//              Padding(
//                padding: EdgeInsets.all(10.0),
//                child: Text(text),
//              ),
//
//              Padding(
//                padding: EdgeInsets.only(top:10.0, left: 10.0,right: 5.0),
//                child: Text("12:30 pm", style: TextStyle(color: Colors.grey,fontSize: 15.0),),
//              ),
//
//            ],
//          ),
//        ),
//      ),
//    ];
//  }
//
//  List<Widget> myMessage(context) {
//    return <Widget>[
//      Container(
//
//        decoration: BoxDecoration(
//            color: Colors.white,
//            borderRadius: BorderRadius.circular(10.0)
//        ),
//        width: MediaQuery.of(context).size.width*0.6,
//        padding: const EdgeInsets.all(5.0),
//        margin: EdgeInsets.only(top: 5.0,left:  MediaQuery.of(context).size.width*0.35,),
//        child: Column(
//
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            Text("Fateh Singh",  style: TextStyle(
//                color: Colors.redAccent,
//                fontWeight: FontWeight.w500
//            ),),
//            Padding(
//              padding: EdgeInsets.all(10.0),
//              child: Text(text),
//            ),
//
//            Padding(
//              padding: EdgeInsets.only(top:10.0, left: 10.0,right: 5.0),
//              child: Text("12:29 pm", style: TextStyle(color: Colors.grey,fontSize: 15.0),),
//            ),
//
//
//          ],
//        ),
//      ),
//
//    ];
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new Container(
//      margin: const EdgeInsets.symmetric(vertical: 10.0),
//      child: new Row(
//        crossAxisAlignment: CrossAxisAlignment.start,
//        children: this.type ? myMessage(context) : otherMessage(context),
//      ),
//    );
//  }
//
//  _onDragStart(BuildContext context, DragStartDetails start) {
//    print(start.globalPosition.toString());
//    RenderBox getBox = context.findRenderObject();
//    localStart = getBox.globalToLocal(start.globalPosition);
//    print(localStart.dx.toString() + "|" + localStart.dy.toString());
//
//  }
//  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
//
//
//    RenderBox getBox = context.findRenderObject();
//    local = getBox.globalToLocal(update.globalPosition);
//    setState(() {
//      x = false;
////      if(local.dx+100.0>localStart.dx ){
////        setState(() {
////          local.dx=local.dx +99.0;
////        });
////
////      }
//    });
//    print(local.dx.toString() + "|" + local.dy.toString());
//  }
//  _onDragEnd(BuildContext context, DragEndDetails s) {
//
//    setState(() {
//      x = true;
//      y = false;
//    });
//
//  }
//
//
//}
//
////
////class ChatMessage extends StatelessWidget {
////
////
////  List<Widget> otherMessage(context) {
////    return <Widget>[
////    Container(
////          decoration: BoxDecoration(
////            color: Colors.white,
////             borderRadius: BorderRadius.circular(10.0)
////          ),
////          width: MediaQuery.of(context).size.width*0.6,
////          padding: const EdgeInsets.all(5.0),
////              margin: const EdgeInsets.only(top: 5.0,right: 16.0,),
////              child: Column(
////                crossAxisAlignment: CrossAxisAlignment.start,
////                children: <Widget>[
////                  Text("Customer Support",  style: TextStyle(
////                    color: Colors.red,
////                    fontWeight: FontWeight.w500
////                  ),),
////                   Padding(
////                     padding: EdgeInsets.all(10.0),
////                     child: Text(text),
////                   ),
////
////                    Padding(
////                      padding: EdgeInsets.only(top:10.0, left: 10.0,right: 5.0),
////                      child: Text("12:30 pm", style: TextStyle(color: Colors.grey,fontSize: 15.0),),
////                    ),
////
////                ],
////              ),
////            ),
////    ];
////  }
////
////  List<Widget> myMessage(context) {
////    return <Widget>[
////      Container(
////
////        decoration: BoxDecoration(
////            color: Colors.white,
////            borderRadius: BorderRadius.circular(10.0)
////        ),
////        width: MediaQuery.of(context).size.width*0.6,
////        padding: const EdgeInsets.all(5.0),
////        margin: EdgeInsets.only(top: 5.0,left:  MediaQuery.of(context).size.width*0.35,),
////        child: Column(
////
////          crossAxisAlignment: CrossAxisAlignment.start,
////          children: <Widget>[
////            Text("Fateh Singh",  style: TextStyle(
////                color: Colors.redAccent,
////                fontWeight: FontWeight.w500
////            ),),
////            Padding(
////              padding: EdgeInsets.all(10.0),
////              child: Text(text),
////            ),
////
////            Padding(
////              padding: EdgeInsets.only(top:10.0, left: 10.0,right: 5.0),
////              child: Text("12:29 pm", style: TextStyle(color: Colors.grey,fontSize: 15.0),),
////            ),
////
////
////          ],
////        ),
////      ),
////
////    ];
////  }
////
////  @override
////  Widget build(BuildContext context) {
////    return new Container(
////      margin: const EdgeInsets.symmetric(vertical: 10.0),
////      child: new Row(
////        crossAxisAlignment: CrossAxisAlignment.start,
////        children: this.type ? myMessage(context) : otherMessage(context),
////      ),
////    );
////  }
////}