import 'package:ConnectMe/helper/helperFunctions.dart';
import 'package:ConnectMe/services/auth.dart';
import 'package:ConnectMe/services/database.dart';
import 'package:ConnectMe/views/chatRoomDashboard.dart';
import 'package:ConnectMe/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  bool _passwordVisible = false;

  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  QuerySnapshot queryUserSnapshot;
  final formKey = GlobalKey<FormState>();
  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  @override
  void initState() {
    _passwordVisible = false;
    Future.delayed(
        Duration(seconds: 1, milliseconds: 100), () =>
          setState(() {
            _loading = false;
          })
        );
    super.initState();
  }

  signMeIn() {
    if (formKey.currentState.validate()) {
      HelperFunctions.saveUserEmailSharedPreference(emailTextEditingController.text);

      databaseMethods.getUsersByUserEmail(emailTextEditingController.text)
          .then((val) {
        queryUserSnapshot = val;
        HelperFunctions
            .saveUserNameSharedPreference(queryUserSnapshot.documents[0].data['name']);
      });

      setState(() {
        isLoading = true;
      });

      authService.signInWithEmailAndPassword(
          emailTextEditingController.text,
          passwordTextEditingController.text).then((val) {
        if (val != null) {
          Navigator.pop(context);
          HelperFunctions.saveUserLoggedInSharedPreference(true);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoom(
                theme: widget.theme,
                toggleTheme: widget.toggleTheme,
                lightThemeColor: widget.lightThemeColor,
              ),
            ),
          );
          print('Signed In as ${emailTextEditingController.text}');
        }
        else {
          print("Error signing in");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: _loading || isLoading ? SpinKitDoubleBounce(
        color: widget.theme == 'dark' ? Colors.white : Colors.green,
      )
      : SingleChildScrollView(
        child: Container(
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
                        validator: (value) {
                          return RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)
                              ? null
                              : "Enter provide valid email";
                        },
                        decoration: InputDecoration(
                            labelText: "Enter Your Email",
                            hintText: "Enter your Registered Email ID",
                            hintStyle: TextStyle(
                              color: Colors.white24
                            ),
                            labelStyle: TextStyle(

                            ),
                            border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            borderSide: new BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(20.0),
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
                                color: Colors.white24
                            ),
                            labelStyle: TextStyle(
                              decorationColor: widget.lightThemeColor,
                            ),
                            border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(20.0),
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
                            borderRadius: new BorderRadius.circular(20.0),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print("This is Forgot Password! block");
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Forgot Password!",
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
                          signMeIn();
                        },
                          child: customButtonDark(context, "Sign In", 18, widget.lightThemeColor
                          ),
                      ),
                      SizedBox(height: 10,),
                      widget.theme == 'dark' ? customButtonDark(context, "Sign In with Google", 18, Colors.white) :
                        customButtonLight(context, "Sign In with Google", 18, Colors.white),
                      SizedBox(height: 10,),
                      widget.theme == 'dark' ? customButtonDark(context, "Sign In with Facebook", 18, Colors.blue) :
                        customButtonLight(context, "Sign In with Facebook", 18, Colors.blue),
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
              ]
            ),
          ),
        ),
      ),
    );
  }
}
