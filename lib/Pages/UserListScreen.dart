import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:messenger/Global/Colors.dart';
import 'package:messenger/Global/Constant.dart';
import 'package:messenger/Global/Routes.dart';
import 'package:messenger/Global/ScreenSizeUtils.dart';
import 'package:messenger/Global/SharedPref.dart';
import 'package:messenger/Global/Strings.dart';
import 'package:messenger/Global/Utils.dart';
import 'package:messenger/Model/UserModel.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final databaseReference = FirebaseDatabase.instance.reference();
  List<dynamic> userList = [];
  String name = '', userId = '';
  SharedPref _sharedPref;
  Utils _utils;

  @override
  void initState() {
    super.initState();
    _sharedPref = SharedPref();
    readUserData();
  }

  // read user data from sharedpreference
  readUserData() async {
    String _name = await _sharedPref.readString(_sharedPref.name);
    String _id = await _sharedPref.readString(_sharedPref.userId);
    setState(() {
      name = _name;
      userId = _id;
    });
    _utils = Utils(context: context);
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
                      'Hello ' + name + '!',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontFamily: Strings.fontName,
                          fontSize: 20.0),
                    ),
                    Stack(
                      children: [
                        Image.asset('assets/images/ic_bell.png',
                            height: SV.setHeight(75)),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Image.asset('assets/images/ic_red_circle.png',
                              height: SV.setHeight(35), width: SV.setWidth(35)),
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
                itemCount: userList.length,
                itemBuilder: (context, index) {
                  UserModel user = userList[index];
                  return Container(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: SV.setWidth(60)),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, Routes.chatScreen,
                              arguments: user);
                        },
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: SV.setHeight(30)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: SV.setHeight(160),
                                        width: SV.setHeight(160),
                                        child: CircleAvatar(
                                          radius: 30.0,
                                          child: ClipOval(
                                            child: FadeInImage.assetNetwork(
                                              placeholder:
                                                  'assets/images/ic_default_profile.png',
                                              image: Constant
                                                      .profilePathPrefix +
                                                  user.image_path
                                                      .replaceAll("/", "%2F") +
                                                  Constant.profilePathSuffix,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: SV.setWidth(60)),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user.name,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: Strings.fontName,
                                                fontSize: 14.0),
                                          ),
                                          SizedBox(height: SV.setHeight(5)),
                                          Text(
                                            'I need a heart icon in red filled.',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: Strings.fontName,
                                                fontSize: 12.0),
                                          ),
                                          SizedBox(height: SV.setHeight(10)),
                                          Text(
                                            '17/02/2021 * 03:00 PM',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: Strings.fontName,
                                                fontSize: 12.0),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  Visibility(
                                    visible: index == 0 ? true : false,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.buttonColor),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '5',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: Strings.fontName,
                                              fontSize: 14.0),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Divider(height: 1, color: AppColors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // check internet for get list of user
  _checkInternet(isAvailable) async {
    if (isAvailable) {
      _utils.showProgressDialog();
      _getUserList();
    }
  }

  // get user list from firebase realtime database
  _getUserList() {
    databaseReference.child("UserList").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> users = snapshot.value;
      setState(() {
        for (var user in users.values) {
          UserModel model = UserModel.fromJson(user);
          if (model.id != userId) {
            userList.add(model);
          }
        }
        _utils.hideProgressDialog();
      });
    });
  }
}
