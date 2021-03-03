import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messenger/Global/Colors.dart';
import 'package:messenger/Global/Routes.dart';
import 'package:messenger/Global/ScreenSizeUtils.dart';
import 'package:messenger/Global/Strings.dart';
import 'package:messenger/Global/Utils.dart';
import 'package:messenger/Model/PassUserArgument.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  String phoneNumber = '';

  Utils _utils;
  var firebaseAuth;

  @override
  void initState() {
    super.initState();
    _utils = Utils(context: context);
    _initializeFirebase();
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
        body: _mobileContent(),
      ),
    );
  }

  _mobileContent() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                AppColors.blueGradientStartColor,
                AppColors.blueGradientEndColor
              ])),
        ),
        Column(
          children: [
            Expanded(
                flex: 3,
                child: Image.asset(
                  'assets/images/white_app_logo.png',
                  height: SV.setHeight(150),
                  width: SV.setHeight(150),
                )),
            Expanded(
              flex: 7,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(80))),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(SV.setHeight(120),
                      SV.setHeight(120), SV.setHeight(120), SV.setHeight(50)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: SV.setHeight(50)),
                          Text(
                            Strings.login,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: Strings.fontName,
                                fontWeight: FontWeight.w700,
                                fontSize: 22.0),
                          ),
                          SizedBox(height: SV.setHeight(120)),
                          Text(
                            Strings.loginContent,
                            style: TextStyle(
                                color: Colors.black,
                                fontFamily: Strings.fontName,
                                fontSize: 14.0),
                          ),
                          SizedBox(height: SV.setHeight(100)),
                          _mobileNumberTextField(),
                        ],
                      ),
                      _sendCodeButton(),
                    ],
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  // user input - design of enter phone number
  _mobileNumberTextField() {
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
            phoneNumber = val;
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
          hintText: Strings.phoneNumber,
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

  // button - design of send code button
  _sendCodeButton(){
    return RaisedButton(
      onPressed: () {
        _checkValidation();
      },
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(8))),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        height: 42.0,
        constraints: const BoxConstraints(
            minWidth: 88.0, minHeight: 42.0),
        decoration: BoxDecoration(
            color: AppColors.buttonColor,
            borderRadius:
            BorderRadius.all(Radius.circular(8))),
        alignment: Alignment.center,
        child: Text(
          Strings.sendCode,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontFamily: Strings.fontName,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // check validation for which user enter the phone number
  _checkValidation(){
    if(_utils.isValidationEmpty(phoneNumber)){
      _utils.alertDialog(Strings.enterPhoneNumber);
    }else{
      _utils.isNetwotkAvailable(true).then((value) => _checkInternet(value));
    }
  }

  // check internet on/off
  _checkInternet(isAvailable){
    if(isAvailable){
      _utils.showProgressDialog();
      _sendCode();
    }
  }

  // send code using the firebase phone authentication
  _sendCode() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91 '+phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        _utils.hideProgressDialog();
      },
      verificationFailed: (FirebaseAuthException e) {
        _utils.hideProgressDialog();
        _utils.alertDialog(e.toString().split("]")[1]);
      },
      codeSent: (String verificationId, int resendToken) {
        _utils.hideProgressDialog();
        Navigator.pushNamed(
            context, Routes.codeVerificationScreen,
            arguments: PassUserArguments(phoneNumber,verificationId));
      },
      timeout: const Duration(seconds: 30),
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

}
