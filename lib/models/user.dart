
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wecare/utils/colors.dart';

class UserRole {
  static const int caregiver = 1; // 1. person who gives cares
  static const int recipient = 2; // 2. person who receives cares
  static const int caremanager = 3; // 3. person who organizes/advices cares
  static const int practitioner =
      4; // 4. doctors and nurses who can do medical staff
}

class CareLevel {
  static const int none = 0;
  static const int one = 1;
  static const int two = 2;
  static const int three = 3;
  static const int four = 4;
  static const int five = 5;
}

class User {
  String? id;
  String? imageUrl;
  String? displayName;
  int? role; // caregiver, recipient, caremanager, or doctor
  int? createdAt;
  String? color;

  String? firstName;
  String? lastName;
  String? company;
  String? phone;
  String? email;
  String? address;
  String? website;
  int? careLevel;
  String? teamId; // team id where this user belongs to
  String? note;

  User({
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
  });

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String?,
        imageUrl = json['imageUrl'] as String?,
        displayName = json['displayName'] as String?,
        firstName = json['firstName'] as String?,
        lastName = json['lastName'] as String?,
        company = json['company'] as String?,
        phone = json['phone'] as String?,
        email = json['email'] as String?,
        address = json['address'] as String?,
        website = json['website'] as String?,
        role = json['role'] as int?,
        careLevel = json['careLevel'] as int?,
        teamId = json['teamId'] as String?,
        note = json['note'] as String?,
        color = json['color'] as String?,
        createdAt = json['createdAt'] as int?;

  Map<String, dynamic> toJson() => {
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
        'createdAt': createdAt,
      };

  // exclude imageUrl for comparison
  Map<String, Object?>? difference(User user) {
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

  Widget get avatar {
    late Widget icon;
    if (imageUrl != null) {
      icon = CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(imageUrl!),
      );
    } else if (color != null) {
      icon = CircleAvatar(
        child: Text(displayName?[0] ?? 'M'),
        backgroundColor: HexColor(color!),
      );
    } else {
      icon = CircleAvatar(
        child: Text(
          displayName?[0] ?? 'M',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
      );
    }
    return icon;
  }
}
