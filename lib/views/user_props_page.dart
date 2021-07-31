import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return PropsWidget(UserProps(context));
  }
}

class UserProps extends PropsValues {
  bool _isNewUser = true;
  bool _imageDirty = false;
  bool _dirty = false;
  late AppUser _user;

  UserProps(BuildContext context) {
    FirebaseService firebase =
        Provider.of<FirebaseService>(context, listen: false);
    AppState appState = Provider.of<AppState>(context, listen: false);

    if (appState.currentUser != null) {
      _isNewUser = false;
      _user = appState.currentUser!.clone();
      // title is the user's display name
      title = _user.display_name;
    } else {
      User? user = firebase.auth.currentUser;
      assert(user != null);
      _user = AppUser();
      _user.email = user!.email;
      title = "Your Information";
      logoutButtonLabel = "Logout";
    }
  }

  bool get dirty => _dirty || _imageDirty;

  List<PropsValueItem> items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: _user.image_url,
        onSaved: (String? value) => _user.filepath = value,
        onChanged: (_) => _imageDirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Display Name",
        init: _user.display_name,
        icon: Icons.person_outline,
        onSaved: (String? value) {
          if (value == null || value.isEmpty) {
            _user.display_name = _user.last_name;
          } else {
            _user.display_name = value;
          }
        },
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "First Name",
        init: _user.first_name,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "First Name is required";
          return null;
        },
        onSaved: (String? value) => _user.first_name = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Last Name",
        init: _user.last_name,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Last Name is required";
          return null;
        },
        onSaved: (String? value) => _user.last_name = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.Color,
        label: "Primary Color",
        init: _user.color,
        icon: Icons.color_lens_outlined,
        onSaved: (String? value) => _user.color = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: _user.company,
        icon: Icons.business_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Company is required";
          return null;
        },
        onSaved: (String? value) => _user.company = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Phone",
        init: _user.phone,
        icon: Icons.phone_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Phone is required";
          return null;
        },
        onSaved: (String? value) => _user.phone = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        enabled: false,
        label: "Email",
        init: _user.email,
        icon: Icons.email_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Email is required";
          return null;
        },
        onSaved: (String? value) => _user.email = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: _user.address,
        icon: Icons.place_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Address is required";
          return null;
        },
        onSaved: (String? value) => _user.address = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Website",
        init: _user.website,
        icon: Icons.public_outlined,
        onSaved: (String? value) => _user.website = value!,
        onChanged: (_) => _dirty = true,
      ),
    ];
  }

  Future<String?> createUser(BuildContext context) async {
    String? error;
    try {
      AppState appState = context.read<AppState>();
      FirebaseService firebase = context.read<FirebaseService>();

      // upload the user
      await firebase.createUser(_user);

      // image
      if (!(_user.filepath?.isEmpty ?? true)) {
        String imagePath = firebase.userImagePath();

        print('create: ' + imagePath);

        // upload the image file
        _user.image_url = await firebase.uploadFile(imagePath, _user.filepath!);

        // update the user with the image url
        await firebase.updateUserImage(_user.image_url);
      }

      // save the user into the local disk
      await AppUser.save(_user);

      // globally set the current user
      appState.currentUser = _user;
    } catch (e) {
      error = e.toString();
      print(error);
    }
    return error;
  }

  Future<String?> updateUser(BuildContext context) async {
    String? error;
    try {
      AppState appState = context.read<AppState>();
      FirebaseService firebase = context.read<FirebaseService>();

      // updates except image
      final Map<String, Object?>? updates = appState.currentUser!.diff(_user);
      if (updates != null) {
        updates.entries.forEach((entry) {
          print('${entry.key}:${entry.value}');
        });
        // update the user with the image url
        await firebase.updateUser(updates);
      }

      // image
      if (_imageDirty) {
        String imagePath = firebase.userImagePath();

        if (_user.filepath?.isEmpty ?? true) {
          print('remove: ' + imagePath);
          _user.image_url = null;
          // delete from storage
          await firebase.deleteFile(imagePath);
          // update the user with the image url
          await firebase.updateUserImage(null);
        } else if (_user.filepath != appState.currentUser!.image_url) {
          print('replace: ' + imagePath);

          // upload the image file
          _user.image_url =
              await firebase.uploadFile(imagePath, _user.filepath!);
          // update the user with the image url
          await firebase.updateUserImage(_user.image_url);
        }
      }

      // save the user into the local disk
      await AppUser.save(_user);

      appState.currentUser = _user;
    } catch (e) {
      print(error);
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
      error = await createUser(context);
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
