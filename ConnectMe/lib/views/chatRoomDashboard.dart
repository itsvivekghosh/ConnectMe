import 'package:ConnectMe/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:ConnectMe/views/home.dart';
import 'package:ConnectMe/views/profile.dart';
import 'package:ConnectMe/services/auth.dart';
import 'package:ConnectMe/helper/constants.dart';


class ChatRoom extends StatefulWidget {
  final Function toggleTheme, toggleAccentColor;
  final Color lightThemeColor;
  final bool isGoogleSignIn;

  ChatRoom({this.toggleTheme, this.lightThemeColor, this.isGoogleSignIn, this.toggleAccentColor});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {

  String loggedInEmail;
  Choice selectedChoice;
  String loggedInUsername;
  bool _isSearching = false;
  String searchQuery = "Search Query";
  AuthService authService = new AuthService();
  TextEditingController searchEditingController;
  String darkThemeAssetPath = 'assets/theme/default_dark.jpg';
  String lightThemeAssetPath = 'assets/theme/default_light.jpg';

  _select(Choice choice) async{
    final myChoice = choice.title;
    setState(() {
      selectedChoice = choice;
    });

    if (myChoice == 'Profile') {
      Navigator.push(context, CupertinoPageRoute(
          builder: (context) => Profile(
            toggleTheme: widget.toggleTheme,
            toggleAccentColor: widget.toggleAccentColor,
            lightThemeColor: widget.lightThemeColor,
            userName: Constants.userName,
            phoneNumber: Constants.phoneNumber,
          ),
        ),
      );
    }

    else if (myChoice == 'Settings') {
      Navigator.push(context, CupertinoPageRoute(
        builder: (context) => SettingsPage(
            toggleTheme: widget.toggleTheme,
            lightThemeColor: widget.lightThemeColor,
            userName: Constants.userName,
            toggleAccentColor: widget.toggleAccentColor,
          ),
        ),
      );
    }

    else if (myChoice == 'New Group') {
      print("New Group");
    }

    else if (myChoice == 'Theme') {
      setState(() {
        widget.toggleTheme();
      });
    }

    else if (myChoice == 'Logout') {
      await authService.signOut();
      Navigator.pushReplacement(context, CupertinoPageRoute(
          builder: (context) => HomePage(
            toggleTheme: widget.toggleTheme,
            lightThemeColor: widget.lightThemeColor,
            toggleAccentColor: widget.toggleAccentColor
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    searchEditingController = new TextEditingController();
    super.initState();
  }

  void _startSearch() {
    // print("open search box");
    ModalRoute
        .of(context)
        .addLocalHistoryEntry(new LocalHistoryEntry(onRemove: _stopSearching));
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    // print("close search box");
    setState(() {
      searchEditingController.clear();
      updateSearchQuery("Search query");
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
    // print("search query " + newQuery);
  }

  Widget _buildSearchField() {
    return new TextField(
      controller: searchEditingController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search Accounts, Messages...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Constants.currentTheme == "dark" ? Colors.white30 : Colors.white70
        ),
      ),
      style: TextStyle(
          color: Colors.white, fontSize: 16.4
      ),
      onChanged: updateSearchQuery,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            // Your code goes here.
            // To get index of current tab use tabController.index
            // print(tabController.index);
          }
        });
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50.0) * 2.37,
            child: AppBar(
              backgroundColor: Constants.currentTheme != 'dark' ? Constants.accentColor : null,
              leading: _isSearching ? const BackButton() : null,
              title: _isSearching ? _buildSearchField() : Container(
                padding: EdgeInsets.only(left: 8, top: 12),
                child: Text(
                  "ConnectMe",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 25
                  ),
                ),
              ),
              bottom: TabBar(
                tabs: tabs,
                indicatorColor: Constants.currentTheme == 'dark' ? Constants.accentColor : Colors.white,
              ),
              actions: _buildActions(),
              // actions: <Widget>[
              //
              // ],
            ),
          ),
          body: TabBarView(
            children: tabs.map((Tab tab) {
              return Center(
                child: Text(
                  tab.text.toLowerCase() + ' Tab ' + Constants.userName.toString(),
                  style: Theme.of(context).textTheme.headline4,
                ),
              );
            }).toList(),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(
              Icons.message,
              color: Colors.white,
            ),
            backgroundColor: Constants.accentColor,
            onPressed: () {
              print('Add me');
            },
          ),
        );
      }),
    );
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        new GestureDetector(
          onTap: () {
            print("Searching... " + searchEditingController.text.toString());
          },
          child: Container(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.search)
          ),
        ),
        new GestureDetector(
          onTap: () {
            if (searchEditingController == null || searchEditingController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
          child: Container(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.clear)
          ),
        ),
      ];
    }

    return <Widget>[
      Container(
        padding: EdgeInsets.only(top: 5),
        child: new GestureDetector(
          onTap: () {
            print("Profile");
          },
          child: Container(
            height: 26, width: 26,
            child: CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/batman.jpeg'),
            ),
          )
        ),
      ),
      Container(
        padding: EdgeInsets.only(top: 5, left: 8),
        child: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            print("Search");
            _startSearch();
          },
        ),
      ),
      Container(
        padding: EdgeInsets.only(top: 5),
        child: PopupMenuButton<Choice>(
          padding: EdgeInsets.only(right: 8),
          onSelected: _select,
          elevation: 4,
          itemBuilder: (BuildContext context) {
            return choices.map((Choice choice) =>
              PopupMenuItem<Choice>(
                value: choice,
                child: Container(
                  margin: EdgeInsets.only(right: 50),
                  child: Text(
                    choice.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400
                    ),
                  ),
                ),
              )
            ).toList();
          },
        ),
      ),
    ];
  }
}

class Choice {
  final String title;
  final IconData icon;
  const Choice({this.title, this.icon});
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'New Group', icon: Icons.group),
  const Choice(title: 'Profile', icon: Icons.person),
  const Choice(title: 'Settings', icon: Icons.settings),
  const Choice(title: 'Theme', icon: Icons.brightness_4),
  const Choice(title: 'Logout', icon: Icons.exit_to_app_rounded),
];

final List<Tab> tabs = <Tab>[
  Tab(text: 'Chats'.toUpperCase()),
  Tab(text: 'Status'.toUpperCase()),
  Tab(text: 'Groups'.toUpperCase()),
];