import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../data/supplier_models.dart';
import 'supplier_controller.dart';

class SupplierFormScreen extends ConsumerStatefulWidget {
  const SupplierFormScreen({super.key, this.existing});

  final Supplier? existing;

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  late final _nameController =
      TextEditingController(text: widget.existing?.name ?? '');
  late final _contactController =
      TextEditingController(text: widget.existing?.contactPerson ?? '');
  late final _phoneController =
      TextEditingController(text: widget.existing?.phone ?? '');
  late final _addressController =
      TextEditingController(text: widget.existing?.address ?? '');
  late final _notesController =
      TextEditingController(text: widget.existing?.notes ?? '');
  bool _submitting = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final repo = ref.read(supplierRepositoryProvider);
      final supplier = _isEdit
          ? await repo.update(
              widget.existing!.id,
              name: _nameController.text.trim(),
              contactPerson: _emptyToNull(_contactController.text),
              phone: _emptyToNull(_phoneController.text),
              address: _emptyToNull(_addressController.text),
              notes: _emptyToNull(_notesController.text),
            )
          : await repo.create(
              name: _nameController.text.trim(),
              contactPerson: _emptyToNull(_contactController.text),
              phone: _emptyToNull(_phoneController.text),
              address: _emptyToNull(_addressController.text),
              notes: _emptyToNull(_notesController.text),
            );
      if (mounted) context.pop(supplier);
    } on ApiException catch (e) {
      setState(() => _error = e.fieldError('name') ?? e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit supplier' : 'New supplier')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Supplier name'),
                autofocus: !_isEdit),
            const SizedBox(height: 12),
            TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                    labelText: 'Contact person (optional)')),
            const SizedBox(height: 12),
            TextField(
                controller: _phoneController,
                decoration:
                    const InputDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(
                controller: _addressController,
                decoration:
                    const InputDecoration(labelText: 'Address (optional)'),
                maxLines: 2),
            const SizedBox(height: 12),
            TextField(
                controller: _notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 3),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEdit ? 'Save changes' : 'Add supplier'),
            ),
          ],
        ),
      ),
    );
  }
}
