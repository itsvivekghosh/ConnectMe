import 'package:ConnectMe/helper/constants.dart';
import 'package:ConnectMe/views/SignIn.dart';
import 'package:ConnectMe/views/SignUp.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

class SelectionScreen extends StatefulWidget {
  final Function toggleTheme;
  final Color lightThemeColor;
  SelectionScreen({this.toggleTheme, this.lightThemeColor});

  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {

  bool isLoading = true;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 600), () {
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading ?
    Center(
      child: JumpingDotsProgressIndicator(
        fontSize: 40.0,
        color: Constants.currentTheme == 'dark' ? Colors.white : Colors.green,
      ),
    ) :
    SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 101),
          child: Container(
            child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "Hello",
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 7,),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      "There,",
                      style: TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.w500,
                        color: Constants.currentTheme == 'dark' ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(height: 100,),
                  Text(
                    'Welcome to ConnectMe!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30
                    ),
                  ),
                  SizedBox(height: 60),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (context) => SignUp(
                            toggleTheme: widget.toggleTheme,
                            lightThemeColor: widget.lightThemeColor,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 60,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(colors: [
                            widget.lightThemeColor, widget.lightThemeColor
                          ]),
                      ),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child:
                        Text(
                          "SIGN UP FOR FREE",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  children: [
                    Padding(
                      padding:EdgeInsets.symmetric(horizontal:10.0),
                      child:Container(
                        height: 0.5,
                        width: 110.0,
                        color: Constants.currentTheme == 'light' ? Colors.black : Colors.white,
                      ),
                    ),
                    Text(
                        "OR",
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 16
                        ),
                    ),
                    Padding(
                      padding:EdgeInsets.symmetric(horizontal:10.0),
                      child:Container(
                        height: 0.5,
                        width: 110.0,
                        color: Constants.currentTheme == 'light' ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30,),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                      CupertinoPageRoute(builder: (context) => SignIn(
                        toggleTheme: widget.toggleTheme,
                          lightThemeColor: widget.lightThemeColor
                      ),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width - 60,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(colors: [
                        Colors.white, Colors.white
                      ]),
                      boxShadow: Constants.currentTheme == 'light' ? [BoxShadow(spreadRadius: 0.4)] : null,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                        "SIGN IN",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Made with Love in India",
                      style: TextStyle(
                          fontWeight: Constants.currentTheme == 'dark' ? FontWeight.w100 : FontWeight.w300
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                        "assets/india.png",
                      height: 35, width: 35,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
