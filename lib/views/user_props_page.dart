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
  bool _imageDirty = false;
  bool _dirty = false;
  bool _isNewUser = true;
  late AppUser _newUser;

  UserProps(User? firebaseUser, AppUser? appUser) {
    assert(firebaseUser != null);

    if (appUser != null) {
      _isNewUser = false;
      _newUser = appUser.clone();
      // title is the user's display name
      title = _newUser.display_name;
    } else {
      _newUser = AppUser(id: firebaseUser!.uid);
      _newUser.email = firebaseUser.email;
      title = "Your Information";
      logoutButtonLabel = "Logout";
    }
  }

  List<PropsValueItem> items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: _newUser.image,
        onSaved: (String? value) {
          if (value != null || value!.isNotEmpty) {
            _newUser.filepath = value;
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
        onChanged: (_) => _imageDirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Display Name",
        init: _newUser.display_name,
        icon: Icons.person_outline,
        onSaved: (String? value) {
          if (value == null || value.isEmpty) {
            _newUser.display_name = _newUser.last_name;
          } else {
            _newUser.display_name = value;
          }
        },
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "First Name",
        init: _newUser.first_name,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "First Name is required";
          return null;
        },
        onSaved: (String? value) => _newUser.first_name = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Last Name",
        init: _newUser.last_name,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Last Name is required";
          return null;
        },
        onSaved: (String? value) => _newUser.last_name = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: _newUser.company,
        icon: Icons.business_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Company is required";
          return null;
        },
        onSaved: (String? value) => _newUser.company = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Phone",
        init: _newUser.phone,
        icon: Icons.phone_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Phone is required";
          return null;
        },
        onSaved: (String? value) => _newUser.phone = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        enabled: false,
        label: "Email",
        init: _newUser.email,
        icon: Icons.email_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Email is required";
          return null;
        },
        onSaved: (String? value) => _newUser.email = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: _newUser.address,
        icon: Icons.place_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Address is required";
          return null;
        },
        onSaved: (String? value) => _newUser.address = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Website",
        init: _newUser.website,
        icon: Icons.public_outlined,
        onSaved: (String? value) => _newUser.website = value!,
        onChanged: (_) => _dirty = true,
      ),
    ];
  }

  bool get dirty => _dirty || _imageDirty;

  Future<String?> createNewUser(BuildContext context) async {
    String? error;

    try {
      FirebaseService firebase = context.read<FirebaseService>();

      // upload the user
      await firebase.setUser(_newUser);

      // upload the image file
      final destination = 'images/' + _newUser.id + '/user.jpg';
      _newUser.image =
          await firebase.uploadFile(destination, _newUser.filepath);

      // update the user with the image url
      await firebase.updateUser({'image': _newUser.image});

      // save the user into the local disk
      await AppUser.save(_newUser);

      // globally set the current user
      AppState appState = context.read<AppState>();
      appState.currentUser = _newUser;
    } catch (e) {
      error = e.toString();
    }

    return error;
  }

  Future<String?> updateUser(BuildContext context) async {
    String? error;

    try {
      AppState appState = context.read<AppState>();
      FirebaseService firebase = context.read<FirebaseService>();

      final updates = _newUser.diff(appState.currentUser!);
      if (updates != null) {
        // update the user with the image url
        await firebase.updateUser(updates);
      }

      if (_imageDirty) {
        // upload the image file
        _newUser.image =
            await firebase.uploadFile(firebase.userImage, _newUser.filepath);
        // update the user with the image url
        await firebase.updateUser({'image': _newUser.image});
      }

      // save the user into the local disk
      await AppUser.save(_newUser);

      appState.currentUser = _newUser;
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
