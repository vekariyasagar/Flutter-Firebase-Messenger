import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messenger/Global/Colors.dart';
import 'package:messenger/Global/Routes.dart';
import 'package:messenger/Global/ScreenSizeUtils.dart';
import 'package:messenger/Global/SharedPref.dart';
import 'package:messenger/Global/Strings.dart';
import 'package:messenger/Global/Utils.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:messenger/Model/UserModel.dart';
import 'package:random_string/random_string.dart';

class RegistrationScreen extends StatefulWidget {
  var mobileNo;

  RegistrationScreen({this.mobileNo});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  String name = '', aboutUs = '';
  File imageFile, imageCropFile;
  AppState state;
  Utils _utils;
  SharedPref _sharedPref;

  final databaseReference = FirebaseDatabase.instance.reference();

  @override
  void initState() {
    super.initState();
    _utils = Utils(context: context);
    _sharedPref = SharedPref();
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
        body: Padding(
          padding: EdgeInsets.fromLTRB(SV.setHeight(120), SV.setHeight(120),
              SV.setHeight(120), SV.setHeight(50)),
          child: Column(
            children: [
              SizedBox(height: SV.setHeight(30)),
              _userProfile(),
              SizedBox(height: SV.setHeight(120)),
              _nameTextField(),
              SizedBox(height: SV.setHeight(50)),
              _aboutMeTextField(),
              Spacer(),
              _getStartedButton()
            ],
          ),
        ),
      ),
    );
  }

  // design of the display profile picture when user select from gallery or capture using camera
  _userProfile() {
    return Center(
      child: GestureDetector(
        onTap: () {
          showGeneralDialog(
            context: context,
            barrierLabel: "imagePicker",
            barrierDismissible: true,
            transitionDuration: Duration(milliseconds: 700),
            pageBuilder: (context, anim1, anim2) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: _imagePickerDialog(),
              );
            },
            transitionBuilder: (context, anim1, anim2, child) {
              return SlideTransition(
                position: Tween(begin: Offset(0, 1), end: Offset(0, 0))
                    .animate(anim1),
                child: child,
              );
            },
          );
        },
        child: Stack(
          children: [
            Container(
              width: SV.setWidth(300),
              height: SV.setHeight(300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.buttonColor,
                image: DecorationImage(
                  image: imageFile == null
                      ? AssetImage('assets/images/theme_color_circle.png')
                      : FileImage(imageFile),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: SV.setHeight(90),
                  width: SV.setHeight(90),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    /* boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 1,
                        offset: Offset(0, 0.2), // changes position of shadow
                      ),
                    ],*/
                  ),
                  child: Icon(
                    Icons.add,
                    size: SV.setHeight(80),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // user input - design of enter name
  _nameTextField() {
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
            name = val;
          });
        },
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
          hintText: Strings.userName,
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

  // user input - design of about me
  _aboutMeTextField() {
    return Container(
      height: SV.setHeight(SV.setHeight(980)),
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.edtBackgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        cursorColor: Colors.black,
        onChanged: (val) {
          setState(() {
            aboutUs = val;
          });
        },
        maxLines: null,
        keyboardType: TextInputType.multiline,
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
          hintText: Strings.aboutMe,
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

  // button - design of get started button
  _getStartedButton() {
    return RaisedButton(
      onPressed: () {
        _checkValidation();
      },
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8))),
      padding: const EdgeInsets.all(0.0),
      child: Container(
        height: 42.0,
        constraints: const BoxConstraints(minWidth: 88.0, minHeight: 42.0),
        decoration: BoxDecoration(
            color: AppColors.buttonColor,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        alignment: Alignment.center,
        child: Text(
          Strings.getStarted,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white,
              fontFamily: Strings.fontName,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // design of image picker dialog
  _imagePickerDialog() {
    return Wrap(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: SV.setHeight(80), horizontal: SV.setHeight(120)),
                child: Text(
                  Strings.changeProfileImage,
                  style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      fontFamily: Strings.fontName,
                      fontSize: 13.0),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    SV.setHeight(120), 0, SV.setHeight(120), SV.setHeight(60)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    getImage(ImageSource.camera);
                  },
                  child: Row(
                    children: [
                      Image.asset('assets/images/ic_camera.png',
                          height: SV.setHeight(80)),
                      SizedBox(width: SV.setWidth(50)),
                      Text(
                        Strings.camera,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontFamily: Strings.fontName,
                            fontSize: 13.0),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 2,
                color: Colors.black,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SV.setHeight(120), vertical: SV.setHeight(60)),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    getImage(ImageSource.gallery);
                  },
                  child: Row(
                    children: [
                      Image.asset('assets/images/ic_gallery.png',
                          height: SV.setHeight(80)),
                      SizedBox(width: SV.setWidth(50)),
                      Text(
                        Strings.gallery,
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                            fontFamily: Strings.fontName,
                            fontSize: 13.0),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // check validation for which user enter the data
  _checkValidation() {
    if (imageFile == null) {
      _utils.alertDialog(Strings.selectImage);
    } else if (_utils.isValidationEmpty(name)) {
      _utils.alertDialog(Strings.enterName);
    } else if (_utils.isValidationEmpty(aboutUs)) {
      _utils.alertDialog(Strings.aboutMe);
    } else {
      _utils.isNetwotkAvailable(true).then((value) => _checkInternet(value));
    }
  }

  // check internet for send image and user registration
  _checkInternet(isAvailable) async {
    if (isAvailable) {
      _utils.showProgressDialog();
      firebase_storage.UploadTask task = await uploadFile(imageFile);
      if (task != null) {
        print(task.snapshot.ref.fullPath);
        String id = randomNumeric(6);
        databaseReference.child("UserList").push().set({
          'name': name,
          'about_us': aboutUs,
          'image_path': task.snapshot.ref.fullPath,
          'id' : id,
          'mobile_no': widget.mobileNo
        });
        _utils.hideProgressDialog();
        _saveUserData(id,task.snapshot.ref.fullPath).then((value) => Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.userListScreen, (Route<dynamic> route) => false));
      } else {
        print("task null");
      }
    }
  }

  // Upload profile image in firebase storage
  Future<firebase_storage.UploadTask> uploadFile(File file) async {
    firebase_storage.UploadTask uploadTask;

    String imageName = imageFile.path
        .substring(imageFile.path.lastIndexOf("/"), imageFile.path.lastIndexOf("."))
        .replaceAll("/", "");

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('profile')
        .child(imageName);

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': file.path});

    uploadTask = ref.putFile(File(file.path), metadata);

    return Future.value(uploadTask);
  }

  // store the user details in sharedpreference
  Future<void> _saveUserData(String id,String imagePath) async{
    _sharedPref.saveString(_sharedPref.userId, id);
    _sharedPref.saveString(_sharedPref.name, name);
    _sharedPref.saveString(_sharedPref.profilePath, imagePath);
  }

  // get the image when user pick from gallery or capture using camera
  Future<void> getImage(ImageSource imageSource) async {
    try {
      final file = await ImagePicker.pickImage(source: imageSource);
      setState(() {
        imageFile = file;
        state = AppState.picked;
      });
      _cropImage();
    } catch (e) {
      print(e);
    }
  }

  // image crop function call after the user picking the image
  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: AppColors.buttonColor,
            cropFrameColor: AppColors.buttonColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
            //title: 'Cropper',
            ));
    if (croppedFile != null) {
      setState(() {
        imageFile = croppedFile;
      });
      setState(() {
        state = AppState.cropped;
      });
    }
  }
}
