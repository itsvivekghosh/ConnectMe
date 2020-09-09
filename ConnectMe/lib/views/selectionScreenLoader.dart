import 'package:flutter/material.dart';
import 'package:ConnectMe/views/home.dart';
import 'package:ConnectMe/helper/constants.dart';
import 'package:ConnectMe/views/chatRoomDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectionScreenLoader extends StatefulWidget {

  final bool userLoggedIn;
  SelectionScreenLoader({this.userLoggedIn});

  @override
  _SelectionScreenLoaderState createState() => _SelectionScreenLoaderState();
}

class _SelectionScreenLoaderState extends State<SelectionScreenLoader> {
  Color lightThemeColor = Colors.green;

  toggleTheme() async {
    setState(() {
      if (Constants.currentTheme == 'light')
        Constants.currentTheme = 'dark';
      else Constants.currentTheme = 'light';
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConnectMe',
      theme: Constants.currentTheme == 'dark' ? ThemeData.dark()
          : ThemeData(
        cursorColor: lightThemeColor,
        primaryColor: lightThemeColor,
        scaffoldBackgroundColor: Colors.white,
        accentColor: lightThemeColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: widget.userLoggedIn ?
        ChatRoom(
            toggleTheme: toggleTheme,
            lightThemeColor: lightThemeColor
          ) :
        HomePage(
          toggleTheme: toggleTheme,
          lightThemeColor: lightThemeColor
      ),
    );
  }
}
