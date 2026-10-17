import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../data/inventory_models.dart';
import 'inventory_controller.dart';

/// Products with a barcode, fetched in one page — a typical shop's catalog
/// is small enough that this is simpler than teaching this one screen to
/// paginate just for a label sheet.
final _barcodeItemsProvider = FutureProvider.autoDispose<List<InventoryItem>>((
  ref,
) async {
  final page = await ref.watch(inventoryRepositoryProvider).list(perPage: 500);
  return page.items.where((item) => item.barcode != null).toList();
});

class BarcodeLabelsScreen extends ConsumerStatefulWidget {
  const BarcodeLabelsScreen({super.key});

  @override
  ConsumerState<BarcodeLabelsScreen> createState() =>
      _BarcodeLabelsScreenState();
}

class _BarcodeLabelsScreenState extends ConsumerState<BarcodeLabelsScreen> {
  final Set<int> _selected = {};
  bool _showProductName = true;
  bool _showPrice = true;
  int _copies = 1;
  bool _busy = false;
  bool _initialized = false;

  void _selectAll(List<InventoryItem> items) =>
      setState(() => _selected.addAll(items.map((i) => i.id)));
  void _selectNone() => setState(_selected.clear);

  Future<void> _share() async {
    if (_selected.isEmpty) return;
    setState(() => _busy = true);
    try {
      final path = await ref
          .read(inventoryRepositoryProvider)
          .downloadBarcodeLabelsPdf(
            itemIds: _selected.toList(),
            showProductName: _showProductName,
            showPrice: _showPrice,
            copies: _copies,
          );
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(path)],
          fileNameOverrides: ['barcode-labels.pdf'],
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(_barcodeItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Barcode labels')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load products.\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (items) {
          if (!_initialized) {
            _initialized = true;
            _selected.addAll(items.map((i) => i.id));
          }
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "No products have a barcode yet. Open a product and generate one first.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: DukaColors.muted),
                ),
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          dense: true,
                          title: const Text('Show product name'),
                          value: _showProductName,
                          onChanged: (v) =>
                              setState(() => _showProductName = v),
                        ),
                        SwitchListTile(
                          dense: true,
                          title: const Text('Show price'),
                          value: _showPrice,
                          onChanged: (v) => setState(() => _showPrice = v),
                        ),
                        ListTile(
                          dense: true,
                          title: const Text('Copies per label'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: _copies > 1
                                    ? () => setState(() => _copies--)
                                    : null,
                              ),
                              Text(
                                '$_copies',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: _copies < 20
                                    ? () => setState(() => _copies++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selected.length} of ${items.length} selected',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => _selectAll(items),
                          child: const Text('Select all'),
                        ),
                        TextButton(
                          onPressed: _selectNone,
                          child: const Text('Select none'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return CheckboxListTile(
                      value: _selected.contains(item.id),
                      onChanged: (checked) => setState(() {
                        if (checked ?? false) {
                          _selected.add(item.id);
                        } else {
                          _selected.remove(item.id);
                        }
                      }),
                      title: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        [
                          item.barcode!,
                          if (item.unitPrice != null)
                            formatTzs(item.unitPrice!),
                        ].join(' · '),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: _busy || _selected.isEmpty ? null : _share,
                  icon: _busy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.ios_share),
                  label: Text(
                    _busy
                        ? 'Preparing PDF…'
                        : 'Share ${_selected.length} label${_selected.length == 1 ? '' : 's'}',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
