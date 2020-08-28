import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {

  getUsersByUsername(String username) async {
    return await Firestore.instance.collection('users')
        .where('name', isEqualTo: username)
        .getDocuments();
  }

  getUsersByUserEmail(String email) async {
    return await Firestore.instance.collection('users')
        .where('email', isEqualTo: email)
        .getDocuments();
  }

  uploadUserInfo(userMap) {
    Firestore.instance.collection('users')
        .add(userMap).catchError((onError) {
          print(onError.toString());
      },
    );
  }

  createChatRoom(String chatRoomID, dynamic chatRoomMap) {
    Firestore.instance.collection("ChatRoom")
        .document(chatRoomID).setData(chatRoomMap).catchError((e) {
      print(e.toString());
    });
  }
}