import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/widgets/dialogs.dart';
import 'package:wecare/widgets/props/props_values.dart';
import 'package:wecare/widgets/props/props_widget.dart';

class UserPropsPage extends StatelessWidget {
  const UserPropsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    FirebaseService firebase =
        Provider.of<FirebaseService>(context, listen: false);
    AppState appState = Provider.of<AppState>(context, listen: false);
    return PropsWidget(
        UserProps(firebase.auth.currentUser, appState.currentUser));
  }
}

class UserProps extends PropsValues {
  bool _isNewUser = true;
  late AppUser _appUser;

  UserProps(User? firebaseUser, AppUser? appUser) {
    assert(firebaseUser != null);

    if (appUser != null) {
      _isNewUser = false;
      _appUser = appUser.clone();
      // title is the user's display name
      title = _appUser.display_name;
    } else {
      _appUser = AppUser(id: firebaseUser!.uid);
      _appUser.email = firebaseUser.email;
      title = "Your Information";
      logoutButtonLabel = "Logout";
    }
  }

  List<PropsValueItem> items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: _appUser.image,
        onSaved: (String? value) {
          if (value != null || value!.isNotEmpty) {
            _appUser.filepath = value;
          }
        },
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return "Photo is required";
          }
          File file = File(value);
          if (!file.existsSync()) {
            return 'Photo is not saved in ' + value;
          }
          return null;
        },
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Display Name",
        init: _appUser.display_name,
        icon: Icons.person_outline,
        onSaved: (String? value) {
          if (value == null || value.isEmpty) {
            _appUser.display_name = _appUser.last_name;
          } else {
            _appUser.display_name = value;
          }
        },
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "First Name",
        init: _appUser.first_name,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "First Name is required";
          return null;
        },
        onSaved: (String? value) => _appUser.first_name = value!,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Last Name",
        init: _appUser.last_name,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Last Name is required";
          return null;
        },
        onSaved: (String? value) => _appUser.last_name = value!,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: _appUser.company,
        icon: Icons.business_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Company is required";
          return null;
        },
        onSaved: (String? value) => _appUser.company = value!,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Phone",
        init: _appUser.phone,
        icon: Icons.phone_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Phone is required";
          return null;
        },
        onSaved: (String? value) => _appUser.phone = value!,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Email",
        init: _appUser.email,
        icon: Icons.email_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Email is required";
          return null;
        },
        onSaved: (String? value) => _appUser.email = value!,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: _appUser.address,
        icon: Icons.place_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Address is required";
          return null;
        },
        onSaved: (String? value) => _appUser.address = value!,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Website",
        init: _appUser.website,
        icon: Icons.public_outlined,
        onSaved: (String? value) => _appUser.website = value!,
      ),
    ];
  }

  bool get dirty {
    //final updates = _appUser.diff(appState.currentUser!);
    return false;
  }

  Future<String?> createNewUser(BuildContext context) async {
    String? error;

    try {
      FirebaseService firebase = context.read<FirebaseService>();

      // upload the user
      await firebase.setUser(_appUser);

      // upload the image file
      final destination = 'images/' + _appUser.id + '/user.jpg';
      _appUser.image =
          await firebase.uploadFile(destination, _appUser.filepath);

      // update the user with the image url
      await firebase.updateUser(_appUser, {'image': _appUser.image});

      // save the user into the local disk
      await AppUser.save(_appUser);

      // globally set the current user
      AppState appState = context.read<AppState>();
      appState.currentUser = _appUser;
    } catch (e) {
      error = e.toString();
    }

    return error;
  }

  Future<String?> updateUser(BuildContext context) async {
    String? error;

    try {
      AppState appState = context.read<AppState>();

      final updates = _appUser.diff(appState.currentUser!);
      if (updates == null) {
        return "nothing has changed";
      }

      FirebaseService firebase = context.read<FirebaseService>();

      // update the user with the image url
      await firebase.updateUser(_appUser, updates);

      // save the user into the local disk
      await AppUser.save(_appUser);

      appState.currentUser = _appUser;
    } catch (e) {
      error = e.toString();
    }

    return error;
  }

  Future<void> submit(BuildContext context) async {
    // check the validation of each field
    bool hasValidated = key?.currentState?.validate() ?? false;
    if (!hasValidated) {
      return;
    }

    // save the form fields
    key?.currentState?.save();

    // display loading icon
    loadingDialog(context);

    String? error;

    if (_isNewUser) {
      error = await createNewUser(context);
    } else {
      error = await updateUser(context);
    }

    // pop down the loading icon
    Navigator.of(context).pop();

    if (error != null) {
      // context comes from scaffold
      showSnackBar(context: context, message: error);
    } else {
      // replace the current page with the root page
      AppState appState = context.read<AppState>();
      appState.route?.replace('/');
    }
  }
}
