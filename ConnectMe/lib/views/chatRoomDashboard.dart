import 'package:ConnectMe/helper/constants.dart';
import 'package:ConnectMe/services/auth.dart';
import 'package:ConnectMe/views/home.dart';
import 'package:ConnectMe/views/profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final Function toggleTheme;
  final Color lightThemeColor;
  final bool isGoogleSignIn;

  ChatRoom({this.toggleTheme, this.lightThemeColor, this.isGoogleSignIn});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  AuthService authService = new AuthService();
  String loggedInUsername;
  String loggedInEmail;
  Choice selectedChoice;

  _select(Choice choice) {
    setState(() {
      selectedChoice = choice;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${Constants.userName}"),
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: _select,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                  value: choice,
                  child: Text(choice.title),
                );
              }).toList();
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, CupertinoPageRoute(
                  builder: (context) => Profile(
                      toggleTheme: widget.toggleTheme,
                      lightThemeColor: widget.lightThemeColor
                  )
              ));
            },
            child: Container(
              child: Icon(
                Icons.account_circle
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await authService.signOut();
              Navigator.pushReplacement(context, CupertinoPageRoute(
                  builder: (context) => HomePage(
                    toggleTheme: widget.toggleTheme,
                    lightThemeColor: widget.lightThemeColor,
                  )
              ));
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)
            ),
          ),
        ],
      ),
      body: Text('Welcome ${Constants.userName}'),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.message,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
        onPressed: () {
          print('add me');
        },
      ),
    );
  }
}

class Choice {
  final String title;
  final IconData icon;
  const Choice({this.title, this.icon});
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Profile', icon: Icons.directions_car),
  const Choice(title: 'Bicycle', icon: Icons.directions_bike),
  const Choice(title: 'Boat', icon: Icons.directions_boat),
  const Choice(title: 'Bus', icon: Icons.directions_bus),
  const Choice(title: 'Train', icon: Icons.directions_railway),
  const Choice(title: 'Walk', icon: Icons.directions_walk),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);
  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.headline4;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}