import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/currency.dart';
import '../data/supplier_models.dart';
import 'supplier_controller.dart';

class SupplierDetailScreen extends ConsumerWidget {
  const SupplierDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supplierAsync = ref.watch(supplierDetailProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier'),
        actions: [
          supplierAsync.maybeWhen(
            data: (supplier) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await context
                    .push<Supplier>('/suppliers/$id/edit', extra: supplier);
                if (updated != null) ref.invalidate(supplierDetailProvider(id));
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: supplierAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Could not load this supplier.\n$e',
                textAlign: TextAlign.center)),
        data: (supplier) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(supplier.name,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _Row('Contact person', supplier.contactPerson ?? '—'),
                    _Row('Phone', supplier.phone ?? '—'),
                    _Row('Address', supplier.address ?? '—'),
                    _Row(
                      'Outstanding balance',
                      formatTzs(supplier.outstandingBalance),
                      valueColor: supplier.outstandingBalance > 0
                          ? Colors.redAccent
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            if (supplier.notes != null && supplier.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Notes', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(supplier.notes!),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

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
                style:
                    TextStyle(fontWeight: FontWeight.w600, color: valueColor),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
