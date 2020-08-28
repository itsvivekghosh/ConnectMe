import 'package:ConnectMe/views/SignIn.dart';
import 'package:ConnectMe/views/SignUp.dart';
import 'package:flutter/material.dart';

class SelectionScreen extends StatefulWidget {
  final String theme;
  final Function toggleTheme;
  SelectionScreen({this.theme, this.toggleTheme});

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        FlatButton(
          child: Text('No'),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => alertDialog);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Container(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - 100,
            alignment: Alignment.center,
            child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      'Welcome to ConnectMe!'.toString(),
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
                      width: 230.0,
                      color: widget.theme == 'light' ? Colors.black : Colors.white,
                    ),
                  ),
                  SizedBox(height: 25,),
                  Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width - 60,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(colors: [
                            Colors.green, Colors.green
                          ]),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp(
                                theme: widget.theme,
                                toggleTheme: widget.toggleTheme
                              )),
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              print("sign up pressed");
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUp(
                                  theme: widget.theme,
                                  toggleTheme: widget.toggleTheme,
                                ),),
                              );
                            },
                            child: Text(
                                "SIGN UP FOR FREE",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                )
                            ),
                          ),
                        ),
                      )
                  ),
                  SizedBox(height: 20,),
                Container(
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
                      child: GestureDetector(
                        onTap: () {
                          print("Sign in pressed");
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SignIn(
                                theme: widget.theme,
                                toggleTheme: widget.toggleTheme,
                            ),),
                          );
                        },
                        child: Text(
                            "SIGN IN",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                            )
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }
}
