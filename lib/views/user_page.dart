import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wecare/models/team.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';
import 'package:wecare/widgets/dialogs.dart';
import 'package:wecare/widgets/props/props_values.dart';
import 'package:wecare/widgets/props/props_widget.dart';

class AddUserPage extends StatelessWidget {
  final String? title;
  final String? logout;
  final int role;
  AddUserPage({Key? key, this.title, this.logout, required this.role})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PropsWidget(
        UserProps(context: context, role: role, title: title, logout: logout));
  }
}

class UpdateUserPage extends StatelessWidget {
  final AppUser user;
  UpdateUserPage({Key? key, required this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PropsWidget(UserProps(
        context: context, user: user, title: user.displayName ?? 'Profile'));
  }
}

class UserPropsPage extends StatelessWidget {
  const UserPropsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    AppState appState = Provider.of<AppState>(context, listen: false);
    return PropsWidget(UserProps(
      context: context,
      user: appState.currentUser!,
      // role won't be available on initial signup
      role: appState.currentUser?.role,
      title: appState.currentUser?.displayName ?? 'Your Profile',
      // on signup, there is no displayName, also from the qr code as well
      logout: ((appState.currentUser?.displayName == null) ? 'Logout' : null),
    ));
  }
}

class UserProps extends PropsValues {
  final BuildContext context;
  final AppUser? user;
  final int? role;

  late AppUser newUser;
  late Team _team;

  bool _imageDirty = false;
  bool _dirty = false;

  UserProps({
    String? title,
    String? logout,
    required this.context,
    this.user,
    this.role,
  }) : super(title: title, logoutButtonLabel: logout) {
    AppState appState = Provider.of<AppState>(context, listen: false);

    assert(appState.currentUser != null);
    assert(appState.currentTeam != null);

    if (user == null) {
      newUser = AppUser();
      newUser.role = role;
    } else {
      newUser = user!.clone();
    }

    _team = appState.currentTeam!;
  }

  bool get dirty => _dirty || _imageDirty;

  List<PropsValueItem> items() {
    return [
      PropsValueItem(
        type: PropsType.Photo,
        init: newUser.imageUrl,
        onSaved: (String? value) => newUser.filepath = value,
        onChanged: (_) => _imageDirty = true,
      ),
      ((logoutButtonLabel != null)
          ? PropsValueItem(
              type: PropsType.InputField,
              enabled: false,
              label: "Your Care Team",
              init: _team.name,
              icon: Icons.group_work_rounded,
            )
          : PropsValueItem(type: PropsType.None)),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Display Name",
        init: newUser.displayName,
        icon: Icons.person_outline,
        onSaved: (String? value) {
          if (value == null || value.isEmpty) {
            newUser.displayName = newUser.lastName;
          } else {
            newUser.displayName = value;
          }
        },
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "First Name",
        init: newUser.firstName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "First Name is required";
          return null;
        },
        onSaved: (String? value) => newUser.firstName = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Last Name",
        init: newUser.lastName,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Last Name is required";
          return null;
        },
        onSaved: (String? value) => newUser.lastName = value!,
        onChanged: (_) => _dirty = true,
      ),
      ((newUser.role == null)
          ? PropsValueItem(
              type: PropsType.Role,
              label: "Your Role",
              init: newUser.role?.toString(),
              icon: Icons.badge_outlined,
              onSaved: (String? value) => newUser.role = int.parse(value!),
              onChanged: (_) => _dirty = true,
            )
          : PropsValueItem(type: PropsType.None)),
      ((newUser.role == null || newUser.role == UserRole.recipient)
          ? PropsValueItem(
              type: PropsType.CareLevel,
              label: "Your Care Level",
              init: newUser.careLevel?.toString(),
              icon: Icons.badge_outlined,
              onSaved: (String? value) => newUser.careLevel = int.parse(value!),
              onChanged: (_) => _dirty = true,
            )
          : PropsValueItem(type: PropsType.None)),
      PropsValueItem(
        type: PropsType.Color,
        label: "Your Color",
        init: newUser.color,
        icon: Icons.color_lens_outlined,
        onSaved: (String? value) => newUser.color = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Phone",
        init: newUser.phone,
        icon: Icons.phone_outlined,
        validator: (String? value) {
          if (value == null || value.isEmpty) return "Phone is required";
          return null;
        },
        onSaved: (String? value) => newUser.phone = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        enabled: false,
        label: "Email",
        init: newUser.email,
        icon: Icons.email_outlined,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Company",
        init: newUser.company,
        icon: Icons.business_outlined,
        onSaved: (String? value) => newUser.company = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Address",
        init: newUser.address,
        icon: Icons.place_outlined,
        onSaved: (String? value) => newUser.address = value!,
        onChanged: (_) => _dirty = true,
      ),
      PropsValueItem(
        type: PropsType.InputField,
        label: "Website",
        init: newUser.website,
        icon: Icons.public_outlined,
        onSaved: (String? value) => newUser.website = value!,
        onChanged: (_) => _dirty = true,
      ),
    ];
  }

  Future<String?> upload(BuildContext context) async {
    String? error;
    try {
      AppState appState = context.read<AppState>();
      FirebaseService firebase = context.read<FirebaseService>();

      // upload the user
      if (user == null) {
        await firebase.createUser(newUser);
      } else {
        final Map<String, Object?>? updates = user!.diff(newUser);
        if (updates != null) {
          await firebase.updateUser(user!.id!, updates);
        }
      }

      // image
      if (_imageDirty) {
        print('imageDirty');
        String imagePath = firebase.userProfileImagePath(newUser.id!);
        if (newUser.filepath?.isEmpty ?? true) {
          // remove
          newUser.imageUrl = null;
          // delete from storage
          await firebase.deleteFile(imagePath);
          // update the user with the image url
          await firebase.updateUserImage(newUser.id!, null);
        } else {
          // upload the image file
          newUser.imageUrl =
              await firebase.uploadFile(imagePath, newUser.filepath!);
          // update the user with the image url
          await firebase.updateUserImage(newUser.id!, newUser.imageUrl);
        }
      }

      // update the team, _team is appState.currentTeam
      if (!_team.isMember(newUser)) {
        final orig = _team.clone();
        if (_team.addMember(newUser)) {
          final Map<String, Object?>? updates = orig.diff(_team);
          if (updates != null) {
            /*
            updates.entries.forEach((entry) {
              print('${entry.key}:${entry.value}');
            });
            */
            await firebase.updateTeam(_team.id, updates);

            // save to the local
            await Team.save(_team);

            // add the newUser to appState
            if (newUser.role == UserRole.caregiver) {
              appState.caregivers.add(newUser);
            } else if (newUser.role == UserRole.recipient) {
              appState.recipients.add(newUser);
            } else if (newUser.role == UserRole.caremanager) {
              appState.caremanagers.add(newUser);
            } else if (newUser.role == UserRole.practitioner) {
              appState.practitioners.add(newUser);
            }
          }
        }
      }

      // update if this is the current user
      if (user == appState.currentUser) {
        print('save newUser: ' + newUser.toJson().toString());
        // save the user into the local disk
        await AppUser.save(newUser);
        // set the current user
        appState.currentUser = newUser;
      }
    } catch (e) {
      error = e.toString();
      print(error);
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

    String? error = await upload(context);

    // pop down the loading icon
    Navigator.of(context).pop();

    if (error != null) {
      // context comes from scaffold
      showSnackBar(context: context, message: error);
    } else {
      // replace the current page with the root page
      AppState appState = context.read<AppState>();
      appState.route?.push('/');
    }
  }
}