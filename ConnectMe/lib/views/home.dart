import 'package:ConnectMe/views/SignIn.dart';
import 'package:ConnectMe/views/SignUp.dart';
import 'package:ConnectMe/views/chatRoomDashboard.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  final Function toggleTheme;
  final String theme;
  HomePage({this.toggleTheme, this.theme});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool signUpState = true;
  toggleState() {
    setState(() {
      signUpState = !signUpState;
    });
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
            child: Icon(
                Icons.nature
            ),
          )
        ],
      ),
      body: Container(
        child: signUpState == false ? SignUp(theme: widget.theme, toggleState: toggleState)
            : SignIn(theme: widget.theme, toggleState: toggleState)
      ),
    );
  }
}
