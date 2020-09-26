import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ConnectMe/services/auth.dart';
import 'package:ConnectMe/widgets/widgets.dart';
import 'package:ConnectMe/helper/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ConnectMe/services/database.dart';
import 'package:ConnectMe/helper/helperFunctions.dart';
import 'package:ConnectMe/views/chatRoomDashboard.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SignUp extends StatefulWidget {
  final Function toggleTheme, toggleAccentColor;
  final Color lightThemeColor;
  SignUp({this.toggleTheme, this.lightThemeColor, this.toggleAccentColor});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool _loading = true;
  String currentLoginUser;
  bool _passwordVisible = false;
  String titleSignUp = "Sign Up";
  final formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController countryCodeController = new TextEditingController();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController userNameEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController phoneNumberEditingController = new TextEditingController();

  bool isErrorInSignUp = false;
  String errorSignUpMessage = '';
  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  setSearchParam(String caseNumber) {
    List<String> caseSearchList = List();
    var length = caseNumber.length;
    for (int i = 0; i < length; i++) {
      for (int j = i+1; j <= length; j++) {
        caseSearchList.add(caseNumber.substring(i,j));
      }
    }
    return caseSearchList;
  }

  void checkAndSignMeIn() async {
    setState(() {
      isErrorInSignUp = false;
      errorSignUpMessage = null;
      titleSignUp = "CREATING ACCOUNT...";
    });

    if (formKey.currentState.validate()) {
      if (countryCodeController.text.isEmpty || countryCodeController.text[0] != '+' || countryCodeController.text.length > 4) {
        setState(() {
          titleSignUp = "Sign Up";
        });
        return;
      }

      var searchList = setSearchParam(userNameEditingController.text);
      Map<String, dynamic> userMap = {
        'name': userNameEditingController.text,
        'email': emailEditingController.text,
        'gender': "Male",
        'dateOfBirth': DateTime.now(),
        'phoneNumber': countryCodeController.text + " " + phoneNumberEditingController.text,
        "userNameCaseSearch": searchList,
        'profileImage': 'https://raw.githubusercontent.com/itsvivekghosh/flutter-tutorial/master/default.png',
      };

      HelperFunctions.saveUserEmailSharedPreference(emailEditingController.text);
      HelperFunctions.saveUserNameSharedPreference(userNameEditingController.text);
      FirebaseAuth _auth = FirebaseAuth.instance;

      await _auth.createUserWithEmailAndPassword(
          email: emailEditingController.text, password: passwordEditingController.text)
        .then((value) async {
          FirebaseUser user = value.user;
          userMap['userId'] = user.uid;
          DatabaseMethods().uploadUserData(userMap, user.uid);

          // send verification Email
          try {
            await user.sendEmailVerification();
          } catch (e) {
            print("An error occurred while trying to send email verification");
            print(e.message);
          }

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          await _auth.currentUser().then((FirebaseUser user) {
            currentLoginUser = user.uid;
            return null;
          });

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('name', userNameEditingController.text).then((value) {
            print("saved name as ${userNameEditingController.text}!");
          }).catchError((onError) {
            print("Error on saving Username Preferences");
          });
          prefs.setString('email', emailEditingController.text).then((value) {
            print("saved email as ${emailEditingController.text}!");
          }).catchError((onError) {
            print("Error on saving Email Preferences");
          });
          prefs.setString('password', passwordEditingController.text).then((value) {
            print("saved password as ${passwordEditingController.text}!");
          }).catchError((onError) {
            print("Error on saving Password Preferences");
          });
          prefs.setString('profilePhotoUrl', profilePhotoUrl).then((value) {
            print("saved profilePhotoUrl as $profilePhotoUrl!");
          }).catchError((onError) {
            print("Error on saving profilePhotoUrl Preferences");
          });

          Constants.userName = userNameEditingController.text;
          Constants.userEmail = emailEditingController.text;
          Constants.profilePhotoUrl = profilePhotoUrl;

          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => ChatRoom(
                toggleTheme: widget.toggleTheme,
                lightThemeColor: widget.lightThemeColor,
                toggleAccentColor: widget.toggleAccentColor,
              ),
            ),
          );
        })
        .catchError((e) {
          print(e.message.toString());
          setState(() {
            isErrorInSignUp = true;
            errorSignUpMessage = e.message;
            titleSignUp = "Sign Up";
          });
        });
    } else {
      print("Error in Sign up!");
      setState(() {
        titleSignUp = "Sign Up";
      });
    }
  }

  @override
  void initState() {
    _passwordVisible = false;
    titleSignUp = "Sign Up";
    super.initState();
    if (mounted) {
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {
          _loading = false;
        });
      });
    }
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
        centerTitle: true,
        title: Text(
            "ConnectMe",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w300
            )
        ),
        actions: [
          GestureDetector(
            onTap: () {
              widget.toggleTheme();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                  Constants.currentTheme == 'dark' ? Icons.wb_sunny_rounded : Icons.brightness_3
              ),
            ),
          ),
        ],
      ),
      body: _loading ? Container(
          child: Center(
            child: JumpingDotsProgressIndicator(
              fontSize: 40.0,
              color: Constants.currentTheme == 'dark' ? Colors.white : widget.lightThemeColor,
            ),
          ),
      ) : Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children:[
              Container(
                  padding: EdgeInsets.fromLTRB(10, 50, 10, 30),
                  child: Text("Hello,", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                    fontFamily: 'RobotoMono',
                  ),
                  ),
              ),
          Form(
            key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                    controller: userNameEditingController,
                    validator: (value) {
                      return value.length < 6
                          ? "Enter Username of 6+ characters"
                          : null;
                    },
                    decoration: InputDecoration(
                      labelText: "Username",
                      hintText: "Enter Username",
                      hintStyle: TextStyle(
                          color: Constants.currentTheme == 'dark' ? Colors.white24 : Colors.black38
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
                  SizedBox(height: 10),
                  TextFormField(
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                    controller: emailEditingController,
                    validator: (value) {
                      if (emailEditingController.text.isEmpty) return "Email Cannot be Empty";
                      return RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(emailEditingController.text) ? null : "Invalid Email";
                    },
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      hintText: "Enter your Email Address",
                      hintStyle: TextStyle(
                          color: Constants.currentTheme == 'dark' ? Colors.white24 : Colors.black38
                      ),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(32.0),
                        borderSide: new BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      errorText: isErrorInSignUp ? errorSignUpMessage : null,
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
                  SizedBox(height: 10),
                  Container(
                    child: phoneField(),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: passwordEditingController,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                    obscureText:  !_passwordVisible ? true : false,
                    validator: (value) {
                      return value.length < 6
                          ? "Enter Password of 6+ characters"
                          : null;
                    },
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "Enter your Password",
                      hintStyle: TextStyle(
                          color: Constants.currentTheme == 'dark' ? Colors.white24 : Colors.black38
                      ),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(32.0),
                        borderSide: new BorderSide(
                            color: Colors.grey,
                            width: 5
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: widget.lightThemeColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
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
                  SizedBox(height: 18,),
                  GestureDetector(
                    onTap: () {
                      checkAndSignMeIn();
                    },
                    child: customButtonDark(
                        context, titleSignUp, 18, widget.lightThemeColor
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(colors: [
                            Colors.white,
                            Colors.white
                          ]),
                          boxShadow: Constants.currentTheme == 'light' ? [BoxShadow(spreadRadius: 0.3)]: null
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20,),
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'with Google',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          )
                        ),),
                      ),
                      SizedBox(width: 4,),
                      Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(colors: [
                              Colors.blue, Colors.blue
                            ])
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 20,),
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                              'with Facebook',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
          ),
          SizedBox(height: 20),
              Constants.currentTheme == 'dark' ? Text(
                "Made with Love in India",
              style: TextStyle(
                fontWeight: FontWeight.w100
              ),
            ) :
          Text(
              "Made with Love in India",
              style: TextStyle(
              color: Colors.black54,
                  fontWeight: FontWeight.w300
            ),
          ),
        ]),
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
                    validator: (value) {
                      return (value.isEmpty) ? "Enter Code!": null;
                    },
                    controller: countryCodeController,
                    maxLength: 4,
                    decoration: InputDecoration(
                      hintText: "+91",
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
                SizedBox(width: 4),
                Expanded(
                  flex: 4,
                  child: TextFormField(
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300
                    ),
                    validator: (value) {
                      return (value.isEmpty) ? "Empty Phone Number!": null;
                    },
                    maxLength: 10,
                    controller: phoneNumberEditingController,
                    decoration: InputDecoration(
                      hintText: "Enter Phone Number",
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
