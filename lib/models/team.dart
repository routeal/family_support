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
  List<Group>? groups;
  DateTime? createdAt;

  Team({this.id, this.name, this.groups, this.createdAt});

  Team.fromJson(Map<String, Object?> json) {
    id = json['id'] == null ? null : json['id'] as String;
    name = json['name'] == null ? null : json['name'] as String;
    if (json['groups'] != null) {
      groups = [];
      (json['groups'] as List).forEach((v) {
        groups!.add(new Group.fromJson(v));
      });
    }
    createdAt = json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String);
  }

  Map<String, Object?> toJson() {
    final Map<String, Object?> data = Map<String, Object?>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.groups != null) {
      data['groups'] = this.groups!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt ?? DateTime.now().toIso8601String();
    return data;
  }

  Future<void> getMembers(BuildContext  context) async {
    if (groups == null) {
      return;
    }

    FirebaseService firebase = context.read<FirebaseService>();
    AppState appState = context.read<AppState>();

    for (Group g in groups!) {
      if (g.members == null || g.members!.isEmpty) {
        continue;
      }
      g.users.clear();
      for (String id in g.members!) {
        if (id == appState.currentUser!.id) {
          g.users.add(appState.currentUser!);
        } else {
          AppUser? user = await firebase.getUser(id);
          if (user != null) {
            g.users.add(user);
          }
        }
      }
    }
  }

  Future<bool> addMember(BuildContext context, AppUser user) async {
    FirebaseService firebase = context.read<FirebaseService>();

    Group? group = groups?.firstWhere((g) => g.role == user.role);

    if (group == null) {
      if (groups == null) {
        groups = [];
      }

      group = Group(role: user.role, members: [user.id!]);
      group.addUser(user);
      groups!.add(group);

      final update = {
        'groups': [
          {'role': user.role, 'members': [user.id]}
        ]
      };

      await firebase.updateTeam(id, update);

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

    final update =  {
      'groups': [
        {'role': user.role, 'members': group.members}
      ]
    };

    await firebase.updateTeam(id, update);

    return true;
  }

  Future<bool> removeMember(BuildContext context, AppUser user) async {

    Group? group = groups?.firstWhere((g) => g.role == user.role);

    if (group == null || group.members == null) {
      return false;
    }

    if (group.members!.contains(user.id)) {
      group.members!.remove(user.id);
      group.removeUser(user);
    } else {
      return false;
    }

    final update = {
      'groups': [
        {'role': user.role, 'members': group.members}
      ]
    };

    FirebaseService firebase = context.read<FirebaseService>();
    await firebase.updateTeam(id, update);

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
  List<AppUser> users = [];

  Group({this.role, this.members});

  void addUser(AppUser user) {
    users.add(user);
  }

  void removeUser(AppUser user) {
    users.removeWhere((u) => u.id == user.id);
  }

  Group.fromJson(Map<String, Object?> json) {
    role = json['role'] as int;
    members = List<String>.from(json['members'] as List);
  }

  Map<String, dynamic> toJson() {
    final Map<String, Object?> data = Map<String, Object?>();
    data['role'] = this.role;
    data['members'] = this.members;
    return data;
  }
}
