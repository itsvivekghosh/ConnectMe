import 'package:ConnectMe/models/Person.dart';
import 'package:ConnectMe/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Person _userFromFirebaseUser(var user) {
    return user != null ? Person(personId: user.uid) : null;
  }

  Future signInWithEmailAndPassword(String email, String password) async {
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

  Future signUpWithEmailAndPassword(String email, String password, dynamic userMap) async {
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

  Future resetPasswordUsingEmail(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> signOut() async {
    try {
      await _auth.signOut();
      await googleSignIn.signOut();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('email')
          .then((value) {
        print("$value removed");
      })
          .catchError((onError) {
        print("Error removing password preferences");
      });
      prefs.remove('password')
          .then((value) {
        print("$value removed");
      })
          .catchError((onError) {
        print("Error removing password preferences");
      });
      prefs.remove('name')
          .then((value) {
        print("$value removed");
      })
          .catchError((onError) {
        print("Error removing name preferences");
      });
    } catch(e) {
      print(e.message);
    }

    return "User Signed Out Successfully!";
  }

  Future<void> signInWithGoogle() async {
    
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

  Future<String> getCurrentPersonID() async {
    return (await _auth.currentUser()).uid;
  }

  Future getCurrentUserInfo() async{
    return await _auth.currentUser();
  }
}