import 'package:ConnectMe/views/SignIn.dart';
import 'package:ConnectMe/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final String theme;
  final Function toggleTheme;
  SignUp({this.theme, this.toggleTheme});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignUp> {

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
                      child: Text("Namaste!", style: TextStyle(
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
                            keyboardType: TextInputType.number,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              hintText: "Enter Your Phone Number",
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
                          SizedBox(height: 10,),
                          TextFormField(
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Enter Your Password",
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
                          SizedBox(height: 20,),
                          customButtonDark(context, "Sign Up", 18, Colors.green),
                          SizedBox(height: 15),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: LinearGradient(colors: [
                                    Colors.white,
                                    Colors.white
                                  ]),
                                  boxShadow: widget.theme == 'light' ? [BoxShadow(spreadRadius: 0.3)]: null
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20,),
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'with Google',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold
                                  )
                                ),),
                              ),
                              SizedBox(width: 4,),
                              Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: LinearGradient(colors: [
                                      Colors.blue,
                                      Colors.blue
                                    ])
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20,),
                                  margin: EdgeInsets.symmetric(horizontal: 3),
                                  child: Text(
                                      'with Facebook',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold
                                      )
                                  ),),
                              ),
                            ],
                          ),
                        ],
                      )
                  ),
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
                ]
            ),
          ),
        ),
      ),
    );
  }
}
