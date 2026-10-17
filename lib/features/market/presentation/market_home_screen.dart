import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../../core/widgets/producer_line.dart';
import '../../../l10n/l10n_extension.dart';
import '../../ai/data/ai_models.dart';
import '../../ai/presentation/ai_providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/market_models.dart';
import 'location_sheet.dart';
import 'market_controller.dart';

typedef _Query = ({
  String search,
  int? animalTypeId,
  MarketSort sort,
  bool inStock,
  MarketLocation? from,
});

final _productsProvider = FutureProvider.autoDispose.family(
  (ref, _Query q) => ref
      .watch(marketRepositoryProvider)
      .products(
        search: q.search,
        animalTypeId: q.animalTypeId,
        sort: q.sort,
        inStock: q.inStock,
        from: q.from,
      ),
);

final _aiSearchProvider = FutureProvider.autoDispose
    .family<AiSearchResult, ({String query, MarketLocation? from})>(
      (ref, q) => ref.watch(aiRepositoryProvider).search(q.query, from: q.from),
    );

final _storesProvider = FutureProvider.autoDispose.family(
  (ref, MarketLocation? from) =>
      ref.watch(marketRepositoryProvider).stores(from: from, limit: 8),
);

/// Public marketplace: search animal products and compare nearby sellers.
class MarketHomeScreen extends ConsumerStatefulWidget {
  const MarketHomeScreen({super.key});

  @override
  ConsumerState<MarketHomeScreen> createState() => _MarketHomeScreenState();
}

class _MarketHomeScreenState extends ConsumerState<MarketHomeScreen> {
  String _search = '';
  int? _animalTypeId;
  MarketSort _sort = MarketSort.nearest;
  bool _inStock = false;
  Timer? _debounce;

  /// Ask AI mode: the box takes a plain-language question, sent on submit.
  bool _aiMode = false;
  String _aiQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleAi(bool on) {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _aiMode = on;
      _aiQuery = '';
      _search = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final from = ref.watch(marketLocationProvider);
    final auth = ref.watch(authControllerProvider);
    // Without a location "nearest" can't apply — the API falls back to price.
    final sort = from == null && _sort == MarketSort.nearest
        ? MarketSort.price
        : _sort;
    final query = (
      search: _search,
      animalTypeId: _animalTypeId,
      sort: sort,
      inStock: _inStock,
      from: from,
    );
    final products = ref.watch(_productsProvider(query));
    final animals = ref.watch(marketFiltersProvider);
    final ai = ref.watch(aiConfigProvider).valueOrNull ?? AiConfig.off;
    final aiMode = _aiMode && ai.searchEnabled;
    final showAiResults = aiMode && _aiQuery.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.marketplaceTitle),
        actions: [
          if (auth.user == null)
            TextButton(
              onPressed: () => context.push('/login'),
              child: Text(l10n.marketSignIn),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_productsProvider);
          ref.invalidate(_storesProvider);
          ref.invalidate(aiConfigProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('market-search'),
                    controller: _searchController,
                    maxLength: aiMode ? 300 : null,
                    decoration: InputDecoration(
                      hintText: aiMode
                          ? l10n.aiSearchHint
                          : l10n.marketSearchHint,
                      prefixIcon: Icon(
                        aiMode ? Icons.auto_awesome : Icons.search,
                        color: aiMode ? DukaColors.indigo : null,
                      ),
                      counterText: '',
                      suffixIcon: aiMode
                          ? IconButton(
                              tooltip: l10n.aiAskAi,
                              icon: const Icon(Icons.send),
                              onPressed: () => setState(
                                () => _aiQuery = _searchController.text.trim(),
                              ),
                            )
                          : null,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: aiMode
                        ? (value) => setState(() => _aiQuery = value.trim())
                        : null,
                    onChanged: (value) {
                      if (aiMode) return;
                      _debounce?.cancel();
                      _debounce = Timer(
                        const Duration(milliseconds: 350),
                        () => setState(() => _search = value.trim()),
                      );
                    },
                  ),
                ),
                if (ai.searchEnabled) ...[
                  const SizedBox(width: 8),
                  FilterChip(
                    key: const Key('ask-ai-toggle'),
                    avatar: const Icon(Icons.auto_awesome, size: 16),
                    label: Text(l10n.aiAskAi),
                    selected: aiMode,
                    onSelected: _toggleAi,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: const MarketLocationChip(),
            ),
            if (from == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.marketSetLocationHint,
                  style: const TextStyle(fontSize: 12, color: DukaColors.muted),
                ),
              ),
            if (ai.orderEnabled && !showAiResults) ...[
              const SizedBox(height: 10),
              const _AiOrderBanner(),
            ],
            if (showAiResults) ...[
              const SizedBox(height: 12),
              _AiResults(
                query: _aiQuery,
                result: ref.watch(
                  _aiSearchProvider((query: _aiQuery, from: from)),
                ),
                onClear: () => _toggleAi(false),
              ),
            ] else ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: animals.maybeWhen(
                  data: (f) => ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _Chip(
                        label: l10n.marketAllAnimals,
                        selected: _animalTypeId == null,
                        onTap: () => setState(() => _animalTypeId = null),
                      ),
                      for (final a in [
                        for (final g in f.animalTypes) ...[g, ...g.children],
                      ])
                        _Chip(
                          label: a.name,
                          selected: _animalTypeId == a.id,
                          onTap: () => setState(() => _animalTypeId = a.id),
                        ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (final s in MarketSort.values)
                    ChoiceChip(
                      label: Text(switch (s) {
                        MarketSort.nearest => l10n.marketSortNearest,
                        MarketSort.price => l10n.marketSortPrice,
                        MarketSort.availability => l10n.marketSortAvailability,
                      }),
                      selected: sort == s,
                      onSelected: s == MarketSort.nearest && from == null
                          ? null
                          : (_) => setState(() => _sort = s),
                    ),
                  FilterChip(
                    label: Text(l10n.marketInStockOnly),
                    selected: _inStock,
                    onSelected: (v) => setState(() => _inStock = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              products.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('$e'),
                data: (list) => list.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.marketNoProducts,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: DukaColors.muted),
                        ),
                      )
                    : Column(
                        children: [
                          for (final p in list) _ProductCard(product: p),
                        ],
                      ),
              ),
            ],
            if (!showAiResults && _search.isEmpty && _animalTypeId == null) ...[
              const SizedBox(height: 16),
              Text(
                from == null ? l10n.marketStores : l10n.marketStoresNearYou,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ref
                  .watch(_storesProvider(from))
                  .maybeWhen(
                    data: (stores) => Column(
                      children: [
                        for (final s in stores)
                          Card(
                            child: ListTile(
                              onTap: () =>
                                  context.push('/market/stores/${s.id}'),
                              leading: const Icon(
                                Icons.storefront,
                                color: DukaColors.indigo,
                              ),
                              title: Text(s.name),
                              subtitle: Text(
                                [s.sellerName, s.addressLine]
                                    .whereType<String>()
                                    .where((t) => t.isNotEmpty)
                                    .join(' · '),
                              ),
                              trailing: s.distanceLabel != null
                                  ? Text(
                                      s.distanceLabel!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : const Icon(Icons.chevron_right),
                            ),
                          ),
                      ],
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Not sure what to buy?" — opens the AI order assistant.
class _AiOrderBanner extends StatelessWidget {
  const _AiOrderBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      color: DukaColors.indigo.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.aiOrderBannerTitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.aiOrderBannerBody,
              style: const TextStyle(fontSize: 13, color: DukaColors.muted),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              key: const Key('ai-order-button'),
              onPressed: () => context.push('/market/ai-order'),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: Text(l10n.aiOrderButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// The AI's note and the products it picked (live prices from the API).
class _AiResults extends StatelessWidget {
  const _AiResults({
    required this.query,
    required this.result,
    required this.onClear,
  });

  final String query;
  final AsyncValue<AiSearchResult> result;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final signIn =
        result.error is ApiException &&
        (result.error! as ApiException).statusCode == 401;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: DukaColors.indigo.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: DukaColors.indigo,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.aiAskAi.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: DukaColors.indigo,
                        ),
                      ),
                    ),
                    TextButton(onPressed: onClear, child: Text(l10n.aiClear)),
                  ],
                ),
                Text(
                  '“$query”',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                result.when(
                  loading: () => Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l10n.aiThinking)),
                    ],
                  ),
                  error: (e, _) => signIn
                      ? Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text(l10n.aiSignInToAsk),
                            TextButton(
                              onPressed: () => context.push('/login'),
                              child: Text(l10n.marketSignIn),
                            ),
                          ],
                        )
                      : Text('$e'),
                  data: (r) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(switch (r.status) {
                        'unavailable' => l10n.aiSearchUnavailable,
                        'limited' => l10n.aiSearchLimited,
                        'refused' => l10n.aiSearchRefused,
                        _ => r.summary,
                      }),
                      if (r.status == 'ok' || r.status == 'off_topic') ...[
                        const SizedBox(height: 6),
                        Text(
                          l10n.aiDisclaimer,
                          style: const TextStyle(
                            fontSize: 11,
                            color: DukaColors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...result.maybeWhen(
          data: (r) => r.products.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.marketNoProducts,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: DukaColors.muted),
                    ),
                  ),
                ]
              : [
                  if (!r.fallback) ...[
                    Text(
                      l10n.aiPicksTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                  ],
                  for (final p in r.products) _ProductCard(product: p),
                ],
          orElse: () => const [],
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    ),
  );
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final MarketProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/market/products/${product.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: product.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.imageUrl!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        color: DukaColors.bg,
                        child: const Icon(
                          Icons.inventory_2_outlined,
                          color: DukaColors.muted,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        product.animalType,
                        product.category,
                      ].whereType<String>().join(' · '),
                      style: const TextStyle(
                        fontSize: 11,
                        color: DukaColors.muted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (product.producer != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: ProducerLine(producer: product.producer),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        l10n.marketSellersCount(product.sellersCount),
                        if (product.nearestLabel != null)
                          l10n.marketNearestDistance(product.nearestLabel!),
                      ].join(' · '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: DukaColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (product.minPrice != null) ...[
                    Text(
                      l10n.marketFrom,
                      style: const TextStyle(
                        fontSize: 11,
                        color: DukaColors.muted,
                      ),
                    ),
                    Text(
                      formatTzs(product.minPrice!),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ] else
                    Text(
                      l10n.marketOutOfStock,
                      style: const TextStyle(
                        color: DukaColors.rose,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
