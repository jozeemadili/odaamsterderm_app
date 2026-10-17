import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../data/report_models.dart';
import 'report_controller.dart';

class ProductPerformanceScreen extends ConsumerWidget {
  const ProductPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsync = ref.watch(productPerformanceReportProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Product performance'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Most sold'),
            Tab(text: 'Most profitable'),
          ]),
        ),
        body: reportAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
              child: Text("Couldn't load product performance.\n$e",
                  textAlign: TextAlign.center)),
          data: (report) => RefreshIndicator(
            onRefresh: () =>
                ref.refresh(productPerformanceReportProvider.future),
            child: TabBarView(
              children: [
                _PerformanceList(
                  rows: report.mostSold,
                  emptyMessage: 'No sales recorded yet.',
                  rankBy: _RankBy.quantity,
                ),
                _PerformanceList(
                  rows: report.mostProfitable,
                  emptyMessage:
                      'No profit data yet — sell a product with its cost set to see it here.',
                  rankBy: _RankBy.profit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _RankBy { quantity, profit }

class _PerformanceList extends StatelessWidget {
  const _PerformanceList(
      {required this.rows, required this.emptyMessage, required this.rankBy});

  final List<ProductPerformanceRow> rows;
  final String emptyMessage;
  final _RankBy rankBy;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(emptyMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: DukaColors.muted)),
      ));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final row = rows[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: DukaColors.bg,
              child: Text('${index + 1}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DukaColors.ink)),
            ),
            title: Text(row.productName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text([
              if (row.store != null) row.store!,
              '${row.quantitySold.toStringAsFixed(0)} sold',
            ].join(' · ')),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rankBy == _RankBy.profit
                      ? formatTzs(row.totalProfit ?? 0)
                      : formatTzs(row.totalSalesAmount),
                  style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: DukaColors.ink),
                ),
                Text(
                  rankBy == _RankBy.profit ? 'profit' : 'sales',
                  style: const TextStyle(fontSize: 10, color: DukaColors.muted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
