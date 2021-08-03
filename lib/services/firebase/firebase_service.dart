import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:wecare/models/customer.dart';
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

  Future<AppUser?> getUser() {
    return usersRef
        .doc(auth.currentUser!.uid)
        .get()
        .then((snapshot) => snapshot.data()!);
  }

  Future<void> createUser(AppUser user) {
    return usersRef.doc(auth.currentUser!.uid).set(user);
  }

  Future<void> updateUser(Map<String, Object?> data) {
    return usersRef.doc(auth.currentUser!.uid).update(data);
  }

  Future<void> updateUserImage(String? url) {
    return usersRef.doc(auth.currentUser!.uid).update({'image_url':url});
  }

  ////////////////////////////////////////////////////////////////////////////
  /// Customer
  ////////////////////////////////////////////////////////////////////////////

  CollectionReference<Customer> get customersRef => FirebaseFirestore.instance
      .collection('users')
      .doc(auth.currentUser!.uid)
      .collection('customers')
      .withConverter<Customer>(
        fromFirestore: (snapshots, _) => Customer.fromJson(snapshots.data()!),
        toFirestore: (customer, _) => customer.toJson(),
      );

  Future<DocumentReference<Customer>> createCustomer(Customer customer) {
    return customersRef.add(customer);
  }

  Future<void> updateCustomer(String customerId, Map<String, Object?> data) {
    return customersRef.doc(customerId).update(data);
  }

  Future<void> updateCustomerImage(String customerId, String? url) {
    return customersRef.doc(customerId).update({'image_url': url});
  }

  ////////////////////////////////////////////////////////////////////////////
  /// Storage
  ////////////////////////////////////////////////////////////////////////////

  String _userImagePath() {
    return 'users/' + auth.currentUser!.uid + '/images';
  }

  String userImagePath() {
    return _userImagePath() + '/user_profile.jpg';
  }

  String customerImagePath(String id) {
    return _userImagePath() + '/' + id + '/customer_profile.jpg';
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
