import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../invoices/presentation/invoice_controller.dart';
import '../data/customer_models.dart';

/// A search-and-pick sheet for choosing a customer, with a lightweight
/// "new customer" form inline — a full customer directory is Phase 5's
/// job, but invoices need *some* way to pick or add one now.
Future<Customer?> showCustomerPicker(BuildContext context) {
  return showModalBottomSheet<Customer>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CustomerPickerSheet(),
  );
}

class _CustomerPickerSheet extends ConsumerStatefulWidget {
  const _CustomerPickerSheet();

  @override
  ConsumerState<_CustomerPickerSheet> createState() =>
      _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends ConsumerState<_CustomerPickerSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<Customer> _results = [];
  bool _searching = false;
  bool _showNewForm = false;

  @override
  void initState() {
    super.initState();
    _search('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final results = await ref.read(customerRepositoryProvider).search(query);
      if (mounted) setState(() => _results = results);
    } catch (_) {
      if (mounted) setState(() => _results = []);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Text('Select customer',
                          style: Theme.of(context).textTheme.titleLarge)),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _showNewForm = !_showNewForm),
                    icon: const Icon(Icons.person_add_alt),
                    label: Text(_showNewForm ? 'Search instead' : 'New'),
                  ),
                ],
              ),
            ),
            if (_showNewForm)
              Expanded(
                  child: _NewCustomerForm(
                      onCreated: (c) => Navigator.pop(context, c)))
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  onChanged: _onChanged,
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _results.isEmpty && !_searching
                    ? const Center(child: Text('No customers found.'))
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: _results.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = _results[index];
                          return ListTile(
                            title: Text(c.name),
                            subtitle: Text([
                              if (c.phone != null) c.phone!,
                              c.customerCode
                            ].join(' · ')),
                            onTap: () => Navigator.pop(context, c),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NewCustomerForm extends ConsumerStatefulWidget {
  const _NewCustomerForm({required this.onCreated});

  final ValueChanged<Customer> onCreated;

  @override
  ConsumerState<_NewCustomerForm> createState() => _NewCustomerFormState();
}

class _NewCustomerFormState extends ConsumerState<_NewCustomerForm> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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
      final customer = await ref.read(customerRepositoryProvider).create(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
          );
      widget.onCreated(customer);
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
            decoration: const InputDecoration(labelText: 'Customer name'),
            autofocus: true),
        const SizedBox(height: 12),
        TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone (optional)'),
            keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email (optional)'),
            keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Add customer'),
        ),
      ],
    );
  }
}
