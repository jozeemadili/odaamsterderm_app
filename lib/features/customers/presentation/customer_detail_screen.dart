import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/format/currency.dart';
import '../../invoices/data/invoice_models.dart';
import '../../pos/data/pos_models.dart';
import '../data/customer_models.dart';
import 'customer_controller.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(customerDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer'),
        actions: [
          detailAsync.maybeWhen(
            data: (detail) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await context.push<Customer>(
                    '/customers/$id/edit',
                    extra: detail.customer);
                if (updated != null) ref.invalidate(customerDetailProvider(id));
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Could not load this customer.\n$e',
                textAlign: TextAlign.center)),
        data: (detail) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(detail.customer.name,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(detail.customer.customerCode,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Row('Phone', detail.customer.phone ?? '—'),
                    _Row('Email', detail.customer.email ?? '—'),
                    _Row('Address', detail.customer.address ?? '—'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Invoices', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (detail.invoices.isEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No invoices yet.'))
            else
              Card(
                child: Column(
                  children: [
                    for (final invoice in detail.invoices)
                      _InvoiceRow(invoice: invoice),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Text('Sales', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (detail.sales.isEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No sales yet.'))
            else
              Card(
                child: Column(
                  children: [
                    for (final sale in detail.sales) _SaleRow(sale: sale),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Flexible(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(invoice.number),
      subtitle:
          Text(DateFormat.yMMMd().format(DateTime.parse(invoice.issueDate))),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatTzs(invoice.total)),
          Text(invoice.statusLabel,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
      onTap: () => context.push('/invoices/${invoice.id}'),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.sale});

  final SaleResult sale;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text('Sale #${sale.id}'),
      subtitle: Text(
          '${DateFormat.yMMMd().format(DateTime.parse(sale.saleDate))}${sale.paymentMethod != null ? ' · ${sale.paymentMethod}' : ''}'),
      trailing: Text(formatTzs(sale.amount)),
    );
  }
}
