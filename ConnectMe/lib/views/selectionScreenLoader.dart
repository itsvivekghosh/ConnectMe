import 'package:ConnectMe/views/chatRoomDashboard.dart';
import 'package:ConnectMe/views/home.dart';
import 'package:flutter/material.dart';

class SelectionScreenLoader extends StatefulWidget {

  final bool userLoggedIn;
  SelectionScreenLoader({this.userLoggedIn});

  @override
  _SelectionScreenLoaderState createState() => _SelectionScreenLoaderState();
}

class _SelectionScreenLoaderState extends State<SelectionScreenLoader> {

  String theme = 'dark';
  Color lightThemeColor = Colors.green;

  toggleTheme() {
    print("Toggling Theme");
    setState(() {
      if (theme == 'light')
        theme = 'dark';
      else theme = 'light';
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
      theme: theme == 'dark' ? ThemeData.dark()
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
            theme: theme,
            lightThemeColor: lightThemeColor
          ) :
        HomePage(
          toggleTheme: toggleTheme,
          theme: theme,
          lightThemeColor: lightThemeColor
      ),
    );
  }
}
