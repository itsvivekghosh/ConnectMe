import 'package:ConnectMe/views/SignIn.dart';
import 'package:ConnectMe/views/SignUp.dart';
import 'package:flutter/material.dart';

class SelectionScreen extends StatefulWidget {
  final String theme;
  final Function toggleTheme;
  final Color lightThemeColor;
  SelectionScreen({this.theme, this.toggleTheme, this.lightThemeColor});

  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {

  Future<bool> _onBackPressed(){
    final alertDialog = AlertDialog(
      content: Text("Hey, do you want to quit ConnectMe?"),
      actions: <Widget>[
        FlatButton(
          child: Text('Yes'),
          onPressed: () =>
              Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text('No'),
          onPressed: () =>
              Navigator.of(context).pop(),
        )
      ],
    );
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) =>
            alertDialog
    );
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Container(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 200),
            child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to ConnectMe!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30
                    ),
                  ),
                  SizedBox(height: 50,),
                  Padding(
                    padding:EdgeInsets.symmetric(horizontal:10.0),
                    child:Container(
                      height: 0.5,
                      width: 320.0,
                      color: widget.theme == 'light' ? Colors.black : Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUp(
                          theme: widget.theme,
                          toggleTheme: widget.toggleTheme,
                          lightThemeColor: widget.lightThemeColor,
                        ),),
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
                          color: widget.theme == 'light' ? Colors.black : Colors.white,
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
                          color: widget.theme == 'light' ? Colors.black : Colors.white,
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
                      MaterialPageRoute(builder: (context) => SignIn(
                        theme: widget.theme,
                        toggleTheme: widget.toggleTheme,
                          lightThemeColor: widget.lightThemeColor
                      ),),
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
                          boxShadow: widget.theme == 'light' ? [BoxShadow(spreadRadius: 0.4)] : null,
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
                  SizedBox(height: 50),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Made with Love in India",
                          style: TextStyle(
                              fontWeight: widget.theme == 'dark' ? FontWeight.w100 : FontWeight.w300
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
      ),
    );
  }
}
