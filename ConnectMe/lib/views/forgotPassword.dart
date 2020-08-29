import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  final String theme;
  final Function toggleState, toggleTheme;
  final bool signUpState;
  final Color lightThemeColor;
  final String emailValue;
  ForgotPassword({this.emailValue, this.theme, this.toggleState, this.toggleTheme, this.signUpState, this.lightThemeColor});

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  final formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController emailEditingController = new TextEditingController();

  @override
  void initState() {
    print(widget.theme);
    super.initState();
  }

  void sendVerificationEmail() async {
    print("Sending Email!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Forgot Password",
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 20
          ),
        ),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Hey, have you forgot your Password? \nDon't Worry, Generating new password is a step forward!",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                        color: widget.theme == 'light' ? Colors.black : Colors.white24
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(height: 40,),
                Container(
                  child: Form(
                    key: formKey,
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: widget.theme == "dark" ? Colors.white : Colors.black,
                          decoration: TextDecoration.none
                      ),
                      validator: (value) {
                        return RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value)
                            ? null
                            : "Enter Valid Email Address";
                      },
                      controller: emailEditingController,
                      decoration: InputDecoration(
                        labelText: "Email Address",
                        hintText: "Enter Your Email Address",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          gapPadding: 0,
                          borderRadius: new BorderRadius.circular(32.0),
                          borderSide: BorderSide(
                            color: widget.lightThemeColor,
                            style: BorderStyle.solid,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                GestureDetector(
                  onTap: () async {
                    await sendVerificationEmail();
                  },
                  child: Container(
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 60,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(colors: [
                          widget.lightThemeColor, widget.lightThemeColor
                        ]),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child:
                        Text(
                          "Send Me Email Verification",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 60,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(colors: [
                          Colors.white, Colors.white
                        ]),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child:
                        Text(
                          "Cancel",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ),
    );
  }
}
