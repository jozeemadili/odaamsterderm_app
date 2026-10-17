import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../customers/data/customer_models.dart';
import '../../customers/presentation/customer_picker.dart';
import 'invoice_controller.dart';

class InvoiceFormScreen extends ConsumerStatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  final _notesController = TextEditingController();
  Customer? _customer;
  DateTime _issueDate = DateTime.now();
  DateTime? _dueDate;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomer() async {
    final customer = await showCustomerPicker(context);
    if (customer != null) setState(() => _customer = customer);
  }

  Future<void> _pickDate({required bool isDue}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDue ? (_dueDate ?? _issueDate) : _issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => isDue ? _dueDate = picked : _issueDate = picked);
  }

  Future<void> _submit() async {
    if (_customer == null) {
      setState(() => _error = 'Select a customer first.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final invoice = await ref.read(invoiceRepositoryProvider).create(
            customerId: _customer!.id,
            issueDate: DateFormat('yyyy-MM-dd').format(_issueDate),
            dueDate: _dueDate != null
                ? DateFormat('yyyy-MM-dd').format(_dueDate!)
                : null,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      ref.read(invoiceListControllerProvider.notifier).upsert(invoice);
      if (mounted) context.pushReplacement('/invoices/${invoice.id}');
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
      appBar: AppBar(title: const Text('New proforma')),
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
              title: Text(_customer?.name ?? 'Select customer'),
              subtitle: _customer != null && _customer!.phone != null
                  ? Text(_customer!.phone!)
                  : null,
              leading: const Icon(Icons.person_outline),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickCustomer,
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Issue date'),
              trailing: Text(dateFormat.format(_issueDate)),
              onTap: () => _pickDate(isDue: false),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_busy_outlined),
              title: const Text('Due date (optional)'),
              trailing:
                  Text(_dueDate != null ? dateFormat.format(_dueDate!) : '—'),
              onTap: () => _pickDate(isDue: true),
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
                  : const Text('Create proforma'),
            ),
          ],
        ),
      ),
    );
  }
}
