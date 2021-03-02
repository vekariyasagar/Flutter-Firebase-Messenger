import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:messenger/Global/Colors.dart';

import 'Global/Routes.dart';
import 'Pages/SplashScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messenger',
      theme: AppThemeData,
      onGenerateRoute: Routes.generateRoutes,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
