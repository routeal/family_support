import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:wecare/models/team.dart';
import 'package:wecare/models/user.dart';

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

  Future<void> sendEmailVerification() {
    User? user = auth.currentUser;
    if (user != null && !user.emailVerified) {
      return user.sendEmailVerification();
    }
    return Future(() => null);
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() {
    return auth.signOut();
  }

  ////////////////////////////////////////////////////////////////////////////
  /// User
  ////////////////////////////////////////////////////////////////////////////

  CollectionReference<AppUser?> get usersRef =>
      firestore.collection('users').withConverter<AppUser>(
            fromFirestore: (snapshots, _) =>
                AppUser.fromJson(snapshots.data()!),
            toFirestore: (AppUser, _) => AppUser.toJson(),
          );

  Future<AppUser?> getUser(String uid) {
    return usersRef.doc(uid).get().then((snapshot) => snapshot.data()!);
  }

  Future<void> createUser(AppUser user) {
    if (user.id == null) {
      final ref = usersRef.doc();
      user.id = ref.id;
    }
    return usersRef.doc(user.id).set(user);
  }

  Future<void> updateUser(String uid, Map<String, Object?> data) {
    return usersRef.doc(uid).update(data);
  }

  Future<void> updateUserImage(String uid, String? url) {
    return usersRef.doc(uid).update({'imageUrl': url});
  }

  ////////////////////////////////////////////////////////////////////////////
  /// Teams
  ////////////////////////////////////////////////////////////////////////////

  CollectionReference<Team?> get teamsRef =>
      firestore.collection('teams').withConverter<Team>(
            fromFirestore: (snapshots, _) => Team.fromJson(snapshots.data()!),
            toFirestore: (Team, _) => Team.toJson(),
          );

  Future<Team?> getTeam(String id) {
    return teamsRef.doc(id).get().then((snapshot) => snapshot.data()!);
  }

  Future<void> createTeam(Team team) {
    final ref = teamsRef.doc();
    team.id = ref.id;
    return ref.set(team);
  }

  Future<void> updateTeam(String? id, Map<String, Object?> data) {
    return teamsRef.doc(id).update(data);
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

  String customerImagePath(String id) {
    return _userImagePath(id) + '/' + id + '/customer_profile.jpg';
  }

  Future<String?> uploadFile(String destination, String localPath) {
    File localFile = File(localPath);
    if (!localFile.existsSync()) {
      throw ('not found: ' + localPath);
    }
    UploadTask uploadTask =
        FirebaseStorage.instance.ref(destination).putFile(localFile);
    return uploadTask.then((snapshot) => snapshot.ref.getDownloadURL());

//    await uploadTask;
//    return uploadTask.snapshot.ref.getDownloadURL();
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
