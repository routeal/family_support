import 'package:flutter/material.dart';

class Customer {
  String? id;
  String? image_url;
  String? name;
  String? phone;
  String? email;
  String? address;
  String? filepath;
  int? color;
  DateTime? created_at;

  Customer({
    this.address,
    this.email,
    this.name,
    this.phone,
    this.image_url,
    this.color,
    this.created_at,
  });

  Customer.fromJson(Map<String, Object?> json)
      : this(
          image_url:
              json['image_url'] == null ? null : json['image_url'] as String,
          name: json['name'] == null ? null : json['name'] as String,
          phone: json['phone'] == null ? null : json['phone']! as String,
          email: json['email'] == null ? null : json['email'] as String,
          address: json['address'] == null ? null : json['address']! as String,
          color: json['color'] == null ? null : json['color']! as int,
          created_at: json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
        );

  Map<String, Object?> toJson() {
    return {
      'image_url': image_url,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'color': color,
      'created_at': (created_at != null)
          ? created_at!.toIso8601String()
          : DateTime.now().toIso8601String(),
    };
  }

  Customer clone() {
    Customer _customer = Customer(
      image_url: this.image_url,
      name: this.name,
      phone: this.phone,
      email: this.email,
      address: this.address,
      color: this.color,
      created_at: this.created_at,
    );
    _customer.id = this.id;
    _customer.filepath = this.filepath;
    return _customer;
  }

  Map<String, Object?>? diff(Customer user) {
    Map<String, Object?> map = Map();
    if (name != user.name) {
      map['name'] = user.name;
    }
    if (phone != user.phone) {
      map['phone'] = user.phone;
    }
    if (address != user.address) {
      map['address'] = user.address;
    }
    if (email != user.email) {
      map['email'] = user.email;
    }
    if (color != user.color) {
      map['color'] = user.color;
    }
    return map.isNotEmpty ? map : null;
  }

  Widget get avatar {
    late Widget icon;
    if (image_url != null) {
      icon = CircleAvatar(
        backgroundImage: NetworkImage(image_url!),
      );
    } else if (color != null) {
      icon = CircleAvatar(
        child: Text(name![0]),
        backgroundColor: Color(color!),
      );
    } else {
      icon = CircleAvatar(
        child: Text(
          name![0],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pinkAccent,
      );
    }
    return icon;
  }
}
