class DashboardTrend {
  DashboardTrend({
    required this.labels,
    required this.sales,
    required this.expenses,
    required this.profit,
  });

  factory DashboardTrend.fromJson(Map<String, dynamic> json) => DashboardTrend(
        labels: (json['labels'] as List).map((e) => e as String).toList(),
        sales:
            (json['sales'] as List).map((e) => (e as num).toDouble()).toList(),
        expenses: (json['expenses'] as List)
            .map((e) => (e as num).toDouble())
            .toList(),
        profit:
            (json['profit'] as List).map((e) => (e as num).toDouble()).toList(),
      );

  final List<String> labels;
  final List<double> sales;
  final List<double> expenses;
  final List<double> profit;
}

/// Merchant-wide stock valuation snapshot — not scoped to the selected
/// period, since it reflects stock on hand right now.
class DashboardStockSummary {
  DashboardStockSummary({
    required this.buyingValue,
    required this.sellingValue,
    required this.expectedProfit,
  });

  factory DashboardStockSummary.fromJson(Map<String, dynamic> json) =>
      DashboardStockSummary(
        buyingValue: (json['buying_value'] as num).toDouble(),
        sellingValue: (json['selling_value'] as num).toDouble(),
        expectedProfit: (json['expected_profit'] as num).toDouble(),
      );

  final double buyingValue;
  final double sellingValue;
  final double expectedProfit;
}

/// Matches the API's `period` query param — controls both the headline
/// sales/expenses range and the trend's bucket granularity (week/month
/// bucket by day, year buckets by calendar month).
enum DashboardPeriod {
  week('week'),
  month('month'),
  year('year');

  const DashboardPeriod(this.apiValue);

  final String apiValue;
}

class DashboardSummary {
  DashboardSummary({
    required this.period,
    required this.periodLabel,
    required this.salesTotal,
    required this.expensesTotal,
    required this.profitTotal,
    required this.todaySalesTotal,
    required this.todayExpensesTotal,
    required this.todayProfitTotal,
    required this.lowStockCount,
    required this.expiringSoonCount,
    required this.unverifiedPaymentsCount,
    required this.unpaidToday,
    required this.unpaidTotal,
    required this.stockSummary,
    required this.totalStores,
    required this.trend,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) =>
      DashboardSummary(
        period: json['period'] as String,
        periodLabel: json['period_label'] as String,
        salesTotal: (json['sales_total'] as num).toDouble(),
        expensesTotal: (json['expenses_total'] as num).toDouble(),
        profitTotal: (json['profit_total'] as num).toDouble(),
        todaySalesTotal: (json['today_sales_total'] as num).toDouble(),
        todayExpensesTotal: (json['today_expenses_total'] as num).toDouble(),
        todayProfitTotal: (json['today_profit_total'] as num).toDouble(),
        lowStockCount: json['low_stock_count'] as int,
        expiringSoonCount: json['expiring_soon_count'] as int,
        unverifiedPaymentsCount: json['unverified_payments_count'] as int,
        unpaidToday: (json['unpaid_today'] as num).toDouble(),
        unpaidTotal: (json['unpaid_total'] as num).toDouble(),
        stockSummary: DashboardStockSummary.fromJson(
            json['stock_summary'] as Map<String, dynamic>),
        totalStores: json['total_stores'] as int,
        trend: DashboardTrend.fromJson(json['trend'] as Map<String, dynamic>),
      );

  final String period;
  final String periodLabel;
  final double salesTotal;
  final double expensesTotal;
  final double profitTotal;
  final double todaySalesTotal;
  final double todayExpensesTotal;
  final double todayProfitTotal;
  final int lowStockCount;
  final int expiringSoonCount;
  final int unverifiedPaymentsCount;
  final double unpaidToday;
  final double unpaidTotal;
  final DashboardStockSummary stockSummary;
  final int totalStores;
  final DashboardTrend trend;
}
