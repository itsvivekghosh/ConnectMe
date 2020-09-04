import 'dart:async';
import 'package:ConnectMe/helper/constants.dart';
import 'package:flutter/material.dart';
import 'package:ConnectMe/views/selectionScreenLoader.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    getUserInfo();
    super.initState();
    Timer(Duration(seconds: 1), () => Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) {
        return SelectionScreenLoader();
      })
    ));
  }

  getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var email = prefs.getString('email');
    var name = prefs.getString('name');
    print("Logged in email:" + email.toString());
    print("Logged in name:" + name.toString());

    setState(() {
      Constants.userName = name;
      Constants.userEmail = email;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(top: 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 80.0,
                          child: Icon(
                            Icons.shopping_cart,
                            color: Colors.greenAccent,
                            size: 100.0,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 25.0),
                        ),
                        Text(
                          "ConnectMe",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 35.0
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                Expanded(
                  flex: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      JumpingDotsProgressIndicator(
                        fontSize: 40.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40,),
              ],
            )
          ],
        ),
      ),
    );
  }
}