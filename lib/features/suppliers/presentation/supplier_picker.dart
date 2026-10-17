import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/supplier_models.dart';
import 'supplier_controller.dart';

/// A pick-or-add sheet for choosing a supplier. The backend doesn't offer a
/// search filter on `/suppliers`, so this just pages through the same
/// name-ordered list the directory screen uses, with a quick-add form.
Future<Supplier?> showSupplierPicker(BuildContext context) {
  return showModalBottomSheet<Supplier>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _SupplierPickerSheet(),
  );
}

class _SupplierPickerSheet extends ConsumerStatefulWidget {
  const _SupplierPickerSheet();

  @override
  ConsumerState<_SupplierPickerSheet> createState() =>
      _SupplierPickerSheetState();
}

class _SupplierPickerSheetState extends ConsumerState<_SupplierPickerSheet> {
  bool _showNewForm = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(supplierListControllerProvider);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Select supplier',
                          style: Theme.of(context).textTheme.titleLarge)),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _showNewForm = !_showNewForm),
                    icon: const Icon(Icons.add_business_outlined),
                    label: Text(_showNewForm ? 'Choose instead' : 'New'),
                  ),
                ],
              ),
            ),
            if (_showNewForm)
              Expanded(
                  child: _NewSupplierForm(
                      onCreated: (s) => Navigator.pop(context, s)))
            else if (state.isLoading && state.items.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (state.items.isEmpty)
              const Expanded(child: Center(child: Text('No suppliers yet.')))
            else
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final s = state.items[index];
                    return ListTile(
                      title: Text(s.name),
                      subtitle: s.contactPerson != null
                          ? Text(s.contactPerson!)
                          : null,
                      onTap: () => Navigator.pop(context, s),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NewSupplierForm extends ConsumerStatefulWidget {
  const _NewSupplierForm({required this.onCreated});

  final ValueChanged<Supplier> onCreated;

  @override
  ConsumerState<_NewSupplierForm> createState() => _NewSupplierFormState();
}

class _NewSupplierFormState extends ConsumerState<_NewSupplierForm> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
      final supplier = await ref.read(supplierRepositoryProvider).create(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
          );
      widget.onCreated(supplier);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_error != null) ...[
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
        ],
        TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Supplier name'),
            autofocus: true),
        const SizedBox(height: 12),
        TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone (optional)'),
            keyboardType: TextInputType.phone),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add supplier'),
        ),
      ],
    );
  }
}
