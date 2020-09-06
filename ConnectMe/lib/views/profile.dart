import 'package:ConnectMe/services/database.dart';
import 'package:ConnectMe/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userName;
  String phoneNumber;
  bool _loading = true;
  final formKey = GlobalKey<FormState>();
  final firestoreInstance = Firestore.instance;
  final DatabaseMethods _databaseMethods = new DatabaseMethods();
  TextEditingController userNameController = new TextEditingController();
  TextEditingController phoneNumberController = new TextEditingController();

  @override
  void initState() {
    getUserData();
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _loading = false;
      });
    });
  }

  void getUserData() async {
    var firebaseUser = await FirebaseAuth.instance.currentUser();
    var userData = await _databaseMethods.getUsersByUserEmail(firebaseUser.email);

    setState(() {
      userName = userData.documents[0].data['name'];
      phoneNumber = userData.documents[0].data['phoneNumber'];
    });
  }

  Future _updateProfile(context) async {
    final doc = Firestore.instance
        .collection('users')
        .document('')
        .updateData({}).catchError((e) => print(e.message));
    print(doc);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
            "Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w300,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading ?
      Center(
        child: JumpingDotsProgressIndicator(
          fontSize: 55.0,
          color: Colors.white,
        ),
      ) : Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              radius: 75.0,
              backgroundImage:
              AssetImage('assets/default.png'),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 50,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          decoration: TextDecoration.none
                      ),
                      keyboardType: TextInputType.emailAddress,
                      controller: userNameController,
                      decoration: InputDecoration(
                        labelText: userName,
                        hintText: "Enter new Username",
                        hintStyle: TextStyle(
                            color: Colors.white24,
                        ),
                        labelStyle: TextStyle(
                            color: Colors.white
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
                            color: Colors.green,
                            style: BorderStyle.solid,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 22),
                    IntlPhoneField(
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300
                      ),
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                        labelText: phoneNumber,
                        hintText: "Enter new Number",
                        hintStyle: TextStyle(
                            color: Colors.white24
                        ),
                        labelStyle: TextStyle(
                          color: Colors.white
                        ),
                        focusColor: Colors.green,
                        border: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(32.0),
                          borderSide: new BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(32.0),
                          borderSide: BorderSide(
                            color: Colors.green,
                            style: BorderStyle.solid,
                            width: 3,
                          ),
                        ),
                      ),
                      initialCountryCode: 'IN',
                    ),
                    SizedBox(height: 30,),
                    GestureDetector(
                      onTap: () async {
                        print("Update Profile");
                        await _updateProfile(context);
                      },
                      child: customButtonDark(
                          context, "Update", 18, Colors.green
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        print("Cancel Update");
                      },
                      child: customButtonDark(
                          context, "Cancel", 18, Colors.white
                      ),
                    ),
                    // SizedBox(height: 15),
                    // Container(
                    //   padding: EdgeInsets.only(right: 10),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     children: [
                    //       Text(
                    //           "Change My Password",
                    //         style: TextStyle(
                    //           fontWeight: FontWeight.w400,
                    //           fontSize: 16,
                    //         ),
                    //         textAlign: TextAlign.left,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
