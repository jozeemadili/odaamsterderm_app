import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../l10n/l10n_extension.dart';
import '../data/catalog_models.dart';
import 'catalog_controller.dart';

/// Browse the shared catalog, see your proposals, propose new products.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key, this.openProposeForm = false});

  final bool openProposeForm;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _search = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.openProposeForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _propose());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _propose() async {
    final proposed = await showModalBottomSheet<CatalogProduct>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _ProposeSheet(),
    );
    if (proposed != null && mounted) {
      ref.invalidate(catalogProposalsProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.catalogProposed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final products = ref.watch(catalogSearchProvider(_search));
    final proposals = ref.watch(catalogProposalsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _propose,
        icon: const Icon(Icons.add),
        label: Text(l10n.catalogPropose),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Text(
            l10n.catalogSubtitle,
            style: const TextStyle(fontSize: 13, color: DukaColors.muted),
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
          ...proposals.maybeWhen(
            data: (list) => list.isEmpty
                ? const <Widget>[]
                : [
                    Text(
                      l10n.catalogProposals,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Card(
                      child: Column(
                        children: [
                          for (final p in list)
                            ListTile(
                              title: Text(p.displayName),
                              subtitle: p.reviewNotes != null
                                  ? Text(
                                      p.reviewNotes!,
                                      style: const TextStyle(
                                        color: DukaColors.rose,
                                      ),
                                    )
                                  : null,
                              trailing: Text(
                                p.isPending
                                    ? l10n.catalogPending
                                    : l10n.catalogRejected,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: p.isPending
                                      ? Colors.orange
                                      : DukaColors.rose,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
            orElse: () => const <Widget>[],
          ),
          products.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('$e'),
            data: (list) => list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.catalogNoMatches,
                      style: const TextStyle(color: DukaColors.muted),
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
                                p.brand,
                              ].whereType<String>().join(' · '),
                            ),
                            trailing: Text(
                              p.unit,
                              style: const TextStyle(
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

class _ProposeSheet extends ConsumerStatefulWidget {
  const _ProposeSheet();

  @override
  ConsumerState<_ProposeSheet> createState() => _ProposeSheetState();
}

class _ProposeSheetState extends ConsumerState<_ProposeSheet> {
  final _name = TextEditingController();
  final _pack = TextEditingController();
  final _brand = TextEditingController();
  final _description = TextEditingController();
  String _unit = 'bag';
  int? _animalTypeId;
  int? _categoryId;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _pack, _brand, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _text(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty ||
        _animalTypeId == null ||
        _categoryId == null) {
      return;
    }
    setState(() => _saving = true);
    try {
      final product = await ref
          .read(catalogRepositoryProvider)
          .propose(
            name: _name.text.trim(),
            packSize: _text(_pack),
            unit: _unit,
            brand: _text(_brand),
            animalTypeId: _animalTypeId!,
            categoryId: _categoryId!,
            description: _text(_description),
          );
      if (mounted) Navigator.pop(context, product);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Flattens a one-level tree into dropdown items, children indented.
  List<DropdownMenuItem<int>> _treeItems(List<CatalogNode> nodes) => [
    for (final n in nodes) ...[
      DropdownMenuItem(value: n.id, child: Text(n.name)),
      for (final c in n.children)
        DropdownMenuItem(value: c.id, child: Text('   ↳ ${c.name}')),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final animals = ref.watch(animalTypesProvider);
    final categories = _animalTypeId == null
        ? null
        : ref.watch(catalogCategoriesProvider(_animalTypeId!));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.catalogPropose,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.catalogNameLabel),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pack,
                    decoration: InputDecoration(
                      labelText: l10n.catalogPackSizeLabel,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: InputDecoration(
                      labelText: l10n.catalogUnitLabel,
                    ),
                    items: [
                      for (final u in catalogUnits)
                        DropdownMenuItem(value: u, child: Text(u)),
                    ],
                    onChanged: (v) => setState(() => _unit = v ?? _unit),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            animals.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (nodes) => DropdownButtonFormField<int>(
                initialValue: _animalTypeId,
                decoration: InputDecoration(labelText: l10n.catalogAnimalLabel),
                items: _treeItems(nodes),
                onChanged: (v) => setState(() {
                  _animalTypeId = v;
                  _categoryId = null;
                }),
              ),
            ),
            const SizedBox(height: 12),
            if (categories != null)
              categories.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('$e'),
                data: (nodes) => DropdownButtonFormField<int>(
                  key: ValueKey(_animalTypeId),
                  initialValue: _categoryId,
                  decoration: InputDecoration(
                    labelText: l10n.catalogCategoryLabel,
                  ),
                  items: _treeItems(nodes),
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _brand,
              decoration: InputDecoration(labelText: l10n.catalogBrandLabel),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.catalogDescriptionLabel,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: Text(l10n.catalogSubmit),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
