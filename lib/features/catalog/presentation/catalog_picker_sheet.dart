import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n_extension.dart';
import '../data/catalog_models.dart';
import 'catalog_controller.dart';

/// Bottom sheet to search the catalog and pick a product to link.
Future<CatalogProduct?> showCatalogPicker(
  BuildContext context, {
  String initialSearch = '',
}) => showModalBottomSheet<CatalogProduct>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _CatalogPickerSheet(initialSearch: initialSearch),
);

class _CatalogPickerSheet extends ConsumerStatefulWidget {
  const _CatalogPickerSheet({required this.initialSearch});

  final String initialSearch;

  @override
  ConsumerState<_CatalogPickerSheet> createState() =>
      _CatalogPickerSheetState();
}

class _CatalogPickerSheetState extends ConsumerState<_CatalogPickerSheet> {
  late final _controller = TextEditingController(text: widget.initialSearch);
  late String _search = widget.initialSearch;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => setState(() => _search = value.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final results = ref.watch(catalogSearchProvider(_search));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.catalogPickTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    onChanged: _onChanged,
                    decoration: InputDecoration(
                      hintText: l10n.catalogSearchHint,
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: results.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (products) => ListView(
                  children: [
                    if (products.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.catalogNoMatches,
                          style: const TextStyle(color: DukaColors.muted),
                        ),
                      ),
                    for (final product in products)
                      ListTile(
                        title: Text(product.displayName),
                        subtitle: Text(
                          [
                            product.animalTypeName,
                            if (product.makerName != null)
                              l10n.producerBy(product.makerName!),
                            product.unit,
                            if (product.isPending) l10n.catalogPending,
                          ].whereType<String>().join(' · '),
                        ),
                        onTap: () => Navigator.pop(context, product),
                      ),
                    ListTile(
                      leading: const Icon(Icons.add_circle_outline),
                      title: Text(l10n.catalogNotFound),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/catalog', extra: {'propose': true});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
