import 'package:ConnectMe/helper/constants.dart';
import 'package:ConnectMe/helper/helperFunctions.dart';
import 'package:ConnectMe/services/auth.dart';
import 'package:ConnectMe/views/home.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String theme;
  final Function toggleTheme;
  final Color lightThemeColor;
  final String currentLoginUser;

  ChatRoom({this.theme, this.toggleTheme, this.lightThemeColor, this.currentLoginUser});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  AuthService authService = new AuthService();

  Future<bool> _onLogoutButtonPressed(){
    final alertDialog = AlertDialog(
      content: Text(
          "Are you sure you want to Logout?",
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
        ),
      ),
      actions: <Widget>[
        FlatButton(
            child: Text(
              "I'm Sure",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.w400
              ),
            ),
            onPressed: () {
              authService.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => HomePage(
                      theme: widget.theme,
                      toggleTheme: widget.toggleTheme,
                      lightThemeColor: widget.lightThemeColor
                  )
              ));
            }
        ),
        FlatButton(
          child: Text(
            "Not Really",
            style: TextStyle(
                color: Colors.green,
                fontSize: 20,
                fontWeight: FontWeight.w400
            ),
          ),
          onPressed: () =>
              Navigator.of(context).pop(),
        )
      ],
    );
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) =>
        alertDialog
    );
  }

  Choice _selectedChoice = null;
  String titleName;

  _select(Choice choice) {
    setState(() {
      _selectedChoice = choice;
    });
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    setState(() {
      titleName = Constants.myName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$titleName"),
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
              _onLogoutButtonPressed();
            },
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.exit_to_app)
            ),
          ),
        ],
      ),
      body: Text('Welcome ${widget.currentLoginUser}'),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.search,
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