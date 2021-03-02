import 'package:bubble/bubble.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:messenger/Global/Colors.dart';
import 'package:messenger/Global/Constant.dart';
import 'package:messenger/Global/ScreenSizeUtils.dart';
import 'package:messenger/Global/SharedPref.dart';
import 'package:messenger/Global/Strings.dart';
import 'package:messenger/Global/Utils.dart';
import 'package:messenger/Model/MessageModel.dart';
import 'package:messenger/Model/UserModel.dart';

class ChatScreen extends StatefulWidget {
  UserModel receiverUser;

  ChatScreen({this.receiverUser});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Utils _utils;
  SharedPref _sharedPref;
  String senderName = '', profile = '', senderId = '';
  String chatId = '';
  final databaseReference = FirebaseDatabase.instance.reference();
  String message = '';
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = new ScrollController();
  List<dynamic> tempMessageList = [],messageList = [];

  @override
  void initState() {
    super.initState();
    _utils = Utils(context: context);
    _sharedPref = SharedPref();
    readUserData();
  }

  // read user data from sharedpreference
  readUserData() async {
    String _name = await _sharedPref.readString(_sharedPref.name);
    String _id = await _sharedPref.readString(_sharedPref.userId);
    String _path = await _sharedPref.readString(_sharedPref.profilePath);
    setState(() {
      senderName = _name;
      senderId = _id;
      profile = _path;
      print('AA_S -- ' + senderId + " -- " + widget.receiverUser.id);
      if (int.parse(senderId) > int.parse(widget.receiverUser.id)) {
        chatId = senderId + "_" + widget.receiverUser.id;
      } else {
        chatId = widget.receiverUser.id + "_" + senderId;
      }
    });
    _utils.isNetwotkAvailable(true).then((value) => _checkInternet(value));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: SV.setHeight(300),
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 0.2), // changes position of shadow
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: SV.setWidth(60)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.receiverUser.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontFamily: Strings.fontName,
                          fontSize: 20.0),
                    ),
                    Stack(
                      children: [
                        Container(
                          height: SV.setHeight(140),
                          width: SV.setHeight(140),
                          child: CircleAvatar(
                            radius: 30.0,
                            child: ClipOval(
                              child: FadeInImage.assetNetwork(
                                placeholder:
                                    'assets/images/ic_default_profile.png',
                                image: Constant.profilePathPrefix +
                                    widget.receiverUser.image_path
                                        .replaceAll("/", "%2F") +
                                    Constant.profilePathSuffix,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Image.asset(
                              'assets/images/ic_online_badge.png',
                              height: SV.setHeight(40),
                              width: SV.setWidth(40)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: messageList.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  MessageModel messageModel = messageList[index];
                  return Container(
                    child: messageModel.sender_id == senderId
                        ? _buildSenderRow(messageModel)
                        : _buildReceiverRow(messageModel),
                  );
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 0.2), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: SV.setWidth(60.0),
                          vertical: SV.setWidth(2.0)),
                      alignment: Alignment.center,
                      child: TextField(
                        maxLines: 8,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        onChanged: (val) {
                          setState(() {
                            message = val;
                          });
                        },
                        controller: _messageController,
                        style: new TextStyle(
                            fontFamily: Strings.fontName,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                        textAlign: TextAlign.left,
                        cursorColor: AppColors.buttonColor,
                        decoration: new InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            hintText: Strings.yourMessageGoesHere,
                            hintStyle: new TextStyle(
                                fontFamily: Strings.fontName,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  Container(
                    height: SV.setWidth(80),
                    width: SV.setWidth(80),
                    margin: EdgeInsets.only(right: SV.setWidth(60)),
                    child: InkWell(
                        onTap: () {
                          if (_utils.isValidationEmpty(message)) {
                            _utils.alertDialog(Strings.enterMessage);
                          } else {
                            _sendMessage();
                          }
                        },
                        child: Image.asset('assets/images/ic_send.png')),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // design of item of message which is sending by sender
  _buildSenderRow(MessageModel messageModel) {
    return Container(
      margin: EdgeInsets.only(
          top: SV.setHeight(30),
          left: SV.setWidth(100),
          right: SV.setWidth(40),
          bottom: SV.setHeight(30)),
      child: Align(
        alignment: Alignment.centerRight,
        child: Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 0.2), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )),
              child: Padding(
                padding: EdgeInsets.all(SV.setWidth(30)),
                child: Bubble(
                  elevation: 0,
                  stick: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(senderName,
                          style: new TextStyle(
                              fontFamily: Strings.fontName,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              height: 1.0)),
                      SizedBox(height: SV.setHeight(30)),
                      Text(messageModel.message,
                          style: new TextStyle(
                              fontFamily: Strings.fontName,
                              fontSize: SV.setSP(40),
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              height: 1.3)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // design of item of message which is sending by receiver
  _buildReceiverRow(MessageModel messageModel) {
    return Container(
      margin: EdgeInsets.only(
          top: SV.setHeight(30),
          right: SV.setWidth(100),
          left: SV.setWidth(40),
          bottom: SV.setHeight(30)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 0.2), // changes position of shadow
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )),
              child: Padding(
                padding: EdgeInsets.all(SV.setWidth(30)),
                child: Bubble(
                  elevation: 0,
                  stick: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.receiverUser.name,
                          style: new TextStyle(
                              fontFamily: Strings.fontName,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              height: 1.0)),
                      SizedBox(height: SV.setHeight(30)),
                      Text(messageModel.message,
                          style: new TextStyle(
                              fontFamily: Strings.fontName,
                              fontSize: SV.setSP(40),
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                              height: 1.3)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getAllMessageList() {
    databaseReference
        .child("ChatList")
        .child(chatId)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> users = snapshot.value;
      setState(() {
        for (var user in users.values) {
          MessageModel model = MessageModel.fromJson(user);
          messageList.add(model);
        }
      });
    });
  }

  // check internet for get list of message
  _checkInternet(isAvailable) async {
    if (isAvailable) {
      _getMessageList();
    }
  }

  // get all message list from the firebase
  _getMessageList() {
    databaseReference
        .child('ChatList')
        .child(chatId)
        .onChildAdded
        .listen((event) {
      MessageModel model = MessageModel.fromJson(event.snapshot.value);
      tempMessageList.add(model);
      tempMessageList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      setState(() {
        messageList = tempMessageList;
      });
      new Future.delayed(new Duration(milliseconds: 300), () {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
      });
    });
  }

  // send message to firebase server
  _sendMessage() {
    print("AA_S -- " + chatId);
    databaseReference.child("ChatList").child(chatId).push().set({
      'message': message,
      'sender_id': senderId,
      'timestamp': ServerValue.timestamp
    });
    setState(() {
      message = '';
      _messageController.clear();
    });
  }
}
