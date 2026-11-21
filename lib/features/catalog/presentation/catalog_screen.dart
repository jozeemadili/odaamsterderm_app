import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/skeleton.dart';
import '../../../app/theme.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/l10n_extension.dart';
import 'catalog_controller.dart';

/// Browse the shared catalog. Missing products are requested with label
/// photos; agents never type product details.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _search = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final products = ref.watch(catalogSearchProvider(_search));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/product-requests/new'),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(l10n.catalogRequestProduct),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text(
            l10n.catalogSubtitle,
            style: TextStyle(fontSize: 13, color: DukaColors.muted),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: l10n.catalogSearchHint,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(
                const Duration(milliseconds: 300),
                () => setState(() => _search = value.trim()),
              );
            },
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(l10n.pickTitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/inventory/add'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.outbox_outlined),
              title: Text(l10n.catalogYourRequests),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/product-requests'),
            ),
          ),
          const SizedBox(height: 12),
          products.when(
            loading: () =>
                const SkeletonList(shrinkWrap: true, padding: EdgeInsets.zero),
            error: (e, _) => Text('$e'),
            data: (list) => list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.catalogNoMatches,
                      style: TextStyle(color: DukaColors.muted),
                    ),
                  )
                : Card(
                    child: Column(
                      children: [
                        for (final p in list.where((p) => p.isApproved))
                          ListTile(
                            title: Text(p.displayName),
                            subtitle: Text(
                              [
                                p.animalTypeName,
                                p.categoryName,
                                if (p.makerName != null)
                                  l10n.producerBy(p.makerName!),
                              ].whereType<String>().join(' · '),
                            ),
                            trailing: Text(
                              p.unit,
                              style: TextStyle(
                                fontSize: 12,
                                color: DukaColors.muted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
