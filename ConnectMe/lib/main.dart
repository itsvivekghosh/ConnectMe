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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connect Me',
      theme: theme == 'dark' ? ThemeData.dark()
          : ThemeData(
        cursorColor: lightThemeColor,
        primaryColor: lightThemeColor,
        scaffoldBackgroundColor: Colors.white,
        accentColor: lightThemeColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(
          toggleTheme: toggleTheme,
          theme: theme,
          lightThemeColor: lightThemeColor
      ),
    );
  }
}
