import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../inventory/data/inventory_models.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../data/stock_receipt_models.dart';
import 'stock_receipt_controller.dart';

class StockReceiptDetailScreen extends ConsumerStatefulWidget {
  const StockReceiptDetailScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<StockReceiptDetailScreen> createState() =>
      _StockReceiptDetailScreenState();
}

class _StockReceiptDetailScreenState
    extends ConsumerState<StockReceiptDetailScreen> {
  bool _busy = false;

  void _refresh(StockReceipt receipt) {
    ref.invalidate(stockReceiptDetailProvider(widget.id));
    ref.read(stockReceiptListControllerProvider.notifier).upsert(receipt);
  }

  Future<void> _run(Future<StockReceipt> Function() action) async {
    setState(() => _busy = true);
    try {
      final receipt = await action();
      _refresh(receipt);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addItem() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          _AddItemSheet(receiptId: widget.id, onAdded: _refresh),
    );
  }

  Future<void> _removeItem(int itemId) async {
    await _run(() =>
        ref.read(stockReceiptRepositoryProvider).removeItem(widget.id, itemId));
  }

  Future<void> _approve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve this receipt?'),
        content: const Text(
            'This adds every line item to stock and can\'t be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Approve')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(
        () => ref.read(stockReceiptRepositoryProvider).approve(widget.id));
  }

  Future<void> _reject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject this receipt?'),
        content: const Text(
            'This marks the receipt rejected — stock is left untouched and it can no longer be edited.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep it')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reject')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(
        () => ref.read(stockReceiptRepositoryProvider).reject(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final receiptAsync = ref.watch(stockReceiptDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Stock receipt')),
      body: receiptAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Could not load this receipt.\n$e',
                textAlign: TextAlign.center)),
        data: (receipt) => AbsorbPointer(
          absorbing: _busy,
          child: Opacity(
            opacity: _busy ? 0.6 : 1,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(receipt.referenceNo ?? 'Receipt #${receipt.id}',
                        style: Theme.of(context).textTheme.headlineSmall),
                    _StatusChip(
                        status: receipt.status, label: receipt.statusLabel),
                  ],
                ),
                const SizedBox(height: 4),
                Text(receipt.supplier?.name ?? 'No supplier',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  DateFormat.yMMMd()
                      .format(DateTime.parse(receipt.receiptDate)),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                if (receipt.notes != null && receipt.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(receipt.notes!),
                ],
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Items',
                                style: Theme.of(context).textTheme.titleMedium),
                            if (receipt.isPending)
                              TextButton.icon(
                                  onPressed: _addItem,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add')),
                          ],
                        ),
                        if (receipt.items.isEmpty)
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('No items yet.')),
                        for (final line in receipt.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${line.productName ?? 'Product'} × ${line.quantity.toStringAsFixed(line.quantity.truncateToDouble() == line.quantity ? 0 : 2)}',
                                  ),
                                ),
                                Text(formatTzs(line.subtotal)),
                                if (receipt.isPending)
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 18),
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => _removeItem(line.id),
                                  ),
                              ],
                            ),
                          ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            Text(formatTzs(receipt.totalAmount),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (receipt.isPending) ...[
                  FilledButton(
                      onPressed: _approve, child: const Text('Approve')),
                  const SizedBox(height: 8),
                  OutlinedButton(
                      onPressed: _reject, child: const Text('Reject')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.label});

  final String status;
  final String label;

  Color get _color => switch (status) {
        'pending' => Colors.blueGrey,
        'approved' => Colors.green,
        'rejected' => Colors.redAccent,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(color: _color, fontWeight: FontWeight.w600)),
    );
  }
}

class _AddItemSheet extends ConsumerStatefulWidget {
  const _AddItemSheet({required this.receiptId, required this.onAdded});

  final int receiptId;
  final ValueChanged<StockReceipt> onAdded;

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
  bool _newProduct = false;

  // Existing-product path.
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<InventoryItem> _results = [];
  bool _searching = false;
  InventoryItem? _selected;

  // New-product path.
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _sellingPriceController = TextEditingController();

  final _quantityController = TextEditingController(text: '1');
  final _unitCostController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _nameController.dispose();
    _unitController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _unitCostController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _searching = true);
      try {
        final page = await ref
            .read(inventoryRepositoryProvider)
            .list(search: value.trim(), page: 1);
        if (mounted) setState(() => _results = page.items.take(8).toList());
      } catch (_) {
        if (mounted) setState(() => _results = []);
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  void _select(InventoryItem item) {
    setState(() {
      _selected = item;
      _unitCostController.text = item.unitCost?.toStringAsFixed(0) ?? '';
      _results = [];
      _searchController.clear();
    });
  }

  Future<void> _submit() async {
    final quantity = double.tryParse(_quantityController.text);
    final unitCost = double.tryParse(_unitCostController.text);
    if (quantity == null || quantity <= 0 || unitCost == null || unitCost < 0) {
      setState(() => _error = 'Enter a valid quantity and unit cost.');
      return;
    }
    if (!_newProduct && _selected == null) {
      setState(() => _error = 'Pick a product first.');
      return;
    }
    if (_newProduct && _nameController.text.trim().isEmpty) {
      setState(() => _error = 'Enter a product name.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final receipt = await ref.read(stockReceiptRepositoryProvider).addItem(
            widget.receiptId,
            inventoryItemId: _newProduct ? null : _selected!.id,
            newProductName: _newProduct ? _nameController.text.trim() : null,
            newProductUnit:
                _newProduct && _unitController.text.trim().isNotEmpty
                    ? _unitController.text.trim()
                    : null,
            newProductUnitPrice: _newProduct
                ? double.tryParse(_sellingPriceController.text)
                : null,
            quantity: quantity,
            unitCost: unitCost,
          );
      widget.onAdded(receipt);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add item', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Existing product')),
                  ButtonSegment(value: true, label: Text('New product')),
                ],
                selected: {_newProduct},
                onSelectionChanged: (s) => setState(() {
                  _newProduct = s.first;
                  _selected = null;
                  _error = null;
                }),
              ),
              const SizedBox(height: 12),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              if (_newProduct) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product name'),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                            labelText: 'Unit (optional)',
                            hintText: 'pcs, kg...'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _sellingPriceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Selling price (optional)'),
                      ),
                    ),
                  ],
                ),
              ] else if (_selected == null) ...[
                TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search products',
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
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 260),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _results.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = _results[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                            '${item.quantityOnHand.toStringAsFixed(0)} ${item.unit ?? ''} on hand'),
                        onTap: () => _select(item),
                      );
                    },
                  ),
                ),
              ] else
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_selected!.name),
                  trailing: TextButton(
                      onPressed: () => setState(() => _selected = null),
                      child: const Text('Change')),
                ),
              if (_newProduct || _selected != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quantityController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Quantity'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _unitCostController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Unit cost'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Add to receipt'),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
