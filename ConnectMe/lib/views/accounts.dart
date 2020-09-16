import 'package:flutter/material.dart';

class AccountSettings extends StatefulWidget {
  final Function toggleTheme;
  final Color lightThemeColor;
  final Function toggleAccentColor;
  AccountSettings({this.lightThemeColor, this.toggleTheme, this.toggleAccentColor});

  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Accounts",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: Container(
        child: Text('Accounts'),
      ),
    );
  }
}
