import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format/currency.dart';
import 'stock_receipt_controller.dart';

class StockReceiptListScreen extends ConsumerStatefulWidget {
  const StockReceiptListScreen({super.key});

  @override
  ConsumerState<StockReceiptListScreen> createState() =>
      _StockReceiptListScreenState();
}

class _StockReceiptListScreenState
    extends ConsumerState<StockReceiptListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 300) {
        ref.read(stockReceiptListControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockReceiptListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stock receipts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/stock-receipts/new'),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(stockReceiptListControllerProvider.notifier).load(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(StockReceiptListState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
              child: Text('Could not load stock receipts.\n${state.error}',
                  textAlign: TextAlign.center)),
        ],
      );
    }
    if (state.items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('No stock receipts yet. Tap + to record one.')),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      itemCount: state.items.length + (state.hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        final receipt = state.items[index];
        return ListTile(
          title: Text(receipt.referenceNo ?? 'Receipt #${receipt.id}'),
          subtitle: Text(
            '${receipt.supplier?.name ?? 'No supplier'} · ${DateFormat.yMMMd().format(DateTime.parse(receipt.receiptDate))}',
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatTzs(receipt.totalAmount),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              _StatusBadge(status: receipt.status, label: receipt.statusLabel),
            ],
          ),
          onTap: () => context.push('/stock-receipts/${receipt.id}'),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.label});

  final String status;
  final String label;

  Color get _color => switch (status) {
        'pending' => Colors.blueGrey,
        'approved' => Colors.green,
        'rejected' => Colors.redAccent,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: _color, fontWeight: FontWeight.w600)),
    );
  }
}
