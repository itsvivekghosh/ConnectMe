import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:ConnectMe/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ConnectMe/helper/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:ConnectMe/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ConnectMe/views/chatRoomDashboard.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Profile extends StatefulWidget {

  final Color lightThemeColor;
  final Function toggleTheme, toggleAccentColor;
  final String userName, phoneNumber;
  Profile({this.toggleTheme, this.lightThemeColor, this.userName, this.phoneNumber, this.toggleAccentColor});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  File _image;
  String userName;
  String phoneNumber;
  Widget image;
  bool _loading = true;
  bool showBottomSheetMenu = false;
  final formKey = GlobalKey<FormState>();
  final fireStoreInstance = Firestore.instance;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final DatabaseMethods _databaseMethods = new DatabaseMethods();
  TextEditingController userNameController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();
  String profileImage = 'https://raw.githubusercontent.com/itsvivekghosh/flutter-tutorial/master/default.png';

  @override
  void initState() {
    if (mounted) {
      getUserData();
      Future.delayed(Duration(milliseconds: 900), () {
        setState(() {
          _loading = false;
          showBottomSheetMenu = false;
        });
      });
      super.initState();
    }
  }

  Future getUserData() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    var userData = await _databaseMethods.getUsersByUserEmail(firebaseUser.email);

    setState(() {
      userName = userData.documents[0].data['name'];
      phoneNumber = userData.documents[0].data['phoneNumber'];
      profileImage = userData.documents[0].data['profileImage'];
      image = Container(
        decoration: BoxDecoration(
            color: Constants.currentTheme == 'dark' ? Colors.black38 : Colors.white
        ),
        child: CachedNetworkImage(
            imageUrl: profileImage,
            placeholder: (context, url) =>
                Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(widget.lightThemeColor),
                  ),
            ),
            imageBuilder: (context, image) => CircleAvatar(
              backgroundImage: image,
              radius: 70,
            ),
            height: 150,
            width: 150,
          ),
        );
      });
    }

  Future _updateProfile(context) async {
    FirebaseUser _firebaseUser = await FirebaseAuth.instance.currentUser();
    var name, number;

    name = userNameController.text.isEmpty ? userName : userNameController.text;
    number = phoneNumberController.text.isEmpty ? phoneNumber : phoneNumberController.text;

    Map<String, String> userUpdateMap = {
      'name': name,
      'phoneNumber': number,
    };

    showLoadingDialog('Updating...', context, _keyLoader);
    await Firestore.instance
        .collection('users')
        .document(_firebaseUser.uid)
        .updateData(userUpdateMap).catchError((e) => print(e.message));

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('name', name)
      .catchError((onError) {
        print("Error storing name preferences");
      });
    Constants.userName = name;

    // uploading new profile picture
    if (_image != null) {
      String fileName = basename(_image.path);
      StorageReference firebaseStorageRef = FirebaseStorage.instance.ref()
          .child('profileImages/$name')
          .child(fileName);
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
      StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
      var url = await storageSnapshot.ref.getDownloadURL();
      if (url != null) { // uploading picture if url is not null
        // print(url);
        userUpdateMap = {
          'profileImage': url,
        };

        await Firestore.instance
            .collection('users')
            .document(_firebaseUser.uid)
            .updateData(userUpdateMap).catchError((e) => print(e.message));
      }
    }

    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    Navigator.pop(context);
    Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (context) => ChatRoom(
            toggleTheme: widget.toggleTheme,
            lightThemeColor: widget.lightThemeColor,
        ),
      ),
    );
  }

  _cropImage(filePath) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: filePath,
      maxWidth: 500,
      maxHeight: 500,
      compressQuality: 60,
      androidUiSettings: AndroidUiSettings(
        toolbarColor: widget.lightThemeColor,
        toolbarTitle: "Crop Profile Image",
        toolbarWidgetColor: Colors.white,
        backgroundColor: Colors.black,
        statusBarColor: widget.lightThemeColor,
      ),
    );
    if (croppedImage != null) {
      setState(() {
        _image = croppedImage;
      });
    }
  }


  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
    );
    if (image != null) {
      _cropImage(image.path);
    }
  }

  Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera,
    );

    if (image != null) {
      _cropImage(image.path);
    }
  }

  removeProfilePhoto() async {
    print("Removing Profile Photo");
    FirebaseUser _firebaseUser = await FirebaseAuth.instance.currentUser();
    var defaultImagePath = 'https://raw.githubusercontent.com/itsvivekghosh/flutter-tutorial/master/default.png';

    Map<String, String> userUpdateMap = {
      'profileImage': defaultImagePath,
    };
    await Firestore.instance
        .collection('users')
        .document(_firebaseUser.uid)
        .updateData(userUpdateMap).catchError((e) => print(e.message));

    setState(() {
      profileImage = defaultImagePath;
      image = Container(
        decoration: BoxDecoration(
            color: Constants.currentTheme == 'dark' ? Colors.black38 : Colors.white
        ),
        child: CachedNetworkImage(
          imageUrl: profileImage,
          placeholder: (context, url) =>
              Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Constants.accentColor),
                ),
              ),
          imageBuilder: (context, image) => CircleAvatar(
            backgroundImage: image,
            radius: 70,
          ),
          height: 150,
          width: 150,
        ),
      );
    });
  }

  _modalBottomSheetMenu(context){
    showModalBottomSheet(
      context: context, builder: (BuildContext bc) {
        return Container(
          height: MediaQuery.of(context).size.height / 4.5,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        "Profile Photo",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20
                        ),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        removeProfilePhoto();
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(30)
                            ),
                            child: Icon(
                              Icons.delete,
                              size: 30,
                              color: Colors.white
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Remove",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        getImageFromGallery();
                        Navigator.pop(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(30)
                            ),
                            child: Icon(
                                Icons.image,
                                size: 30,
                                color: Colors.white
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Gallery",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        getImageFromCamera();
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(30)
                            ),
                            child: Icon(
                                Icons.camera,
                                size: 30,
                                color: Colors.white
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Camera",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
            "Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading ?
      Center(
        child: JumpingDotsProgressIndicator(
          fontSize: 55.0,
          color: Constants.currentTheme == "dark" ? Colors.white : widget.lightThemeColor,
        ),
      ) : SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                     CircleAvatar(
                      radius: 70,
                      child: ClipOval(
                        child: new SizedBox(
                          width: 140.0,
                          height: 140.0,
                          child: (_image != null) ?
                          Image.file(
                            _image,
                            fit: BoxFit.fill,
                          ) :
                          image
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0, //give the values according to your requirement
                      child: GestureDetector(
                        onTap: () {
                          _modalBottomSheetMenu(context);
                        },
                        child: Container(
                          // margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: widget.lightThemeColor,
                            borderRadius: BorderRadius.circular(30)
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            decoration: TextDecoration.none
                        ),
                        keyboardType: TextInputType.text,
                        controller: userNameController,
                        decoration: InputDecoration(
                          labelText: userName,
                          hintText: "Enter new Username",
                          hintStyle: TextStyle(
                              color: Constants.currentTheme == 'dark' ? Colors.white24 : Colors.black26,
                          ),
                          labelStyle: TextStyle(
                              color: Constants.currentTheme == 'dark' ? Colors.white : Colors.black,
                          ),
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(32.0),
                            borderSide: new BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(32.0),
                            borderSide: BorderSide(
                              color: widget.lightThemeColor,
                              style: BorderStyle.solid,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 22),
                      IntlPhoneField(
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300
                        ),
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                          labelText: phoneNumber,
                          hintText: "Enter new Number",
                          hintStyle: TextStyle(
                              color: Constants.currentTheme == 'dark' ? Colors.white24 : Colors.black26,
                          ),
                          labelStyle: TextStyle(
                            color: Constants.currentTheme == 'dark' ? Colors.white : Colors.black,
                          ),
                          focusColor: widget.lightThemeColor,
                          border: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(32.0),
                            borderSide: new BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(32.0),
                            borderSide: BorderSide(
                              color: widget.lightThemeColor,
                              style: BorderStyle.solid,
                              width: 3,
                            ),
                          ),
                        ),
                        initialCountryCode: 'IN',
                      ),
                      SizedBox(height: 30,),
                      GestureDetector(
                        onTap: () async {
                          await _updateProfile(context);
                        },
                        child: customButtonDark(
                          context, "Update", 18, widget.lightThemeColor
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(builder: (context) => ChatRoom(
                                toggleTheme: widget.toggleTheme,
                                lightThemeColor: widget.lightThemeColor,
                                toggleAccentColor: widget.toggleAccentColor,
                              ),
                            ),
                          );
                        },
                        child: customButtonDark(
                          context, "Cancel", 18, Colors.white
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
