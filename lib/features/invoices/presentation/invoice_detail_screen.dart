import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../inventory/data/inventory_models.dart';
import '../../inventory/presentation/inventory_controller.dart';
import '../../pos/presentation/cart_controller.dart';
import '../data/invoice_models.dart';
import 'invoice_controller.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  const InvoiceDetailScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  bool _busy = false;

  void _refresh(Invoice invoice) {
    ref.invalidate(invoiceDetailProvider(widget.id));
    ref.read(invoiceListControllerProvider.notifier).upsert(invoice);
  }

  Future<void> _run(Future<Invoice> Function() action) async {
    setState(() => _busy = true);
    try {
      final invoice = await action();
      _refresh(invoice);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addItem() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _AddItemSheet(invoiceId: widget.id, onAdded: _refresh),
    );
  }

  Future<void> _removeItem(int itemId) async {
    await _run(() => ref.read(invoiceRepositoryProvider).removeItem(widget.id, itemId));
  }

  Future<void> _editDiscount(Invoice invoice) async {
    final result = await showDialog<(String?, double?)>(
      context: context,
      builder: (context) => const _DiscountDialog(),
    );
    if (result == null) return;
    await _run(() => ref.read(invoiceRepositoryProvider).setDiscount(widget.id, type: result.$1, value: result.$2));
  }

  Future<void> _approve() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve this proforma?'),
        content: const Text('This locks the invoice, decrements stock for every line item, and can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Approve')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() => ref.read(invoiceRepositoryProvider).approve(widget.id));
  }

  Future<void> _cancelInvoice() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this proforma?'),
        content: const Text('This proforma will be marked cancelled and can no longer be edited or approved.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep it')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel proforma')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() => ref.read(invoiceRepositoryProvider).cancel(widget.id));
  }

  Future<void> _recordPayment(Invoice invoice) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RecordPaymentSheet(invoice: invoice),
    );
    if (result == true) {
      ref.invalidate(invoiceDetailProvider(widget.id));
    }
  }

  Future<void> _sharePdf(Invoice invoice) async {
    setState(() => _busy = true);
    try {
      final filename = '${invoice.isDraft ? 'proforma' : 'invoice'}-${invoice.number}.pdf';
      final path = await ref.read(invoiceRepositoryProvider).downloadPdf(widget.id, filename);
      await SharePlus.instance.share(ShareParams(files: [XFile(path)], fileNameOverrides: [filename]));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceAsync = ref.watch(invoiceDetailProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        actions: [
          invoiceAsync.maybeWhen(
            data: (invoice) => IconButton(
              icon: const Icon(Icons.ios_share),
              tooltip: 'Share PDF',
              onPressed: _busy ? null : () => _sharePdf(invoice),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: invoiceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load this invoice.\n$e', textAlign: TextAlign.center)),
        data: (invoice) => AbsorbPointer(
          absorbing: _busy,
          child: Opacity(
            opacity: _busy ? 0.6 : 1,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(invoice.number, style: Theme.of(context).textTheme.headlineSmall),
                    _StatusChip(status: invoice.status, label: invoice.statusLabel),
                  ],
                ),
                const SizedBox(height: 4),
                Text(invoice.customer?.name ?? 'No customer', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Issued ${DateFormat.yMMMd().format(DateTime.parse(invoice.issueDate))}'
                  '${invoice.dueDate != null ? ' · Due ${DateFormat.yMMMd().format(DateTime.parse(invoice.dueDate!))}' : ''}',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                if (invoice.notes != null && invoice.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(invoice.notes!),
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
                            Text('Items', style: Theme.of(context).textTheme.titleMedium),
                            if (invoice.isDraft)
                              TextButton.icon(onPressed: _addItem, icon: const Icon(Icons.add), label: const Text('Add')),
                          ],
                        ),
                        if (invoice.items.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('No items yet.')),
                        for (final line in invoice.items) _LineItemRow(line: line, editable: invoice.isDraft, onRemove: () => _removeItem(line.id)),
                        const Divider(height: 24),
                        _totalsRow('Subtotal', invoice.subtotal),
                        InkWell(
                          onTap: invoice.isDraft ? () => _editDiscount(invoice) : null,
                          child: _totalsRow(
                            'Discount',
                            invoice.discountAmount,
                            negative: true,
                            trailing: invoice.isDraft ? const Icon(Icons.chevron_right, size: 18) : null,
                          ),
                        ),
                        _totalsRow('Total', invoice.total, bold: true),
                        if (!invoice.isDraft) ...[
                          _totalsRow('Paid', invoice.amountPaid),
                          _totalsRow('Balance due', invoice.balanceDue, bold: true),
                        ],
                      ],
                    ),
                  ),
                ),
                if (invoice.payments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Payments', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          for (final p in invoice.payments)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${DateFormat.yMMMd().format(DateTime.parse(p.paymentDate))}'
                                      '${p.paymentMethod != null ? ' · ${p.paymentMethod}' : ''}'),
                                  Text(formatTzs(p.amount)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (invoice.isDraft) ...[
                  FilledButton(onPressed: _approve, child: const Text('Approve')),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: _cancelInvoice, child: const Text('Cancel proforma')),
                ] else if (!invoice.isCancelled && invoice.balanceDue > 0)
                  FilledButton(onPressed: () => _recordPayment(invoice), child: const Text('Record payment')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalsRow(String label, double value, {bool bold = false, bool negative = false, Widget? trailing}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
    final text = negative && value > 0 ? '−${formatTzs(value)}' : formatTzs(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Row(children: [Text(text, style: style), ?trailing]),
        ],
      ),
    );
  }
}

class _LineItemRow extends StatelessWidget {
  const _LineItemRow({required this.line, required this.editable, required this.onRemove});

  final InvoiceLineItem line;
  final bool editable;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text('${line.itemName} × ${line.quantity.toStringAsFixed(line.quantity.truncateToDouble() == line.quantity ? 0 : 2)}'),
          ),
          Text(formatTzs(line.subtotal)),
          if (editable)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              visualDensity: VisualDensity.compact,
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.label});

  final String status;
  final String label;

  Color get _color => switch (status) {
        'draft' => Colors.blueGrey,
        'invoiced' => Colors.orange,
        'partially_paid' => Colors.amber.shade800,
        'paid' => Colors.green,
        'cancelled' => Colors.redAccent,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: _color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: _color, fontWeight: FontWeight.w600)),
    );
  }
}

class _AddItemSheet extends ConsumerStatefulWidget {
  const _AddItemSheet({required this.invoiceId, required this.onAdded});

  final int invoiceId;
  final ValueChanged<Invoice> onAdded;

  @override
  ConsumerState<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends ConsumerState<_AddItemSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<InventoryItem> _results = [];
  bool _searching = false;
  InventoryItem? _selected;

  final _quantityController = TextEditingController(text: '1');
  final _unitPriceController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
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
        final page = await ref.read(inventoryRepositoryProvider).list(search: value.trim(), page: 1);
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
      _unitPriceController.text = item.unitPrice?.toStringAsFixed(0) ?? '0';
      _results = [];
      _searchController.clear();
    });
  }

  Future<void> _submit() async {
    final item = _selected;
    if (item == null) return;
    final quantity = double.tryParse(_quantityController.text);
    final unitPrice = double.tryParse(_unitPriceController.text);
    if (quantity == null || quantity <= 0 || unitPrice == null || unitPrice < 0) {
      setState(() => _error = 'Enter a valid quantity and price.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final invoice = await ref.read(invoiceRepositoryProvider).addItem(
            widget.invoiceId,
            inventoryItemId: item.id,
            quantity: quantity,
            unitPrice: unitPrice,
          );
      widget.onAdded(invoice);
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
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add item', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (_selected == null) ...[
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
                          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
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
                      subtitle: Text('${item.quantityOnHand.toStringAsFixed(0)} ${item.unit ?? ''} on hand'),
                      trailing: item.unitPrice != null ? Text(formatTzs(item.unitPrice!)) : null,
                      onTap: () => _select(item),
                    );
                  },
                ),
              ),
            ] else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selected!.name),
                trailing: TextButton(onPressed: () => setState(() => _selected = null), child: const Text('Change')),
              ),
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Quantity'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _unitPriceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Unit price'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Add to invoice'),
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

class _DiscountDialog extends StatefulWidget {
  const _DiscountDialog();

  @override
  State<_DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<_DiscountDialog> {
  String _type = 'percent';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Discount on whole invoice'),
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
            decoration: InputDecoration(labelText: _type == 'percent' ? 'Percent off' : 'Amount off'),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, (null, null)), child: const Text('Remove')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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

class _RecordPaymentSheet extends ConsumerStatefulWidget {
  const _RecordPaymentSheet({required this.invoice});

  final Invoice invoice;

  @override
  ConsumerState<_RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<_RecordPaymentSheet> {
  late final _amountController = TextEditingController(text: widget.invoice.balanceDue.toStringAsFixed(0));
  final _referenceController = TextEditingController();
  int? _paymentMethodId;
  DateTime _paymentDate = DateTime.now();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(invoiceRepositoryProvider).recordPayment(
            widget.invoice.id,
            amount: amount,
            paymentMethodId: _paymentMethodId,
            paymentDate: DateFormat('yyyy-MM-dd').format(_paymentDate),
            reference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
          );
      if (mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() => _error = e.fieldError('amount') ?? e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final methodsAsync = ref.watch(paymentMethodsProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record payment', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Balance due: ${formatTzs(widget.invoice.balanceDue)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 16),
            Text('Payment method', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            methodsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Could not load payment methods.'),
              data: (methods) => Wrap(
                spacing: 8,
                children: [
                  for (final m in methods)
                    ChoiceChip(
                      label: Text(m.name),
                      selected: _paymentMethodId == m.id,
                      onSelected: (_) => setState(() => _paymentMethodId = m.id),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Payment date'),
              trailing: Text(DateFormat.yMMMd().format(_paymentDate)),
              onTap: _pickDate,
            ),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(labelText: 'Reference (optional)'),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Record payment'),
            ),
            const SizedBox(height: 12),
          ],
          ),
        ),
      ),
    );
  }
}
