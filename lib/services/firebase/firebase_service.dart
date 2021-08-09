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

  CollectionReference<app.User?> get usersRef =>
      firestore.collection('users').withConverter<app.User>(
            fromFirestore: (snapshots, _) =>
                app.User.fromJson(snapshots.data()!),
            toFirestore: (appUser, _) => appUser.toJson(),
          );

  Future<app.User?> getUser(String uid) async {
    final snapshot = await firestore.collection('users').doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    final data = snapshot.data();
    print(data.toString());
    if (data == null) {
      return null;
    }
    try {
      data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
    } catch (e) {}
    print(data.toString());
    return app.User.fromJson(data);
  }

  Future<void> createUser(app.User user) async {
    if (user.id == null) {
      final ref = usersRef.doc();
      user.id = ref.id;
    }
    final messageMap = user.toJson();
    messageMap['createdAt'] = FieldValue.serverTimestamp();
    return firestore.collection('users').doc(user.id).set(messageMap);
  }

  Future<void> updateUser(String uid, Map<String, Object?> data) {
    return usersRef.doc(uid).update(data);
  }

  Future<void> updateUserImage(String uid, String url) {
    return usersRef.doc(uid).update({'imageUrl': url});
  }

  ////////////////////////////////////////////////////////////////////////////
  /// Teams
  ////////////////////////////////////////////////////////////////////////////

  CollectionReference<Team?> get teamsRef =>
      firestore.collection('teams').withConverter<Team>(
            fromFirestore: (snapshots, _) => Team.fromJson(snapshots.data()!),
            toFirestore: (team, _) => team.toJson(),
          );

  Future<Team?> getTeam(String id) async {
    final snapshot = await firestore.collection('teams').doc(id).get();
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
    final ref = teamsRef.doc();
    team.id = ref.id;
    final messageMap = team.toJson();
    messageMap['createdAt'] = FieldValue.serverTimestamp();
    return firestore.collection('teams').doc(team.id).set(messageMap);
  }

  Future<void> updateTeam(String id, Map<String, Object?> data) {
    return teamsRef.doc(id).update(data);
  }

  Future<void> setTeam(Team team) async {
    final messageMap = team.toJson();
    messageMap.remove('createdAt');
    return firestore.collection('teams').doc(team.id).set(messageMap);
  }

  ////////////////////////////////////////////////////////////////////////////
  /// Storage
  ////////////////////////////////////////////////////////////////////////////

  String _userImagePath(String uid) {
    return 'users/' + uid + '/images';
  }

  String userProfileImagePath(String uid) {
    return _userImagePath(uid) + '/user_profile.jpg';
  }

  Future<String?> uploadFile(String destination, String localPath) {
    File localFile = File(localPath);
    if (!localFile.existsSync()) {
      throw ('not found: ' + localPath);
    }
    UploadTask uploadTask =
        FirebaseStorage.instance.ref(destination).putFile(localFile);
    return uploadTask.then((snapshot) => snapshot.ref.getDownloadURL());
  }

  Future<void> deleteFile(String destination) {
    return FirebaseStorage.instance.ref().child(destination).delete();
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
