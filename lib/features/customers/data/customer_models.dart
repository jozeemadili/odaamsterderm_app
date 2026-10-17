class Customer {
  Customer({
    required this.id,
    required this.customerCode,
    required this.name,
    this.phone,
    this.email,
    this.address,
    required this.creditAllowed,
    this.creditLimit,
    this.notes,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as int,
        customerCode: json['customer_code'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        address: json['address'] as String?,
        creditAllowed: json['credit_allowed'] as bool? ?? false,
        creditLimit: json['credit_limit'] != null
            ? (json['credit_limit'] as num).toDouble()
            : null,
        notes: json['notes'] as String?,
      );

  final int id;
  final String customerCode;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final bool creditAllowed;
  final double? creditLimit;
  final String? notes;
}
