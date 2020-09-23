import 'package:ConnectMe/models/Person.dart';
import 'package:ConnectMe/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Person _userFromFirebaseUser(var user) {
    return user != null ? Person(personId: user.uid) : null;
  }

  signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  signUpWithEmailAndPassword(String email, String password, dynamic userMap) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      DatabaseMethods().uploadUserData(userMap, user.uid);
      try {
        await user.sendEmailVerification();
        return _userFromFirebaseUser(user);
      } catch (e) {
        print("An error occurred while trying to send email verification");
        print(e.message);
      }
      return _userFromFirebaseUser(user);
    }
    catch (e) {
      print(e.toString());
      return null;
    }
  }

  resetPasswordUsingEmail(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  signOut() async {
    try {
      await _auth.signOut();
      await googleSignIn.signOut();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('email')
          .catchError((onError) {
            print("Error removing password preferences");
          });
      prefs.remove('password')
          .catchError((onError) {
            print("Error removing password preferences");
          });
      prefs.remove('name')
          .catchError((onError) {
            print("Error removing name preferences");
          });
    } catch(e) {
      print(e.message);
    }

    return "User Signed Out Successfully!";
  }

  signInWithGoogle() async {
    
    try {
      final GoogleSignIn _googleSignIn = new GoogleSignIn(
        scopes: ['email'],
        hostedDomain: '',
        clientId: '',
      );
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken
      );
      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

      // saving logged in State in local drive
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString('email', user.email.toString()).then((value) {
        print("Google Sign in Email saved!");
      }).catchError((onError) {
        print("Error on saving Email Preferences");
      });

      print("Signed in as: ${user.displayName}");
    } catch(e) {
        print("error while sign in: $e");
    }
  }

  void updateGoogleUserData(FirebaseUser user) async {
    print(user.uid);
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .getDocuments()
    .catchError((e) => print('Error: $e'));
    final List<DocumentSnapshot> documents = result.documents;

    if (documents.length == 0) {
      DocumentReference _documentReference = Firestore.instance.collection(
          'users').document(user.uid);

      return _documentReference.setData({
        'uid': user.uid,
        'email': user.email,
        'profileImage': user.photoUrl,
        'name': user.displayName,
      }, merge: true);
    }
  }

  getCurrentPersonID() async {
    return (await _auth.currentUser()).uid;
  }

  getCurrentUserInfo() async{
    return await _auth.currentUser();
  }
}