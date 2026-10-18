import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import '../data/pos_models.dart';
import 'cart_controller.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _tenderedController = TextEditingController();
  final _approverEmailController = TextEditingController();
  final _approverPasswordController = TextEditingController();

  bool _tenderedTouched = false;
  bool _submitting = false;
  String? _error;
  CheckoutNeedsApproval? _pendingApproval;

  @override
  void dispose() {
    _tenderedController.dispose();
    _approverEmailController.dispose();
    _approverPasswordController.dispose();
    super.dispose();
  }

  double _total() => ref.read(posCartControllerProvider).total;

  double get _tendered => double.tryParse(_tenderedController.text) ?? _total();
  double get _changeDue {
    final change = _tendered - _total();
    return change > 0 ? change : 0;
  }

  Future<void> _submit() async {
    final cart = ref.read(posCartControllerProvider);
    if (cart.isEmpty) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final outcome = await ref
          .read(posRepositoryProvider)
          .checkout(
            items: cart.lines.map((l) => l.toInput()).toList(),
            overallDiscountType: cart.overallDiscountType,
            overallDiscountValue: cart.overallDiscountValue,
            paymentMethodId: cart.paymentMethodId,
            amountTendered: _tenderedTouched
                ? double.tryParse(_tenderedController.text)
                : null,
            approverEmail: _pendingApproval != null
                ? _approverEmailController.text.trim()
                : null,
            approverPassword: _pendingApproval != null
                ? _approverPasswordController.text
                : null,
          );

      if (!mounted) return;

      switch (outcome) {
        case CheckoutSuccess(sale: final sale):
          ref.read(posCartControllerProvider.notifier).clear();
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (context) => _ReceiptDialog(sale: sale),
          );
          if (mounted) {
            while (context.canPop()) {
              context.pop();
            }
          }
        case CheckoutNeedsApproval():
          setState(() => _pendingApproval = outcome);
      }
    } on ApiException catch (e) {
      setState(() => _error = e.fieldError('approver_password') ?? e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(posCartControllerProvider);
    final methodsAsync = ref.watch(paymentMethodsProvider);

    if (!_tenderedTouched) {
      _tenderedController.text = cart.total.toStringAsFixed(0);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order summary',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final line in cart.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${line.item.name} × ${line.quantity.toStringAsFixed(line.quantity.truncateToDouble() == line.quantity ? 0 : 2)}',
                              ),
                            ),
                            Text(formatTzs(line.subtotal)),
                          ],
                        ),
                      ),
                    const Divider(height: 20),
                    _totalRow('Subtotal', cart.subtotal),
                    if (cart.overallDiscountAmount > 0)
                      _totalRow('Discount', -cart.overallDiscountAmount),
                    _totalRow('Total', cart.total, bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment method',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            methodsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text(
                'Could not load payment methods — Cash will be used.',
              ),
              data: (methods) {
                if (methods.isEmpty) {
                  return const Text(
                    'No payment methods configured — Cash will be used.',
                  );
                }
                return Wrap(
                  spacing: 8,
                  children: [
                    for (final m in methods)
                      ChoiceChip(
                        label: Text(m.name),
                        selected: cart.paymentMethodId == m.id,
                        onSelected: (_) => ref
                            .read(posCartControllerProvider.notifier)
                            .setPaymentMethod(m.id),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tenderedController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Amount tendered'),
              onChanged: (_) => setState(() => _tenderedTouched = true),
            ),
            const SizedBox(height: 8),
            Text(
              'Change due: ${formatTzs(_changeDue)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_pendingApproval != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_pendingApproval!.message),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _approverEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Supervisor email',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _approverPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Supervisor password',
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _pendingApproval != null
                          ? 'Approve & complete sale'
                          : 'Complete sale',
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(formatTzs(value), style: style),
        ],
      ),
    );
  }
}

class _ReceiptDialog extends StatelessWidget {
  const _ReceiptDialog({required this.sale});

  final SaleResult sale;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 40),
      title: const Text('Sale complete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Sale #${sale.id}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            formatTzs(sale.amount),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (sale.changeDue != null && sale.changeDue! > 0) ...[
            const SizedBox(height: 4),
            Text('Change due: ${formatTzs(sale.changeDue!)}'),
          ],
          if (sale.paymentMethod != null) ...[
            const SizedBox(height: 4),
            Text(
              sale.paymentMethod!,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ],
      ),
      actions: [
        if (sale.receiptUrl != null)
          OutlinedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(sale.receiptUrl!),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.receipt_long, size: 18),
            label: Text(context.l10n.receiptOpen),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
