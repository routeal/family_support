import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecare/models/team.dart';
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
  late AppUser _user;
  late Team _team;

  UserProps(BuildContext context) {
    FirebaseService firebase =
        Provider.of<FirebaseService>(context, listen: false);
    AppState appState = Provider.of<AppState>(context, listen: false);

    assert(appState.currentUser != null);
    assert(appState.currentTeam != null);

    _user = appState.currentUser!.clone();
    _team = appState.currentTeam!;

    if (appState.currentUser!.role != null) {
      // title is the user's display name
      title = _user.displayName;
    } else {
      title = "Your Profile";
      logoutButtonLabel = "Logout";
    }
  }

  bool get dirty => _dirty || _imageDirty;

  List<PropsValueItem> items() {
    /*
    if (_user.role != null) {
      if (_user.role == UserRole.caregiver) {
        return caregiver_items();
      } else if (_user.role == UserRole.recipient) {
        return recipient_items();
      } else if (_user.role == UserRole.caremanager) {
        return caremanager_items();
      } else if (_user.role == UserRole.practitioner) {
        return practitioner_items();
      }
    }
    */
    return all_items();
  }

  List<PropsValueItem> caregiver_items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: _user.imageUrl,
        onSaved: (String? value) => _user.filepath = value,
        onChanged: (_) => _imageDirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Display Name",
        init: _user.displayName,
        icon: Icons.person_outline,
        onSaved: (String? value) {
          if (value == null || value.isEmpty) {
            _user.displayName = _user.lastName;
          } else {
            _user.displayName = value;
          }
        },
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "First Name",
        init: _user.firstName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "First Name is required";
          return null;
        },
        onSaved: (String? value) => _user.firstName = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Last Name",
        init: _user.lastName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Last Name is required";
          return null;
        },
        onSaved: (String? value) => _user.lastName = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.Color,
        label: "Your Color",
        init: _user.color,
        icon: Icons.color_lens_outlined,
        onSaved: (String? value) => _user.color = value!,
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
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: _user.company,
        icon: Icons.business_outlined,
        onSaved: (String? value) => _user.company = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: _user.address,
        icon: Icons.place_outlined,
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

  List<PropsValueItem> recipient_items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: _user.imageUrl,
        onSaved: (String? value) => _user.filepath = value,
        onChanged: (_) => _imageDirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Display Name",
        init: _user.displayName,
        icon: Icons.person_outline,
        onSaved: (String? value) {
          if (value == null || value.isEmpty) {
            _user.displayName = _user.lastName;
          } else {
            _user.displayName = value;
          }
        },
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "First Name",
        init: _user.firstName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "First Name is required";
          return null;
        },
        onSaved: (String? value) => _user.firstName = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Last Name",
        init: _user.lastName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Last Name is required";
          return null;
        },
        onSaved: (String? value) => _user.lastName = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        enabled: false,
        label: "Your Care Team",
        init: _team.name,
        icon: Icons.group_work_rounded,
      ),
      PropsValueItem(
        type: PropsType.Role,
        label: "Your Role",
        init: _user.role?.toString(),
        icon: Icons.badge_outlined,
        onSaved: (String? value) => _user.role = int.parse(value!),
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.CareLevel,
        label: "Your Care Level (only for recipients)",
        init: _user.careLevel?.toString(),
        icon: Icons.badge_outlined,
        onSaved: (String? value) => _user.careLevel = int.parse(value!),
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.Color,
        label: "Your Color",
        init: _user.color,
        icon: Icons.color_lens_outlined,
        onSaved: (String? value) => _user.color = value!,
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
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: _user.company,
        icon: Icons.business_outlined,
        onSaved: (String? value) => _user.company = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: _user.address,
        icon: Icons.place_outlined,
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

  List<PropsValueItem> caremanager_items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: _user.imageUrl,
        onSaved: (String? value) => _user.filepath = value,
        onChanged: (_) => _imageDirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Display Name",
        init: _user.displayName,
        icon: Icons.person_outline,
        onSaved: (String? value) {
          if (value == null || value.isEmpty) {
            _user.displayName = _user.lastName;
          } else {
            _user.displayName = value;
          }
        },
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "First Name",
        init: _user.firstName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "First Name is required";
          return null;
        },
        onSaved: (String? value) => _user.firstName = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Last Name",
        init: _user.lastName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Last Name is required";
          return null;
        },
        onSaved: (String? value) => _user.lastName = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        enabled: false,
        label: "Your Care Team",
        init: _team.name,
        icon: Icons.group_work_rounded,
      ),
      PropsValueItem(
        type: PropsType.Role,
        label: "Your Role",
        init: _user.role?.toString(),
        icon: Icons.badge_outlined,
        onSaved: (String? value) => _user.role = int.parse(value!),
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.CareLevel,
        label: "Your Care Level (only for recipients)",
        init: _user.careLevel?.toString(),
        icon: Icons.badge_outlined,
        onSaved: (String? value) => _user.careLevel = int.parse(value!),
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.Color,
        label: "Your Color",
        init: _user.color,
        icon: Icons.color_lens_outlined,
        onSaved: (String? value) => _user.color = value!,
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
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: _user.company,
        icon: Icons.business_outlined,
        onSaved: (String? value) => _user.company = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: _user.address,
        icon: Icons.place_outlined,
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

  List<PropsValueItem> practitioner_items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: _user.imageUrl,
        onSaved: (String? value) => _user.filepath = value,
        onChanged: (_) => _imageDirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Display Name",
        init: _user.displayName,
        icon: Icons.person_outline,
        onSaved: (String? value) {
          if (value == null || value.isEmpty) {
            _user.displayName = _user.lastName;
          } else {
            _user.displayName = value;
          }
        },
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "First Name",
        init: _user.firstName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "First Name is required";
          return null;
        },
        onSaved: (String? value) => _user.firstName = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Last Name",
        init: _user.lastName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Last Name is required";
          return null;
        },
        onSaved: (String? value) => _user.lastName = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        enabled: false,
        label: "Your Care Team",
        init: _team.name,
        icon: Icons.group_work_rounded,
      ),
      PropsValueItem(
        type: PropsType.Role,
        label: "Your Role",
        init: _user.role?.toString(),
        icon: Icons.badge_outlined,
        onSaved: (String? value) => _user.role = int.parse(value!),
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.CareLevel,
        label: "Your Care Level (only for recipients)",
        init: _user.careLevel?.toString(),
        icon: Icons.badge_outlined,
        onSaved: (String? value) => _user.careLevel = int.parse(value!),
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.Color,
        label: "Your Color",
        init: _user.color,
        icon: Icons.color_lens_outlined,
        onSaved: (String? value) => _user.color = value!,
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
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: _user.company,
        icon: Icons.business_outlined,
        onSaved: (String? value) => _user.company = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: _user.address,
        icon: Icons.place_outlined,
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

  List<PropsValueItem> all_items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: _user.imageUrl,
        onSaved: (String? value) => _user.filepath = value,
        onChanged: (_) => _imageDirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Display Name",
        init: _user.displayName,
        icon: Icons.person_outline,
        onSaved: (String? value) {
          if (value == null || value.isEmpty) {
            _user.displayName = _user.lastName;
          } else {
            _user.displayName = value;
          }
        },
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "First Name",
        init: _user.firstName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "First Name is required";
          return null;
        },
        onSaved: (String? value) => _user.firstName = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Last Name",
        init: _user.lastName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Last Name is required";
          return null;
        },
        onSaved: (String? value) => _user.lastName = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        enabled: false,
        label: "Your Care Team",
        init: _team.name,
        icon: Icons.group_work_rounded,
      ),
      PropsValueItem(
        type: PropsType.Role,
        label: "Your Role",
        init: _user.role?.toString(),
        icon: Icons.badge_outlined,
        onSaved: (String? value) => _user.role = int.parse(value!),
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.CareLevel,
        label: "Your Care Level (only for recipients)",
        init: _user.careLevel?.toString(),
        icon: Icons.badge_outlined,
        onSaved: (String? value) => _user.careLevel = int.parse(value!),
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.Color,
        label: "Your Color",
        init: _user.color,
        icon: Icons.color_lens_outlined,
        onSaved: (String? value) => _user.color = value!,
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
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: _user.company,
        icon: Icons.business_outlined,
        onSaved: (String? value) => _user.company = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: _user.address,
        icon: Icons.place_outlined,
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

      _user.id = firebase.auth.currentUser!.uid;

      // upload the user
      await firebase.createUser(_user);

      // image
      if (!(_user.filepath?.isEmpty ?? true)) {
        String imagePath = firebase.userImagePath();

        print('create: ' + imagePath);

        // upload the image file
        _user.imageUrl = await firebase.uploadFile(imagePath, _user.filepath!);

        // update the user with the image url
        await firebase.updateUserImage(_user.imageUrl);
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

      // update the team
      if (!_team.isMember(_user)) {
        final orig = _team.clone();
        if (_team.addMember(_user)) {
          final Map<String, Object?>? updates = orig.diff(_team);
          if (updates != null) {
            await firebase.updateTeam(_team.id, updates);
          }
        }
      }

      // image
      if (_imageDirty) {
        String imagePath = firebase.userImagePath();

        if (_user.filepath?.isEmpty ?? true) {
          print('remove: ' + imagePath);
          _user.imageUrl = null;
          // delete from storage
          await firebase.deleteFile(imagePath);
          // update the user with the image url
          await firebase.updateUserImage(null);
        } else if (_user.filepath != appState.currentUser!.imageUrl) {
          print('replace: ' + imagePath);

          // upload the image file
          _user.imageUrl =
              await firebase.uploadFile(imagePath, _user.filepath!);
          // update the user with the image url
          await firebase.updateUserImage(_user.imageUrl);
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

    error = await updateUser(context);

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
