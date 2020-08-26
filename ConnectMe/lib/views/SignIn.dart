import 'package:ConnectMe/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 120,
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
              mainAxisSize: MainAxisSize.min,
            children:[
              Container(
                padding: EdgeInsets.symmetric(vertical: 70),
                child: Text("Hello,", style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  fontFamily: 'RobotoMono' ,
                ),)
              ),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          hintText: "Enter Your Email",
                          border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(12.0),
                          borderSide: new BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(12.0),
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
                      style: TextStyle(fontSize: 20),
                      obscureText: true,
                      decoration: InputDecoration(
                          hintText: "Enter Password",
                          border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(12.0),
                          borderSide: new BorderSide(
                            color: Colors.grey,
                            width: 5
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(12.0),
                          borderSide: BorderSide(
                            color: Colors.green,
                            style: BorderStyle.solid,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    customButton(context, "Sign In", 18, 'green'),
                    SizedBox(height: 20,),
                    customButton(context, "Sign In with Google", 18, 'white'),
                    SizedBox(height: 20,),
                    customButton(context, "Sign In with Facebook", 18, 'blue'),
                  ],
                )
              ),
            ]
          ),
        ),
      ),
    );
  }
}
