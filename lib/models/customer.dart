class Customer {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    required this.createdAt,
  });

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
