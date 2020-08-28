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
      body: Text("Hello from password reset Screen: ${widget.emailValue}"),
    );
  }
}
