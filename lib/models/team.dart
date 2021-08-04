import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wecare/models/user.dart';

class Team {
  String? id;
  String? name;
  List<String> caregivers = [];
  List<String> recipients = [];
  List<String> caremanagers = [];
  List<String> practitioners = [];
  DateTime? createdAt;

  Team({
    this.id,
    this.name,
    this.createdAt,
  });

  Team.fromJson(Map<String, Object?> json) {
    id = json['id'] == null ? null : json['id'] as String;
    name = json['name'] == null ? null : json['name'] as String;
    if (json['caregivers'] != null) {
      caregivers = List<String>.from(json['caregivers'] as List);
    }
    if (json['recipients'] != null) {
      recipients = List<String>.from(json['recipients'] as List);
    }
    if (json['caremanagers'] != null) {
      caremanagers = List<String>.from(json['caremanagers'] as List);
    }
    if (json['practitioners'] != null) {
      practitioners = List<String>.from(json['practitioners'] as List);
    }
    createdAt = json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String);
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': DateTime.now().toIso8601String(),
      'caregivers': caregivers,
      'recipients': recipients,
      'caremanagers': caremanagers,
      'practitioners': practitioners,
    };
  }

  Team clone() {
    final team = Team(
      id: this.id,
      name: this.name,
      createdAt: this.createdAt,
    );
    team.caregivers = List<String>.from(this.caregivers);
    team.recipients = this.recipients;
    team.caremanagers = this.caremanagers;
    team.practitioners = this.practitioners;
    return team;
  }

  Map<String, Object?>? diff(Team team) {
    Map<String, Object?> map = Map();
    if (id != team.id) {
      map['id'] = team.id;
    }
    if (name != team.name) {
      map['name'] = team.name;
    }
    if (!IterableEquality().equals(caregivers, team.caregivers)) {
      map['caregivers'] = team.caregivers;
    }
    if (!IterableEquality().equals(recipients, team.recipients)) {
      map['recipients'] = team.recipients;
    }
    if (!IterableEquality().equals(caremanagers, team.caremanagers)) {
      map['caremanagers'] = team.caremanagers;
    }
    if (!IterableEquality().equals(practitioners, team.practitioners)) {
      map['practitioners'] = team.practitioners;
    }
    return map.isNotEmpty ? map : null;
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

  bool isMember(AppUser user) {
    int userRole = user.role ?? 0;
    String id = user.id ?? '';
    if (userRole == UserRole.caregiver) {
      return caregivers.contains(id);
    }
    if (userRole == UserRole.recipient) {
      return recipients.contains(id);
    }
    if (userRole == UserRole.caremanager) {
      return caremanagers.contains(id);
    }
    if (userRole == UserRole.practitioner) {
      return practitioners.contains(id);
    }
    return false;
  }

  bool addMember(AppUser user) {
    if (user.role == null || user.id == null) return false;
    if (isMember(user)) return false;
    int userRole = user.role ?? 0;
    String id = user.id ?? '';
    if (userRole == UserRole.caregiver) {
      caregivers.add(id);
    }
    if (userRole == UserRole.recipient) {
      recipients.add(id);
    }
    if (userRole == UserRole.caremanager) {
      caremanagers.add(id);
    }
    if (userRole == UserRole.practitioner) {
      practitioners.add(id);
    }
    return true;
  }
}
