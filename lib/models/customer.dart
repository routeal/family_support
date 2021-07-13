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
    image_url: json['image_url'] == null
        ? null
        : json['image_url'] as String,
    name:  json['name'] == null
        ? null
        : json['name'] as String,
    phone: json['phone'] == null
        ? null
        : json['phone']! as String,
    email: json['email'] == null
        ? null
        : json['email'] as String,
    address: json['address'] == null
        ? null
        : json['address']! as String,
    color: json['color'] == null
        ? null
        : json['color']! as int,
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
      'created_at': created_at ?? DateTime.now().toIso8601String(),
    };
  }
}