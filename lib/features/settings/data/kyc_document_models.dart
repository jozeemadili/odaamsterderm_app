class KycDocument {
  KycDocument({
    required this.id,
    required this.documentType,
    required this.status,
    this.notes,
    this.fileUrl,
  });

  factory KycDocument.fromJson(Map<String, dynamic> json) => KycDocument(
        id: json['id'] as int,
        documentType: json['document_type'] as String,
        status: json['status'] as String,
        notes: json['notes'] as String?,
        fileUrl: json['file_url'] as String?,
      );

  final int id;
  final String documentType;
  final String status;
  final String? notes;
  final String? fileUrl;

  String get statusLabel => switch (status) {
        'approved' => 'Approved',
        'rejected' => 'Rejected',
        _ => 'Pending review',
      };

  /// document_type value -> display label. Matches KycDocumentController's
  /// validation list on the API.
  static const types = {
    'national_id': 'National ID',
    'business_license': 'Business license',
    'tin_certificate': 'TIN certificate',
    'other': 'Other document',
  };
}
