import 'package:ConnectMe/views/selectionScreen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  final Function toggleTheme;
  final Color lightThemeColor;
  HomePage({this.toggleTheme, this.lightThemeColor});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      child: SelectionScreen(
          toggleTheme: widget.toggleTheme,
          lightThemeColor: widget.lightThemeColor
        ),
      ),
    );
  }
}
