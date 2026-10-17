import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../data/customer_models.dart';
import 'customer_controller.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  const CustomerFormScreen({super.key, this.existing});

  final Customer? existing;

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  late final _nameController =
      TextEditingController(text: widget.existing?.name ?? '');
  late final _phoneController =
      TextEditingController(text: widget.existing?.phone ?? '');
  late final _emailController =
      TextEditingController(text: widget.existing?.email ?? '');
  late final _addressController =
      TextEditingController(text: widget.existing?.address ?? '');
  bool _submitting = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
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
      final repo = ref.read(customerRepositoryProvider);
      final customer = _isEdit
          ? await repo.update(
              widget.existing!.id,
              name: _nameController.text.trim(),
              phone: _emptyToNull(_phoneController.text),
              email: _emptyToNull(_emailController.text),
              address: _emptyToNull(_addressController.text),
            )
          : await repo.create(
              name: _nameController.text.trim(),
              phone: _emptyToNull(_phoneController.text),
              email: _emptyToNull(_emailController.text),
              address: _emptyToNull(_addressController.text),
            );
      if (mounted) context.pop(customer);
    } on ApiException catch (e) {
      setState(() => _error = e.fieldError('name') ?? e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit customer' : 'New customer')),
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
                decoration: const InputDecoration(labelText: 'Customer name'),
                autofocus: !_isEdit),
            const SizedBox(height: 12),
            TextField(
                controller: _phoneController,
                decoration:
                    const InputDecoration(labelText: 'Phone (optional)'),
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'Email (optional)'),
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextField(
                controller: _addressController,
                decoration:
                    const InputDecoration(labelText: 'Address (optional)'),
                maxLines: 2),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEdit ? 'Save changes' : 'Add customer'),
            ),
          ],
        ),
      ),
    );
  }
}
