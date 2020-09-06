import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:ConnectMe/services/auth.dart';
import 'package:ConnectMe/widgets/widgets.dart';
import 'package:ConnectMe/helper/constants.dart';
import 'package:ConnectMe/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ConnectMe/views/forgotPassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ConnectMe/helper/helperFunctions.dart';
import 'package:ConnectMe/views/chatRoomDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_indicators/progress_indicators.dart';


class SignIn extends StatefulWidget {
  final String theme;
  final Function toggleState, toggleTheme;
  final bool signUpState;
  final Color lightThemeColor;
  SignIn({this.theme, this.toggleState, this.toggleTheme, this.signUpState, this.lightThemeColor});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  bool _loading = true;
  bool isLoading = false;
  bool isEmailWrong = false;
  bool isPasswordWrong = false;
  bool _passwordVisible = false;
  String currentLoginUser;
  String wrongEmailMessage = '';
  String wrongPasswordMessage = '';
  String emailErrorText = '';
  String passwordErrorText = '';

  GoogleSignIn googleAuth = new GoogleSignIn();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  QuerySnapshot queryUserSnapshot;
  final formKey = GlobalKey<FormState>();
  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  void initState() {
    _passwordVisible = false;
    isPasswordWrong = false;
    isEmailWrong = false;
    super.initState();
    if (mounted) {
      Future.delayed(Duration(milliseconds: 1000), () {
        setState(() {
          _loading = false;
        });
      });
    }
  }

  Future<void> _googleSignUp() async {
    try {
      final GoogleSignIn _googleSignIn = new GoogleSignIn(
        scopes: ['email'],
        hostedDomain: "",
        clientId: "",
      );
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential  = GoogleAuthProvider.getCredential(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken
      );
      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      HelperFunctions.saveUserLoggedInSharedPreference(true);

      // saving logged in State in local drive
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('email', user.email)
          .then((value) {
            print("Saved email as ${user.email}");
          })
          .catchError((onError) {
            print("Error storing email preferences");
          });

      prefs.setString('name', user.displayName)
          .then((value) {
            print("Saved name as ${user.displayName}");
          })
          .catchError((onError) {
            print("Error storing name preferences");
          });
      Constants.userName = user.displayName;
      Constants.userEmail = user.email;

      print("Signed In as: ${user.displayName}");

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => ChatRoom(
              theme: widget.theme,
              toggleTheme: widget.toggleTheme,
              lightThemeColor: widget.lightThemeColor,
              isGoogleSignIn: true
          ),
        ),
      );
    } catch(e) {
      print(e.message);
    }
  }

  signIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });

      await authService
          .signInWithEmailAndPassword(
          emailTextEditingController.text, passwordTextEditingController.text)
          .then((result) async {
        if (result != null)  {
          QuerySnapshot userInfoSnapshot =
          await DatabaseMethods().getUserInfo(emailTextEditingController.text);

          HelperFunctions.saveUserLoggedInSharedPreference(true);
          HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot.documents[0].data["name"]);
          HelperFunctions.saveUserEmailSharedPreference(
              userInfoSnapshot.documents[0].data["email"]);

          // saving logged in State in local drive
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', emailTextEditingController.text).then((value) {
            print("saved as ${emailTextEditingController.text}!");
          }).catchError((onError) {
            print("Error on saving Email Preferences");
          });
          var name = await HelperFunctions.getUserNameSharedPreference();
          prefs.setString('name', name)
              .then((value) {
                print("saved as $name!");
              })
              .catchError((onError) {
                print("Error on saving name Preferences");
              });
          Constants.userName = name;
          Constants.userEmail = emailTextEditingController.text;

          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => ChatRoom(
                  theme: widget.theme,
                  toggleTheme: widget.toggleTheme,
                  lightThemeColor: widget.lightThemeColor,
                  isGoogleSignIn: false
              ),
            ),
          );
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  void callForgotPassword() {
    Navigator.push(context,
      CupertinoPageRoute(
        builder: (context) {
            return ForgotPassword(
              theme: widget.theme,
              lightThemeColor: widget.lightThemeColor,
              toggleTheme: widget.toggleTheme,
            );
        }
      ),
    );
  }

  void validateAndSignMeIn() async {
    print("Signing In...");
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      try {
        if (emailTextEditingController.text.isEmpty || passwordTextEditingController.text.isEmpty) {
          print("Error Signing in");
          throw PlatformException(
            code: "EMAIL OR PASSWORD CANNOT BE NULL"
          );
        }
      } catch(e) {
        print("exception caught: 'EMAIL OR PASSWORD CANNOT BE NULL'");
        setState(() {
          isEmailWrong = true;
          isPasswordWrong = true;
          if (emailTextEditingController.text.isEmpty)
            emailErrorText = 'Email cannot be empty';
          if (passwordTextEditingController.text.isEmpty)
            passwordErrorText = 'Password cannot be empty';
        });
        return;
      }

      setState(() {
        isEmailWrong = false;
        isPasswordWrong = false;
      });
      final checkUser = await _auth.signInWithEmailAndPassword(
          email: emailTextEditingController.text, password: passwordTextEditingController.text);
      if (checkUser != null) {
        await signIn();
      }
    } catch(e) {
      print("Error while Signing In is: ${e.toString()}");
      if (e is PlatformException && e.code == 'ERROR_USER_NOT_FOUND') {
        setState(() {
          isEmailWrong = true;
          emailErrorText = 'User not found';
        });
      }
      else if (e is PlatformException && e.code == 'ERROR_WRONG_PASSWORD') {
        setState(() {
          isPasswordWrong = true;
          passwordErrorText = 'Please check your password';
        });
      }
      if (e is PlatformException && e.code == 'ERROR_INVALID_EMAIL') {
        setState(() {
          isEmailWrong = true;
          emailErrorText = 'Enter Valid email address';
        });
      }
      else
        setState(() {
          isPasswordWrong = true;
          isEmailWrong = true;
          if (emailTextEditingController.text.isEmpty) {
            emailErrorText = "Email cannot be empty";
          }
          if(passwordTextEditingController.text.isEmpty) {
            passwordErrorText = "Password cannot be empty";
          }
          bool val = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(emailTextEditingController.text);
          if(emailTextEditingController.text.isNotEmpty) {
            emailErrorText = val ? "Enter valid email address" : "User doesn't exist";
          }
          if (passwordTextEditingController.text.isNotEmpty) {
            passwordErrorText = 'Please check your password';
          }
        }
      );
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
      body: isLoading || _loading ?
      Center(
        child: JumpingDotsProgressIndicator(
          fontSize: 55.0,
          color: widget.theme == 'dark' ? Colors.white : Colors.green,
        ),
      ) :
      Container(
        height: MediaQuery.of(context).size.height - 80,
        alignment: Alignment.center,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
              mainAxisSize: MainAxisSize.min,
            children:[
              Container(
                  padding: EdgeInsets.fromLTRB(10, 40, 10, 50),
                child: Text("Hello,", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  fontFamily: 'RobotoMono' ,
                ),
                )
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: widget.theme == "dark" ? Colors.white : Colors.black,
                          decoration: TextDecoration.none
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: emailTextEditingController,
                      decoration: InputDecoration(
                          labelText: "Enter Your Email",
                          hintText: "Enter your Registered Email ID",
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
                        errorText: isEmailWrong ? emailErrorText : null,
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
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: widget.theme == "dark" ? Colors.white : Colors.black,
                          decoration: TextDecoration.none
                      ),
                      controller: passwordTextEditingController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _passwordVisible ? false : true,
                      decoration: InputDecoration(
                          labelText: "Enter Password",
                          hintText: "Enter your Password",
                          hintStyle: TextStyle(
                              color: widget.theme == 'dark' ? Colors.white24 : Colors.black38
                          ),
                          labelStyle: TextStyle(
                            decorationColor: widget.lightThemeColor,
                          ),
                          border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(32.0),
                          borderSide: new BorderSide(
                            color: Colors.grey,
                            width: 5
                          ),
                        ),
                        errorText: isPasswordWrong ? passwordErrorText : null,
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
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            callForgotPassword();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        validateAndSignMeIn();
                      },
                      child: customButtonDark(
                          context, "Sign In", 18, widget.lightThemeColor
                      ),
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        print("signing in with google");
                        try {
                          await _googleSignUp();
                        } catch(e) {
                          print("Error while Signing In...");
                        }
                      },
                      child: Container(
                        child: widget.theme == 'dark' ?
                          customButtonGoogleDark(context, "Sign In with Google", 18, Colors.white) :
                          customButtonGoogleLight(context, "Sign In with Google", 18, Colors.white),
                      ),
                    ),
                    SizedBox(height: 10,),
                    GestureDetector(
                      onTap: () {
                        print('Sign In With Facebook');
                        // _loginWithFacebook();
                        // print(_message);
                      },
                      child: Container(
                        child: widget.theme == 'dark' ?
                          customButtonFacebookDark(context, "Sign In with Facebook", 18, Colors.blue) :
                          customButtonFacebookLight(context, "Sign In with Facebook", 18, Colors.blue),
                      ),
                    ),
                    SizedBox(height: 50),
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
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
