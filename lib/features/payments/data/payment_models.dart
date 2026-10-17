class PaymentRecord {
  PaymentRecord({
    required this.id,
    required this.amount,
    required this.payerName,
    required this.paymentDate,
    required this.status,
    this.notes,
    this.proofOfPaymentUrl,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: json['id'] as int,
        amount: (json['amount'] as num).toDouble(),
        payerName: json['payer_name'] as String,
        paymentDate: json['payment_date'] as String,
        status: json['status'] as String,
        notes: json['notes'] as String?,
        proofOfPaymentUrl: json['proof_of_payment_url'] as String?,
      );

  final int id;
  final double amount;
  final String payerName;
  final String paymentDate;
  final String status;
  final String? notes;
  final String? proofOfPaymentUrl;

  String get statusLabel => switch (status) {
        'verified' => 'Verified',
        'flagged' => 'Flagged',
        _ => 'Recorded',
      };
}
