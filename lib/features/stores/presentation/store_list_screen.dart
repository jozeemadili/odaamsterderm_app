import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import '../data/store_models.dart';
import 'store_controller.dart';

class StoreListScreen extends ConsumerWidget {
  const StoreListScreen({super.key});

  Future<void> _addStore(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.addStore,
                style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.storeNameLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: l10n.storeAddressLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: l10n.storePhoneLabel),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                try {
                  await ref.read(storeRepositoryProvider).create(
                        name: name,
                        address: addressController.text.trim().isEmpty
                            ? null
                            : addressController.text.trim(),
                        phone: phoneController.text.trim().isEmpty
                            ? null
                            : phoneController.text.trim(),
                      );
                  if (sheetContext.mounted) Navigator.pop(sheetContext, true);
                } on ApiException catch (e) {
                  if (sheetContext.mounted) {
                    ScaffoldMessenger.of(sheetContext)
                        .showSnackBar(SnackBar(content: Text(e.message)));
                  }
                }
              },
              child: Text(l10n.save),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (created == true) {
      ref.invalidate(storesProvider);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final storesAsync = ref.watch(storesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.storesTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addStore(context, ref),
        child: const Icon(Icons.add),
      ),
      body: storesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text(l10n.dashboardLoadError('$e'),
                textAlign: TextAlign.center)),
        data: (stores) => stores.isEmpty
            ? Center(child: Text(l10n.noStoresYet))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(storesProvider.future),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: stores.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _StoreCard(store: stores[index]),
                ),
              ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/stores/${store.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(store.name,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  if (store.isPrimary)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: DukaColors.indigo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999)),
                      child: const Text('primary',
                          style: TextStyle(
                              fontSize: 10.5,
                              color: DukaColors.indigo,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              if (store.address != null) ...[
                const SizedBox(height: 4),
                Text(store.address!,
                    style: const TextStyle(
                        fontSize: 12.5, color: DukaColors.muted)),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${store.productCount} products',
                      style: const TextStyle(
                          fontSize: 12.5,
                          color: DukaColors.indigo,
                          fontWeight: FontWeight.w700)),
                  Text(formatTzs(store.stockValue),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: DukaColors.ink)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
