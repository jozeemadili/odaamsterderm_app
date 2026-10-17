import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../catalog/presentation/catalog_picker_sheet.dart';
import '../data/inventory_models.dart';
import 'inventory_controller.dart';

final inventoryItemProvider = FutureProvider.autoDispose
    .family<InventoryItem, int>(
      (ref, id) => ref.watch(inventoryRepositoryProvider).get(id),
    );

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _busy = false;

  void _refresh(InventoryItem item) {
    ref.invalidate(inventoryItemProvider(widget.id));
    ref.read(inventoryListControllerProvider.notifier).upsert(item);
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(inventoryRepositoryProvider)
          .uploadImage(widget.id, File(picked.path));
      _refresh(updated);
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

  Future<void> _generateBarcode() async {
    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(inventoryRepositoryProvider)
          .generateBarcode(widget.id);
      _refresh(updated);
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

  Future<void> _adjustStock() async {
    final result = await showDialog<(String, double, String)>(
      context: context,
      builder: (context) => const _StockMovementDialog(),
    );
    if (result == null) return;

    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(inventoryRepositoryProvider)
          .stockMovement(
            widget.id,
            type: result.$1,
            quantity: result.$2,
            reason: result.$3,
          );
      _refresh(updated);
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

  Future<void> _run(Future<InventoryItem> Function() action) async {
    setState(() => _busy = true);
    try {
      _refresh(await action());
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

  Future<void> _linkCatalogProduct(InventoryItem item) async {
    final product = await showCatalogPicker(
      context,
      initialSearch: item.product == null ? item.name : '',
    );
    if (product == null) return;
    await _run(
      () => ref
          .read(inventoryRepositoryProvider)
          .linkCatalogProduct(widget.id, product.id),
    );
  }

  Future<void> _editMarketplace(InventoryItem item) async {
    final result = await showModalBottomSheet<(bool, double, bool)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MarketplaceSheet(item: item),
    );
    if (result == null) return;
    await _run(
      () => ref
          .read(inventoryRepositoryProvider)
          .updateMarketplace(
            widget.id,
            visible: result.$1,
            quantity: result.$2,
            active: result.$3,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(inventoryItemProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [
          itemAsync.maybeWhen(
            data: (item) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final updated = await context.push<InventoryItem>(
                  '/inventory/${item.id}/edit',
                  extra: item,
                );
                if (updated != null) _refresh(updated);
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: itemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Could not load this product.\n$e',
            textAlign: TextAlign.center,
          ),
        ),
        data: (item) => AbsorbPointer(
          absorbing: _busy,
          child: Opacity(
            opacity: _busy ? 0.6 : 1,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: item.imageUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: item.imageUrl!,
                                  width: 160,
                                  height: 160,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, _, _) => Container(
                                    width: 160,
                                    height: 160,
                                    color: DukaColors.bg,
                                    child: const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 48,
                                      color: DukaColors.muted,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 160,
                                  height: 160,
                                  color: DukaColors.bg,
                                  child: const Icon(
                                    Icons.inventory_2_outlined,
                                    size: 48,
                                    color: DukaColors.muted,
                                  ),
                                ),
                        ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: CircleAvatar(
                            radius: 16,
                            child: const Icon(Icons.camera_alt, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  children: [
                    if (item.branch != null)
                      _Chip(label: item.branch!.name, color: DukaColors.indigo),
                    if (item.isLowStock)
                      const _Chip(label: 'Low stock', color: Colors.redAccent),
                    if (item.isExpired)
                      const _Chip(label: 'Expired', color: Colors.redAccent),
                    if (item.isExpiringSoon && !item.isExpired)
                      const _Chip(label: 'Expiring soon', color: Colors.orange),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _Row('SKU', item.sku ?? '—'),
                        _Row('Barcode', item.barcode ?? '—'),
                        _Row('Category', item.category?.name ?? '—'),
                        _Row('Store', item.branch?.name ?? 'Not assigned'),
                        _Row('Unit', item.unit ?? '—'),
                        _Row(
                          'On hand',
                          '${item.quantityOnHand.toStringAsFixed(0)} ${item.unit ?? ''}',
                        ),
                        _Row(
                          'Reorder level',
                          item.reorderLevel.toStringAsFixed(0),
                        ),
                        _Row(
                          'Unit cost',
                          item.unitCost != null
                              ? formatTzs(item.unitCost!)
                              : '—',
                        ),
                        _Row(
                          'Selling price',
                          item.unitPrice != null
                              ? formatTzs(item.unitPrice!)
                              : '—',
                        ),
                        _Row('Expiry date', _formatExpiry(item.expiryDate)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _MarketplaceCard(
                  item: item,
                  onLink: () => _linkCatalogProduct(item),
                  onEdit: () => _editMarketplace(item),
                ),
                const SizedBox(height: 20),
                if (item.barcode == null)
                  OutlinedButton.icon(
                    onPressed: _generateBarcode,
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Generate barcode'),
                  ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _adjustStock,
                  icon: const Icon(Icons.swap_vert),
                  label: const Text('Adjust stock'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/inventory/new',
                    extra: {'duplicateFrom': item},
                  ),
                  icon: const Icon(Icons.storefront_outlined),
                  label: const Text('Stock at another store'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatExpiry(String? raw) {
  if (raw == null) return '—';
  final date = DateTime.tryParse(raw);
  if (date == null) return raw;

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final expiryDate = DateTime(date.year, date.month, date.day);
  final days = expiryDate.difference(todayDate).inDays;

  final String relative;
  if (days == 0) {
    relative = 'today';
  } else if (days == 1) {
    relative = 'tomorrow';
  } else if (days == -1) {
    relative = 'yesterday';
  } else if (days > 0) {
    relative = 'in $days days';
  } else {
    relative = '${-days} days ago';
  }

  return '${DateFormat.yMMMd().format(date)} · $relative';
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MarketplaceCard extends StatelessWidget {
  const _MarketplaceCard({
    required this.item,
    required this.onLink,
    required this.onEdit,
  });

  final InventoryItem item;
  final VoidCallback onLink;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final m = item.marketplace;
    final blockers = m.blockers ?? const <String>[];
    final statusColor = !m.isVisible
        ? DukaColors.muted
        : m.status == 'active'
        ? Colors.green
        : m.status == 'out_of_stock'
        ? DukaColors.rose
        : DukaColors.muted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Marketplace',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                _Chip(
                  label: m.isVisible ? m.statusLabel : 'Hidden',
                  color: statusColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              leading: const Icon(Icons.link),
              title: Text(
                item.product?.displayName ?? 'Not linked to the catalog',
              ),
              subtitle: item.product != null
                  ? Text(
                      [
                        item.product!.animalTypeName,
                        item.product!.categoryName,
                        if (item.product!.isPending) 'pending approval',
                      ].whereType<String>().join(' · '),
                    )
                  : const Text('Needed to sell on the marketplace'),
              trailing: TextButton(
                onPressed: onLink,
                child: Text(item.product == null ? 'Link' : 'Change'),
              ),
            ),
            _Row(
              'Actual stock',
              '${_fmt(item.quantityOnHand)} ${item.unit ?? ''}',
            ),
            _Row('Reserved for orders', _fmt(m.reservedQuantity)),
            _Row('Marketplace quantity', _fmt(m.quantity)),
            for (final b in blockers)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        b,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.storefront),
                label: const Text('Marketplace settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// Visible / quantity / active editor. Pops (visible, quantity, active).
class _MarketplaceSheet extends StatefulWidget {
  const _MarketplaceSheet({required this.item});

  final InventoryItem item;

  @override
  State<_MarketplaceSheet> createState() => _MarketplaceSheetState();
}

class _MarketplaceSheetState extends State<_MarketplaceSheet> {
  late bool _visible =
      widget.item.marketplace.isVisible ||
      (widget.item.marketplace.blockers?.isEmpty ?? false);
  late bool _active = widget.item.marketplace.status != 'inactive';
  late final _quantity = TextEditingController(
    text: _fmt(widget.item.marketplace.quantity),
  );

  @override
  void dispose() {
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final available = widget.item.marketplace.availableQuantity;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Marketplace settings',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Customers see the marketplace quantity. You can expose up to ${_fmt(available)} ${widget.item.unit ?? ''}.',
            style: const TextStyle(fontSize: 12.5, color: DukaColors.muted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantity,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Marketplace quantity',
              suffixIcon: TextButton(
                onPressed: () => _quantity.text = _fmt(available),
                child: const Text('All'),
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _visible,
            onChanged: (v) => setState(() => _visible = v),
            title: const Text('Visible on marketplace'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _active,
            onChanged: (v) => setState(() => _active = v),
            title: const Text('Active'),
            subtitle: const Text(
              'Inactive keeps the listing hidden until you reactivate it.',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              final qty = double.tryParse(_quantity.text.trim());
              if (qty == null || qty < 0) return;
              Navigator.pop(context, (_visible, qty, _active));
            },
            child: const Text('Save'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StockMovementDialog extends StatefulWidget {
  const _StockMovementDialog();

  @override
  State<_StockMovementDialog> createState() => _StockMovementDialogState();
}

class _StockMovementDialogState extends State<_StockMovementDialog> {
  String _type = 'in';
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adjust stock'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'in', label: Text('Stock in')),
              ButtonSegment(value: 'out', label: Text('Stock out')),
              ButtonSegment(value: 'adjustment', label: Text('Adjustment')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _type == 'adjustment'
                  ? 'Counted quantity'
                  : 'Quantity',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: _type == 'adjustment'
                  ? 'Reason (required)'
                  : 'Note (optional)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final qty = double.tryParse(_quantityController.text);
            final reason = _reasonController.text.trim();
            final isAdjustment = _type == 'adjustment';
            // An adjustment sets the counted level (may be 0) and needs a reason.
            if (qty == null || qty < 0 || (!isAdjustment && qty == 0)) return;
            if (isAdjustment && reason.isEmpty) return;
            Navigator.pop(context, (_type, qty, reason));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
