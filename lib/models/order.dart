class Order {
  final int id;
  final double totalAmount;
  final bool isPaid;
  final String customerId;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.totalAmount,
    required this.isPaid,
    required this.customerId,
    required this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'] as int,
      totalAmount: map['total_amount'] as double,
      isPaid: (map['is_paid'] as int) == 1,
      customerId: map['customer_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total_amount': totalAmount,
      'is_paid': isPaid ? 1 : 0,
      'customer_id': customerId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
