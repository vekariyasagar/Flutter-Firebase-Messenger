import 'package:flutter/material.dart';

final ThemeData AppThemeData = new ThemeData(
    brightness: Brightness.light,
    primaryColorBrightness: Brightness.light,
    accentColor: Color(AppColors._white),
    accentColorBrightness: Brightness.light);

class AppColors {


  static Color blueGradientStartColor = Color(0xFF3B1FB1);
  static Color blueGradientEndColor = Color(0xFF341C63);

  static Color buttonColor = Color(0xFF341C63);

  static Color edtBackgroundColor = Color(0x1A341C63);
  static Color transparentBlack = Color(0x40000000);
  static Color red = Color(0xFFFF0000);
  static Color grey = Color(0xFFA6A6A6);
  static Color green = Color(0xFF55A38B);

  AppColors._();

  static const _white = 0xFFFFFFFF;

}
