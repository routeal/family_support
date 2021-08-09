import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  Future<void> getUsers(BuildContext context) async {
    if (groups == null) {
      return;
    }

    FirebaseService firebase = context.read<FirebaseService>();
    AppState appState = context.read<AppState>();

    for (Group g in groups) {
      if (g.members == null || g.members!.isEmpty) {
        continue;
      }
      g.users.clear();
      for (String id in g.members!) {
        //print(g.role.toString() + ':' + id);
        if (id == appState.currentUser!.id) {
          g.users.add(appState.currentUser!);
        } else {
          User? user = await firebase.getUser(id);
          if (user != null) {
            //print(g.role.toString() + ':' + id + ' added');
            g.users.add(user);
          }
        }
      }
    }
  }

  Future<bool> addUser(BuildContext context, User user) async {
    FirebaseService firebase = context.read<FirebaseService>();

    Group? group = groups.firstWhere((g) => g.role == user.role);

    if (group == null) {
      if (groups == null) {
        groups = [];
      }

      group = Group(role: user.role, members: [user.id!]);
      group.addUser(user);
      groups.add(group);

      final update = toJson();

      await firebase.updateTeam(id!, update);

      return true;
    }

    if (group.members == null) {
      group.members = [];
      group.members!.add(user.id!);
      group.addUser(user);
    } else {
      if (!group.members!.contains(user.id!)) {
        group.members!.add(user.id!);
        group.addUser(user);
      } else {
        return false;
      }
    }

    final update = toJson();

    await firebase.updateTeam(id!, update);

    return true;
  }

  Future<bool> removeUser(BuildContext context, User user) async {
    Group? group = groups.firstWhere((g) => g.role == user.role);

    if (group == null || group.members == null) {
      return false;
    }

    if (group.members!.contains(user.id)) {
      group.members!.remove(user.id);
      group.removeUser(user);
    } else {
      return false;
    }

    final update = toJson();

    FirebaseService firebase = context.read<FirebaseService>();
    await firebase.updateTeam(id!, update);

    return true;
  }

  static Future<Team?> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? teamPref = prefs.getString('team');
    if (teamPref != null) {
      Map<String, dynamic> userMap =
          jsonDecode(teamPref) as Map<String, dynamic>;
      return Team.fromJson(userMap);
    }
    return null;
  }

  // save to local device
  static Future<void> save(Team? team) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (team != null) {
      await prefs.setString('team', jsonEncode(team.toJson()));
    } else {
      await prefs.remove('team');
    }
  }
}

class Group {
  int? role;
  List<String>? members;
  List<User> users = [];

  Group({this.role, this.members});

  void addUser(User user) {
    users.add(user);
  }

  void removeUser(User user) {
    users.removeWhere((u) => u.id == user.id);
  }

  Group.fromJson(Map<String, Object?> json) {
    role = json['role'] == null ? null : json['role'] as int;
    if (json['members'] != null) {
      members = List<String>.from(json['members'] as List);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, Object?> data = Map<String, Object?>();
    data['role'] = this.role;
    data['members'] = this.members;
    return data;
  }
}

class Members {
  static void getMembers(BuildContext context) async {
    AppState appState = context.read<AppState>();
    if (appState.currentTeam?.groups?.isEmpty ?? true) {
      return;
    }

    var members = [];
    for (Group group in appState.currentTeam!.groups) {
      members = [...group.members ?? []];
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

  static void addUser(BuildContext context, User user) async {
    AppState appState = context.read<AppState>();

    assert(appState.currentTeam != null);

    final contains = appState.currentMembers.where((u) => u.id == user.id);

    if (contains.isNotEmpty) {
      return;
    }

    appState.currentMembers.add(user);

    Group? group =
        appState.currentTeam!.groups.firstWhere((g) => g.role == user.role);

    group.members!.add(user.id!);

    FirebaseService firebase = context.read<FirebaseService>();
    await firebase.updateTeam(
        appState.currentTeam!.id!, appState.currentTeam!.toJson());
  }

  static void removeUser(BuildContext context, User user) async {
    AppState appState = context.read<AppState>();

    assert(appState.currentTeam != null);

    final contains = appState.currentMembers.where((u) => u.id == user.id);

    if (contains.isEmpty) {
      return;
    }

    appState.currentMembers.removeWhere((u) => u.id == user.id);

    Group? group =
        appState.currentTeam!.groups.firstWhere((g) => g.role == user.role);

    group.members!.remove(user.id);

    FirebaseService firebase = context.read<FirebaseService>();
    await firebase.updateTeam(
        appState.currentTeam!.id!, appState.currentTeam!.toJson());
  }
}
