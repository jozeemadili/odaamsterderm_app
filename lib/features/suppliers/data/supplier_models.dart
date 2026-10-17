class Supplier {
  Supplier({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.address,
    this.notes,
    required this.outstandingBalance,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'] as int,
        name: json['name'] as String,
        contactPerson: json['contact_person'] as String?,
        phone: json['phone'] as String?,
        address: json['address'] as String?,
        notes: json['notes'] as String?,
        outstandingBalance: (json['outstanding_balance'] as num).toDouble(),
      );

  final int id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? address;
  final String? notes;
  final double outstandingBalance;
}
