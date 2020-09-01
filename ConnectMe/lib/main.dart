import 'package:ConnectMe/helper/helperFunctions.dart';
import 'package:ConnectMe/views/chatRoomDashboard.dart';
import 'package:ConnectMe/views/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool userIsLoggedIn;
  String theme = 'dark';
  Color lightThemeColor = Colors.green;

  toggleTheme() {
    setState(() {
      if (theme == 'light')
        theme = 'dark';
      else theme = 'light';
    });
  }

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  getLoggedInState() async {
    await HelperFunctions().getUserLoggedInSharedPreference().then((value){
      setState(() {
        userIsLoggedIn  = value;
      });
    });
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
      home: userIsLoggedIn != null ?
            // true and null part
              userIsLoggedIn ? ChatRoom(
                  toggleTheme: toggleTheme,
                  theme: theme,
                  lightThemeColor: lightThemeColor
              ) : HomePage(
                  toggleTheme: toggleTheme,
                  theme: theme,
                  lightThemeColor: lightThemeColor
              )
      // false and non null part
          : Container(
        child: ChatRoom(
            toggleTheme: toggleTheme,
            theme: theme,
            lightThemeColor: lightThemeColor
        ),
      ),
    );
  }
}
