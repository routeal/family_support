import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:wecare/models/user.dart';

class FirebaseService {
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseAuth get auth => FirebaseAuth.instance;

  CollectionReference<AppUser?> get usersRef =>
      firestore.collection('users').withConverter<AppUser>(
            fromFirestore: (snapshots, _) =>
                AppUser.fromJson(snapshots.data()!),
            toFirestore: (AppUser, _) => AppUser.toJson(),
          );

  String? _userId;
  String? get userId => _userId;
  set userId(String? value) => _userId = value;

  bool _emailVerified = true;
  bool get emailVerified => _emailVerified;
  set emailVerified(bool b) => _emailVerified = b;

  Stream<User?> get onAuthStateChanged => auth.authStateChanges();

  Future<void> init() async {
    await Firebase.initializeApp();
    if (kIsWeb) {
      await auth.setPersistence(Persistence.LOCAL);
    }
  }

  Future<User?> signIn({required String email, required String password, bool createAccount = false}) async {
    UserCredential userCreds;
    if (createAccount) {
      userCreds = await auth.createUserWithEmailAndPassword(email: email, password: password);
    } else {
      userCreds = await auth.signInWithEmailAndPassword(email: email, password: password);
    }
    return userCreds.user;
  }

  Future<void> sendEmailVerification() async {
    User? user = auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    userId = null;
  }

  Future<AppUser?> getUser() async {
    return await usersRef
        .doc(_userId)
        .get()
        .then((snapshot) => snapshot.data()!);
  }

  Future<void> setUser(AppUser user) async {
    await usersRef
        .doc(user.id)
        .set(user);
  }

  Future<void> updateUser(AppUser user, Map<String, Object?> data) async {
    await usersRef
        .doc(user.id)
        .update(data);
  }

  Future<String?> uploadFile(String destination, String localPath) async {
    File localFile = File(localPath);
    if (!localFile.existsSync()) {
      throw('not found: ' + localPath);
    }
    UploadTask uploadTask = FirebaseStorage.instance.ref(destination).putFile(localFile);
    await uploadTask;
    return uploadTask.snapshot.ref.getDownloadURL();
  }

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
    FirebaseFunctions.instance
        .useFunctionsEmulator(origin: 'http://localhost:5001');
  }
}
