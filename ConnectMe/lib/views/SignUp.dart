import 'package:ConnectMe/helper/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ConnectMe/helper/helperFunctions.dart';
import 'package:ConnectMe/services/auth.dart';
import 'package:ConnectMe/services/database.dart';
import 'package:ConnectMe/views/chatRoomDashboard.dart';
import 'package:ConnectMe/widgets/widgets.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUp extends StatefulWidget {
  final String theme;
  final Function toggleTheme;
  final Color lightThemeColor;
  SignUp({this.theme, this.toggleTheme, this.lightThemeColor});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool _loading = true;
  String currentLoginUser;
  bool _passwordVisible = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController userNameEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController phoneNumberEditingController = new TextEditingController();

  bool isErrorInSignUp = false;
  String errorSignUpMessage = '';
  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  void checkAndSignMeIn() async {
    setState(() {
      isErrorInSignUp = false;
      errorSignUpMessage = null;
    });
    if (formKey.currentState.validate()) {
      Map<String, String> userMap = {
        'name': userNameEditingController.text,
        'email': emailEditingController.text,
        'phoneNumber': phoneNumberEditingController.text,
      };

      HelperFunctions.saveUserEmailSharedPreference(emailEditingController.text);
      HelperFunctions.saveUserNameSharedPreference(userNameEditingController.text);
      FirebaseAuth _auth = FirebaseAuth.instance;

      await _auth.createUserWithEmailAndPassword(
          email: emailEditingController.text, password: passwordEditingController.text)
        .then((value) async {
          FirebaseUser user = value.user;
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
          Constants.userName = userNameEditingController.text;
          Constants.userEmail = emailEditingController.text;

          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => ChatRoom(
                  theme: widget.theme,
                  toggleTheme: widget.toggleTheme,
                  lightThemeColor: widget.lightThemeColor
              ),
            ),
          );
        })
        .catchError((e) {
          print(e.message.toString());
          setState(() {
            isErrorInSignUp = true;
            errorSignUpMessage = e.message;
          });
        });
    }
  }

  @override
  void initState() {
    _passwordVisible = false;
    print(widget.theme);
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
        centerTitle: true,
        title: Text(
            "ConnectMe",
            style: TextStyle(
              fontSize: 25,
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
                  widget.theme != 'dark' ? Icons.brightness_6 : Icons.brightness_5
              ),
            ),
          )
        ],
      ),
      body: _loading ? Container(
          child: Center(
            child: JumpingDotsProgressIndicator(
              fontSize: 55.0,
              color: widget.theme == 'dark' ? Colors.white : Colors.green,
            ),
          )
      ) :  Container(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    Container(
                        padding: EdgeInsets.fromLTRB(10, 20, 10, 30),
                        child: Text("Hello,", style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 50,
                          fontFamily: 'RobotoMono' ,
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
                            return value.length < 5
                                ? "Enter Username of 5+ characters"
                                : null;
                          },
                          decoration: InputDecoration(
                            labelText: "Username",
                            hintText: "Enter Username",
                            hintStyle: TextStyle(
                                color: widget.theme == 'dark' ? Colors.white24 : Colors.black38
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
                            if (emailEditingController.text.isEmpty) return "Enter Email";
                            return RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(emailEditingController.text) ? null : "Invalid Email";
                          },
                          decoration: InputDecoration(
                            labelText: "Email Address",
                            hintText: "Enter your Email Address",
                            hintStyle: TextStyle(
                                color: widget.theme == 'dark' ? Colors.white24 : Colors.black38
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
                        IntlPhoneField(
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300
                          ),
                          controller: phoneNumberEditingController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            hintText: "Enter your Number",
                            hintStyle: TextStyle(
                                color: widget.theme == 'dark' ? Colors.white24 : Colors.black38
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
                        SizedBox(height: 7,),
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
                                color: widget.theme == 'dark' ? Colors.white24 : Colors.black38
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
                              context, "Sign Up", 18, widget.lightThemeColor
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
                                boxShadow: widget.theme == 'light' ? [BoxShadow(spreadRadius: 0.3)]: null
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
                widget.theme == 'dark' ? Text(
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
              ]
            ),
          ),
        ),
    );
  }
}
