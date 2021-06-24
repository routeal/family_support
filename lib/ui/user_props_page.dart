import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/src/provider.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/ui/app_state.dart';
import 'package:wecare/widgets/loading.dart';
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
  late AppUser _appUser;

  UserProps(User? user, AppUser? appUser) {
    if (appUser != null) {
      title = appUser.display_name;
      saveButtonLabel = "Save";
      _appUser = appUser;
    } else {
      title = "Your Information";
      saveButtonLabel = "Save";
      logoutButtonLabel = "Logout";
      _appUser = AppUser(
        id: user?.uid,
        phone: user?.phoneNumber,
        display_name: user?.displayName,
        email: user?.email,
      );
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
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
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
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
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
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
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
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
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
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
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
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
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
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Website",
        init: _appUser.website,
        icon: Icons.public_outlined,
        onSaved: (String? value) => _appUser.website = value!,
        // ignore: non_constant_identifier_names
        onChanged: (String) => (dirty = true),
      ),
    ];
  }

  Future<void> submit(context) async {
    // check the validation of each field
    bool hasValidated = key?.currentState?.validate() ?? false;
    if (!hasValidated) {
      return;
    }

    // save the form fields
    key?.currentState?.save();

    // display loading icon
    loadingDialog(context);

    FirebaseService firebase = context.read<FirebaseService>();

    // save the current firebase user id
    _appUser.id = firebase.auth.currentUser!.uid;

    try {
      // upload the user
      await firebase.setUser(_appUser);

      // upload the image file
      final destination = 'images/' + _appUser.id! + '/user.jpg';
      _appUser.image =
          await firebase.uploadFile(destination, _appUser.filepath);

      // update the user with the image url
      await firebase.updateUser(_appUser, {'image': _appUser.image});

      // save the user into the local disk
      await AppUser.save(_appUser);

      // globally set the current user
      AppState appState = context.read<AppState>();
      appState.currentUser = _appUser;

      // pop down the loading icon
      Navigator.of(context).pop();

      // replace the current page with the root page
      appState.route?.replace('/');
    } catch (e) {
      print('Error: user props: ' + e.toString());
    }
  }
}
