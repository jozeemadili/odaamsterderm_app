import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../data/report_models.dart';
import 'report_controller.dart';

class TodaySalesScreen extends ConsumerWidget {
  const TodaySalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(todaySalesReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Today's sales")),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text("Couldn't load today's sales.\n$e",
                textAlign: TextAlign.center)),
        data: (report) => report.rows.isEmpty
            ? const Center(
                child: Text('No sales recorded yet today.',
                    style: TextStyle(color: DukaColors.muted)))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(todaySalesReportProvider.future),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      DateFormat.yMMMd().format(DateTime.parse(report.date)),
                      style: const TextStyle(
                          fontSize: 12,
                          color: DukaColors.muted,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    _SummaryCard(summary: report.summary),
                    const SizedBox(height: 16),
                    for (final row in report.rows) _SalesRowCard(row: row),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final TodaySalesSummary summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: DukaColors.ink,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today\'s total',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _SummaryStat(
                        label: 'Buying value',
                        value: formatTzs(summary.totalBuyingValue))),
                Expanded(
                    child: _SummaryStat(
                        label: 'Selling value',
                        value: formatTzs(summary.totalSalesAmount))),
                Expanded(
                    child: _SummaryStat(
                        label: 'Profit',
                        value: formatTzs(summary.totalProfit),
                        valueColor: summary.totalProfit >= 0
                            ? const Color(0xFF6FE0A0)
                            : DukaColors.rose)),
              ],
            ),
            if (summary.profitPartial) ...[
              const SizedBox(height: 10),
              const Text(
                'Buying value and profit only include sales with a recorded cost price.',
                style: TextStyle(fontSize: 10.5, color: Colors.white60),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat(
      {required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10.5, color: Colors.white70)),
        const SizedBox(height: 3),
        Text(value,
            style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: valueColor ?? Colors.white)),
      ],
    );
  }
}

class _SalesRowCard extends StatelessWidget {
  const _SalesRowCard({required this.row});

  final SalesReportRow row;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(row.productName,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text(
                  '${row.quantitySold.toStringAsFixed(row.quantitySold.truncateToDouble() == row.quantitySold ? 0 : 2)} sold',
                  style: const TextStyle(
                      fontSize: 12, color: DukaColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                if (row.store != null) row.store!,
                if (row.soldBy != null) 'by ${row.soldBy}',
              ].join(' · '),
              style: const TextStyle(fontSize: 11.5, color: DukaColors.muted),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sales',
                        style: TextStyle(
                            fontSize: 11, color: DukaColors.muted)),
                    Text(formatTzs(row.totalSalesAmount),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DukaColors.ink)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Profit',
                        style: TextStyle(
                            fontSize: 11, color: DukaColors.muted)),
                    Text(
                      row.totalProfit != null
                          ? formatTzs(row.totalProfit!)
                          : 'N/A',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: row.totalProfit == null
                              ? DukaColors.muted
                              : (row.totalProfit! >= 0
                                  ? const Color(0xFF1B9E5A)
                                  : DukaColors.rose)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
