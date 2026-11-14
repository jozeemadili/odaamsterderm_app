import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/widgets/skeleton.dart';
import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../market/data/market_models.dart';
import '../../market/presentation/market_controller.dart';
import '../../orders/presentation/order_controller.dart';
import '../data/ai_models.dart';
import 'ai_providers.dart';

String _fmtQty(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// One chat line. Assistant answers from Ask AI carry the products it
/// picked; order-assistant answers keep the server's basket [memo].
class _Msg {
  _Msg(this.role, this.text, {this.memo = '', this.picks = const []});

  /// user | assistant | notice
  final String role;
  final String text;
  final String memo;
  final List<MarketProduct> picks;
}

/// The farm assistant: one chat for questions and orders. Signed-in
/// customers get the order assistant (answers and builds a basket they
/// review and add to the cart); everyone else gets Ask AI answers with
/// product suggestions and a prompt to sign in to order.
class AiOrderScreen extends ConsumerStatefulWidget {
  const AiOrderScreen({super.key, this.initialQuery});

  /// A question typed on the marketplace, sent as soon as the screen opens.
  final String? initialQuery;

  @override
  ConsumerState<AiOrderScreen> createState() => _AiOrderScreenState();
}

class _AiOrderScreenState extends ConsumerState<AiOrderScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  List<AiBasketLine> _basket = [];
  final Map<int, double> _qty = {};
  bool _waiting = false;
  bool _adding = false;
  String? _basketError;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery?.trim();
    if (q != null && q.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(q));
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Signed-in customers with the order assistant switched on.
  bool get _canOrder {
    final user = ref.read(authControllerProvider).user;
    final ai = ref.read(aiConfigProvider).valueOrNull ?? AiConfig.off;
    return user != null && user.isCustomer && ai.orderEnabled;
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

    setState(() {
      _messages.add(_Msg('user', message));
      _input.clear();
      _waiting = true;
    });
    _scrollDown();

    final reply = _canOrder ? await _askOrder() : await _askSearch(message);

    if (!mounted) return;
    setState(() {
      _messages.add(reply);
      _waiting = false;
    });
    _scrollDown();
  }

  Future<_Msg> _askOrder() async {
    final l10n = context.l10n;
    try {
      final r = await ref.read(aiRepositoryProvider).order([
        for (final m in _messages)
          if (m.role != 'notice')
            AiChatMessage(role: m.role, content: m.text, memo: m.memo),
      ], from: ref.read(marketLocationProvider));
      if (r.status == 'ok' && r.basket.isNotEmpty) {
        _basket = r.basket;
        _qty
          ..clear()
          ..addEntries(r.basket.map((l) => MapEntry(l.offerId, l.quantity)));
        _basketError = null;
      }
      return switch (r.status) {
        'ok' => _Msg('assistant', r.reply, memo: r.memo),
        'limited' => _Msg('notice', l10n.aiOrderBusy),
        'refused' => _Msg('notice', l10n.aiOrderRefused),
        _ => _Msg('notice', l10n.aiOrderUnavailable),
      };
    } catch (_) {
      return _Msg('notice', l10n.aiOrderUnavailable);
    }
  }

  Future<_Msg> _askSearch(String question) async {
    final l10n = context.l10n;
    final history = <({String question, String answer})>[];
    for (var i = 0; i + 1 < _messages.length - 1; i++) {
      if (_messages[i].role == 'user' && _messages[i + 1].role == 'assistant') {
        history.add((
          question: _messages[i].text,
          answer: _messages[i + 1].text,
        ));
      }
    }
    try {
      final r = await ref
          .read(aiRepositoryProvider)
          .search(
            question,
            from: ref.read(marketLocationProvider),
            history: history.length > 6
                ? history.sublist(history.length - 6)
                : history,
          );
      return switch (r.status) {
        'unavailable' => _Msg('notice', l10n.aiSearchUnavailable),
        'limited' => _Msg('notice', l10n.aiSearchLimited),
        'refused' => _Msg('notice', l10n.aiSearchRefused),
        _ => _Msg(
          'assistant',
          r.summary,
          picks: r.fallback ? const [] : r.products.take(8).toList(),
        ),
      };
    } on ApiException catch (e) {
      return _Msg(
        'notice',
        e.statusCode == 401 ? l10n.aiSignInToAsk : l10n.aiOrderUnavailable,
      );
    } catch (_) {
      return _Msg('notice', l10n.aiOrderUnavailable);
    }
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

    Navigator.of(context).maybePop(); // the basket sheet
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

  double get _total => _basket.fold<double>(
    0,
    (sum, l) => sum + (_qty[l.offerId] ?? 0) * l.unitPrice,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final user = ref.watch(authControllerProvider).user;
    final ai = ref.watch(aiConfigProvider).valueOrNull;
    final enabled = ai == null || ai.orderEnabled || ai.searchEnabled;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DukaColors.card,
        shape: Border(bottom: BorderSide(color: DukaColors.line)),
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: DukaColors.leafTint,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 17,
                color: DukaColors.leafDeep,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aiAssistantTitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: DukaColors.ink,
                    ),
                  ),
                  Text(
                    l10n.aiAssistantSubtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: DukaColors.leafDeep,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (_messages.isNotEmpty)
            TextButton(onPressed: _startOver, child: Text(l10n.aiNewChat)),
        ],
      ),
      body: SafeArea(
        child: !enabled
            ? _Gate(text: l10n.aiOrderUnavailable)
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      controller: _scroll,
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      children: [
                        if (_messages.isEmpty) _intro(context),
                        for (final m in _messages) ...[
                          _bubble(m),
                          if (m.picks.isNotEmpty) _picks(m.picks),
                        ],
                        if (_waiting)
                          _bubble(
                            _Msg('assistant', l10n.aiOrderChecking),
                            pending: true,
                          ),
                        if (user == null && _messages.isNotEmpty)
                          _signInToOrder(context),
                      ],
                    ),
                  ),
                  if (_basket.isNotEmpty) _basketBar(context),
                  _composer(context),
                ],
              ),
      ),
    );
  }

  Widget _intro(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DukaColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DukaColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aiOrderSubtitle,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: DukaColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aiOrderIntro,
            style: TextStyle(height: 1.45, color: DukaColors.ink),
          ),
          const SizedBox(height: 4),
          for (final example in [
            l10n.aiOrderExample1,
            l10n.aiOrderExample2,
            l10n.aiOrderExample3,
          ])
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Material(
                color: DukaColors.maroonTint.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => _send(example),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            example,
                            style: TextStyle(
                              color: DukaColors.indigo,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: DukaColors.indigo,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _bubble(_Msg m, {bool pending = false}) {
    if (m.role == 'notice') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          m.text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: DukaColors.muted),
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
          color: mine ? DukaColors.indigo : DukaColors.card,
          border: mine ? null : Border.all(color: DukaColors.line),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: pending
            // Waiting for the answer: placeholder lines where it will appear.
            ? const SizedBox(
                width: 210,
                child: Shimmer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bone(height: 10),
                      SizedBox(height: 8),
                      Bone(width: 170, height: 10),
                      SizedBox(height: 8),
                      Bone(width: 110, height: 10),
                    ],
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      m.text,
                      style: TextStyle(
                        height: 1.4,
                        color: mine ? Colors.white : DukaColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Products the assistant picked, as small tappable cards.
  Widget _picks(List<MarketProduct> products) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 6),
    child: SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final p = products[i];
          return Material(
            color: DukaColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: DukaColors.line),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => context.push('/market/products/${p.id}'),
              child: SizedBox(
                width: 176,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 52,
                        child: p.photos.isEmpty
                            ? Icon(
                                Icons.inventory_2_outlined,
                                color: DukaColors.muted,
                              )
                            : Image.network(
                                p.photos.first,
                                fit: BoxFit.contain,
                              ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              p.displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                            if (p.minPrice != null &&
                                ref.watch(showPricesProvider))
                              Text(
                                formatTzs(p.minPrice!),
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: DukaColors.ink,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _signInToOrder(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: DukaColors.leafTint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.aiSignInToOrder,
              style: TextStyle(fontSize: 13, color: DukaColors.ink),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/login'),
            child: Text(l10n.marketSignIn),
          ),
        ],
      ),
    );
  }

  /// Dark bar above the composer: what's in the proposed basket.
  Widget _basketBar(BuildContext context) {
    final l10n = context.l10n;
    final count = _basket.where((l) => (_qty[l.offerId] ?? 0) > 0).length;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      decoration: BoxDecoration(
        color: DukaColors.brandDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.aiOrderBasketTitle} · ${l10n.aiBasketSummary(count)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                if (ref.watch(showPricesProvider))
                  Text(
                    formatTzs(_total),
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          FilledButton(
            key: const Key('ai-review-order'),
            style: FilledButton.styleFrom(
              backgroundColor: DukaColors.leaf,
              foregroundColor: DukaColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => _openBasket(context),
            child: Text(l10n.aiReviewOrder),
          ),
        ],
      ),
    );
  }

  void _openBasket(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: DukaColors.card,
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheet) {
        void refresh(VoidCallback change) {
          setState(change);
          setSheet(() {});
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _basketCard(sheetContext, refresh),
          ),
        );
      },
    ),
  );

  Widget _basketCard(
    BuildContext context,
    void Function(VoidCallback) refresh,
  ) {
    final l10n = context.l10n;
    final stores = _basket.map((l) => l.store).toSet().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.aiOrderBasketTitle,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: DukaColors.ink,
                ),
              ),
            ),
            Text(
              l10n.aiOrderPickupStores(stores),
              style: TextStyle(fontSize: 12, color: DukaColors.muted),
            ),
          ],
        ),
        const Divider(height: 20),
        for (final line in _basket) _line(line, refresh),
        const Divider(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                ref.watch(showPricesProvider)
                    ? l10n.aiOrderTotal
                    : l10n.cartPriceConfirmedByStore,
              ),
            ),
            if (ref.watch(showPricesProvider))
              Text(
                formatTzs(_total),
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: DukaColors.ink,
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
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('ai-add-to-cart'),
          onPressed: _adding || _total <= 0 ? null : _addToCart,
          child: Text(l10n.aiOrderAddToCart),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.aiOrderNothingOrdered,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: DukaColors.muted),
        ),
      ],
    );
  }

  Widget _line(AiBasketLine line, void Function(VoidCallback) refresh) {
    final l10n = context.l10n;
    final q = _qty[line.offerId] ?? 0;
    void set(double v) =>
        refresh(() => _qty[line.offerId] = v.clamp(0, line.available));

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
                  style: TextStyle(fontSize: 12, color: DukaColors.muted),
                ),
                Text(
                  [
                    if (ref.watch(showPricesProvider))
                      '${formatTzs(line.unitPrice)} / ${line.unit}',
                    l10n.aiOrderAvailable(_fmtQty(line.available)),
                  ].join(' · '),
                  style: TextStyle(fontSize: 12, color: DukaColors.muted),
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
                onPressed: () => refresh(() {
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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: DukaColors.line),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: DukaColors.card,
        border: Border(top: BorderSide(color: DukaColors.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              key: const Key('ai-order-input'),
              controller: _input,
              enabled: !_waiting,
              minLines: 1,
              maxLines: 4,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: l10n.aiAskPlaceholder,
                counterText: '',
                fillColor: DukaColors.bg,
                border: border,
                enabledBorder: border,
                focusedBorder: border.copyWith(
                  borderSide: BorderSide(color: DukaColors.indigo),
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: l10n.aiOrderSend,
            style: IconButton.styleFrom(
              backgroundColor: DukaColors.indigo,
              foregroundColor: Colors.white,
              minimumSize: const Size(48, 48),
            ),
            onPressed: _waiting ? null : () => _send(),
            icon: const Icon(Icons.arrow_upward),
          ),
        ],
      ),
    );
  }
}

class _Gate extends StatelessWidget {
  const _Gate({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 40, color: DukaColors.indigo),
          const SizedBox(height: 12),
          Text(text, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
