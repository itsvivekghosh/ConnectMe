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
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_indicators/progress_indicators.dart';

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
  String phoneNumber, countryCode;
  Widget image;
  bool _loading = true;
  String saveImagePath = '';
  bool showBottomSheetMenu = false;
  Map<String, String> userUpdateMap;
  final formKey = GlobalKey<FormState>();
  String updateStateButtonTitle = 'Update';
  final fireStoreInstance = Firestore.instance;
  final DatabaseMethods _databaseMethods = new DatabaseMethods();
  TextEditingController userNameController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();
  TextEditingController countryCodeController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String profileImage = 'https://raw.githubusercontent.com/itsvivekghosh/flutter-tutorial/master/default.png';

  @override
  void initState() {
    if (mounted) {
      getUserData();
      updateStateButtonTitle = 'Update';
      Future.delayed(Duration(seconds: 1), () {
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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      userName = userData.documents[0].data['name'];
      phoneNumber = userData.documents[0].data['phoneNumber'];
      profileImage = userData.documents[0].data['profileImage'];

      // extracting phoneNumber
      if (phoneNumber != null) {
        var fullPhoneNumber = phoneNumber.split(' ');
        if (fullPhoneNumber.length == 2) {
          setState(() {
            countryCode = fullPhoneNumber[0];
            phoneNumber = fullPhoneNumber[1];
          });
        }
      }

      if (prefs.getString('profileImagePath') == Constants.profilePhotoUrl || prefs.getString('profileImagePath') == '') {
        image = Container(
          child: ProgressiveImage(
            placeholder: AssetImage('assets/default.png'),
            image: NetworkImage(profileImage),
            thumbnail: AssetImage('assets/default.png'),
            height: 150,
            width: 150,
            blur: 2.8,
            fit: BoxFit.cover,
          ),
        );
      } else {
        try {
          image = Container(
            child: ProgressiveImage(
              placeholder: FileImage(File(prefs.getString('profileImagePath'))),
              image: NetworkImage(profileImage),
              thumbnail: FileImage(File(prefs.getString('profileImagePath'))),
              height: 150,
              width: 150,
              blur: 2.8,
              fit: BoxFit.cover,
            ),
          );
        } catch (e) {
          image = Container(
            child: ProgressiveImage(
              placeholder: NetworkImage(profileImage),
              image: NetworkImage(profileImage),
              thumbnail: NetworkImage(profileImage),
              height: 150,
              width: 150,
              blur: 2.9,
              fit: BoxFit.cover,
            ),
          );
        }
      }
      });
    }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      splashColor: Colors.green.shade50,
      hoverColor: Colors.green.shade50,
      child: Text(
        "No",
        style: TextStyle(
          fontSize: 18,
          color: Colors.green,
        ),
      ),
      onPressed:  () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    Widget continueButton = FlatButton(
      splashColor: Colors.green.shade50,
      hoverColor: Colors.green.shade50,
      child: Text(
        "Yes",
        style: TextStyle(
          fontSize: 18,
          color: Colors.green,
        ),
      ),
      onPressed:  () {
        removeProfilePhoto(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
          "Remove Profile Photo",
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          )
      ),
      content: Text(
        "Are you sure, you want to remove your profile photo? \n\nAfter this you\'ll be redirected to Home Page!",
        style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
        ),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future _updateProfile(context) async {
    if (
          _image == null &&
          userNameController.text.isEmpty &&
          phoneNumberController.text.isEmpty &&
          countryCodeController.text.isEmpty
        ) {
      _scaffoldKey.currentState.showSnackBar(
          showSnackBarWithMessage("Got Empty Credentials", "Please Try again!", Colors.red)
      );
      return;
    }

    FirebaseUser _firebaseUser = await FirebaseAuth.instance.currentUser();
    var name, number, _countryCode;

    name = userNameController.text.isEmpty ? userName : userNameController.text;
    number = phoneNumberController.text.isEmpty ? phoneNumber : phoneNumberController.text;
    _countryCode = countryCodeController.text.isEmpty ? countryCode : countryCodeController.text;

    Map<String, String> userUpdateMap = {
      'name': name,
      'phoneNumber': countryCode + " " + number,
    };
    setState(() {
      updateStateButtonTitle = 'UPDATING...';
    });

    await Firestore.instance
        .collection('users')
        .document(_firebaseUser.uid)
        .updateData(userUpdateMap).catchError((e) {

        print("Unable to Update data.. $e");
        setState(() {
          updateStateButtonTitle = 'Update';
        });
      }
    );

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
    if (saveImagePath != '') {
      prefs.setString('profileImagePath', saveImagePath);
    }

    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => ChatRoom(
            toggleAccentColor: widget.toggleAccentColor,
            toggleTheme: widget.toggleTheme,
            lightThemeColor: widget.lightThemeColor,
            isGoogleSignIn: false
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
        saveImagePath = croppedImage.path;
      });
    }
  }

  Future getImageFromGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
    );

    if (image != null) {
      Directory appDir = await getApplicationDocumentsDirectory();
      final File newImage = await image.copy('${appDir.path}/profileImage.jpg');
      if (newImage != null) {
        _cropImage(newImage.path);
      }
    }
  }

  Future getImageFromCamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera,
    );

    if (image != null) {
      Directory appDir = await getApplicationDocumentsDirectory();
      final File newImage = await image.copy('${appDir.path}/profileImage.jpg');
      if (newImage != null) {
        _cropImage(newImage.path);
      }
    }
  }

  removeProfilePhoto(context) async {
    FirebaseUser _firebaseUser = await FirebaseAuth.instance.currentUser();
    var defaultImagePath = profilePhotoUrl;

    Map<String, String> userUpdateMap = {
      'profileImage': defaultImagePath,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profileImagePath', '');

    await Firestore.instance
        .collection('users')
        .document(_firebaseUser.uid)
        .updateData(userUpdateMap).catchError((e) => print(e.message));

    setState(() {
      profileImage = defaultImagePath;
      image = CircleAvatar(
        radius: 30,
        child: ProgressiveImage(
          placeholder: AssetImage('assets/default.png'),
          image: AssetImage('assets/default.png'),
          thumbnail: AssetImage('assets/default.png'),
          height: 150,
          width: 150,
          blur: 2.8,
        ),
      );
    });

    Navigator.of(context, rootNavigator: true).pop();

    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => ChatRoom(
          toggleAccentColor: widget.toggleAccentColor,
          toggleTheme: widget.toggleTheme,
          lightThemeColor: widget.lightThemeColor,
          isGoogleSignIn: false
        ),
      ),
    );
  }

  _modalBottomSheetMenu(context){
    showModalBottomSheet(
      context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        builder: (BuildContext bc) {
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
                        Navigator.of(context).pop();
                        showAlertDialog(context);
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
                        Navigator.of(context).pop();
                        getImageFromGallery();
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
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
          fontSize: 40.0,
          color: Constants.currentTheme == "dark" ? Colors.white : Constants.accentColor,
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
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: new SizedBox(
                          width: 140.0,
                          height: 140.0,
                          child: (_image != null) ?
                          Image.file(
                            _image,
                            fit: BoxFit.fill,
                          ) :
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, CupertinoPageRoute(builder: (_) {
                                return Scaffold(
                                  appBar: AppBar(
                                    backgroundColor: Colors.black,
                                    title: Text(userName, style: TextStyle(fontWeight: FontWeight.w300)),
                                    centerTitle: true,
                                  ),
                                  body: PhotoView(
                                    imageProvider: NetworkImage(profileImage)
                                  ),
                                );
                              }));
                            },
                            child: Container(
                              child: image,
                            ),
                          ),
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
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(
                            color: Constants.accentColor,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
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
                              color: Constants.accentColor == Colors.black ?
                              Constants.currentTheme == 'dark' ? Colors.white70 : Colors.black
                                  : Constants.accentColor ,
                              style: BorderStyle.solid,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 22),
                      phoneField(),
                      SizedBox(height: 30,),
                      GestureDetector(
                        onTap: () async {
                          await _updateProfile(context);
                        },
                        child: customButtonDark(
                          context, updateStateButtonTitle, 18, Constants.accentColor
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

  Widget phoneField() {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.end,
                    controller: countryCodeController,
                    maxLength: 4,
                    decoration: InputDecoration(
                      hintText: "+91",
                      labelText: countryCode,
                      focusColor: Constants.accentColor,
                      hintStyle: TextStyle(
                        color: Constants.currentTheme == 'dark' ? Colors.white24 : Colors.black26,
                      ),
                      labelStyle: TextStyle(
                        color: Constants.currentTheme == 'dark' ? Colors.white : Colors.black,
                      ),
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
                          color: Constants.accentColor == Colors.black ?
                          Constants.currentTheme == 'dark' ? Colors.white70 : Colors.black
                              : Constants.accentColor,
                          style: BorderStyle.solid,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300
                    ),
                    maxLength: 10,
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
                      focusColor: Constants.accentColor,
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
                          color: Constants.accentColor == Colors.black ?
                          Constants.currentTheme == 'dark' ? Colors.white70 : Colors.black
                            : Constants.accentColor,
                          style: BorderStyle.solid,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
