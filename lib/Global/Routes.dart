import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:messenger/Model/PassUserArgument.dart';
import 'package:messenger/Model/UserModel.dart';
import 'package:messenger/Pages/ChatScreen.dart';
import 'package:messenger/Pages/CodeVerificationScreen.dart';
import 'package:messenger/Pages/LoginScreen.dart';
import 'package:messenger/Pages/RegistrationScreen.dart';
import 'package:messenger/Pages/UserListScreen.dart';

class Routes {
  static const loginScreen = 'LoginScreen';
  static const codeVerificationScreen = 'CodeVerificationScreen';
  static const registrationScreen = 'RegistrationScreen';
  static const userListScreen = 'UserListScreen';
  static const chatScreen = 'ChatScreen';

  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case loginScreen:
        return MaterialPageRoute(
            builder: (_) => new LoginScreen());
        break;
      case codeVerificationScreen:
        PassUserArguments arguments = settings.arguments;
        return MaterialPageRoute(
            builder: (_) => new CodeVerificationScreen(mobileNo: arguments.mobileNo,verificationId: arguments.verificationId));
        break;
      case registrationScreen:
        String mobileNo = settings.arguments as String;
        return MaterialPageRoute(
            builder: (_) => new RegistrationScreen(mobileNo: mobileNo));
        break;
      case userListScreen:
        return MaterialPageRoute(builder: (_) => new UserListScreen());
        break;
      case chatScreen:
        UserModel user = settings.arguments as UserModel;
        return MaterialPageRoute(builder: (_) => new ChatScreen(receiverUser: user));
        break;
    }
  }
}
