import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/currency.dart';
import '../data/invoice_models.dart';
import 'invoice_controller.dart';

const _statusFilters = [
  (null, 'All'),
  ('draft', 'Proforma'),
  ('invoiced', 'Invoiced'),
  ('partially_paid', 'Partial'),
  ('paid', 'Paid'),
  ('cancelled', 'Cancelled'),
];

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 300) {
        ref.read(invoiceListControllerProvider.notifier).loadMore();
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
    final state = ref.watch(invoiceListControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/invoices/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              children: [
                for (final (value, label) in _statusFilters) ...[
                  ChoiceChip(
                    label: Text(label),
                    selected: state.status == value,
                    onSelected: (_) => ref
                        .read(invoiceListControllerProvider.notifier)
                        .setStatus(value),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(invoiceListControllerProvider.notifier).load(),
              child: _buildBody(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(InvoiceListState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 80),
          Center(
              child: Text('Could not load invoices.\n${state.error}',
                  textAlign: TextAlign.center)),
        ],
      );
    }
    if (state.items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 80),
          Center(child: Text('No invoices yet. Tap + to draft a proforma.')),
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
        return _InvoiceTile(invoice: state.items[index]);
      },
    );
  }
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/invoices/${invoice.id}'),
      title: Text(invoice.number,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(invoice.customer?.name ?? 'No customer'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatTzs(invoice.total),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          _StatusBadge(status: invoice.status, label: invoice.statusLabel),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.label});

  final String status;
  final String label;

  Color get _color => switch (status) {
        'draft' => Colors.blueGrey,
        'invoiced' => Colors.orange,
        'partially_paid' => Colors.amber.shade800,
        'paid' => Colors.green,
        'cancelled' => Colors.redAccent,
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
