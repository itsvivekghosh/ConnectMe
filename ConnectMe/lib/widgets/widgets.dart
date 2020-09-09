import 'package:ConnectMe/helper/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

Widget customButtonDark(dynamic context, String text, double fontSize, Color color) {
  return Container(
    alignment: Alignment.center,
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.symmetric(vertical: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(colors: [
        color, color
      ]),
        boxShadow: color == Colors.white ? [BoxShadow(spreadRadius: 0.3)]: null
    ),
    child:
    Container(
      child: Text(
        text,
        style: TextStyle(
          color: color == Colors.white ? Colors.black: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold
        )
      ),
    ),
  );
}

Widget customButtonLight(dynamic context, String text, double fontSize, Color color) {
  return Container(
    alignment: Alignment.center,
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.symmetric(vertical: 20),
    decoration:
      BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: [
            color, color
          ]),
          boxShadow: color == Colors.white ? [BoxShadow(spreadRadius: 0.3)]: null
      ),
      child: Container(
        child: Text(
          text,
          style:
          TextStyle(
              color: color == Colors.white ? Colors.black: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold
          )
        ),
      )
  );
}

Widget customButtonGoogleDark(dynamic context, String text, double fontSize, Color color) {
  return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: [
            color, color
          ]),
          boxShadow: color == Colors.white ? [BoxShadow(spreadRadius: 0.3)]: null
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
              image: AssetImage("assets/google_logo.png"),
              height: 20.0
          ),
          SizedBox(width: 8,),
          Container(
            child: Text(
                text,
                style: TextStyle(
                    color: color == Colors.white ? Colors.black: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      )
  );
}

Widget customButtonFacebookDark(dynamic context, String text, double fontSize, Color color) {
  return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: [
            color, color
          ]),
          boxShadow: color == Colors.white ? [BoxShadow(spreadRadius: 0.3)]: null
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image(
                image: AssetImage("assets/facebook_logo.png"),
                height: 18.0,
                color: Colors.white,
            ),
          ),
          SizedBox(width: 8,),
          Container(
            child: Text(
                text,
                style: TextStyle(
                    color: color == Colors.white ? Colors.black: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      )
  );
}

Widget customButtonGoogleLight(dynamic context, String text, double fontSize, Color color) {
  return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: [
            color, color
          ]),
          boxShadow: color == Colors.white ? [BoxShadow(spreadRadius: 0.3)]: null
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
              image: AssetImage("assets/google_logo.png"),
              height: 20.0,
          ),
          SizedBox(width: 8,),
          Container(
            child: Text(
                text,
                style: TextStyle(
                    color: color == Colors.white ? Colors.black: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      )
  );
}

Widget customButtonFacebookLight(dynamic context, String text, double fontSize, Color color) {
  return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(colors: [
            color, color
          ]),
          boxShadow: color == Colors.white ? [BoxShadow(spreadRadius: 0.3)]: null
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image(
              image: AssetImage("assets/facebook_logo.png"),
              color: Colors.white,
              height: 20.0
          ),
          SizedBox(width: 8,),
          Container(
            child: Text(
                text,
                style: TextStyle(
                    color: color == Colors.white ? Colors.black: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold
                )
            ),
          ),
        ],
      )
  );
}

Future<void> showLoadingDialog(var message, BuildContext context, GlobalKey key) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new WillPopScope(
            onWillPop: () async => false,
            child: SimpleDialog(
                key: key,
                backgroundColor: Colors.white,
                children: <Widget>[
                  Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          JumpingDotsProgressIndicator(
                            color: Colors.green,
                            fontSize: 40,
                        ),
                        SizedBox(width: 25),
                        Text(
                          message,
                          style: TextStyle(
                              color: Colors.black
                          ),
                        )
                      ],
                    ),
                  )
                ]
            )
        );
      }
    );
}