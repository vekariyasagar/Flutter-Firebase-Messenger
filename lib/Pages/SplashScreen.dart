import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:messenger/Global/Colors.dart';
import 'package:messenger/Global/Routes.dart';
import 'package:messenger/Global/ScreenSizeUtils.dart';
import 'package:messenger/Global/SharedPref.dart';
import 'package:messenger/Global/Utils.dart';

import 'LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  SharedPref _sharedPref;
  Utils _utils;

  @override
  void initState() {
    super.initState();
    _utils = Utils(context: context);
    _sharedPref = SharedPref();
    new Future.delayed(new Duration(seconds: 2), () {
      _readUserDataAndRedirect();
    });
  }


  @override
  Widget build(BuildContext context) {

    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

    // This is used for device compatibility responsive UI
    ScreenUtil.instance.init(context);

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: Stack(
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
            Center(
              child: Container(
                width: SV.setHeight(250),
                height: SV.setHeight(250),
                child: Image.asset('assets/images/white_app_logo.png'),
              ),
            ),
          ],
        ),
      ),
    );

  }

  // Read data from sharedpreference and redirect the user according to data
  Future<void> _readUserDataAndRedirect() async {
    bool hashKey = await _sharedPref.containKey(_sharedPref.userId);
    String userId = "";
    print("AA_S -- " + userId);
    if (hashKey) {
      userId = await _sharedPref.readString(_sharedPref.userId);
    }
    if (_utils.isValidationEmpty(userId)) {
      Navigator.pushReplacementNamed(
        context,
        Routes.loginScreen,
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        Routes.userListScreen,
      );
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
}
