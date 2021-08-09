import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:wecare/models/team.dart';
import 'package:wecare/models/user.dart' as app;

class FirebaseService {
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  ////////////////////////////////////////////////////////////////////////////
  /// Authentication
  ////////////////////////////////////////////////////////////////////////////

  FirebaseAuth get auth => FirebaseAuth.instance;
  Stream<User?> get onAuthStateChanged => auth.authStateChanges();

  Future<void> init() async {
    await Firebase.initializeApp();
    if (kIsWeb) {
      await auth.setPersistence(Persistence.LOCAL);
    }
  }

  Future<User?> signIn(
      {required String email,
      required String password,
      bool createAccount = false}) async {
    UserCredential userCreds;
    if (createAccount) {
      userCreds = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } else {
      userCreds = await auth.signInWithEmailAndPassword(
          email: email, password: password);
    }
    return userCreds.user;
  }

  Future<void> sendEmailVerification() async {
    User? user = auth.currentUser;
    if (user != null && !user.emailVerified) {
      return user.sendEmailVerification();
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    auth.signOut();
  }

  ////////////////////////////////////////////////////////////////////////////
  /// User
  ////////////////////////////////////////////////////////////////////////////

  get usersRef => firestore.collection('users');

  Future<app.User?> getUser(String uid) async {
    final snapshot = await usersRef.doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    try {
      data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
    } catch (e) {}
    return app.User.fromJson(data);
  }

  Future<void> createUser(app.User user) async {
    if (user.id == null) {
      final ref = usersRef.doc();
      user.id = ref.id;
    }
    final messageMap = user.toJson();
    messageMap['createdAt'] = FieldValue.serverTimestamp();
    return usersRef.doc(user.id).set(messageMap);
  }

  Future<void> updateUser(String uid, Map<String, Object?> data) async {
    data.remove('createdAt');
    return usersRef.doc(uid).update(data);
  }

  ////////////////////////////////////////////////////////////////////////////
  /// Teams
  ////////////////////////////////////////////////////////////////////////////

  get teamsRef => firestore.collection('teams');

  Future<Team?> getTeam(String id) async {
    final snapshot = await teamsRef.doc(id).get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data();
    if (data == null) {
      return null;
    }
    try {
      data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
    } catch (e) {}
    return Team.fromJson(data);
  }

  Future<void> createTeam(Team team) async {
    team.id = teamsRef.id;
    final messageMap = team.toJson();
    messageMap['createdAt'] = FieldValue.serverTimestamp();
    return teamsRef.set(messageMap);
  }

  Future<void> updateTeam(String id, Map<String, Object?> data) async {
    data.remove('createdAt');
    return teamsRef.doc(id).update(data);
  }

  ////////////////////////////////////////////////////////////////////////////
  /// Storage
  ////////////////////////////////////////////////////////////////////////////

  String userImagePath(String uid) {
    return 'users/' + uid + '/images';
  }

  String userProfileImagePath(String uid) {
    return userImagePath(uid) + '/user_profile.jpg';
  }

  Future<String?> uploadFile(String destination, String localPath) async {
    File localFile = File(localPath);
    if (!localFile.existsSync()) {
      throw ('not found: ' + localPath);
    }
    UploadTask uploadTask =
        FirebaseStorage.instance.ref(destination).putFile(localFile);
    return uploadTask.then((snapshot) => snapshot.ref.getDownloadURL());
  }

  Future<void> deleteFile(String destination) async {
    return FirebaseStorage.instance.ref().child(destination).delete();
  }

  ////////////////////////////////////////////////////////////////////////////
  /// Chat Messages
  ////////////////////////////////////////////////////////////////////////////

  chatRef(String id) => firestore.collection('chat/$id/messages');

  Future<void> sendMessage(String id, Map<String, Object?> message) async {
    await chatRef(id).add(message);
  }

  ////////////////////////////////////////////////////////////////////////////
  /// Emulator
  ////////////////////////////////////////////////////////////////////////////

/*
  void setupEmulator() async {
    // authentication
    FirebaseAuth.instance.useEmulator('http://localhost:9099');

    // cloud firestore
    FirebaseFirestore.instance.settings = const Settings(
      host: 'localhost:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );

    // cloud storage
    FirebaseStorage.instance.useEmulator(host: 'localhost', port: 9199);

    // cloud functions
//    FirebaseFunctions.instance
//        .useFunctionsEmulator(origin: 'http://localhost:5001');
  }
*/
}
