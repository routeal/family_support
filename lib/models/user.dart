import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  String? id;
  String filepath = "";

  String? image;
  String? display_name;
  String? first_name;
  String? last_name;
  String? company;
  String? phone;
  String? email;
  String? address;
  String? website;
  String? note;
  DateTime? created_at;

  AppUser({
    this.id,
    this.image,
    this.display_name,
    this.first_name,
    this.last_name,
    this.company,
    this.phone,
    this.email,
    this.address,
    this.website,
    this.note,
    this.created_at,
  });

  AppUser.fromJson(Map<String, Object?> json)
      : this(
          id: json['id'] == null ? null : json['id'] as String,
          image: json['image'] == null ? null : json['image'] as String,
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
          created_at: json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
        );

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'image': image,
      'display_name': display_name,
      'first_name': first_name,
      'last_name': last_name,
      'company': phone,
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    };
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
}
