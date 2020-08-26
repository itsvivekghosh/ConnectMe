import 'package:ConnectMe/views/SignIn.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "ConnectMe",
          style: TextStyle(
            fontSize: 25,
          )
        ),
      ),
      body: Container(
        child: SignIn()
      ),
    );
  }
}
