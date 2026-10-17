class Expense {
  Expense({
    required this.id,
    required this.category,
    required this.amount,
    this.description,
    required this.expenseDate,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as int,
        category: json['category'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String?,
        expenseDate: json['expense_date'] as String,
      );

  final int id;
  final String category;
  final double amount;
  final String? description;
  final String expenseDate;

  /// The categories the merchant portal seeds by default for every merchant.
  /// The API accepts any free-text category, so this is a mobile-side
  /// convenience list, not a hard constraint.
  static const defaultCategories = [
    'Rent',
    'Payroll',
    'Utilities',
    'Transport',
    'Supplier',
    'Other'
  ];
}
