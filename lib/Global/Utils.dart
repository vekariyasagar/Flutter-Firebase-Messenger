import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:messenger/Global/Colors.dart';
import 'package:messenger/Global/Strings.dart';

class Utils {
  BuildContext context;

  Utils({this.context});

  // Checking internet on/off
  Future<bool> isNetwotkAvailable(bool showDialog) async {
    ConnectivityResult _result;
    final Connectivity _connectivity = Connectivity();
    try {
      _result = await _connectivity.checkConnectivity();
      print(_result);
      switch (_result) {
        case ConnectivityResult.wifi:
          return true;
        case ConnectivityResult.mobile:
          return true;
        default:
          if (showDialog) {
            alertDialog(
                Strings.internetError);
          }
          return false;
      }
    } on PlatformException catch (e) {
      print(e.toString());
      if (showDialog) {
        alertDialog(Strings.internetError);
      }
      return false;
    }
  }

  // When user getting response from server, need to show message or validation is mismatch at time to display dialog
  void alertDialog(String title) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                'Messenger',
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: Strings.fontName,
                    fontWeight: FontWeight.w700),
              ),
              content: Text(title,
                  style: TextStyle(
                      fontSize: 15,
                      fontFamily: Strings.fontName,
                      fontWeight: FontWeight.w400)),
              actions: <Widget>[
                FlatButton(
                  child: Text(Strings.ok),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ]);
        });
  }

  // Checking validation empty or not
  bool isValidationEmpty(String val) {
    if (val == null ||
        val.isEmpty ||
        val == "null" ||
        val == "" ||
        val.length == 0 ||
        val == "NULL") {
      return true;
    } else {
      return false;
    }
  }

  // Checking email validation
  bool emailValidator(String email) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(email)) {
      return true;
    }

    return false;
  }

  // When call background task at that time display progress dialog
  void showProgressDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Container(
                child: Center(
              child: Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                      color:AppColors.blueGradientStartColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      SpinKitPouringHourglass(color: Colors.white, size: 40.0),
                      SizedBox(height: 20),
                      Text(
                        Strings.loading,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.white,
                            fontFamily: Strings.fontName,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  )),
            )),
          );
        });
  }

  // Hide progress dialog, when the process of API calling is completed
  void hideProgressDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  // Checking types of device
  String getDeviceType() {
    if (Platform.isAndroid) {
      return 'Android';
    } else {
      return 'iOS';
    }
  }

}
