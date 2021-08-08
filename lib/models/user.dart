import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wecare/utils/colors.dart';

class UserRole {
  static const int caregiver = 1; // 1. person who gives cares
  static const int recipient = 2; // 2. person who receives cares
  static const int caremanager = 3; // 3. person who organizes/advices cares
  static const int practitioner =
      4; // 4. doctors and nurses who can do medical staff
}

class UserRoleString {
  static String? getValue(int role) {
    switch (role) {
      case UserRole.caregiver:
        return 'Caregiver';
      case UserRole.recipient:
        return 'Recipient';
      case UserRole.caremanager:
        return 'Care Manager';
      case UserRole.practitioner:
        return 'Practitioner';
    }
  }
}

class CareLevel {
  static const int none = 0;
  static const int one = 1;
  static const int two = 2;
  static const int three = 3;
  static const int four = 4;
  static const int five = 5;
}

class AppUser {
  String? id;
  String? imageUrl;
  String? displayName;
  String? firstName;
  String? lastName;
  String? company;
  String? phone;
  String? email;
  String? address;
  String? website;
  int? role; // caregiver, recipient, caremanager, or doctor
  int? careLevel;
  String? teamId; // team id where this user belongs to
  String? note;
  String? color;
  DateTime? createdAt;
  // only for internal use
  String? filepath;

  AppUser({
    this.id,
    this.imageUrl,
    this.displayName,
    this.firstName,
    this.lastName,
    this.company,
    this.phone,
    this.email,
    this.address,
    this.website,
    this.role,
    this.careLevel,
    this.teamId,
    this.note,
    this.color,
    this.createdAt,
    this.filepath,
  });

  AppUser.fromJson(Map<String, Object?> json)
      : this(
          id: json['id'] == null ? null : json['id'] as String,
          imageUrl:
              json['imageUrl'] == null ? null : json['imageUrl'] as String,
          displayName: json['displayName'] == null
              ? null
              : json['displayName'] as String,
          firstName:
              json['firstName'] == null ? null : json['firstName'] as String,
          lastName:
              json['lastName'] == null ? null : json['lastName'] as String,
          company: json['company'] == null ? null : json['company']! as String,
          phone: json['phone'] == null ? null : json['phone']! as String,
          email: json['email'] == null ? null : json['email'] as String,
          address: json['address'] == null ? null : json['address']! as String,
          website: json['website'] == null ? null : json['website'] as String,
          role: json['role'] == null ? null : json['role'] as int,
          careLevel:
              json['careLevel'] == null ? null : json['careLevel'] as int,
          teamId: json['teamId'] == null ? null : json['teamId'] as String,
          note: json['note'] == null ? null : json['note'] as String,
          color: json['color'] == null ? null : json['color'] as String,
          createdAt: json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
        );

  // imageUrl will be set after the photo is stored
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'company': company,
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
      'role': role,
      'careLevel': careLevel,
      'teamId': teamId,
      'note': note,
      'color': color,
      'createdAt': ((createdAt == null) ? DateTime.now().toIso8601String() : createdAt!.toIso8601String()),
    };
  }

  AppUser clone() {
    return AppUser(
      id: this.id,
      imageUrl: this.imageUrl,
      displayName: this.displayName,
      firstName: this.firstName,
      lastName: this.lastName,
      company: this.company,
      phone: this.phone,
      email: this.email,
      address: this.address,
      website: this.website,
      role: this.role,
      careLevel: this.careLevel,
      teamId: this.teamId,
      note: this.note,
      color: this.color,
      createdAt: this.createdAt,
      filepath: this.filepath,
    );
  }

  // exclude imageUrl for comparison
  Map<String, Object?>? diff(AppUser user) {
    Map<String, Object?> map = Map();
    if (id != user.id) {
      map['id'] = user.id;
    }
    if (displayName != user.displayName) {
      map['displayName'] = user.displayName;
    }
    if (firstName != user.firstName) {
      map['firstName'] = user.firstName;
    }
    if (lastName != user.lastName) {
      map['lastName'] = user.lastName;
    }
    if (company != user.company) {
      map['company'] = user.company;
    }
    if (phone != user.phone) {
      map['phone'] = user.phone;
    }
    if (email != user.email) {
      map['email'] = user.email;
    }
    if (address != user.address) {
      map['address'] = user.address;
    }
    if (website != user.website) {
      map['website'] = user.website;
    }
    if (role != user.role) {
      map['role'] = user.role;
    }
    if (careLevel != user.careLevel) {
      map['careLevel'] = user.careLevel;
    }
    if (teamId != user.teamId) {
      map['teamId'] = user.teamId;
    }
    if (note != user.note) {
      map['note'] = user.note;
    }
    if (color != user.color) {
      map['color'] = user.color;
    }
    return map.isNotEmpty ? map : null;
  }

  // load from local device
  static Future<AppUser?> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userPref = prefs.getString('user');
    if (userPref != null) {
      Map<String, dynamic> userMap =
          jsonDecode(userPref) as Map<String, dynamic>;
      return AppUser.fromJson(userMap);
    }
    return null;
  }

  // save to local device
  static Future<void> save(AppUser? user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString('user', jsonEncode(user.toJson()));
    } else {
      await prefs.remove('user');
    }
  }

  Widget get avatar {
    late Widget icon;
    if (imageUrl != null) {
      icon = CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(imageUrl!),
      );
    } else if (color != null) {
      icon = CircleAvatar(
        child: Text(displayName?[0] ?? ''),
        backgroundColor: HexColor(color!),
      );
    } else {
      icon = CircleAvatar(
        child: Text(
          displayName?[0] ?? 'A',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
      );
    }
    return icon;
  }
}
