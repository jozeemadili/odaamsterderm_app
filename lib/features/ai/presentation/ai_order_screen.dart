import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../market/presentation/market_controller.dart';
import '../../orders/presentation/order_controller.dart';
import '../data/ai_models.dart';
import 'ai_providers.dart';

String _fmtQty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// "Use AI to place order": chat with the assistant, adjust the basket it
/// proposes, then add it to the cart and confirm the order there.
class AiOrderScreen extends ConsumerStatefulWidget {
  const AiOrderScreen({super.key});

  @override
  ConsumerState<AiOrderScreen> createState() => _AiOrderScreenState();
}

class _AiOrderScreenState extends ConsumerState<AiOrderScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<AiChatMessage> _messages = [];
  List<AiBasketLine> _basket = [];
  final Map<int, double> _qty = {};
  bool _waiting = false;
  bool _adding = false;
  String? _basketError;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  });

  Future<void> _send([String? text]) async {
    final message = (text ?? _input.text).trim();
    if (message.isEmpty || _waiting) return;
    final l10n = context.l10n;

    setState(() {
      _messages.add(AiChatMessage(role: 'user', content: message));
      _input.clear();
      _waiting = true;
    });
    _scrollDown();

    AiChatMessage reply;
    try {
      final r = await ref
          .read(aiRepositoryProvider)
          .order(_messages, from: ref.read(marketLocationProvider));
      reply = switch (r.status) {
        'ok' => AiChatMessage(
          role: 'assistant',
          content: r.reply,
          memo: r.memo,
        ),
        'limited' => AiChatMessage(role: 'notice', content: l10n.aiOrderBusy),
        'refused' => AiChatMessage(
          role: 'notice',
          content: l10n.aiOrderRefused,
        ),
        _ => AiChatMessage(role: 'notice', content: l10n.aiOrderUnavailable),
      };
      if (r.status == 'ok' && r.basket.isNotEmpty) {
        _basket = r.basket;
        _qty
          ..clear()
          ..addEntries(r.basket.map((l) => MapEntry(l.offerId, l.quantity)));
        _basketError = null;
      }
    } catch (_) {
      reply = AiChatMessage(role: 'notice', content: l10n.aiOrderUnavailable);
    }

    if (!mounted) return;
    setState(() {
      _messages.add(reply);
      _waiting = false;
    });
    _scrollDown();
  }

  Future<void> _addToCart() async {
    final l10n = context.l10n;
    setState(() {
      _adding = true;
      _basketError = null;
    });

    final cart = ref.read(cartControllerProvider.notifier);
    final problems = <String>[];
    for (final line in _basket) {
      final q = _qty[line.offerId] ?? 0;
      if (q <= 0) continue;
      try {
        await cart.add(line.offerId, q);
      } catch (e) {
        problems.add('${line.name}: $e');
      }
    }

    if (!mounted) return;
    setState(() => _adding = false);
    if (problems.isNotEmpty) {
      setState(() => _basketError = l10n.aiOrderSomeFailed(problems.join(' ')));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.aiOrderAdded)));
    context.push('/cart');
  }

  void _startOver() => setState(() {
    _messages.clear();
    _basket = [];
    _qty.clear();
    _basketError = null;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).user;
    final enabled =
        ref.watch(aiConfigProvider).valueOrNull?.orderEnabled ?? true;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aiOrderTitle),
        actions: [
          if (_messages.isNotEmpty)
            TextButton(
              onPressed: _startOver,
              child: Text(l10n.aiOrderStartOver),
            ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? _Gate(
                text: l10n.aiOrderSignIn,
                action: FilledButton(
                  onPressed: () => context.push('/login'),
                  child: Text(l10n.marketSignIn),
                ),
              )
            : !user.isCustomer
            ? _Gate(text: l10n.aiOrderNotCustomer)
            : !enabled
            ? _Gate(text: l10n.aiOrderUnavailable)
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_messages.isEmpty) _intro(context),
                        for (final m in _messages) _bubble(m),
                        if (_waiting)
                          _bubble(
                            AiChatMessage(
                              role: 'assistant',
                              content: l10n.aiOrderChecking,
                            ),
                            pending: true,
                          ),
                        if (_basket.isNotEmpty) _basketCard(context),
                      ],
                    ),
                  ),
                  _composer(context),
                ],
              ),
      ),
    );
  }

  Widget _intro(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.aiOrderSubtitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(l10n.aiOrderIntro),
            const SizedBox(height: 4),
            for (final example in [
              l10n.aiOrderExample1,
              l10n.aiOrderExample2,
              l10n.aiOrderExample3,
            ])
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () => _send(example),
                  child: Text(example),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(AiChatMessage m, {bool pending = false}) {
    if (m.role == 'notice') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          m.content,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: DukaColors.muted),
        ),
      );
    }
    final mine = m.role == 'user';
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        decoration: BoxDecoration(
          color: mine ? DukaColors.indigo : DukaColors.line,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pending) ...[
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                m.content,
                style: TextStyle(color: mine ? Colors.white : DukaColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basketCard(BuildContext context) {
    final l10n = context.l10n;
    final total = _basket.fold<double>(
      0,
      (sum, l) => sum + (_qty[l.offerId] ?? 0) * l.unitPrice,
    );
    final stores = _basket.map((l) => l.store).toSet().length;

    return Card(
      margin: const EdgeInsets.only(top: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: DukaColors.gold),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.aiOrderBasketTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  l10n.aiOrderPickupStores(stores),
                  style: const TextStyle(fontSize: 12, color: DukaColors.muted),
                ),
              ],
            ),
            const Divider(),
            for (final line in _basket) _line(line),
            const Divider(),
            Row(
              children: [
                Expanded(child: Text(l10n.aiOrderTotal)),
                Text(
                  formatTzs(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (_basketError != null) ...[
              const SizedBox(height: 8),
              Text(
                _basketError!,
                style: const TextStyle(color: DukaColors.rose, fontSize: 12),
              ),
            ],
            const SizedBox(height: 10),
            FilledButton(
              key: const Key('ai-add-to-cart'),
              onPressed: _adding || total <= 0 ? null : _addToCart,
              child: Text(l10n.aiOrderAddToCart),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.aiOrderNothingOrdered,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: DukaColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(AiBasketLine line) {
    final l10n = context.l10n;
    final q = _qty[line.offerId] ?? 0;
    void set(double v) =>
        setState(() => _qty[line.offerId] = v.clamp(0, line.available));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  [line.store, line.distance].whereType<String>().join(' · '),
                  style: const TextStyle(fontSize: 12, color: DukaColors.muted),
                ),
                Text(
                  '${formatTzs(line.unitPrice)} / ${line.unit} · ${l10n.aiOrderAvailable(_fmtQty(line.available))}',
                  style: const TextStyle(fontSize: 12, color: DukaColors.muted),
                ),
                if (line.note != null)
                  Text(
                    line.note!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DukaColors.rose,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: q > 0 ? () => set(q - 1) : null,
                  ),
                  Text(
                    _fmtQty(q),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: q < line.available ? () => set(q + 1) : null,
                  ),
                ],
              ),
              TextButton(
                onPressed: () => setState(() {
                  _basket = _basket
                      .where((l) => l.offerId != line.offerId)
                      .toList();
                  _qty.remove(line.offerId);
                }),
                child: Text(
                  l10n.aiOrderRemove,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _composer(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: const BoxDecoration(
        color: DukaColors.card,
        border: Border(top: BorderSide(color: DukaColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('ai-order-input'),
              controller: _input,
              enabled: !_waiting,
              minLines: 1,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: l10n.aiOrderHint,
                counterText: '',
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _waiting ? null : () => _send(),
            child: Text(l10n.aiOrderSend),
          ),
        ],
      ),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 40, color: DukaColors.gold),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    ),
  );
}
