import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customersupport/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeerMessageBox extends StatelessWidget {
  final int index;
  final DocumentSnapshot document;
  final String id;
  final listMessage;
  const PeerMessageBox({Key key, this.index, this.document, this.id, this.listMessage}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
//                              child: CachedNetworkImage(
//                                placeholder: (c, m) {
//                                  return Container(
//                                    child: CircularProgressIndicator(
//                                      valueColor: AlwaysStoppedAnimation<Color>(
//                                          themeColor),
//                                    ),
//                                    width: 200.0,
//                                    height: 200.0,
//                                    padding: EdgeInsets.all(70.0),
//                                    decoration: BoxDecoration(
//                                      color: greyColor2,
//                                      borderRadius: BorderRadius.all(
//                                        Radius.circular(8.0),
//                                      ),
//                                    ),
//                                  );
//                                },
//                                errorWidget: (c, s, o) {
//                                  return Material(
//                                    child: Image.asset(
//                                      'images/img_not_available.jpeg',
//                                      width: 200.0,
//                                      height: 200.0,
//                                      fit: BoxFit.cover,
//                                    ),
//                                    borderRadius: BorderRadius.all(
//                                      Radius.circular(8.0),
//                                    ),
//                                  );
//                                },
//                                imageUrl: document['content'],
//                                width: 200.0,
//                                height: 200.0,
//                                fit: BoxFit.cover,
//                              ),
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

}
