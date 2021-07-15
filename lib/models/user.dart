import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wecare/utils/commands.dart';

class AppUser {
  String? image_url;
  String? display_name;
  String? first_name;
  String? last_name;
  String? company;
  String? phone;
  String? email;
  String? address;
  String? website;
  String? note;
  String? filepath;
  int? color;
  DateTime? created_at;

  AppUser({
    this.image_url,
    this.display_name,
    this.first_name,
    this.last_name,
    this.company,
    this.phone,
    this.email,
    this.address,
    this.website,
    this.note,
    this.color,
    this.created_at,
    this.filepath,
  });

  AppUser.fromJson(Map<String, Object?> json)
      : this(
          image_url:
              json['image_url'] == null ? null : json['image_url'] as String,
          display_name: json['display_name'] == null
              ? null
              : json['display_name'] as String,
          first_name:
              json['first_name'] == null ? null : json['first_name'] as String,
          last_name:
              json['last_name'] == null ? null : json['last_name'] as String,
          company: json['company'] == null ? null : json['company']! as String,
          phone: json['phone'] == null ? null : json['phone']! as String,
          email: json['email'] == null ? null : json['email'] as String,
          address: json['address'] == null ? null : json['address']! as String,
          website: json['website'] == null ? null : json['website'] as String,
          note: json['note'] == null ? null : json['note'] as String,
          color: json['color'] == null ? null : json['color'] as int,
          created_at: json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
        );

  Map<String, Object?> toJson() {
    return {
      'image_url': image_url,
      'display_name': display_name,
      'first_name': first_name,
      'last_name': last_name,
      'company': company,
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
      'note': note,
      'color': (color ?? getRandomPrimaryColor()),
      'created_at': (created_at != null)
          ? created_at!.toIso8601String()
          : DateTime.now().toIso8601String(),
    };
  }

  AppUser clone() {
    return AppUser(
      image_url: this.image_url,
      display_name: this.display_name,
      first_name: this.first_name,
      last_name: this.last_name,
      company: this.company,
      phone: this.phone,
      email: this.email,
      address: this.address,
      website: this.website,
      note: this.note,
      color: this.color,
      created_at: this.created_at,
      filepath: this.filepath,
    );
  }

  Map<String, Object?>? diff(AppUser user) {
    Map<String, Object?> map = Map();
    if (display_name != user.display_name) {
      map['display_name'] = user.display_name;
    }
    if (first_name != user.first_name) {
      map['first_name'] = user.first_name;
    }
    if (last_name != user.last_name) {
      map['last_name'] = user.last_name;
    }
    if (company != user.company) {
      map['company'] = user.company;
    }
    if (phone != user.phone) {
      map['phone'] = user.phone;
    }
    if (address != user.address) {
      map['address'] = user.address;
    }
    if (website != user.website) {
      map['website'] = user.website;
    }
    if (note != user.note) {
      map['note'] = user.note;
    }
    if (color != user.color) {
      map['color'] = user.color;
    }
    return map.isNotEmpty ? map : null;
  }

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
    if (image_url != null) {
      icon = CircleAvatar(
        backgroundImage: NetworkImage(image_url!),
      );
    } else if (color != null) {
      icon = CircleAvatar(
        child: Text(display_name![0]),
        backgroundColor: Color(color!),
      );
    } else {
      icon = CircleAvatar(
        child: Text(
          display_name![0],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
      );
    }
    return icon;
  }
}
