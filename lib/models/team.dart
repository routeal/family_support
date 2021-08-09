import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:wecare/models/user.dart';
import 'package:wecare/services/firebase/firebase_service.dart';
import 'package:wecare/views/app_state.dart';

class Team {
  String? id;
  String? name;
  List<Group> groups;
  int? createdAt;

  Team({this.id, this.name, required this.groups, this.createdAt});

  Team.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        name = json['name'] as String?,
        groups = (json['groups'] as List<dynamic>)
            .map((v) => Group.fromJson(v))
            .toList(),
        createdAt = json['createdAt'] as int?;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'groups': groups.map((v) => v.toJson()).toList(),
        'createdAt': createdAt,
      };
}

class Group {
  int? role;
  List<String>? members;

  Group({this.role, this.members});

  Group.fromJson(Map<String, Object?> json) {
    role = json['role'] == null ? null : json['role'] as int;
    if (json['members'] != null) {
      members = List<String>.from(json['members'] as List);
    }
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, Object?>();
    data['role'] = this.role;
    data['members'] = this.members;
    return data;
  }
}

class Members {
  static Future<void> loadUsers(BuildContext context) async {
    AppState appState = context.read<AppState>();
    if (appState.currentTeam?.groups.isEmpty ?? true) {
      return;
    }

    var members = [];
    for (Group group in appState.currentTeam!.groups) {
      members += group.members ?? [];
    }

    for (String s in members) {
      print('member: ' + s);
    }

    FirebaseService firebase = context.read<FirebaseService>();

    appState.currentMembers.clear();

    for (String id in members) {
      if (id == appState.currentUser!.id) {
        appState.currentMembers.add(appState.currentUser!);
      } else {
        User? user = await firebase.getUser(id);
        if (user != null) {
          appState.currentMembers.add(user);
        }
      }
    }
  }

  static Future<bool> addUser(BuildContext context, User user) async {
    AppState appState = context.read<AppState>();

    assert(appState.currentTeam != null);

    final contains = appState.currentMembers.where((u) => u.id == user.id);

    if (contains.isNotEmpty) {
      return false;
    }

    appState.currentMembers.add(user);

    Group? group =
        appState.currentTeam!.groups.firstWhere((g) => g.role == user.role);

    group.members!.add(user.id!);

    FirebaseService firebase = context.read<FirebaseService>();
    await firebase.updateTeam(
        appState.currentTeam!.id!, appState.currentTeam!.toJson());

    return true;
  }

  static Future<bool> removeUser(BuildContext context, User user) async {
    AppState appState = context.read<AppState>();

    assert(appState.currentTeam != null);

    final contains = appState.currentMembers.where((u) => u.id == user.id);

    if (contains.isEmpty) {
      return false;
    }

    appState.currentMembers.removeWhere((u) => u.id == user.id);

    Group? group =
        appState.currentTeam!.groups.firstWhere((g) => g.role == user.role);

    group.members!.remove(user.id);

    FirebaseService firebase = context.read<FirebaseService>();
    await firebase.updateTeam(
        appState.currentTeam!.id!, appState.currentTeam!.toJson());

    return true;
  }

  static List<User> getUsers(BuildContext context, int role) {
    AppState appState = context.read<AppState>();

    final group =
        appState.currentTeam!.groups.singleWhere((g) => g.role == role);

    if (group.members?.isEmpty ?? true) {
      return [];
    }

    final m = group.members!;

    return appState.currentMembers.where((u) => m.contains(u.id)).toList();
  }
}
