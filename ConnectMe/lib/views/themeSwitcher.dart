import 'package:ConnectMe/helper/constants.dart';
import 'package:flutter/material.dart';

class ThemeSwitcher extends StatefulWidget {
  final Function toggleTheme, toggleAccentColor;
  final Color lightThemeColor;
  ThemeSwitcher({this.toggleTheme, this.lightThemeColor, this.toggleAccentColor});

  @override
  _ThemeSwitcherState createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {

  String currentTheme = Constants.currentTheme;
  @override
  void initState() {
    currentTheme = Constants.currentTheme;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Themes",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(top: 100),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                toggleThemeWidget(),
                SizedBox(height: 60),
                Container(
                  child: Text(
                    "Change Accent Color",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                changeAccentColor(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget toggleThemeWidget() {
    return Container(
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Constants.currentTheme != 'light')
                setState(() {
                  widget.toggleTheme();
                  currentTheme = Constants.currentTheme;
                });
            },
            child: Column(
              children: [
                Container(
                  child: themeTile('assets/theme/default_light.jpg'),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: currentTheme == 'light' ?
                          Colors.blueAccent.withOpacity(0.2)
                            : Colors.black.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Light",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              if (Constants.currentTheme != 'dark')
                setState(() {
                  widget.toggleTheme();
                  currentTheme = Constants.currentTheme;
                });
            },
            child: Column(
              children: [
                Container(
                  child: themeTile('assets/theme/default_dark.jpg'),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: currentTheme == 'dark' ? Colors.blueAccent.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  child: Text(
                    "Dark",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget changeAccentColor() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              widget.toggleAccentColor(Colors.red);
            },
            child: Container(
              child: drawCircle(
                Colors.red, Constants.accentColor == Colors.red
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.toggleAccentColor(Colors.green);
            },
            child: Container(
              child: drawCircle(
                Colors.green, Constants.accentColor == Colors.green
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.toggleAccentColor(Colors.blue);
            },
            child: Container(
              child: drawCircle(
                Colors.blue, Constants.accentColor == Colors.blue
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.toggleAccentColor(Colors.brown);
            },
            child: Container(
              child: drawCircle(
                Colors.brown, Constants.accentColor == Colors.brown
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.toggleAccentColor(Colors.deepOrange);
            },
            child: Container(
              child: drawCircle(
                Colors.deepOrange, Constants.accentColor == Colors.deepOrange
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              widget.toggleAccentColor(Colors.black);
            },
            child: Container(
              child: drawCircle(
                Colors.black, Constants.accentColor == Colors.black
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget themeTile(pathToImage) {
  return ClipRRect(
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10)
    ),
    child: Image.asset(
      pathToImage,
      width: 142.0,
      height: 148.0,
      fit: BoxFit.fill,
    ),
  );
}

Widget drawCircle(color, checkColor) {
  return Container(
    width: 42.0,
    height: 42.0,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Constants.currentTheme == 'dark' ?
              checkColor ? Colors.blueAccent.withOpacity(0.3) : Colors.white.withOpacity(0.03)
              : checkColor ? Colors.blueAccent.withOpacity(0.3) : Colors.black.withOpacity(0.1),
          spreadRadius: 5,
          blurRadius: checkColor ? 3 : 7,
          offset: Offset(0, 0), // changes position of shadow
        ),
      ],
    ),
  );
}
