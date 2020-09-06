import 'package:flutter/material.dart';

class Constants {
  static String userName;
  static String userEmail;
  static String phoneNumber;
  static String currentTheme;
}

const kPrimaryColor = Color(0xFFFF7643);
const kPrimaryLightColor = Color(0xFFFFECDF);

const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFFA53E), Color(0xFFFF7643),
  ],
);

const kSecondaryColor = Color(0xFFFF7643);
const kTextColor = Color(0xFF757575);

const kAnimatedDuration = Duration(milliseconds: 200);