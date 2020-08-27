import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    child: Container(
      child: Text(
        text,
        style: TextStyle(
          color: color == Colors.white ? Colors.black: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold
        )
      ),
    )
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