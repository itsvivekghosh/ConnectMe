import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget customButton(dynamic context, String text, double fontSize, String backgroundColor) {
  return Container(
    alignment: Alignment.center,
    width: MediaQuery.of(context).size.width,
    padding: EdgeInsets.symmetric(vertical: 20),
    decoration: backgroundColor == 'green' ? BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      gradient: LinearGradient(colors: [
        Colors.green,
        Colors.green
      ])
    ): BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(colors: [
          Colors.white,
          Colors.white
        ])
    ),
    child: Container(
      child: Text(
        text,
        style: backgroundColor == 'green' ? TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold
        ) : TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontWeight: FontWeight.bold
        ),
      ),
    )
  );
}