import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../suppliers/data/supplier_models.dart';
import '../../suppliers/presentation/supplier_picker.dart';
import 'stock_receipt_controller.dart';

class StockReceiptFormScreen extends ConsumerStatefulWidget {
  const StockReceiptFormScreen({super.key});

  @override
  ConsumerState<StockReceiptFormScreen> createState() =>
      _StockReceiptFormScreenState();
}

class _StockReceiptFormScreenState
    extends ConsumerState<StockReceiptFormScreen> {
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();
  Supplier? _supplier;
  DateTime _receiptDate = DateTime.now();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickSupplier() async {
    final supplier = await showSupplierPicker(context);
    if (supplier != null) setState(() => _supplier = supplier);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _receiptDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _receiptDate = picked);
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final receipt = await ref.read(stockReceiptRepositoryProvider).create(
            supplierId: _supplier?.id,
            referenceNo: _referenceController.text.trim().isEmpty
                ? null
                : _referenceController.text.trim(),
            receiptDate: DateFormat('yyyy-MM-dd').format(_receiptDate),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      ref.read(stockReceiptListControllerProvider.notifier).upsert(receipt);
      if (mounted) context.pushReplacement('/stock-receipts/${receipt.id}');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(title: const Text('New stock receipt')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_supplier?.name ?? 'Supplier (optional)'),
              subtitle:
                  _supplier?.phone != null ? Text(_supplier!.phone!) : null,
              leading: const Icon(Icons.local_shipping_outlined),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickSupplier,
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _referenceController,
              decoration:
                  const InputDecoration(labelText: 'Reference no. (optional)'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Receipt date'),
              trailing: Text(dateFormat.format(_receiptDate)),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create receipt'),
            ),
          ],
        ),
      ),
    );
  }
}
