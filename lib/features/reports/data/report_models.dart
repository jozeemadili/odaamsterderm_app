class SalesReportRow {
  SalesReportRow({
    required this.inventoryItemId,
    required this.productName,
    required this.quantitySold,
    required this.totalSalesAmount,
    this.totalBuyingValue,
    this.totalProfit,
    this.soldBy,
    this.store,
  });

  factory SalesReportRow.fromJson(Map<String, dynamic> json) =>
      SalesReportRow(
        inventoryItemId: json['inventory_item_id'] as int,
        productName: json['product_name'] as String,
        quantitySold: (json['quantity_sold'] as num).toDouble(),
        totalSalesAmount: (json['total_sales_amount'] as num).toDouble(),
        totalBuyingValue: json['total_buying_value'] != null
            ? (json['total_buying_value'] as num).toDouble()
            : null,
        totalProfit: json['total_profit'] != null
            ? (json['total_profit'] as num).toDouble()
            : null,
        soldBy: json['sold_by'] as String?,
        store: json['store'] as String?,
      );

  final int inventoryItemId;
  final String productName;
  final double quantitySold;
  final double totalSalesAmount;
  final double? totalBuyingValue;
  final double? totalProfit;
  final String? soldBy;
  final String? store;
}

/// Aggregate totals across every row in the report. `totalBuyingValue` and
/// `totalProfit` only sum the sales that captured a cost at checkout time —
/// [profitPartial] is true when at least one sale in the report predates
/// that and was left out, so the UI can flag the totals as partial.
class TodaySalesSummary {
  TodaySalesSummary({
    required this.totalQuantitySold,
    required this.totalSalesAmount,
    required this.totalBuyingValue,
    required this.totalProfit,
    required this.profitPartial,
  });

  factory TodaySalesSummary.fromJson(Map<String, dynamic> json) =>
      TodaySalesSummary(
        totalQuantitySold: (json['total_quantity_sold'] as num).toDouble(),
        totalSalesAmount: (json['total_sales_amount'] as num).toDouble(),
        totalBuyingValue: (json['total_buying_value'] as num).toDouble(),
        totalProfit: (json['total_profit'] as num).toDouble(),
        profitPartial: json['profit_partial'] as bool,
      );

  final double totalQuantitySold;
  final double totalSalesAmount;
  final double totalBuyingValue;
  final double totalProfit;
  final bool profitPartial;
}

class TodaySalesReport {
  TodaySalesReport({required this.date, required this.summary, required this.rows});

  factory TodaySalesReport.fromJson(Map<String, dynamic> json) =>
      TodaySalesReport(
        date: json['date'] as String,
        summary: TodaySalesSummary.fromJson(
            json['summary'] as Map<String, dynamic>),
        rows: (json['rows'] as List)
            .map((e) => SalesReportRow.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String date;
  final TodaySalesSummary summary;
  final List<SalesReportRow> rows;
}

class ProductPerformanceRow {
  ProductPerformanceRow({
    required this.inventoryItemId,
    required this.productName,
    required this.quantitySold,
    required this.totalSalesAmount,
    this.totalProfit,
    this.store,
  });

  factory ProductPerformanceRow.fromJson(Map<String, dynamic> json) =>
      ProductPerformanceRow(
        inventoryItemId: json['inventory_item_id'] as int,
        productName: json['product_name'] as String,
        quantitySold: (json['quantity_sold'] as num).toDouble(),
        totalSalesAmount: (json['total_sales_amount'] as num).toDouble(),
        totalProfit: json['total_profit'] != null
            ? (json['total_profit'] as num).toDouble()
            : null,
        store: json['store'] as String?,
      );

  final int inventoryItemId;
  final String productName;
  final double quantitySold;
  final double totalSalesAmount;
  final double? totalProfit;
  final String? store;
}

class ProductPerformanceReport {
  ProductPerformanceReport({required this.mostSold, required this.mostProfitable});

  factory ProductPerformanceReport.fromJson(Map<String, dynamic> json) =>
      ProductPerformanceReport(
        mostSold: (json['most_sold'] as List)
            .map((e) =>
                ProductPerformanceRow.fromJson(e as Map<String, dynamic>))
            .toList(),
        mostProfitable: (json['most_profitable'] as List)
            .map((e) =>
                ProductPerformanceRow.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final List<ProductPerformanceRow> mostSold;
  final List<ProductPerformanceRow> mostProfitable;
}
