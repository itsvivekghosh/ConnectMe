import 'dart:io';
import 'package:ConnectMe/views/ChatScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:ConnectMe/views/home.dart';
import 'package:ConnectMe/views/profile.dart';
import 'package:ConnectMe/services/auth.dart';
import 'package:ConnectMe/services/database.dart';
import 'package:ConnectMe/views/settings.dart';
import 'package:ConnectMe/views/themeSwitcher.dart';
import 'package:ConnectMe/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ConnectMe/helper/constants.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ChatRoom extends StatefulWidget {
  final Function toggleTheme, toggleAccentColor;
  final Color lightThemeColor;
  final bool isGoogleSignIn;

  ChatRoom({this.toggleTheme, this.lightThemeColor, this.isGoogleSignIn, this.toggleAccentColor});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  Widget image;
  dynamic _image;
  String loggedInEmail;
  String gotBioMessage;
  Choice selectedChoice;
  String loggedInUsername;
  bool _isSearching = false;
  String searchQuery = "Search Query";

  QuerySnapshot searchResultsSnapshot;
  final formKey = GlobalKey<FormState>();
  Future<QuerySnapshot> futureSearchResults;
  AuthService authService = new AuthService();
  TextEditingController searchEditingController;
  String darkThemeAssetPath = 'assets/theme/dark_green.jpg';
  String lightThemeAssetPath = 'assets/theme/light_green.jpg';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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
            image: image,
          ),
        ),
      );
    }

    else if (myChoice == 'New Group') {
      print("New Group");
    }

    else if (myChoice == 'Theme') {
      Navigator.push(context, CupertinoPageRoute(
        builder: (context) => ThemeSwitcher(
          toggleTheme: widget.toggleTheme,
          lightThemeColor: widget.lightThemeColor,
          toggleAccentColor: widget.toggleAccentColor,
        ),
        ),
      );
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
    getProfileImage();
    getProfileInfo();
    searchEditingController = new TextEditingController();
    super.initState();
  }

  getProfileInfo() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    final DatabaseMethods _databaseMethods = new DatabaseMethods();
    var userData = await _databaseMethods.getUsersByUserEmail(firebaseUser.email);

    setState(() {
      gotBioMessage = userData.documents[0].data['bio'];
    });
  }

  void _startSearch() {
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
      searchResultsSnapshot = null;
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    // print("close search box");
    setState(() {
      searchResultsSnapshot = null;
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
    return TextFormField(
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

  controlSearching(String query) {
    if (query.isNotEmpty) {
      Future<QuerySnapshot> allFoundUsers = Firestore.instance.collection('users')
        .where('userNameCaseSearch', arrayContains: query)
        .getDocuments()
        .then((value) {
        setState(() {
          searchResultsSnapshot = value;
        });
        return null;
      }).catchError((e) {
        print("Error Caught!: $e");
      });
      setState(() {
        futureSearchResults = allFoundUsers;
      });
    } else {
      // Empty Query field
      // print("Empty Query");
    }
  }

  dynamic getProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    final DatabaseMethods _databaseMethods = new DatabaseMethods();
    var userData = await _databaseMethods.getUsersByUserEmail(firebaseUser.email);
    var profileImage = userData.documents[0].data['profileImage'];
    imageCache.clear();

    setState(() {
      if (prefs.getString('profileImagePath') == Constants.profilePhotoUrl || prefs.getString('profileImagePath') == '') {
        image = ClipOval(
          child: ProgressiveImage(
            placeholder: AssetImage('assets/default.png'),
            image: NetworkImage(profileImage),
            thumbnail: AssetImage('assets/default.png'),
            width: 85,
            height: 85,
            fit: BoxFit.cover,
            blur: 3,
          ),
        );
        _image = ClipOval(
          child: ProgressiveImage(
            placeholder: AssetImage('assets/default.png'),
            image: NetworkImage(profileImage),
            thumbnail: AssetImage('assets/default.png'),
            width: 30,
            height: 30,
            blur: 3,
            fit: BoxFit.cover,
          ),
        );
      }
      else {
        try {
          image = ClipOval(
            child: ProgressiveImage(
              placeholder: FileImage(File(prefs.getString('profileImagePath'))),
              image: NetworkImage(profileImage),
              thumbnail: FileImage(File(prefs.getString('profileImagePath'))),
              width: 85,
              height: 85,
              fit: BoxFit.cover,
              blur: 3,
            ),
          );

          _image = ClipOval(
            child: ProgressiveImage(
              placeholder: FileImage(File(prefs.getString('profileImagePath'))),
              image: NetworkImage(profileImage),
              thumbnail: FileImage(File(prefs.getString('profileImagePath'))),
              width: 30,
              height: 30,
              blur: 3,
              fit: BoxFit.cover,
            ),
          );
        } catch (e) {
          image = ClipOval(
            child: ProgressiveImage(
              placeholder: NetworkImage(profileImage),
              image: NetworkImage(profileImage),
              thumbnail: NetworkImage(profileImage),
              width: 85,
              height: 85,
              fit: BoxFit.cover,
              blur: 3,
            ),
          );
          _image = ClipOval(
            child: ProgressiveImage(
              placeholder: NetworkImage(profileImage),
              image: NetworkImage(profileImage),
              thumbnail: NetworkImage(profileImage),
              width: 30,
              height: 30,
              blur: 3,
              fit: BoxFit.cover,
            ),
          );
        }
      }
    });
  }

  removeBio() async {
    if (gotBioMessage == null) {
      _scaffoldKey.currentState.showSnackBar(
          showSnackBarWithMessage("Cannot Remove Empty Bio!", "", Colors.red)
      );
      Navigator.of(context).pop();
      return;
    }
    FirebaseUser _firebaseUser = await FirebaseAuth.instance.currentUser();
    Map<String, String> userUpdateMap = {
      'bio': null,
    };

    await Firestore.instance
        .collection('users')
        .document(_firebaseUser.uid)
        .updateData(userUpdateMap).catchError((e) {
      print("Unable to Update data.. $e");
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('bio', null)
        .catchError((onError) {
      print("Error storing bio preferences $onError");
    });
    Constants.bioMessage = null;

    setState(() {
      gotBioMessage = null;
    });

    _scaffoldKey.currentState.showSnackBar(
      showSnackBarWithMessage("Your Bio has been Removed Successfully!", "", Colors.red)
    );
    Navigator.of(context).pop();
  }

  updateBio(bioMessage) async {
    if (formKey.currentState.validate()) {
      FirebaseUser _firebaseUser = await FirebaseAuth.instance.currentUser();

      Map<String, String> userUpdateMap = {
        'bio': bioMessage == '' ? null : bioMessage,
      };

      await Firestore.instance
          .collection('users')
          .document(_firebaseUser.uid)
          .updateData(userUpdateMap).catchError((e) {
        print("Unable to Update data.. $e");
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('bio', bioMessage)
          .catchError((onError) {
        print("Error storing bio preferences $onError");
      });
      Constants.bioMessage = bioMessage;

      setState(() {
        gotBioMessage = bioMessage;
      });

      _scaffoldKey.currentState.showSnackBar(
          showSnackBarWithMessage("Your Bio has been Updated Successfully!", "", Colors.green)
      );
      Navigator.of(context).pop();
    } else {
      // some error code here
    }
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
          key: _scaffoldKey,
          resizeToAvoidBottomPadding: true,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50.0) * 2.37,
            child: AppBar(
              automaticallyImplyLeading: false,
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
              bottom: _isSearching ? null : TabBar(
                tabs: tabs,
                indicatorColor: Constants.currentTheme == 'dark' ?
                  Constants.accentColor == Colors.black ? Colors.white : Constants.accentColor
                    : Colors.white
              ),
              actions: _buildActions(),
            ),
          ),
          body: TabBarView(
            children: [
              _isSearching ?
                  futureSearchResults == null || searchResultsSnapshot == null ?
                    displayNoSearchResults('Search Something', Icons.all_inclusive) : displaySearchResults()
                : Text('Chat Screen'),
              Text("Status"), // STATUS
              Text("Groups"), // GROUPS
            ],
          ),
          floatingActionButton: _isSearching ? null : FloatingActionButton(
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

  Widget displayNoSearchResults(message, icon) {
    return Container(
      padding: EdgeInsets.only(top: 150),
      child: ListView(
        shrinkWrap: true,
        children: [
          Icon(
            icon,
            color: Constants.currentTheme == 'dark' ? Colors.white12 : Colors.black12,
            size: 150,
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Constants.currentTheme == 'dark' ? Colors.white12 : Colors.black12,
              fontSize: 22,
              fontWeight: FontWeight.w300
            ),
          ),
        ],
      ),
    );
  }

  Widget displaySearchResults() {
    if (searchResultsSnapshot.documents.length > 0) {
      return ListView.builder(
        itemCount: searchResultsSnapshot.documents.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> userMap = {
            "userId": searchResultsSnapshot.documents[index].data['userId'],
            "userEmail": searchResultsSnapshot.documents[index].data['email'],
            "userName": searchResultsSnapshot.documents[index].data['name'],
            "profilePhotoUrl": searchResultsSnapshot.documents[index].data['profileImage'],
          };
          return SearchTile(userMap: userMap);
        },
      );
    } else {
      return displayNoSearchResults('No results found', Icons.info);
    }
  }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        new GestureDetector(
          onTap: () {
            controlSearching(searchEditingController.text.toString());
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
            _modalBottomSheetMenu(context);
          },
          child: Container(
            height: 30, width: 30,
            child: CircleAvatar(
              radius: 30,
              child: _image,
              backgroundColor: Colors.transparent,
            ),
          )
        ),
      ),
      Container(
        padding: EdgeInsets.only(top: 5, left: 8),
        child: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
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

  _modalBottomSheetMenu(context) async {

    FocusNode myFocusNode = new FocusNode();
    TextEditingController bioEditingController = new TextEditingController();

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        enableDrag: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        builder: (context) {
      return CupertinoPageScaffold (
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, CupertinoPageRoute(
                      builder: (context) => Profile(
                        toggleTheme: widget.toggleTheme,
                        toggleAccentColor: widget.toggleAccentColor,
                        lightThemeColor: widget.lightThemeColor,
                        userName: Constants.userName,
                        phoneNumber: Constants.phoneNumber,
                      ),
                    ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // image != null ? image : Container(),
                      Container(
                        child: image,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Constants.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30
                            ),
                          ),
                          Text(
                            Constants.userEmail,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                              color: Constants.currentTheme == "dark" ? Colors.white54 : Colors.black54
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Manage Your Bio",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 10,),
                Form(
                  key: formKey,
                  child: TextFormField(
                    focusNode: myFocusNode,
                    validator: (val){
                      return val == '' ? "Bio Cannot be Empty!" : null;
                    },
                    controller: bioEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: gotBioMessage == null ? "Enter Bio" : gotBioMessage,
                      hintText: "Enter Your Bio here",
                      hintStyle: TextStyle(
                        color: Constants.currentTheme == 'dark' ? Colors.white24 : Colors.black38,
                        fontWeight: FontWeight.w300
                      ),
                      labelStyle: TextStyle(
                        color: Constants.currentTheme == 'dark' ? Colors.white : Colors.black,
                        fontSize: myFocusNode.hasFocus ? 20 : 18,
                        fontWeight: FontWeight.w500
                      ),
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(32.0),
                        borderSide: new BorderSide(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(32.0),
                        borderSide: BorderSide(
                          color: Constants.accentColor == Colors.black ?
                          Constants.currentTheme == 'dark' ? Colors.white70 : Colors.black
                              : Constants.accentColor,
                          style: BorderStyle.solid,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.only(left: 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          removeBio();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(colors: [
                                Colors.white,
                                Colors.white
                              ]),
                              boxShadow: Constants.currentTheme == 'light' ? [BoxShadow(spreadRadius: 0.3)]: null
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20,),
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Remove Bio",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          updateBio(bioEditingController.text);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(colors: [
                                Constants.accentColor, Constants.accentColor
                              ])
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20,),
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            child: Text(
                              "Update Bio",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
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

class SearchTile extends StatelessWidget {
  final Map<String, dynamic> userMap;
  SearchTile({this.userMap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          print("Profile of ${userMap['userName']}");
        },
          child: Container(
          padding: EdgeInsets.only(top: 10, left: 10),
          child: Column(
            children: [
            ListTile(
              leading: Container(
                width: 60,
                height: 60,
                child: profileImage(userMap['profilePhotoUrl']),
              ),
              title: Text(
                userMap['userName'],
                style: TextStyle(
                    fontWeight: FontWeight.w600
                ),
              ),
              subtitle: Text(
                userMap['userEmail'],
                style: TextStyle(
                  fontWeight: FontWeight.w400
                ),
              ),
              trailing: userMap['userName'] != Constants.userName ? Container(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  onPressed: () {
                    joinChatScreen(context, userMap);
                  },
                  icon: Icon(
                    Icons.message,
                    size: 25,
                    color: Constants.currentTheme == "dark" ? Colors.white : Constants.accentColor
                  ),
                ),
              ) : null,
            ),
            SizedBox(height: 10),
            drawLine(),
          ],
        ),
      ),
    );
  }

  Widget profileImage(profilePhotoUrl) {
    return Container(
      child: ClipOval(
        child: ProgressiveImage(
          placeholder: CachedNetworkImageProvider(profilePhotoUrl),
          image: CachedNetworkImageProvider(profilePhotoUrl),
          thumbnail: CachedNetworkImageProvider(profilePhotoUrl),
          width: 80,
          height: 80,
          blur: 3,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

Widget drawLine() {
  return Padding(
    padding:EdgeInsets.symmetric(horizontal: 50.0),
    child: Container(
      height: 0.6,
      width: 350.0,
      color: Constants.currentTheme == 'light' ? Colors.black26 : Colors.white38,
    ),
  );
}

joinChatScreen(context, userMap) {
  if (userMap['userName'] != Constants.userName) {
    print("Connect With '${userMap['userName']}' '${userMap['userId']}'");
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) {
        return ChatScreen(user: userMap);
      }),
    );
  } else {
    print("You cannot send message to yourself");
  }
}