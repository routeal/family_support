class Customer {
  String id = "";
  String filepath = "";

  String? image;
  String? name;
  String? phone;
  String? email;
  String? address;
  String? website;
  String? representative;
  DateTime? created_at;

  Customer({
    this.address,
    this.email,
    this.name,
    this.phone,
    this.representative,
    this.website,
    this.image,
    this.created_at,
  });

  Customer.fromJson(Map<String, Object?> json)
  : this(
    image: json['image'] == null
        ? null
        : json['image'] as String,
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
    website: json['url'] == null
        ? null
        : json['url'] as String,
    representative: json['rep'] == null
        ? null
        : json['rep']! as String,
    created_at: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
  );

  Map<String, Object?> toJson() {
    return {
      'image': image,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'url': website,
      'rep': representative,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}