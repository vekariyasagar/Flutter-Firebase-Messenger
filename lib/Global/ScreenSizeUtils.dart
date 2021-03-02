import 'package:flutter/material.dart';

class SV {
  static double width;
  static double height;
  static double notch = ScreenUtil.statusBarHeight;
  static double bottomBar = ScreenUtil.bottomBarHeight;
  static Size mq = ScreenUtil.mediaQueryData.size;
  static setHeight(double height) => ScreenUtil.instance.setHeight(height);
  static setWidth(double width) => ScreenUtil.instance.setWidth(width);
  static setHeightRatio(double height) => ScreenUtil.instance
      .setHeight((SV.getHeight * height) - AppBar().preferredSize.height);
  static setWidthRatio(double width) =>
      ScreenUtil.instance.setWidth(SV.getWidth * width);

  static double getWidth = ScreenUtil.instance.width;
  static double getHeight = ScreenUtil.instance.height;
  static setSP(double size) => ScreenUtil.instance.setSp(size);
}

// In this class getting height and width according to device resolution

class ScreenUtil {
  static ScreenUtil instance = new ScreenUtil();

  double width;
  double height;
  bool allowFontScaling;

  static MediaQueryData _mediaQueryData;
  static double _screenWidth;
  static double _screenHeight;
  static double _pixelRatio;
  static double _statusBarHeight;

  static double _bottomBarHeight;

  static double _textScaleFactor;

  ScreenUtil({
    this.width = 1080,
    this.height = 1920,
    this.allowFontScaling = false,
  });

  static ScreenUtil getInstance() {
    return instance;
  }

  void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _mediaQueryData = mediaQuery;
    _pixelRatio = mediaQuery.devicePixelRatio;
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _statusBarHeight = mediaQuery.padding.top;
    _bottomBarHeight = _mediaQueryData.padding.bottom;
    _textScaleFactor = mediaQuery.textScaleFactor;
  }

  static MediaQueryData get mediaQueryData => _mediaQueryData;

  static double get textScaleFactory => _textScaleFactor;

  static double get pixelRatio => _pixelRatio;

  /// dp
  static double get screenWidthDp => _screenWidth;

  /// dp
  static double get screenHeightDp => _screenHeight;

  /// px
  static double get screenWidth => _screenWidth * _pixelRatio;

  /// px
  static double get screenHeight => _screenHeight * _pixelRatio;

  /// dp
  static double get statusBarHeight => _statusBarHeight;

  /// dp
  static double get bottomBarHeight => _bottomBarHeight;

  get scaleWidth => _screenWidth / instance.width;

  get scaleHeight => _screenHeight / instance.height;

  setWidth(double width) => width * scaleWidth;

  setHeight(double height) => height * scaleHeight;

  ///@param fontSize px ,
  ///@param allowFontScaling false。
  ///@param allowFontScaling Specifies whether fonts should scale to respect Text Size accessibility settings. The default is false.
  setSp(double fontSize) => allowFontScaling
      ? setWidth(fontSize)
      : setWidth(fontSize) / _textScaleFactor;
}
