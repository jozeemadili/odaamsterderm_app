import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../l10n/l10n_extension.dart';
import '../../stores/presentation/store_controller.dart';
import '../data/agent_catalog_models.dart';
import 'catalog_controller.dart';

typedef _PickQuery = ({String search, String producers});

final _pickProvider = FutureProvider.autoDispose.family((ref, _PickQuery q) {
  return ref
      .watch(catalogRepositoryProvider)
      .pick(
        search: q.search,
        producerIds: q.producers.isEmpty
            ? const []
            : q.producers.split(',').map(int.parse).toList(),
      );
});

/// Stock is added by picking pack sizes from the shared catalogue: no
/// product details are typed. Missing products are requested with photos.
class AddFromCatalogueScreen extends ConsumerStatefulWidget {
  const AddFromCatalogueScreen({super.key});

  @override
  ConsumerState<AddFromCatalogueScreen> createState() =>
      _AddFromCatalogueScreenState();
}

class _Line {
  final price = TextEditingController();
  final qty = TextEditingController();
}

class _AddFromCatalogueScreenState
    extends ConsumerState<AddFromCatalogueScreen> {
  String _search = '';
  final Set<int> _producers = {};
  final Map<int, _Line> _lines = {};
  int? _branchId;
  bool _listOnline = true;
  bool _saving = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    for (final l in _lines.values) {
      l.price.dispose();
      l.qty.dispose();
    }
    super.dispose();
  }

  void _toggle(int variantId, bool on) => setState(() {
    if (on) {
      _lines[variantId] = _Line();
    } else {
      final l = _lines.remove(variantId);
      l?.price.dispose();
      l?.qty.dispose();
    }
  });

  Future<void> _add() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final lines = <PickLine>[];
    for (final e in _lines.entries) {
      final price = double.tryParse(e.value.price.text.trim());
      final qty = double.tryParse(e.value.qty.text.trim());
      if (price == null || qty == null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.pickNeedPriceQty)));
        return;
      }
      lines.add(PickLine(variantId: e.key, unitPrice: price, quantity: qty));
    }
    if (lines.isEmpty || _branchId == null) return;

    setState(() => _saving = true);
    try {
      final result = await ref
          .read(catalogRepositoryProvider)
          .addFromCatalogue(
            branchId: _branchId!,
            lines: lines,
            listOnline: _listOnline,
          );
      for (final l in _lines.values) {
        l.price.dispose();
        l.qty.dispose();
      }
      _lines.clear();
      ref.invalidate(_pickProvider);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.pickAdded(result.added))),
      );
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stores = ref.watch(storesProvider);
    final producers = ref.watch(pickProducersProvider);
    final products = ref.watch(
      _pickProvider((
        search: _search,
        producers: (_producers.toList()..sort()).join(','),
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pickTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => context.push(v),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: '/product-requests/new',
                child: Text(l10n.catalogRequestProduct),
              ),
              PopupMenuItem(
                value: '/product-requests',
                child: Text(l10n.catalogYourRequests),
              ),
              PopupMenuItem(
                value: '/inventory/new',
                child: Text(l10n.pickShopOnly),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _listOnline = !_listOnline),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _listOnline,
                        onChanged: (v) =>
                            setState(() => _listOnline = v ?? true),
                      ),
                      Flexible(
                        child: Text(
                          l10n.pickListOnline,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              FilledButton(
                onPressed: _lines.isEmpty || _saving ? null : _add,
                child: Text(l10n.pickAddButton(_lines.length)),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            l10n.pickIntro,
            style: TextStyle(fontSize: 13, color: DukaColors.muted),
          ),
          const SizedBox(height: 12),
          stores.maybeWhen(
            data: (list) {
              if (_branchId == null && list.isNotEmpty) {
                _branchId = list.first.id;
              }
              return list.length < 2
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DropdownButtonFormField<int>(
                        initialValue: _branchId,
                        decoration: InputDecoration(labelText: l10n.pickStore),
                        items: [
                          for (final s in list)
                            DropdownMenuItem(value: s.id, child: Text(s.name)),
                        ],
                        onChanged: (v) => setState(() => _branchId = v),
                      ),
                    );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          TextField(
            decoration: InputDecoration(
              hintText: l10n.pickSearchHint,
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
          Text(
            l10n.pickCompanies,
            style: TextStyle(fontSize: 12.5, color: DukaColors.muted),
          ),
          const SizedBox(height: 6),
          producers.maybeWhen(
            data: (list) => SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final p = list[i];
                  return FilterChip(
                    label: Text('${p.name} ${p.productsCount}'),
                    selected: _producers.contains(p.id),
                    onSelected: (on) => setState(
                      () => on ? _producers.add(p.id) : _producers.remove(p.id),
                    ),
                  );
                },
              ),
            ),
            orElse: () => const SizedBox(height: 40),
          ),
          const SizedBox(height: 12),
          if (_search.isEmpty && _producers.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                l10n.pickMostStocked,
                style: TextStyle(fontSize: 12.5, color: DukaColors.muted),
              ),
            ),
          products.when(
            loading: () =>
                const SkeletonList(shrinkWrap: true, padding: EdgeInsets.zero),
            error: (e, _) => Text('$e'),
            data: (list) => list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Text(
                          l10n.pickNothing,
                          style: TextStyle(color: DukaColors.muted),
                        ),
                        TextButton(
                          onPressed: () => context.push(
                            '/product-requests/new',
                            extra: {'name': _search},
                          ),
                          child: Text(l10n.pickRequestIt),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      for (final p in list)
                        _ProductCard(
                          product: p,
                          lines: _lines,
                          onToggle: _toggle,
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.lines,
    required this.onToggle,
  });

  final PickProduct product;
  final Map<int, _Line> lines;
  final void Function(int variantId, bool on) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: product.imageUrl == null
                        ? ColoredBox(color: DukaColors.muted.withAlpha(30))
                        : CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        [
                          product.producer,
                          product.category,
                          if (product.agentsCount > 0)
                            l10n.pickStockedBy(product.agentsCount),
                        ].whereType<String>().join(' · '),
                        style: TextStyle(fontSize: 12, color: DukaColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final v in product.variants)
              v.stocked
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              v.name,
                              style: TextStyle(color: DukaColors.muted),
                            ),
                          ),
                          Text(
                            l10n.pickInStock,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          value: lines.containsKey(v.id),
                          title: Text(v.name),
                          onChanged: (on) => onToggle(v.id, on ?? false),
                        ),
                        if (lines[v.id] case final line?)
                          Padding(
                            padding: const EdgeInsets.only(left: 48, bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: line.price,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: l10n.pickPrice,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 90,
                                  child: TextField(
                                    controller: line.qty,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText: l10n.pickQty,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
          ],
        ),
      ),
    );
  }
}
