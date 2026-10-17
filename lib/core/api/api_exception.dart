/// A DukaFlow API error, normalized from Laravel's validation/error JSON
/// shape: `{"message": "...", "errors": {"field": ["msg", ...]}}`.
class ApiException implements Exception {
  ApiException({required this.message, this.errors, this.statusCode});

  final String message;
  final Map<String, List<String>>? errors;
  final int? statusCode;

  /// The first validation message for [field], if any.
  String? fieldError(String field) => errors?[field]?.firstOrNull;

  @override
  String toString() => message;
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
