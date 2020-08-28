import 'package:ConnectMe/views/SignIn.dart';
import 'package:ConnectMe/views/SignUp.dart';
import 'package:ConnectMe/views/selectionScreen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  final Function toggleTheme;
  final String theme;
  HomePage({this.toggleTheme, this.theme});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
//        child: signUpState == false ? SignUp(theme: widget.theme, toggleState: toggleState)
//            : SignIn(theme: widget.theme, toggleState: toggleState)
      child: SelectionScreen(
        theme: widget.theme,
        toggleTheme: widget.toggleTheme
      ),
      ),
    );
  }
}
