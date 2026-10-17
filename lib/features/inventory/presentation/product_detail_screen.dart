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
import '../data/inventory_models.dart';
import 'inventory_controller.dart';

final inventoryItemProvider =
    FutureProvider.autoDispose.family<InventoryItem, int>(
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

    final picked = await ImagePicker()
        .pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (picked == null) return;

    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(inventoryRepositoryProvider)
          .uploadImage(widget.id, File(picked.path));
      _refresh(updated);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _adjustStock() async {
    final result = await showDialog<(String, double)>(
      context: context,
      builder: (context) => const _StockMovementDialog(),
    );
    if (result == null) return;

    setState(() => _busy = true);
    try {
      final updated = await ref
          .read(inventoryRepositoryProvider)
          .stockMovement(widget.id, type: result.$1, quantity: result.$2);
      _refresh(updated);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
                    extra: item);
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
            child: Text('Could not load this product.\n$e',
                textAlign: TextAlign.center)),
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
                                            color: DukaColors.muted),
                                      ))
                              : Container(
                                  width: 160,
                                  height: 160,
                                  color: DukaColors.bg,
                                  child: const Icon(Icons.inventory_2_outlined,
                                      size: 48, color: DukaColors.muted),
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
                Text(item.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center),
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
                        _Row('On hand',
                            '${item.quantityOnHand.toStringAsFixed(0)} ${item.unit ?? ''}'),
                        _Row('Reorder level',
                            item.reorderLevel.toStringAsFixed(0)),
                        _Row(
                            'Unit cost',
                            item.unitCost != null
                                ? formatTzs(item.unitCost!)
                                : '—'),
                        _Row(
                            'Selling price',
                            item.unitPrice != null
                                ? formatTzs(item.unitPrice!)
                                : '—'),
                        _Row('Expiry date', _formatExpiry(item.expiryDate)),
                      ],
                    ),
                  ),
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
                  onPressed: () => context
                      .push('/inventory/new', extra: {'duplicateFrom': item}),
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
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
          borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600)),
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

  @override
  void dispose() {
    _quantityController.dispose();
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
            decoration: const InputDecoration(labelText: 'Quantity'),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final qty = double.tryParse(_quantityController.text);
            if (qty == null || qty <= 0) return;
            Navigator.pop(context, (_type, qty));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
