import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

final String USER_COLLECTION = 'users';
final String POST_COLLECTION = 'posts';

class FirebaseService {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseFirestore _db = FirebaseFirestore.instance;

  Map? currentUser;

  FirebaseService();

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required File image,
  }) async {
    try {
      UserCredential _userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      String _userId = _userCredential.user!.uid;
      String _fileName =
          Timestamp.now().millisecondsSinceEpoch.toString() +
          p.extension(image.path); //ex: 324708408308409.jpg
      UploadTask _task = _storage
          .ref('images/$_userId/$_fileName')
          .putFile(image);
      return _task.then((snapshot) async {
        String _downloadURL = await snapshot.ref.getDownloadURL();
        await _db.collection(USER_COLLECTION).doc(_userId).set({
          "name": name,
          "email": email,
          "image": _downloadURL,
        });
        return true;
      });
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential _userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (_userCredential.user != null) {
        currentUser = await getUserData(uid: _userCredential.user!.uid);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<Map> getUserData({required String uid}) async {
    DocumentSnapshot _doc = await _db
        .collection(USER_COLLECTION)
        .doc(uid)
        .get();
    return _doc.data() as Map;
  }

  Future<bool> postImage(File image) async {
    try {
      String _userId = _auth.currentUser!.uid;
      String _fileName =
          Timestamp.now().microsecondsSinceEpoch.toString() +
          p.extension(image.path);
      UploadTask _task = _storage
          .ref('images/$_userId/$_fileName')
          .putFile(image);
      return await _task.then((snapshot) async {
        String _downloadURL = await snapshot.ref.getDownloadURL();
        await _db.collection(POST_COLLECTION).add({
          "userId": _userId,
          "timestamp": Timestamp.now(),
          "image": _downloadURL,
        });
        return true;
      });
    } catch (e) {
      print(e);
      return false;
    }
  }

  Stream<QuerySnapshot> getLatestPosts() {
    return _db
        .collection(POST_COLLECTION)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getPostsForUser() {
    String userId = _auth.currentUser!.uid;
    return _db
        .collection(POST_COLLECTION)
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
