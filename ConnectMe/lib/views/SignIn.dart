import 'package:ConnectMe/views/SignUp.dart';
import 'package:ConnectMe/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final String theme;
  final Function toggleState, toggleTheme;
  final bool signUpState;
  SignIn({this.theme, this.toggleState, this.toggleTheme, this.signUpState});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            "ConnectMe",
            style: TextStyle(
              fontSize: 25,
            )
        ),
        actions: [
          GestureDetector(
            onTap: () {
              widget.toggleTheme();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                  Icons.access_time
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 80,
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
                mainAxisSize: MainAxisSize.min,
              children:[
                Container(
                    padding: EdgeInsets.fromLTRB(10, 40, 10, 50),
                  child: Text("Hello,", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                    fontFamily: 'RobotoMono' ,
                  ),
                  )
                ),
                Form(
                  child: Column(
                    children: [
                      TextFormField(
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                        decoration: InputDecoration(
                            hintText: "Enter Your Email",
                            border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            borderSide: new BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            borderSide: BorderSide(
                              color: Colors.green,
                              style: BorderStyle.solid,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                        obscureText: true,
                        decoration: InputDecoration(
                            hintText: "Enter Password",
                            border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            borderSide: new BorderSide(
                              color: Colors.grey,
                              width: 5
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(20.0),
                            borderSide: BorderSide(
                              color: Colors.green,
                              style: BorderStyle.solid,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print("This is Forgot Password! block");
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Forgot Password!",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      customButtonDark(context, "Sign In", 18, Colors.green),
                      SizedBox(height: 10,),
                      widget.theme == 'dark' ? customButtonDark(context, "Sign In with Google", 18, Colors.white) :
                        customButtonLight(context, "Sign In with Google", 18, Colors.white),
                      SizedBox(height: 10,),
                      widget.theme == 'dark' ? customButtonDark(context, "Sign In with Facebook", 18, Colors.blue) :
                        customButtonLight(context, "Sign In with Facebook", 18, Colors.blue),
                      SizedBox(height: 50),
                      widget.theme == 'dark' ? Text(
                        "Made with Love in India",
                        style: TextStyle(
                            fontWeight: FontWeight.w100
                        ),
                      ) :
                      Text(
                        "Made with Love in India",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w300
                        ),
                      ),
                    ],
                  )
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}
