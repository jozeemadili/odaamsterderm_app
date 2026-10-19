import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/l10n_extension.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../data/staff_repository.dart';
import 'settings_controller.dart';

class StaffFormScreen extends ConsumerStatefulWidget {
  const StaffFormScreen({super.key});

  @override
  ConsumerState<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends ConsumerState<StaffFormScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = StaffRepository.roles.keys.first;
  bool _allStores = false;
  final Set<int> _storeIds = {};
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      setState(() => _error = 'Name and email are required.');
      return;
    }
    if (!_allStores && _storeIds.isEmpty) {
      setState(() => _error = context.l10n.staffChooseStore);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final user = await ref
          .read(staffRepositoryProvider)
          .create(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            role: _role,
            allStores: _allStores,
            storeIds: _storeIds.toList(),
          );
      if (mounted) context.pop(user);
    } on ApiException catch (e) {
      setState(() => _error = e.fieldError('email') ?? e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add staff account')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            const Text(
              "A temporary password is generated automatically; share the invite by phone or in person.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone (optional)'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: [
                for (final entry in StaffRepository.roles.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (v) => setState(() => _role = v ?? _role),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.staffStoreAccess,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.staffAllStores),
              value: _allStores,
              onChanged: (v) => setState(() => _allStores = v),
            ),
            if (!_allStores)
              ref
                  .watch(inventoryBranchesProvider)
                  .maybeWhen(
                    data: (stores) => Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final store in stores)
                          FilterChip(
                            label: Text(store.name),
                            selected: _storeIds.contains(store.id),
                            onSelected: (on) => setState(
                              () => on
                                  ? _storeIds.add(store.id)
                                  : _storeIds.remove(store.id),
                            ),
                          ),
                      ],
                    ),
                    orElse: () => const LinearProgressIndicator(),
                  ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Add staff'),
            ),
          ],
        ),
      ),
    );
  }
}
