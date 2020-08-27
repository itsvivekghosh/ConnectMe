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
        primaryColor: Colors.green[800],
        scaffoldBackgroundColor: Colors.white,
        accentColor: Colors.green[800],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(toggleTheme: toggleTheme, theme: theme),
    );
  }
}
