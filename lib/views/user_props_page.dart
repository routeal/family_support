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
    return PropsWidget(UserProps(context));
  }
}

class UserProps extends PropsValues {
  bool _imageDirty = false;
  bool _dirty = false;
  bool _isNewUser = true;
  late AppUser _updateUser;

  UserProps(BuildContext context) {
    FirebaseService firebase =
        Provider.of<FirebaseService>(context, listen: false);
    AppState appState = Provider.of<AppState>(context, listen: false);

    if (appState.currentUser != null) {
      _isNewUser = false;
      _updateUser = appState.currentUser!.clone();
      // title is the user's display name
      title = _updateUser.display_name;
    } else {
      User? user = firebase.auth.currentUser;
      assert(user != null);
      _updateUser = AppUser();
      _updateUser.email = user!.email;
      title = "Your Information";
      logoutButtonLabel = "Logout";
    }
  }

  bool get dirty => _dirty || _imageDirty;

  List<PropsValueItem> items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: _updateUser.image_url,
        onSaved: (String? value) {
          if (value != null || value!.isNotEmpty) {
            _updateUser.filepath = value;
          }
        },
        validator: (_) {
          // not necessarily set
          return null;
        },
        onChanged: (_) => _imageDirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Display Name",
        init: _updateUser.display_name,
        icon: Icons.person_outline,
        onSaved: (String? value) {
          if (value == null || value.isEmpty) {
            _updateUser.display_name = _updateUser.last_name;
          } else {
            _updateUser.display_name = value;
          }
        },
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "First Name",
        init: _updateUser.first_name,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "First Name is required";
          return null;
        },
        onSaved: (String? value) => _updateUser.first_name = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Last Name",
        init: _updateUser.last_name,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Last Name is required";
          return null;
        },
        onSaved: (String? value) => _updateUser.last_name = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: _updateUser.company,
        icon: Icons.business_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Company is required";
          return null;
        },
        onSaved: (String? value) => _updateUser.company = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Phone",
        init: _updateUser.phone,
        icon: Icons.phone_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Phone is required";
          return null;
        },
        onSaved: (String? value) => _updateUser.phone = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        enabled: false,
        label: "Email",
        init: _updateUser.email,
        icon: Icons.email_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Email is required";
          return null;
        },
        onSaved: (String? value) => _updateUser.email = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: _updateUser.address,
        icon: Icons.place_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Address is required";
          return null;
        },
        onSaved: (String? value) => _updateUser.address = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Website",
        init: _updateUser.website,
        icon: Icons.public_outlined,
        onSaved: (String? value) => _updateUser.website = value!,
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
      await firebase.setUser(_updateUser);

      if (_updateUser.filepath != null && _updateUser.filepath!.isNotEmpty) {
        String imagePath =
            'images/' + firebase.auth.currentUser!.uid + '/user.jpg';

        // upload the image file
        _updateUser.image_url =
            await firebase.uploadFile(imagePath, _updateUser.filepath!);

        // update the user with the image url
        await firebase.updateUser({'image_url': _updateUser.image_url});
      }

      // save the user into the local disk
      await AppUser.save(_updateUser);

      // globally set the current user
      appState.currentUser = _updateUser;
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

      final updates = _updateUser.diff(appState.currentUser!);
      if (updates != null) {
        // update the user with the image url
        await firebase.updateUser(updates);
      }

      if (_imageDirty &&
          _updateUser.filepath != null &&
          _updateUser.filepath!.isNotEmpty) {
        String imagePath =
            'images/' + firebase.auth.currentUser!.uid + '/user.jpg';

        // upload the image file
        _updateUser.image_url =
            await firebase.uploadFile(imagePath, _updateUser.filepath!);

        // update the user with the image url
        await firebase.updateUser({'image_url': _updateUser.image_url});
      }

      // save the user into the local disk
      await AppUser.save(_updateUser);
      appState.currentUser = _updateUser;
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
