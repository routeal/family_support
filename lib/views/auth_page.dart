import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/widgets/auth_widget.dart';

class AuthPage extends StatelessWidget {
  Future<String?> _onLogin(
      BuildContext context, String email, String password) async {
    try {
      FirebaseService firebase = context.read<FirebaseService>();
      User? user = await firebase.signIn(email: email, password: password);
      if (user == null) {
        throw ('Unable to sign in due to unknown error.');
      }
      print('login success');
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else {
        return e.message ?? 'Unknown error has occurred.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _onSignup(
      BuildContext context, String email, String password) async {
    try {
      FirebaseService firebase = context.read<FirebaseService>();
      User? user = await firebase.signIn(
          email: email, password: password, createAccount: true);
      if (user == null) {
        throw ('Unable to sign in due to unknown error.');
      }
      await firebase.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      } else {
        return e.message ?? 'Unknown error has occurred.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _onSendEmailVerification(BuildContext context) async {
    try {
      FirebaseService firebase = context.read<FirebaseService>();
      await firebase.sendEmailVerification();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _onSendResetPassword(
      BuildContext context, String email) async {
    try {
      FirebaseService firebase = context.read<FirebaseService>();
      await firebase.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _onSubmitCompleted(BuildContext context) async {
    print('onSubmitCompleted');
  }

  Future<void> _onClose(BuildContext context) async {
    FirebaseService firebase = context.read<FirebaseService>();
    await firebase.signOut();
  }

  @override
  Widget build(BuildContext context) {
    //User? user = context.watch<User?>();
    FirebaseService firebase = context.read<FirebaseService>();
    return AuthWidget(
      title: AppLocalizations.of(context)!.appName,
      footer: AppLocalizations.of(context)!.company,
      onLogin: _onLogin,
      onSignup: _onSignup,
      onSendEmailVerification: _onSendEmailVerification,
      onSendResetPassword: _onSendResetPassword,
      onSubmitCompleted: _onSubmitCompleted,
      onClose: _onClose,
      initialValue: firebase.auth.currentUser?.email,
      isAuthPage: true,
    );
  }
}

class SendEmailVerificationPage extends StatelessWidget {
  Future<String?> _onSendEmailVerification(BuildContext context) async {
    try {
      FirebaseService firebase = context.read<FirebaseService>();
      await firebase.sendEmailVerification();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _onClose(BuildContext context) async {
    FirebaseService firebase = context.read<FirebaseService>();
    firebase.signOut();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseService firebase = context.read<FirebaseService>();
    String? email = firebase.auth.currentUser?.email;
    return AuthWidget(
      title: AppLocalizations.of(context)!.appName,
      footer: AppLocalizations.of(context)!.company,
      onSendEmailVerification: _onSendEmailVerification,
      onClose: _onClose,
      initialValue: email,
      isAuthPage: false,
    );
  }
}
