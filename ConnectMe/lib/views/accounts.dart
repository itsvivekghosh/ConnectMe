import 'package:ConnectMe/helper/constants.dart';
import 'package:ConnectMe/services/database.dart';
import 'package:ConnectMe/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:progressive_image/progressive_image.dart';

class AccountSettings extends StatefulWidget {
  final Function toggleTheme;
  final Color lightThemeColor;
  final Function toggleAccentColor;
  AccountSettings({this.lightThemeColor, this.toggleTheme, this.toggleAccentColor});

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  String userGender;
  bool _isLoading = true;
  bool _isEmailVerified = false;
  String errorMessage, errorType;
  bool isErrorInTextField = false;
  DateTime selectedDate = DateTime.now(), lastDate;

  final _formKey = GlobalKey<FormState>();
  final _dobFormKey = GlobalKey<FormState>();
  TextEditingController oldPasswordController = new TextEditingController();
  TextEditingController newPasswordController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController confirmPasswordController = new TextEditingController();
  TextEditingController dobFieldController = new TextEditingController();

  @override
  void initState() {
    getDetailsOfUser();
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  getDetailsOfUser() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    final DatabaseMethods _databaseMethods = new DatabaseMethods();
    var userData = await _databaseMethods.getUsersByUserEmail(firebaseUser.email);
    await firebaseUser.reload();
    firebaseUser = await FirebaseAuth.instance.currentUser();
    if (userData.documents[0].data['dateOfBirth'] == null)
      setState(() {
        lastDate = selectedDate = null;
        userGender = userData.documents[0].data['gender'];
        _isEmailVerified = firebaseUser.isEmailVerified;
      });
    else
      setState(() {
        userGender = userData.documents[0].data['gender'];
        lastDate = selectedDate = DateTime.parse(userData.documents[0].data['dateOfBirth'].toDate().toString());
        _isEmailVerified = firebaseUser.isEmailVerified;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Accounts",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: _isLoading ?
      Center(
        child: JumpingDotsProgressIndicator(
          color: Constants.currentTheme == 'dark' ? Colors.white
              : Constants.accentColor,
          fontSize: 35,
        ),
      ) : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                genderCard(),
                drawLine(),
                setBirthday(),
                drawLine(),
                verifyEmail(),
                drawLine(),
                Form(
                  key: _formKey,
                  child: changePasswordField(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget changePasswordField() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 30),
          textFormFieldTitleContent("Change Your Password"),
          SizedBox(height: 20),
          formField("Old Password", "Enter your Old Password", 'old', oldPasswordController),
          SizedBox(height: 20,),
          formField("New Password", "Enter New Password", 'new', newPasswordController),
          SizedBox(height: 20,),
          formField("Confirm Password", "Enter New Password again", 'confirm', confirmPasswordController),
          SizedBox(height: 22,),
          GestureDetector(
            onTap: () {
              _updatePassword();
            },
            child: actionButtonFormField("Change Password")
          ),
          SizedBox(height: 18),
        ],
      ),
    );
  }

  _updatePassword() async {
    setState(() {
      isErrorInTextField = false;
      errorMessage = null;
    });

    if (_formKey.currentState.validate()) { /// if found form validated

      var confirmPassword = confirmPasswordController.text.toString();
      var oldPassword = oldPasswordController.text.toString();
      var newPassword = newPasswordController.text.toString();

      if (newPassword != confirmPassword) {
        setState(() {
          isErrorInTextField = true;
          errorMessage = 'Password does not match!';
        });
        return;
      }
      else if (newPassword == oldPassword) {
        setState(() {
          isErrorInTextField = true;
          errorMessage = 'Old Password and New Password cannot be same';
        });
        return;
      }
      else {
        setState(() {
          isErrorInTextField = false;
          errorMessage = null;
        });
        try {
          final FirebaseAuth _auth = FirebaseAuth.instance;
          await _auth.signInWithEmailAndPassword(
            email: Constants.userEmail,
            password: oldPassword,
          );
          // logic to update password
          FirebaseUser user = await FirebaseAuth.instance.currentUser();
          user.updatePassword(confirmPassword).then((_){})
            .catchError((error){
              print("Password can't be changed" + error.toString());
            }
          );
          _scaffoldKey.currentState.showSnackBar(
            showSnackBarWithMessage("Password Changed Successfully!", "", Colors.green)
          );
        } catch(e) {
          setState(() {
            isErrorInTextField = true;
            errorMessage = "Invalid Old Password!";
          });
        }
      }
    } else {
      // error while validating fields...
      _scaffoldKey.currentState.showSnackBar(
        showSnackBarWithMessage("Error while changing Password!", "Please Try Again!", Colors.red)
      );
    }
  }

  Widget formField(labelText, hintText, type, controller) {
    return TextFormField(
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w300,
        decoration: TextDecoration.none
      ),
      obscureText: true,
      controller: controller,
      validator: (value) {
        return value.isEmpty ? "You can't have an empty Password!" : null;
      },
      keyboardType: TextInputType.visiblePassword,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Constants.currentTheme == 'dark' ? Colors.white24 : Colors.black26,
        ),
        errorText: isErrorInTextField ?
          type == 'old' ? errorMessage : null
            : null,
        border: new OutlineInputBorder(
          borderRadius: new BorderRadius.circular(32.0),
          borderSide: new BorderSide(
            color: Colors.grey,
            width: 2,
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
    );
  }

  Widget textFormFieldTitleContent(title) {
    List<Widget> listText = new List<Widget>();
    var titleList = title.split(' ');
    for(var i = 0; i < titleList.length; i++) {
      listText.add(
        titleContentTile(titleList[i] + " ", 25.8, Constants.currentTheme == 'dark' ? Colors.white60 : Colors.black54
        ),
      );
    }
    return Container(
      child: Row(children: listText),
    );
  }

  Widget titleContentTile(text, size, color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size,
        color: color,
      ),
    );
  }

  Widget actionButtonFormField(buttonTitle) {
    return Container(
      child: Constants.currentTheme == 'dark' ?
        customButtonDark(context, buttonTitle, 18, Constants.accentColor)
          : customButtonLight(context, buttonTitle, 18, Constants.accentColor),
    );
  }

  Future _changeGender(gender) async {
    setState(() {
      if (userGender == "Male" && gender != userGender) {
        userGender = "Female";
        _changeGenderTile();
      }
      else if (userGender == "Female" && gender != userGender) {
        userGender = "Male";
        _changeGenderTile();
      }
    });
  }
  _changeGenderTile() async {
    try {
      FirebaseUser _firebaseUser = await FirebaseAuth.instance.currentUser();
      Map<String, String> userUpdateMap = {
        'gender': userGender == '' ? null : userGender,
      };
      await Firestore.instance
          .collection('users')
          .document(_firebaseUser.uid)
          .updateData(userUpdateMap).catchError((e) {
        print("Unable to Update data.. $e");
      });

      _scaffoldKey.currentState.showSnackBar(
          showSnackBarWithMessage("Gender value Changed Successfully to '$userGender'!", "", Colors.green)
      );
    } catch(e) {
      print(e);
    }
  }

  Widget genderCard() {
    return Column(
      children: [
        textFormFieldTitleContent("Select Your Gender"),
        SizedBox(height: 30),
        Row(
          children: [
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _changeGender('Male');
              },
              child: genderCardTile('assets/gender/default_male.png', "Male")
            ),
            GestureDetector(
              onTap: () {
                _changeGender('Female');
              },
              child: genderCardTile('assets/gender/default_female.png', "Female")
            ),
          ],
        ),
        // SizedBox(height: 20),
        // actionButtonFormField("Change Gender"),
      ],
    );
  }

  Widget genderCardTile(assetImage, gender) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          genderTile(assetImage, gender),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              gender,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 18.5
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget genderTile(pathToImage, gender) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color : gender == userGender ?
              Constants.currentTheme == 'dark' ? Colors.blueAccent.withOpacity(0.3) : Colors.blueAccent.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 7,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)
        ),
        child: ProgressiveImage(
          placeholder: AssetImage(pathToImage),
          width: 100.0,
          height: 100.0,
          thumbnail: AssetImage(pathToImage),
          image: AssetImage(pathToImage),
        ),
      ),
    );
  }

  Widget setBirthday() {
    return Container(
      padding: EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleContentTile(
            "Set Birthday", 25.8,
            Constants.currentTheme == 'dark' ? Colors.white60 : Colors.black54
          ),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Form(
              key: _dobFormKey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  birthdayTile(),
                  IconButton(
                    icon: Icon(Icons.save_rounded),
                    color: Constants.currentTheme == 'dark' ? Colors.white60 : Colors.black54,
                    onPressed: () {
                      _saveBirthDayDate();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _saveBirthDayDate() async {
    if (selectedDate == null) {
      _scaffoldKey.currentState.showSnackBar(
          showSnackBarWithMessage("Cannot Update Empty Date!", "Please Try Again!", Colors.red)
      );
      return;
    } else if (lastDate == selectedDate) {
      _scaffoldKey.currentState.showSnackBar(
          showSnackBarWithMessage("Cannot Update Empty Date!", "Change Birth Date!", Colors.red)
      );
      return;
    }
    FirebaseUser _firebaseUser = await FirebaseAuth.instance.currentUser();
    Map<String, Timestamp> userUpdateMap = {
      'dateOfBirth': Timestamp.fromMillisecondsSinceEpoch(selectedDate.millisecondsSinceEpoch)
    };

    await Firestore.instance
      .collection('users')
      .document(_firebaseUser.uid)
      .updateData(userUpdateMap).catchError((e) {
      print("Unable to Update data.. $e");
    });
    _scaffoldKey.currentState.showSnackBar(
        showSnackBarWithMessage("Birth Date Changed Successfully!", "", Colors.green)
    );
  }

  Widget birthdayTile() {
    return Container(
      padding: const EdgeInsets.only(left: 10.0),
      child: Container(
        child: GestureDetector(
          onTap: () {
            _selectDate(context);
          },
          child: Text(
              selectedDate != null ? "${selectedDate.toLocal()}".split(' ')[0] : "Birthday not set yet",
            style: selectedDate != null ? TextStyle(fontSize: 25, fontWeight: FontWeight.bold) :
              TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate == null ? DateTime.now() : selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Select Birth Date',
      cancelText: 'Cancel',
      confirmText: 'Set',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
      fieldLabelText: 'Birth date',
      fieldHintText: 'Month/Date/Year',
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  Widget verifyEmail() {
    return Container(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          textFormFieldTitleContent("Verify email address!"),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextFormField(
                  enabled: false,
                  keyboardType: TextInputType.emailAddress,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: Constants.userEmail,
                  ),
                ),
                Icon(
                  _isEmailVerified ? Icons.verified : Icons.info,
                  color: _isEmailVerified ? Colors.green : Colors.redAccent,
                ),
              ],
            ),
          ),
          !_isEmailVerified ? Column(
            children: [
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      _requestEmailVerification();
                    },
                    child: Text(
                      "Request Email Verification!",
                      style: TextStyle(
                        color: Constants.currentTheme == 'dark' ? Colors.white70 : Colors.black54
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ) : Container(),
        ],
      ),
    );
  }

  _requestEmailVerification() async {
    FirebaseUser firebaseUser = await FirebaseAuth.instance.currentUser();
    try {
      await firebaseUser.sendEmailVerification();
      _popupMessage("Check you Email!", "An Email verification has been sended to your email for verification!");
      return firebaseUser.uid;
    } catch (e) {
      print("An error occurred while trying to send email verification!");
      print(e.message);
    }
  }

  Widget drawLine() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Container(
        height: 0.34,
        color: Constants.currentTheme == 'light' ? Colors.black26 : Colors.white38,
      ),
    );
  }

  Future<void> _popupMessage(title, message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return MaterialApp(
          theme: Constants.currentTheme == 'dark' ? ThemeData.dark() : ThemeData.light(),
          home: AlertDialog(
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            // backgroundColor: Constants.currentTheme == 'dark' ? Colors.black : Colors.white,
            content: SingleChildScrollView(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w300
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    color: Constants.accentColor
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}