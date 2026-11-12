import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../../core/widgets/distance_pill.dart';
import '../../../core/widgets/duka_logo_mark.dart';
import '../../../core/widgets/photo_carousel.dart';
import '../../../core/widgets/producer_line.dart';
import '../../../core/widgets/store_brand_header.dart';
import '../../../l10n/l10n_extension.dart';
import '../../ai/data/ai_models.dart';
import '../../catalog/data/catalog_models.dart';
import '../../ai/presentation/ai_providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/market_models.dart';
import 'location_sheet.dart';
import 'market_controller.dart';

/// Amsterdam Group's own range, featured first; Silverlands gets a block.
const _featuredBrand = 'Amsterdam Group';
const _partnerBrand = 'Silverlands';

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

final _brandProvider = FutureProvider.autoDispose
    .family<List<MarketProduct>, ({String brand, MarketLocation? from})>(
      (ref, q) => ref
          .watch(marketRepositoryProvider)
          .products(brand: q.brand, sort: MarketSort.price, from: q.from),
    );

final _storesProvider = FutureProvider.autoDispose.family(
  (ref, MarketLocation? from) =>
      ref.watch(marketRepositoryProvider).stores(from: from, limit: 8),
);

/// One question of an Ask AI chat and, once it arrives, its answer.
class _AiTurn {
  _AiTurn(this.question);

  final String question;
  AiSearchResult? result;
  Object? error;

  bool get loading => result == null && error == null;

  /// The answer to send back as context with the next question.
  String? get answer =>
      result != null &&
          (result!.status == 'ok' || result!.status == 'off_topic') &&
          result!.summary.isNotEmpty
      ? result!.summary
      : null;
}

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

  /// Ask AI mode: the box takes a plain-language question; answers and
  /// follow-ups build a chat.
  bool _aiMode = false;
  final List<_AiTurn> _aiTurns = [];
  final _searchController = TextEditingController();
  final _scroll = ScrollController();
  final _productsKey = GlobalKey();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toggleAi(bool on) {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _aiMode = on;
      _aiTurns.clear();
      _search = '';
    });
  }

  /// Asks the AI; [followUp] keeps the earlier turns as context.
  Future<void> _askAi(String question, {bool followUp = false}) async {
    question = question.trim();
    if (question.isEmpty) return;

    final history = followUp
        ? [
            for (final t in _aiTurns)
              if (t.answer != null) (question: t.question, answer: t.answer!),
          ]
        : <({String question, String answer})>[];
    final turn = _AiTurn(question);
    setState(() {
      if (!followUp) _aiTurns.clear();
      _aiTurns.add(turn);
    });

    try {
      turn.result = await ref
          .read(aiRepositoryProvider)
          .search(
            question,
            from: ref.read(marketLocationProvider),
            history: history.length > 6
                ? history.sublist(history.length - 6)
                : history,
          );
    } catch (e) {
      turn.error = e;
    }
    if (mounted) setState(() {});
  }

  void _showBrand(String brand) {
    _searchController.text = brand;
    setState(() {
      _aiMode = false;
      _aiTurns.clear();
      _search = brand;
    });
  }

  void _scrollToProducts() {
    final target = _productsKey.currentContext;
    if (target != null) {
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }
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
    final aiChat = aiMode && _aiTurns.isNotEmpty;
    final landing = !aiMode && _search.isEmpty && _animalTypeId == null;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const DukaLogoMark(size: 32),
            const SizedBox(width: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Amsterdam ',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700,
                      color: DukaColors.leafDeep,
                    ),
                  ),
                  TextSpan(
                    text: 'Digital',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700,
                      color: DukaColors.indigo,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
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
          ref.invalidate(_brandProvider);
          ref.invalidate(_storesProvider);
          ref.invalidate(aiConfigProvider);
        },
        child: ListView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          children: [
            if (landing) ...[
              _MarketHero(onBrowse: _scrollToProducts),
              const SizedBox(height: 16),
            ],
            _SearchRow(
              controller: _searchController,
              aiMode: aiMode,
              aiAvailable: ai.searchEnabled,
              onToggleAi: _toggleAi,
              onAsk: (q) => _askAi(q),
              onChanged: (value) {
                _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 350),
                  () => setState(() => _search = value.trim()),
                );
              },
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: MarketLocationChip(),
            ),
            if (from == null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.marketSetLocationHint,
                  style: const TextStyle(fontSize: 12, color: DukaColors.muted),
                ),
              ),
            if (aiChat) ...[
              const SizedBox(height: 14),
              _AiChat(
                turns: _aiTurns,
                onFollowUp: (q) => _askAi(q, followUp: true),
                onEnd: () => _toggleAi(false),
              ),
            ] else ...[
              if (ai.orderEnabled) ...[
                const SizedBox(height: 14),
                const _AiOrderBanner(),
              ],
              if (landing) ...[
                const SizedBox(height: 20),
                _SectionTitle(title: l10n.marketShopByAnimal),
                const SizedBox(height: 10),
                animals.maybeWhen(
                  data: (f) => _AnimalTiles(
                    groups: f.animalTypes,
                    onPick: (id) => setState(() => _animalTypeId = id),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                _BrandRow(
                  brand: _featuredBrand,
                  products: ref.watch(
                    _brandProvider((brand: _featuredBrand, from: from)),
                  ),
                  onSeeAll: () => _showBrand(_featuredBrand),
                ),
                _PartnerBlock(
                  brand: _partnerBrand,
                  products: ref.watch(
                    _brandProvider((brand: _partnerBrand, from: from)),
                  ),
                  onShop: () => _showBrand(_partnerBrand),
                ),
              ] else ...[
                const SizedBox(height: 12),
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
              ],
              const SizedBox(height: 18),
              SizedBox(
                key: _productsKey,
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final s in MarketSort.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(switch (s) {
                            MarketSort.nearest => l10n.marketSortNearest,
                            MarketSort.price => l10n.marketSortPrice,
                            MarketSort.availability =>
                              l10n.marketSortAvailability,
                          }),
                          selected: sort == s,
                          onSelected: s == MarketSort.nearest && from == null
                              ? null
                              : (_) => setState(() => _sort = s),
                        ),
                      ),
                    FilterChip(
                      label: Text(l10n.marketInStockOnly),
                      selected: _inStock,
                      onSelected: (v) => setState(() => _inStock = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _SectionTitle(
                                  title: _search.isNotEmpty
                                      ? _search
                                      : l10n.marketAllProducts,
                                ),
                              ),
                              Text(
                                '${list.length}',
                                style: const TextStyle(color: DukaColors.muted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _ProductGrid(products: list),
                        ],
                      ),
              ),
            ],
            if (landing) ...[
              const SizedBox(height: 22),
              _SectionTitle(
                title: from == null
                    ? l10n.marketStores
                    : l10n.marketStoresNearYou,
              ),
              const SizedBox(height: 10),
              ref
                  .watch(_storesProvider(from))
                  .maybeWhen(
                    data: (stores) => Column(
                      children: [
                        for (final s in stores)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () =>
                                    context.push('/market/stores/${s.id}'),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    StoreBrandHeader(store: s),
                                    if (s.addressLine.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          12,
                                          8,
                                          12,
                                          10,
                                        ),
                                        child: Text(
                                          s.addressLine,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: DukaColors.muted,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.eyebrow});

  final String title;
  final String? eyebrow;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (eyebrow != null)
        Text(
          eyebrow!,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w700,
            color: DukaColors.indigo,
          ),
        ),
      Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: DukaColors.ink,
        ),
      ),
    ],
  );
}

/// The search box with the Ask AI switch beside it.
class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.aiMode,
    required this.aiAvailable,
    required this.onToggleAi,
    required this.onAsk,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool aiMode;
  final bool aiAvailable;
  final ValueChanged<bool> onToggleAi;
  final ValueChanged<String> onAsk;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide(
        color: aiMode ? DukaColors.indigo : DukaColors.line,
        width: aiMode ? 1.5 : 1,
      ),
    );

    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const Key('market-search'),
            controller: controller,
            maxLength: aiMode ? 300 : null,
            decoration: InputDecoration(
              hintText: aiMode ? l10n.aiSearchHint : l10n.marketSearchHint,
              prefixIcon: Icon(
                aiMode ? Icons.auto_awesome : Icons.search,
                color: aiMode ? DukaColors.indigo : DukaColors.muted,
              ),
              counterText: '',
              border: border,
              enabledBorder: border,
              focusedBorder: border,
              suffixIcon: aiMode
                  ? IconButton(
                      tooltip: l10n.aiAskAi,
                      icon: const Icon(Icons.send, color: DukaColors.indigo),
                      onPressed: () => onAsk(controller.text),
                    )
                  : null,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: aiMode ? onAsk : null,
            onChanged: aiMode ? null : onChanged,
          ),
        ),
        if (aiAvailable) ...[
          const SizedBox(width: 8),
          FilterChip(
            key: const Key('ask-ai-toggle'),
            avatar: Icon(
              Icons.auto_awesome,
              size: 16,
              color: aiMode ? DukaColors.ink : DukaColors.indigo,
            ),
            label: Text(l10n.aiAskAi),
            selected: aiMode,
            showCheckmark: false,
            selectedColor: DukaColors.leaf,
            onSelected: onToggleAi,
          ),
        ],
      ],
    );
  }
}

/// Green banner with the red-and-green wave, as on the website.
class _MarketHero extends StatelessWidget {
  const _MarketHero({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.1, -0.5),
            radius: 1.3,
            colors: [
              Colors.white,
              Color(0xFFF4F9E4),
              Color(0xFFD6EC97),
              Color(0xFFA3D05A),
            ],
            stops: [0, 0.35, 0.7, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 56,
              child: Image.asset(
                'assets/images/hero-wave.webp',
                fit: BoxFit.fitWidth,
                alignment: const Alignment(0, 0.35),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 72),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.marketHeroEyebrow,
                    style: const TextStyle(
                      color: DukaColors.indigo,
                      fontSize: 11,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.marketHeroTitle,
                    style: GoogleFonts.montserrat(
                      color: DukaColors.indigo,
                      fontSize: 25,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.marketHeroBody,
                    style: TextStyle(
                      color: DukaColors.ink.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onBrowse,
                    child: Text(l10n.marketBrowse),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Not sure what to buy?": opens the AI order assistant.
class _AiOrderBanner extends StatelessWidget {
  const _AiOrderBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DukaColors.brandDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DukaColors.leaf.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: DukaColors.leaf,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.aiOrderBannerTitle,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aiOrderBannerBody,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            key: const Key('ai-order-button'),
            style: FilledButton.styleFrom(
              backgroundColor: DukaColors.leaf,
              foregroundColor: DukaColors.ink,
            ),
            onPressed: () => context.push('/market/ai-order'),
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: Text(l10n.aiOrderButton),
          ),
        ],
      ),
    );
  }
}

/// "Other poultry (ducks, turkeys…)" → "Other poultry".
String _shortName(String name) =>
    name.replaceAll(RegExp(r'\s*\(.*\)$'), '');

/// Big animal tiles on the landing view; each shows its sub-types.
class _AnimalTiles extends StatelessWidget {
  const _AnimalTiles({required this.groups, required this.onPick});

  final List<CatalogNode> groups;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 10.0;
      final tile = (constraints.maxWidth - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final g in groups)
            SizedBox(
              width: tile,
              height: 84,
              child: Material(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: DukaColors.line),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onPick(g.id),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _shortName(g.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: DukaColors.ink,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          g.children.isEmpty
                              ? context.l10n.marketAllProducts
                              : g.children
                                    .map((c) => _shortName(c.name))
                                    .join(', '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: DukaColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

/// "Featured: Amsterdam Group products" — a swipeable row of cards.
class _BrandRow extends StatelessWidget {
  const _BrandRow({
    required this.brand,
    required this.products,
    required this.onSeeAll,
  });

  final String brand;
  final AsyncValue<List<MarketProduct>> products;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = products.valueOrNull ?? const <MarketProduct>[];
    if (list.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _SectionTitle(
                  eyebrow: l10n.marketFeatured,
                  title: l10n.marketBrandProducts(brand),
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text('${l10n.marketSeeAll} →'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 334,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) =>
                  SizedBox(width: 168, child: _ProductCard(product: list[i])),
            ),
          ),
        ],
      ),
    );
  }
}

/// A partner range (Silverlands) in a maroon block of its own.
class _PartnerBlock extends StatelessWidget {
  const _PartnerBlock({
    required this.brand,
    required this.products,
    required this.onShop,
  });

  final String brand;
  final AsyncValue<List<MarketProduct>> products;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = (products.valueOrNull ?? const <MarketProduct>[])
        .where((p) => p.photos.isNotEmpty)
        .take(4)
        .toList();
    if (list.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DukaColors.indigo,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.marketPartnerTitle(brand),
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.marketPartnerBody,
              style: const TextStyle(
                color: DukaColors.maroonTint,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            for (final p in list)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.push('/market/products/${p.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width: 56,
                              height: 64,
                              child: Image.network(
                                p.photos.first,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.displayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.minPrice != null
                                      ? formatTzs(p.minPrice!)
                                      : l10n.marketOutOfStock,
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w700,
                                    color: DukaColors.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: DukaColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 4),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: DukaColors.leaf,
                foregroundColor: DukaColors.ink,
              ),
              onPressed: onShop,
              child: Text('${l10n.marketShopBrand(brand)} →'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ask AI as a chat: each question and answer as bubbles, a follow-up box
/// under the latest answer, and the products picked for the latest question.
class _AiChat extends StatefulWidget {
  const _AiChat({
    required this.turns,
    required this.onFollowUp,
    required this.onEnd,
  });

  final List<_AiTurn> turns;
  final ValueChanged<String> onFollowUp;
  final VoidCallback onEnd;

  @override
  State<_AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<_AiChat> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty || widget.turns.last.loading) return;
    _input.clear();
    widget.onFollowUp(text);
  }

  String _answerText(BuildContext context, _AiTurn turn) {
    final l10n = context.l10n;
    final r = turn.result!;
    return switch (r.status) {
      'unavailable' => l10n.aiSearchUnavailable,
      'limited' => l10n.aiSearchLimited,
      'refused' => l10n.aiSearchRefused,
      _ => r.summary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final latest = widget.turns.last;
    final products = latest.result?.products ?? const <MarketProduct>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          decoration: BoxDecoration(
            color: DukaColors.maroonTint.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: DukaColors.indigo.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      l10n.aiChatTitle.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: DukaColors.indigo,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onEnd,
                    child: Text(l10n.aiEndChat),
                  ),
                ],
              ),
              for (final turn in widget.turns) ...[
                _Bubble(text: turn.question, mine: true),
                if (turn.loading)
                  _Bubble(text: l10n.aiThinking, pending: true)
                else if (turn.error != null)
                  _Bubble(
                    text:
                        turn.error is ApiException &&
                            (turn.error! as ApiException).statusCode == 401
                        ? l10n.aiSignInToAsk
                        : '${turn.error}',
                    action:
                        turn.error is ApiException &&
                            (turn.error! as ApiException).statusCode == 401
                        ? TextButton(
                            onPressed: () => context.push('/login'),
                            child: Text(l10n.marketSignIn),
                          )
                        : null,
                  )
                else
                  _Bubble(text: _answerText(context, turn)),
              ],
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('ai-follow-up'),
                      controller: _input,
                      enabled: !latest.loading,
                      minLines: 1,
                      maxLines: 3,
                      maxLength: 300,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: l10n.aiFollowUpHint,
                        counterText: '',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: DukaColors.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: DukaColors.line),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: l10n.aiOrderSend,
                    style: IconButton.styleFrom(
                      backgroundColor: DukaColors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: latest.loading ? null : _send,
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.aiDisclaimer,
                style: const TextStyle(fontSize: 11, color: DukaColors.muted),
              ),
            ],
          ),
        ),
        if (products.isNotEmpty) ...[
          const SizedBox(height: 18),
          if (!(latest.result?.fallback ?? false)) ...[
            _SectionTitle(title: l10n.aiPicksTitle),
            const SizedBox(height: 10),
          ],
          _ProductGrid(products: products),
        ],
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    this.mine = false,
    this.pending = false,
    this.action,
  });

  final String text;
  final bool mine;
  final bool pending;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Align(
    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
      ),
      decoration: BoxDecoration(
        color: mine ? DukaColors.indigo : Colors.white,
        border: mine ? null : Border.all(color: DukaColors.line),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(mine ? 18 : 4),
          bottomRight: Radius.circular(mine ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: mine ? Colors.white : DukaColors.ink,
                  ),
                ),
              ),
            ],
          ),
          ?action,
        ],
      ),
    ),
  );
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

/// Two-column grid of product tiles (three on wide screens).
class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.products});

  final List<MarketProduct> products;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 12.0;
      final columns = constraints.maxWidth >= 600 ? 3 : 2;
      final tile = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final p in products)
            SizedBox(
              width: tile,
              child: _ProductCard(product: p),
            ),
        ],
      );
    },
  );
}

/// Product tile: swipeable front/back photos, then name and best price.
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final MarketProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void open() => context.push('/market/products/${product.id}');

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: GestureDetector(
              onTap: open,
              child: ColoredBox(
                color: const Color(0xFFF4F7EC),
                child: PhotoCarousel(urls: product.photos),
              ),
            ),
          ),
          InkWell(
            onTap: open,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      product.animalType,
                      product.category,
                    ].whereType<String>().join(' · ').toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.4,
                      color: DukaColors.muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 36,
                    child: Text(
                      product.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ),
                  if (product.producer != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: ProducerLine(producer: product.producer),
                    ),
                  const SizedBox(height: 8),
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
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: DukaColors.ink,
                      ),
                    ),
                  ] else
                    Text(
                      product.sellersCount > 0
                          ? l10n.marketOutOfStock
                          : l10n.marketNotInStoresYet,
                      style: TextStyle(
                        color: product.sellersCount > 0
                            ? DukaColors.rose
                            : DukaColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (product.sellersCount > 0)
                        Text(
                          l10n.marketSellersCount(product.sellersCount),
                          style: const TextStyle(
                            fontSize: 12,
                            color: DukaColors.muted,
                          ),
                        ),
                      if (product.nearestLabel != null)
                        DistancePill(
                          label: product.nearestLabel!,
                          prefix: l10n.marketNearestShort,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
