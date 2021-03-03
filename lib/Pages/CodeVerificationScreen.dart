import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:messenger/Global/Colors.dart';
import 'package:messenger/Global/Routes.dart';
import 'package:messenger/Global/ScreenSizeUtils.dart';
import 'package:messenger/Global/SharedPref.dart';
import 'package:messenger/Global/Strings.dart';
import 'package:messenger/Global/Utils.dart';
import 'package:messenger/Model/UserModel.dart';

class CodeVerificationScreen extends StatefulWidget {
  String mobileNo;
  String verificationId;

  CodeVerificationScreen({this.mobileNo, this.verificationId});

  @override
  _CodeVerificationScreenState createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  String verificationCode = '';
  Utils _utils;
  SharedPref _sharedPref;
  var firebaseAuth;
  final databaseReference = FirebaseDatabase.instance.reference();
  List<dynamic> userList = [];
  String _verificationId = '';

  CountdownTimerController controller;
  int _endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 80;
  bool isTimerVisible = false;

  @override
  void initState() {
    super.initState();
    _utils = Utils(context: context);
    _sharedPref = SharedPref();
    _initializeFirebase();
    setState(() {
      _verificationId = widget.verificationId;
    });
    controller = CountdownTimerController(endTime: _endTime, onEnd: _onEnd);
    controller.start();
    setState(() {
      isTimerVisible = true;
    });
  }

  _initializeFirebase() async {
    firebaseAuth = FirebaseAuth.instance;
  }

  @override
  Widget build(BuildContext context) {
    // This is used for device compatibility responsive UI
    ScreenUtil.instance.init(context);

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          padding: EdgeInsets.all(SV.setHeight(50)),
          margin: EdgeInsets.only(top: SV.setHeight(150)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/theme_color_app_logo.png',
                      height: SV.setHeight(150),
                      width: SV.setHeight(150),
                    ),
                  ),
                  SizedBox(height: SV.setHeight(150)),
                  Row(
                    children: [
                      IconButton(
                        icon: new Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        Strings.changePhoneNumber,
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontFamily: Strings.fontName,
                            fontSize: 13.0),
                      ),
                    ],
                  ),
                  SizedBox(height: SV.setHeight(80)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: SV.setWidth(50)),
                    child: Text(
                      Strings.enterVerificationCodeContent,
                      style: TextStyle(
                          color: Colors.black,
                          fontFamily: Strings.fontName,
                          fontSize: 14.0),
                    ),
                  ),
                  SizedBox(height: SV.setHeight(100)),
                  Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: SV.setWidth(50)),
                      child: _verificationTextFieldWidget()),
                  Visibility(
                    visible: isTimerVisible,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: SV.setHeight(90)),
                        child: CountdownTimer(
                          endTime: _endTime,
                          widgetBuilder: (_, CurrentRemainingTime time) {
                            if (time == null) {
                              return Container();
                            } else {
                              String minute = time.min == null
                                  ? "00"
                                  : "0" + time.min.toString();
                              String second = time.sec == null
                                  ? "00"
                                  : time.sec.toString().length == 1
                                      ? "0" + time.sec.toString()
                                      : time.sec.toString();
                              return Text(
                                minute + " : " + second,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: Strings.fontName,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.0),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: SV.setHeight(70)),
                  _resendCodeButton()
                ],
              ),
              _verifyCodeButton()
            ],
          ),
        ),
      ),
    );
  }

  // user input - design of enter verification code
  _verificationTextFieldWidget() {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.edtBackgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        cursorColor: Colors.black,
        onChanged: (val) {
          setState(() {
            verificationCode = val;
          });
        },
        keyboardType: TextInputType.number,
        style: TextStyle(
          fontFamily: Strings.fontName,
          fontSize: SV.setSP(45),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(
            left: SV.setWidth(25),
            right: SV.setWidth(25),
            top: SV.setWidth(25),
          ),
          hintText: Strings.verificationCode,
          hintStyle: TextStyle(
              color: AppColors.transparentBlack,
              fontFamily: Strings.fontName,
              fontSize: 14.0),
          isDense: true,
          counter: SizedBox.shrink(),
        ),
      ),
    );
  }

  // button - design of resend code button
  _resendCodeButton() {
    return Center(
      child: Container(
        width: SV.setWidth(550),
        child: RaisedButton(
          onPressed: isTimerVisible == true
              ? null
              : () {
                  _utils
                      .isNetwotkAvailable(true)
                      .then((value) => _checkInternetForResendCode(value));
                },
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          padding: const EdgeInsets.all(0.0),
          child: Container(
            constraints: const BoxConstraints(minWidth: 88.0, minHeight: 42.0),
            decoration: BoxDecoration(
                color: isTimerVisible != true
                    ? AppColors.buttonColor
                    : AppColors.grey,
                borderRadius: BorderRadius.all(Radius.circular(8))),
            alignment: Alignment.center,
            child: Text(
              Strings.resendCode,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: Strings.fontName,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  // button - design of verify button
  _verifyCodeButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(SV.setWidth(50), 0, SV.setWidth(50), 0),
      child: RaisedButton(
        onPressed: () {
          _checkValidation();
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
        padding: const EdgeInsets.all(0.0),
        child: Container(
          constraints: const BoxConstraints(minWidth: 88.0, minHeight: 42.0),
          decoration: BoxDecoration(
              color: AppColors.buttonColor,
              borderRadius: BorderRadius.all(Radius.circular(8))),
          alignment: Alignment.center,
          child: Text(
            Strings.verify,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontFamily: Strings.fontName,
                fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  // check internet for resend code
  _checkInternetForResendCode(isAvailable) {
    if (isAvailable) {
      _utils.showProgressDialog();
      _resendCode();
    }
  }

  // check validation for which user enter the code
  _checkValidation() {
    if (_utils.isValidationEmpty(verificationCode)) {
      _utils.alertDialog(Strings.enterVerificationCode);
    } else {
      _utils.isNetwotkAvailable(true).then((value) => _checkInternet(value));
    }
  }

  // check internet for verify code
  _checkInternet(isAvailable) {
    if (isAvailable) {
      _utils.showProgressDialog();
      _verifyCode();
    }
  }

  // when countdown timer will be completed then it's call
  _onEnd() {
    setState(() {
      isTimerVisible = false;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // resend code using firebase authentication
  _resendCode() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91 ' + widget.mobileNo,
      verificationCompleted: (PhoneAuthCredential credential) {
        _utils.hideProgressDialog();
      },
      verificationFailed: (FirebaseAuthException e) {
        _utils.hideProgressDialog();
        _utils.alertDialog(e.toString().split("]")[1]);
      },
      codeSent: (String verificationId, int resendToken) {
        _utils.hideProgressDialog();
        setState(() {
          isTimerVisible = true;
          _verificationId = verificationId;
        });
      },
      timeout: const Duration(seconds: 30),
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  // verify code with the firebase server
  _verifyCode() async {
    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: verificationCode);
      final User user =
          (await firebaseAuth.signInWithCredential(phoneAuthCredential)).user;
      print(user.uid);
      if (_utils.isValidationEmpty(user.uid)) {
        _utils.hideProgressDialog();
        _utils.alertDialog(Strings.invalidCode);
      } else {
        _getUserList();
      }
    } catch (e) {
      _utils.hideProgressDialog();
      print(e.toString());
      _utils.alertDialog(e.toString().split("]")[1]);
    }
  }

  // get user list from firebase realtime database
  _getUserList() {
    databaseReference.child("UserList").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> users = snapshot.value;
      for (var user in users.values) {
        print(user);
        UserModel model = UserModel.fromJson(user);
        userList.add(model);
      }
      _utils.hideProgressDialog();
      _checkUserAndRedirect();
    });
  }

  // check the user exist or not, if user exist then redirect to user list screen otherwise redirect to register screen
  _checkUserAndRedirect() {
    bool isMatch = false;
    int tempUserPos = 0;
    print("AA_S -- " + userList.length.toString());
    if (userList.length > 0) {
      for (int i = 0; i < userList.length; i++) {
        UserModel user = userList[i];
        print(user.mobile_no + " -- " + widget.mobileNo);
        if (user.mobile_no == widget.mobileNo) {
          tempUserPos = i;
          isMatch = true;
          break;
        }
      }
      if (isMatch) {
        _saveUserData(tempUserPos).then((value) => Navigator.of(context)
            .pushNamedAndRemoveUntil(
                Routes.userListScreen, (Route<dynamic> route) => false));
      } else {
        Navigator.pushNamed(context, Routes.registrationScreen,
            arguments: widget.mobileNo);
      }
    } else {
      Navigator.pushNamed(context, Routes.registrationScreen,
          arguments: widget.mobileNo);
    }
  }

  // if user exist, store the user details in sharedpreference
  Future<void> _saveUserData(int pos) async {
    UserModel user = userList[pos];
    print(user.id + " -- " + user.name + " -- " + user.image_path);
    _sharedPref.saveString(_sharedPref.userId, user.id);
    _sharedPref.saveString(_sharedPref.name, user.name);
    _sharedPref.saveString(_sharedPref.profilePath, user.image_path);
  }
}
