import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../../inventory/data/inventory_models.dart';
import '../../inventory/presentation/inventory_controller.dart';
import 'cart_controller.dart';

class PosScreen extends ConsumerStatefulWidget {
  const PosScreen({super.key});

  @override
  ConsumerState<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends ConsumerState<PosScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<InventoryItem> _results = [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
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

  void _addToCart(InventoryItem item) {
    ref.read(posCartControllerProvider.notifier).addItem(item);
    _searchController.clear();
    setState(() => _results = []);
    FocusScope.of(context).unfocus();
  }

  Future<void> _scan() async {
    final item = await context.push<InventoryItem>('/pos/scan');
    if (item != null)
      ref.read(posCartControllerProvider.notifier).addItem(item);
  }

  Future<void> _clearCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear cart?'),
        content: const Text('This removes every item from the current sale.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) ref.read(posCartControllerProvider.notifier).clear();
  }

  Future<void> _editLineDiscount(CartLine line) async {
    final result = await showDialog<(String?, double?)>(
      context: context,
      builder: (context) => _DiscountDialog(
        title: 'Discount on ${line.item.name}',
        initialType: line.discountType,
        initialValue: line.discountValue,
      ),
    );
    if (result == null) return;
    ref
        .read(posCartControllerProvider.notifier)
        .setLineDiscount(line.item.id, type: result.$1, value: result.$2);
  }

  Future<void> _editOverallDiscount(PosCartState cart) async {
    final result = await showDialog<(String?, double?)>(
      context: context,
      builder: (context) => _DiscountDialog(
        title: 'Discount on whole sale',
        initialType: cart.overallDiscountType,
        initialValue: cart.overallDiscountValue,
      ),
    );
    if (result == null) return;
    ref
        .read(posCartControllerProvider.notifier)
        .setOverallDiscount(type: result.$1, value: result.$2);
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(posCartControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New sale'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan barcode',
            onPressed: _scan,
          ),
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear cart',
              onPressed: _clearCart,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products to add',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          if (_results.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: DukaColors.line),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _results.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _results[index];
                  final outOfStock = item.quantityOnHand <= 0;
                  return ListTile(
                    dense: true,
                    title: Text(item.name),
                    subtitle: Text(
                      outOfStock
                          ? 'Out of stock'
                          : '${item.quantityOnHand.toStringAsFixed(0)} ${item.unit ?? ''} on hand',
                      style: outOfStock
                          ? const TextStyle(color: Colors.redAccent)
                          : null,
                    ),
                    trailing: item.unitPrice != null
                        ? Text(formatTzs(item.unitPrice!))
                        : null,
                    onTap: outOfStock ? null : () => _addToCart(item),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: cart.isEmpty
                ? const Center(
                    child: Text('Search or scan a product to start a sale.'),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.lines.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final line = cart.lines[index];
                      return _CartLineTile(
                        line: line,
                        onIncrement: () => ref
                            .read(posCartControllerProvider.notifier)
                            .setQuantity(line.item.id, line.quantity + 1),
                        onDecrement: () => ref
                            .read(posCartControllerProvider.notifier)
                            .setQuantity(line.item.id, line.quantity - 1),
                        onDiscount: () => _editLineDiscount(line),
                        onRemove: () => ref
                            .read(posCartControllerProvider.notifier)
                            .removeItem(line.item.id),
                      );
                    },
                  ),
          ),
          _SummaryPanel(
            cart: cart,
            onEditDiscount: () => _editOverallDiscount(cart),
          ),
        ],
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDiscount,
    required this.onRemove,
  });

  final CartLine line;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDiscount;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      formatTzs(line.unitPrice),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (line.discountAmount > 0) ...[
                      const SizedBox(width: 6),
                      Text(
                        '−${formatTzs(line.discountAmount)}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                TextButton.icon(
                  onPressed: onDiscount,
                  icon: const Icon(Icons.percent, size: 14),
                  label: Text(
                    line.discountType == null ? 'Discount' : 'Edit discount',
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 28),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    visualDensity: VisualDensity.compact,
                    onPressed: onDecrement,
                  ),
                  Text(
                    line.quantity.toStringAsFixed(
                      line.quantity.truncateToDouble() == line.quantity ? 0 : 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    visualDensity: VisualDensity.compact,
                    onPressed: onIncrement,
                  ),
                ],
              ),
              Text(
                formatTzs(line.subtotal),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 24),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text(
                  'Remove',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends ConsumerWidget {
  const _SummaryPanel({required this.cart, required this.onEditDiscount});

  final PosCartState cart;
  final VoidCallback onEditDiscount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryRow('Subtotal', formatTzs(cart.subtotal)),
            InkWell(
              onTap: onEditDiscount,
              child: _SummaryRow(
                cart.overallDiscountType == null ? 'Add discount' : 'Discount',
                cart.overallDiscountAmount > 0
                    ? '−${formatTzs(cart.overallDiscountAmount)}'
                    : '—',
                trailing: const Icon(Icons.chevron_right, size: 18),
              ),
            ),
            const Divider(height: 16),
            _SummaryRow('Total', formatTzs(cart.total), bold: true),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: cart.isEmpty
                    ? null
                    : () => context.push('/pos/checkout'),
                child: Text(
                  cart.isEmpty
                      ? 'Add items to charge'
                      : 'Charge · ${formatTzs(cart.total)}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.bold = false, this.trailing});

  final String label;
  final String value;
  final bool bold;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      fontSize: bold ? 17 : 14.5,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: style.copyWith(
              color: bold
                  ? null
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              Text(value, style: style),
              ?trailing,
            ],
          ),
        ],
      ),
    );
  }
}

class _DiscountDialog extends StatefulWidget {
  const _DiscountDialog({
    required this.title,
    this.initialType,
    this.initialValue,
  });

  final String title;
  final String? initialType;
  final double? initialValue;

  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  late String _type = widget.initialType ?? 'percent';
  late final _controller = TextEditingController(
    text: widget.initialValue?.toStringAsFixed(0) ?? '',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'percent', label: Text('Percent')),
              ButtonSegment(value: 'fixed', label: Text('Fixed (TZS)')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: _type == 'percent' ? 'Percent off' : 'Amount off',
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        if (widget.initialType != null)
          TextButton(
            onPressed: () => Navigator.pop(context, (null, null)),
            child: const Text('Remove'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(_controller.text);
            if (value == null || value <= 0) return;
            Navigator.pop(context, (_type, value));
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
