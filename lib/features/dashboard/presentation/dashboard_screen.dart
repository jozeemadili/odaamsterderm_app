import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../notifications/presentation/notification_controller.dart';
import '../data/dashboard_models.dart';
import '../data/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider(
  (ref) => DashboardRepository(ref.watch(apiClientProvider)),
);

final dashboardPeriodProvider = StateProvider.autoDispose<DashboardPeriod>(
  (ref) => DashboardPeriod.month,
);

final dashboardSummaryProvider = FutureProvider.autoDispose((ref) {
  final period = ref.watch(dashboardPeriodProvider);
  return ref.watch(dashboardRepositoryProvider).fetch(period: period);
});

/// Picks up to 4 evenly-spaced indices (always including the first and
/// last day) so axis labels never crowd together regardless of span.
Set<int> _bottomLabelIndexes(int length) {
  if (length <= 4) return {for (var i = 0; i < length; i++) i};
  const count = 4;
  return {
    for (var i = 0; i < count; i++) (i * (length - 1) / (count - 1)).round(),
  };
}

String _timeGreeting(AppLocalizations l10n) {
  final hour = DateTime.now().hour;
  if (hour < 12) return l10n.greetingMorning;
  if (hour < 17) return l10n.greetingAfternoon;
  return l10n.greetingEvening;
}

/// Localized label for a trend period, keyed off the stable `period` value
/// ('week'/'month'/'year') rather than the backend's English `period_label`
/// string, so it reads correctly regardless of the app's chosen language.
String _periodLabel(AppLocalizations l10n, String period) => switch (period) {
  'week' => l10n.periodLabelWeek,
  'year' => l10n.periodLabelYear,
  _ => l10n.periodLabelMonth,
};

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final auth = ref.watch(authControllerProvider);
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final notificationsCount =
        ref.watch(notificationsFeedProvider).valueOrNull?.count ?? 0;

    return Scaffold(
      body: SafeArea(
        child: summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.dashboardLoadError('$error'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: DukaColors.muted),
              ),
            ),
          ),
          data: (summary) => RefreshIndicator(
            color: DukaColors.indigo,
            onRefresh: () => ref.refresh(dashboardSummaryProvider.future),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _TopBar(
                  auth: auth,
                  notificationsCount: notificationsCount,
                  onNotifications: () => context.push('/notifications'),
                  onLogout: () =>
                      ref.read(authControllerProvider.notifier).logout(),
                ),
                const SizedBox(height: 18),
                _TrendCard(summary: summary),
                const SizedBox(height: 16),
                _TodayCard(summary: summary),
                const SizedBox(height: 16),
                _FinancialSummaryCard(summary: summary),
                const SizedBox(height: 16),
                _StockSummaryCard(summary: summary),
                const SizedBox(height: 16),
                if (summary.marketplace != null) ...[
                  _MarketplaceCard(marketplace: summary.marketplace!),
                  const SizedBox(height: 16),
                ],
                _StatCard(summary: summary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Period selector — week / month / year. Deliberately small and docked
/// right above the chart it controls (not up by the greeting), so it
/// reads as a control on the trend card rather than the whole screen.
/// ---------------------------------------------------------------------
class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector();

  static Map<DashboardPeriod, String> _labels(AppLocalizations l10n) => {
    DashboardPeriod.week: l10n.periodWeek,
    DashboardPeriod.month: l10n.periodMonth,
    DashboardPeriod.year: l10n.periodYear,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(dashboardPeriodProvider);
    final labels = _labels(context.l10n);

    return Theme(
      data: Theme.of(context).copyWith(visualDensity: VisualDensity.compact),
      child: SegmentedButton<DashboardPeriod>(
        segments: [
          for (final period in DashboardPeriod.values)
            ButtonSegment(value: period, label: Text(labels[period]!)),
        ],
        selected: {selected},
        showSelectedIcon: false,
        onSelectionChanged: (value) =>
            ref.read(dashboardPeriodProvider.notifier).state = value.first,
        style: SegmentedButton.styleFrom(
          backgroundColor: DukaColors.bg,
          foregroundColor: DukaColors.muted,
          selectedBackgroundColor: DukaColors.indigo,
          selectedForegroundColor: Colors.white,
          side: const BorderSide(color: DukaColors.line),
          textStyle: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          minimumSize: const Size(0, 26),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Top bar — plain mark (never a real logo), greeting, business name.
/// ---------------------------------------------------------------------
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.auth,
    required this.notificationsCount,
    required this.onNotifications,
    required this.onLogout,
  });

  final AuthState auth;
  final int notificationsCount;
  final VoidCallback onNotifications;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: DukaColors.ink,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.storefront_outlined,
            color: Colors.white,
            size: 17,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.greetingMessage(
                  _timeGreeting(l10n),
                  auth.user?.name.split(' ').first ?? l10n.greetingFallbackName,
                ),
                style: const TextStyle(
                  fontSize: 11.5,
                  color: DukaColors.muted,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                auth.merchant?.businessName ?? '',
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _IconButton(
          icon: Icons.notifications_outlined,
          onTap: onNotifications,
          badgeCount: notificationsCount,
        ),
        const SizedBox(width: 8),
        _IconButton(icon: Icons.logout, onTap: onLogout),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: DukaColors.line),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox(
              width: 34,
              height: 34,
              child: Icon(icon, size: 15, color: DukaColors.ink),
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              constraints: const BoxConstraints(minWidth: 15),
              decoration: BoxDecoration(
                color: DukaColors.rose,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 8.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Trend card — sales figure, minimal dotted line chart, expenses inline.
/// ---------------------------------------------------------------------
class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trend = summary.trend;
    final maxValue = [
      ...trend.sales,
      ...trend.expenses,
      ...trend.profit,
    ].fold<double>(0, (m, v) => v > m ? v : m);
    final maxY = maxValue <= 0 ? 100.0 : maxValue * 1.2;
    final labelIndexes = _bottomLabelIndexes(trend.labels.length);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n
                            .salesLabelPrefix(
                              _periodLabel(l10n, summary.period),
                            )
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: DukaColors.muted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatTzs(summary.salesTotal),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '↓ ${formatTzs(summary.expensesTotal)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: DukaColors.rose,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.expensesLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        color: DukaColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _LegendDot(
                      color: DukaColors.indigo,
                      label: l10n.legendSales,
                    ),
                    const SizedBox(width: 10),
                    _LegendDot(
                      color: DukaColors.rose,
                      label: l10n.legendExpenses,
                    ),
                    const SizedBox(width: 10),
                    _LegendDot(
                      color: const Color(0xFF1B9E5A),
                      label: l10n.profitLabel,
                    ),
                  ],
                ),
                const _PeriodSelector(),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: trend.labels.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noActivityYet,
                        style: const TextStyle(
                          color: DukaColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: (trend.labels.length - 1).toDouble(),
                        minY: 0,
                        maxY: maxY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: maxY / 3,
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: DukaColors.line,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (_) => DukaColors.ink,
                            getTooltipItems: (spots) => spots
                                .map(
                                  (s) => LineTooltipItem(
                                    formatTzs(s.y),
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < trend.expenses.length; i++)
                                FlSpot(i.toDouble(), trend.expenses[i]),
                            ],
                            isCurved: false,
                            color: DukaColors.rose,
                            barWidth: 1.8,
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < trend.profit.length; i++)
                                FlSpot(i.toDouble(), trend.profit[i]),
                            ],
                            isCurved: false,
                            color: const Color(0xFF1B9E5A),
                            barWidth: 1.8,
                            dotData: const FlDotData(show: false),
                          ),
                          LineChartBarData(
                            spots: [
                              for (var i = 0; i < trend.sales.length; i++)
                                FlSpot(i.toDouble(), trend.sales[i]),
                            ],
                            isCurved: false,
                            color: DukaColors.indigo,
                            barWidth: 2.2,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, bar, index) =>
                                  FlDotCirclePainter(
                                    radius: 2.6,
                                    color: DukaColors.indigo,
                                    strokeWidth: 0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            if (trend.labels.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < trend.labels.length; i++)
                    if (labelIndexes.contains(i))
                      Text(
                        trend.labels[i].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: DukaColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: DukaColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// Stat card — three plain rows with thin dividers, not tiles.
/// ---------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  const _StatCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Column(
        children: [
          _StatRow(
            icon: Icons.warning_amber_rounded,
            iconColor: DukaColors.rose,
            label: l10n.statLowStock,
            value: '${summary.lowStockCount}',
            onTap: () => context.push('/inventory'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.event_busy,
            iconColor: DukaColors.indigo,
            label: l10n.statExpiringSoon,
            value: '${summary.expiringSoonCount}',
            onTap: () => context.push('/inventory'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.receipt_long_outlined,
            iconColor: DukaColors.muted,
            label: l10n.statUnverifiedPayments,
            value: '${summary.unverifiedPaymentsCount}',
            onTap: () => context.push('/payments'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.storefront_outlined,
            iconColor: DukaColors.indigo,
            label: l10n.totalStoresLabel,
            value: '${summary.totalStores}',
            onTap: () => context.push('/stores'),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Financial summary — profit (sales − expenses) for the selected period,
/// plus the all-time unpaid-invoice total. "Unpaid today" lives on the
/// Today card above instead, so it isn't repeated here.
/// ---------------------------------------------------------------------
class _FinancialSummaryCard extends StatelessWidget {
  const _FinancialSummaryCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Column(
        children: [
          _StatRow(
            icon: Icons.trending_up,
            iconColor: summary.profitTotal >= 0
                ? DukaColors.indigo
                : DukaColors.rose,
            label: l10n.profitLabel,
            value: formatTzs(summary.profitTotal),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.receipt_long_outlined,
            iconColor: DukaColors.rose,
            label: l10n.unpaidTotalLabel,
            value: formatTzs(summary.unpaidTotal),
            onTap: () => context.push('/invoices'),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Today card — live sales, profit, expenses and unpaid for today only,
/// always visible regardless of the trend card's period selector. Sales
/// opens today's per-product sales report.
/// ---------------------------------------------------------------------
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
            child: Text(
              l10n.todayCardTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          _StatRow(
            icon: Icons.point_of_sale_outlined,
            iconColor: DukaColors.indigo,
            label: '${l10n.legendSales} (${summary.todaySalesCount})',
            value: formatTzs(summary.todaySalesTotal),
            onTap: () => context.push('/reports/sales/today'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.trending_up,
            iconColor: summary.todayProfitTotal >= 0
                ? DukaColors.indigo
                : DukaColors.rose,
            label: l10n.profitLabel,
            value: formatTzs(summary.todayProfitTotal),
            onTap: () => context.push('/reports/sales/today'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.trending_down,
            iconColor: DukaColors.rose,
            label: l10n.legendExpenses,
            value: formatTzs(summary.todayExpensesTotal),
            onTap: () => context.push('/expenses'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.today_outlined,
            iconColor: DukaColors.rose,
            label: l10n.unpaidTodayLabel,
            value: formatTzs(summary.unpaidToday),
            onTap: () => context.push('/invoices'),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// Stock valuation snapshot — buying/selling value and expected profit
/// across every store, not scoped to the period selector.
/// ---------------------------------------------------------------------
class _StockSummaryCard extends StatelessWidget {
  const _StockSummaryCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stock = summary.stockSummary;

    return Card(
      child: Column(
        children: [
          _StatRow(
            icon: Icons.inventory_2_outlined,
            iconColor: DukaColors.muted,
            label: l10n.stockValueCostLabel,
            value: formatTzs(stock.buyingValue),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.sell_outlined,
            iconColor: DukaColors.indigo,
            label: l10n.stockValueSellingLabel,
            value: formatTzs(stock.sellingValue),
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.stacked_bar_chart,
            iconColor: DukaColors.muted,
            label: l10n.stockQuantityLabel,
            value: _qty(stock.totalQuantity),
            onTap: () => context.push('/inventory'),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.trending_up,
            iconColor: stock.expectedProfit >= 0
                ? DukaColors.indigo
                : DukaColors.rose,
            label: l10n.expectedProfitLabel,
            value: formatTzs(stock.expectedProfit),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

String _qty(double v) => NumberFormat.decimalPattern().format(
  v == v.roundToDouble() ? v.round() : v,
);

class _MarketplaceCard extends StatelessWidget {
  const _MarketplaceCard({required this.marketplace});

  final DashboardMarketplace marketplace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void open() => context.push('/marketplace');

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
            child: Text(
              l10n.marketplaceTitle,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          if (!marketplace.approved)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
              child: Text(
                l10n.marketplaceApprovalPending,
                style: const TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
          _StatRow(
            icon: Icons.storefront,
            iconColor: DukaColors.indigo,
            label: l10n.marketplaceListedProducts,
            value: '${marketplace.listedCount}',
            onTap: open,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.public,
            iconColor: DukaColors.muted,
            label: l10n.marketplaceUnitsExposed,
            value: _qty(marketplace.unitsExposed),
            onTap: open,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _StatRow(
            icon: Icons.remove_shopping_cart_outlined,
            iconColor: marketplace.outOfStockCount > 0
                ? DukaColors.rose
                : DukaColors.muted,
            label: l10n.marketplaceOutOfStockOnline,
            value: '${marketplace.outOfStockCount}',
            onTap: open,
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: DukaColors.ink,
                ),
              ),
            ),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
