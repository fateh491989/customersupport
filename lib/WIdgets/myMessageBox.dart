import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customersupport/Config/config.dart';
import 'package:customersupport/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyMessages extends StatelessWidget {
  final int index;
  final DocumentSnapshot document;
  final String id;
  final listMessage;

  const MyMessages(
      {Key key, this.index, this.document, this.listMessage, this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  document[UserMessage.type] == 0
                      // Text
                      ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "${document[UserMessage.content]} ",
                                style: TextStyle(color: primaryColor),
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      DateFormat('dd MMM kk:mm').format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              int.parse(document[UserMessage.timestamp]))),
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
                      : document[UserMessage.type] == 1
                          // Image
                          ? Container(
                              child: Column(
                                children: <Widget>[
                                  Material(
                                    child: document[UserMessage.content] == 'Image'
                                        ? Column(
                                            children: <Widget>[
                                              Image.asset(
                                                'assets/images/loading.png',
                                                height: 250,
                                                width: 300,
                                              ),
                                              Container(
                                                  height: 20,
                                                  width: 280,
                                                  child: DateShow(document: document[UserMessage.timestamp],))
                                            ],

                                          )
                                        : Column(
                                          children: <Widget>[
                                            FadeInImage(
                                                placeholder:
                                                    AssetImage('assets/images/loading.png'),
                                                image: NetworkImage(document[UserMessage.content]),
                                                height: 250,
                                                width: 300,
                                              ),
                                            Container(
                                                height: 20,
                                                width: 280,
                                                child: DateShow(document: document[UserMessage.timestamp],))
                                          ],
                                        ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                ],
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
              ),
            ],
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      )
    ]);
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1][UserMessage.idFrom] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1][UserMessage.idFrom] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }
}


class DateShow extends StatelessWidget {
  final String document;
  const DateShow({Key key, this.document}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          child: Text(
            DateFormat('dd MMM kk:mm').format(
                DateTime.fromMillisecondsSinceEpoch(
                    int.parse(document))),
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
    );
  }
}
