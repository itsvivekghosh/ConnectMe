import 'package:ConnectMe/helper/constants.dart';
import 'package:ConnectMe/views/profile.dart';
import 'package:ConnectMe/views/themeSwitcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

int selectedItem;

class SettingsPage extends StatefulWidget {
  final Function toggleTheme, toggleAccentColor;
  final Color lightThemeColor;
  final String userName, phoneNumber;
  SettingsPage({this.toggleTheme, this.lightThemeColor, this.userName, this.phoneNumber, this.toggleAccentColor});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    selectedItem = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: SettingsItems(
          lightColorTheme: widget.lightThemeColor,
          toggleTheme: widget.toggleTheme,
          toggleAccentColor: widget.toggleAccentColor,
        ),
      ),
    );
  }
}

class SettingsItems extends StatefulWidget {
  final Function toggleTheme, toggleAccentColor;
  final Color lightColorTheme;
  SettingsItems({this.lightColorTheme, this.toggleTheme, this.toggleAccentColor});

  @override
  _SettingsItemsState createState() => _SettingsItemsState();
}

class _SettingsItemsState extends State<SettingsItems> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 40),
            child: Text('Profile'),
          ),
          Container(
            padding: EdgeInsets.only(left: 40),
            child: Column(
              children: [
                SizedBox(height: 30,),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedItem = 1;
                      createActivity(context, widget.toggleTheme, widget.lightColorTheme, widget.toggleAccentColor);
                    });
                  },
                  child: settingsTile(
                    'Accounts', "Privacy, Security, Change Number", Icons.account_circle, Constants.accentColor
                  ),
                ),
                drawLine(),
                SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedItem = 2;
                    });
                    createActivity(context, widget.toggleTheme, widget.lightColorTheme, widget.toggleAccentColor);
                  },
                  child: settingsTile(
                    'Theme', "Change Theme, Wallpapers", Icons.brightness_5, Constants.accentColor
                  ),
                ),
                drawLine(),
                SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedItem = 3;
                    });
                  },
                  child: settingsTile(
                      'Notifications', "Message and Group Tones", Icons.notifications, Constants.accentColor
                  ),
                ),
                drawLine(),
                SizedBox(height: 25),
                GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedItem = 4;
                      });
                    },
                    child: settingsTile('Data and Storage usage', "Network usage, auto-download",
                        Icons.notifications, Constants.accentColor
                    ),
                ),
                drawLine(),
                SizedBox(height: 25),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedItem = 5;
                    });
                  },
                  child: settingsTile(
                    'Help', "FAQ, Contact Us, Privacy Policy", Icons.help_outline, Constants.accentColor
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Made with Love in India",
                  style: TextStyle(
                      fontWeight: Constants.currentTheme == 'dark' ? FontWeight.w100 : FontWeight.w300
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  "assets/india.png",
                  height: 30, width: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget settingsTile(title, subtitle, icon, iconTheme) {
  return Column(
    children: [
      Row(
        children: [
          Container(
            height: 30, width: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: Constants.currentTheme == 'dark' ?
                  Colors.white54 :
                    Constants.accentColor == Colors.black ? Colors.black54 : iconTheme.shade300,
              size: 30,
            ),
          ),
          SizedBox(width: 22),
          Container(
            padding: EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      color: Constants.currentTheme == 'dark' ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
                Text(
                    subtitle,
                  style: TextStyle(
                    color: Constants.currentTheme == 'dark' ? Colors.white54 : Colors.black54,
                  ),
                ),
                SizedBox(height: 10,),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

Widget drawLine() {
  return Padding(
    padding:EdgeInsets.symmetric(horizontal: 50.0),
    child: Container(
      height: 0.6,
      width: 250.0,
      color: Constants.currentTheme == 'light' ? Colors.black26 : Colors.white38,
    ),
  );
}

createActivity(context, toggleTheme, lightThemeColor, toggleAccentColor) {
  if (selectedItem == 1) {
      Navigator.push(context, CupertinoPageRoute(
        builder: (context) => Profile(
          toggleTheme: toggleTheme,
          lightThemeColor: lightThemeColor,
          toggleAccentColor: toggleAccentColor
        ),
      ),
    );
  }
  else if (selectedItem == 2) {
    Navigator.push(context, CupertinoPageRoute(
        builder: (context) => ThemeSwitcher(
          toggleTheme: toggleTheme,
          lightThemeColor: lightThemeColor,
          toggleAccentColor: toggleAccentColor,
        ),
      ),
    );
  }
}