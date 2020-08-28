import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ConnectMe/helper/helperFunctions.dart';
import 'package:ConnectMe/services/auth.dart';
import 'package:ConnectMe/services/database.dart';
import 'package:ConnectMe/views/chatRoomDashboard.dart';
import 'package:ConnectMe/widgets/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignUp extends StatefulWidget {
  final String theme;
  final Function toggleTheme;
  final Color lightThemeColor;
  SignUp({this.theme, this.toggleTheme, this.lightThemeColor});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool _passwordVisible = false;
  bool _loading = true;
  bool isLoadingNext = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController emailEditingController = new TextEditingController();
  TextEditingController userNameEditingController = new TextEditingController();
  TextEditingController passwordEditingController = new TextEditingController();
  TextEditingController phoneNumberEditingController = new TextEditingController();

  AuthService authService = new AuthService();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  signUp() async {
    if (formKey.currentState.validate()) {

      setState(() {
        isLoadingNext = true;
      });

      Map<String, String> userMap = {
        'name': userNameEditingController.text,
        'email': emailEditingController.text,
      };

      HelperFunctions.saveUserEmailSharedPreference(emailEditingController.text);
      HelperFunctions.saveUserNameSharedPreference(userNameEditingController.text);

      await authService
          .signUpWithEmailAndPassword(
          emailEditingController.text, passwordEditingController.text)
          .then(
            (value) {
          Navigator.pop(context);
          databaseMethods.uploadUserInfo(userMap);
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
        },
      );
    }
  }

  @override
  void initState() {
    _passwordVisible = false;
    Future.delayed(Duration(seconds: 1, milliseconds: 100), () {
      setState(() {
        _loading = false;
      });
    });
    super.initState();
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
      body: _loading || isLoadingNext ?
        Center(
        child:
        SpinKitDoubleBounce(
          color: widget.theme == 'dark' ?  Colors.white : Colors.green,
          size: 75,
        ),
      ) :
        SingleChildScrollView(
          child:Container(
            height: MediaQuery.of(context).size.height - 80,
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
                        )),
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
                            labelText: "Enter Username",
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                          controller: emailEditingController,
                          validator: (value) {
                            return RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value)
                                ? null
                                : "Enter Valid Email Address";
                          },
                          decoration: InputDecoration(
                            labelText: "Enter Your Email",
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
                        IntlPhoneField(
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300
                          ),
                          controller: phoneNumberEditingController,
                          decoration: InputDecoration(
                            labelText: 'Enter Phone Number',
                            focusColor: widget.lightThemeColor,
                            border: OutlineInputBorder(
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
                            labelText: "Enter Your Password",
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
                        SizedBox(height: 10,),
                        GestureDetector(
                          onTap: () {
                            signUp();
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
                                    Colors.blue,
                                    Colors.blue
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
      ),
    );
  }
}
