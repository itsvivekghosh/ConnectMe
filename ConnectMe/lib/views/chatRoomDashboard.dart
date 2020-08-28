import 'package:ConnectMe/services/auth.dart';
import 'package:ConnectMe/views/home.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String theme;
  final Function toggleTheme;
  final Color lightThemeColor;

  ChatRoom({this.theme, this.toggleTheme, this.lightThemeColor});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  AuthService authService = new AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ConnectMe"),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              authService.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(
                  builder: (context) => HomePage(
                      theme: widget.theme,
                      toggleTheme: widget.toggleTheme,
                      lightThemeColor: widget.lightThemeColor
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
      body: Text('Chat Room')
    );
  }
}
