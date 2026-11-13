import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme.dart';
import '../../../core/format/currency.dart';
import '../../../core/widgets/distance_pill.dart';
import '../../../core/widgets/duka_logo_mark.dart';
import '../../../core/widgets/store_brand_header.dart';
import '../../../l10n/l10n_extension.dart';
import '../../ai/data/ai_models.dart';
import '../../ai/presentation/ai_providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/market_models.dart';
import 'location_sheet.dart';
import 'market_controller.dart';

/// Amsterdam Group's own range, featured first on the home screen.
const _featuredBrand = 'Amsterdam Group';

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
      ref.watch(marketRepositoryProvider).stores(from: from, limit: 6),
);

/// "Other poultry (ducks, turkeys…)" → "Other poultry".
String _shortName(String name) => name.replaceAll(RegExp(r'\s*\(.*\)$'), '');

/// Public marketplace: a compact store front. Search (with Ask AI inside
/// the search bar), animal chips, Amsterdam Group picks and every product
/// as an easy-to-scan row.
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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Opens the farm assistant, with what's in the search box as the question.
  void _openAssistant() {
    final q = _searchController.text.trim();
    context.push(
      q.isEmpty
          ? '/market/ai-order'
          : '/market/ai-order?q=${Uri.encodeQueryComponent(q)}',
    );
  }

  void _showBrand(String brand) {
    _searchController.text = brand;
    setState(() => _search = brand);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final from = ref.watch(marketLocationProvider);
    final user = ref.watch(authControllerProvider).user;
    // Without a location "nearest" can't apply — the API falls back to price.
    final sort = from == null && _sort == MarketSort.nearest
        ? MarketSort.price
        : _sort;
    final products = ref.watch(
      _productsProvider((
        search: _search,
        animalTypeId: _animalTypeId,
        sort: sort,
        inStock: _inStock,
        from: from,
      )),
    );
    final animals = ref.watch(marketFiltersProvider);
    final ai = ref.watch(aiConfigProvider).valueOrNull ?? AiConfig.off;
    final aiAvailable = ai.searchEnabled || ai.orderEnabled;
    final landing = _search.isEmpty && _animalTypeId == null;

    return Scaffold(
      backgroundColor: DukaColors.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 16,
        title: Row(
          children: [
            const DukaLogoMark(size: 28),
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
              style: const TextStyle(fontSize: 17),
            ),
          ],
        ),
        actions: [
          if (user == null)
            TextButton(
              onPressed: () => context.push('/login'),
              child: Text(l10n.marketSignIn),
            )
          else if (user.isCustomer)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton.outlined(
                tooltip: l10n.navCart,
                style: IconButton.styleFrom(
                  side: const BorderSide(color: DukaColors.line),
                ),
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_cart_outlined, size: 20),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(92),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchPill(
                  controller: _searchController,
                  showAi: aiAvailable,
                  onAskAi: _openAssistant,
                  onChanged: (value) {
                    _debounce?.cancel();
                    _debounce = Timer(
                      const Duration(milliseconds: 350),
                      () => setState(() => _search = value.trim()),
                    );
                  },
                ),
                const SizedBox(height: 6),
                _LocationLine(from: from),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_productsProvider);
          ref.invalidate(_brandProvider);
          ref.invalidate(_storesProvider);
          ref.invalidate(aiConfigProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            if (landing) ...[const _SlimHero(), const SizedBox(height: 14)],
            SizedBox(
              height: 38,
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
                      for (final g in f.animalTypes) ...[
                        g,
                        if (_animalTypeId != null &&
                            (_animalTypeId == g.id ||
                                g.children.any((c) => c.id == _animalTypeId)))
                          ...g.children,
                      ],
                    ])
                      _Chip(
                        label: _shortName(a.name),
                        selected: _animalTypeId == a.id,
                        onTap: () => setState(() => _animalTypeId = a.id),
                      ),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ),
            if (landing)
              _PicksRow(
                title: l10n.marketPicks(_featuredBrand),
                products: ref.watch(
                  _brandProvider((brand: _featuredBrand, from: from)),
                ),
                onSeeAll: () => _showBrand(_featuredBrand),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SectionTitle(
                    title: _search.isNotEmpty
                        ? _search
                        : l10n.marketAllProducts,
                  ),
                ),
                _SortButton(
                  sort: sort,
                  canNearest: from != null,
                  inStock: _inStock,
                  onSort: (s) => setState(() => _sort = s),
                  onInStock: (v) => setState(() => _inStock = v),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                        for (final p in list)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _ProductRow(product: p),
                          ),
                      ],
                    ),
            ),
            if (landing) ...[
              const SizedBox(height: 18),
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
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () =>
                                    context.push('/market/stores/${s.id}'),
                                child: StoreBrandHeader(store: s),
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
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: GoogleFonts.montserrat(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: DukaColors.ink,
    ),
  );
}

/// One search pill with the Ask AI button inside it.
class _SearchPill extends StatelessWidget {
  const _SearchPill({
    required this.controller,
    required this.showAi,
    required this.onAskAi,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool showAi;
  final VoidCallback onAskAi;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      height: 46,
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2EC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 20, color: DukaColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const Key('market-search'),
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.marketSearchHint,
                isDense: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (showAi)
            FilledButton.icon(
              key: const Key('ask-ai-button'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 38),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: onAskAi,
              icon: const Icon(
                Icons.auto_awesome,
                size: 15,
                color: Color(0xFFC9E89E),
              ),
              label: Text(l10n.aiAskAi),
            ),
        ],
      ),
    );
  }
}

/// "Near Tegeta" under the search bar; tap to change it.
class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.from});

  final MarketLocation? from;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => showMarketLocationSheet(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 15,
              color: DukaColors.indigo,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                from == null
                    ? l10n.marketSetLocation
                    : l10n.marketNear(from!.label ?? l10n.marketMyLocation),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: DukaColors.ink,
                ),
              ),
            ),
            const Icon(Icons.expand_more, size: 18, color: DukaColors.muted),
          ],
        ),
      ),
    );
  }
}

/// A slim welcome strip: green glow, the wave, two short lines.
class _SlimHero extends StatelessWidget {
  const _SlimHero();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 120,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.6, -0.8),
            radius: 1.6,
            colors: [
              Colors.white,
              Color(0xFFF4F9E4),
              Color(0xFFCFE88E),
              Color(0xFFA3D05A),
            ],
            stops: [0, 0.4, 0.8, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 30,
              child: Image.asset(
                'assets/images/hero-wave.webp',
                fit: BoxFit.fitWidth,
                alignment: const Alignment(0, 0.35),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.marketHeroTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      color: DukaColors.indigo,
                      fontSize: 15,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.marketHeroBody,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: DukaColors.ink.withValues(alpha: 0.8),
                      fontSize: 11.5,
                      height: 1.35,
                    ),
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

/// "Amsterdam Group picks": small swipeable cards.
class _PicksRow extends StatelessWidget {
  const _PicksRow({
    required this.title,
    required this.products,
    required this.onSeeAll,
  });

  final String title;
  final AsyncValue<List<MarketProduct>> products;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final list = (products.valueOrNull ?? const <MarketProduct>[])
        .where((p) => p.photos.isNotEmpty)
        .toList();
    if (list.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _SectionTitle(title: title)),
              TextButton(onPressed: onSeeAll, child: Text(l10n.marketSeeAll)),
            ],
          ),
          SizedBox(
            height: 176,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final p = list[i];
                return SizedBox(
                  width: 128,
                  child: Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: DukaColors.line),
                    ),
                    child: InkWell(
                      onTap: () => context.push('/market/products/${p.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 100,
                            color: const Color(0xFFF4F7EC),
                            padding: const EdgeInsets.all(6),
                            child: Image.network(
                              p.photos.first,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(9, 7, 9, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.displayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  p.minPrice != null
                                      ? formatTzs(p.minPrice!)
                                      : l10n.marketNotInStoresYet,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: p.minPrice != null
                                      ? GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: DukaColors.ink,
                                        )
                                      : const TextStyle(
                                          fontSize: 11.5,
                                          color: DukaColors.muted,
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Sort order and "available now" in one compact menu.
class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.sort,
    required this.canNearest,
    required this.inStock,
    required this.onSort,
    required this.onInStock,
  });

  final MarketSort sort;
  final bool canNearest;
  final bool inStock;
  final ValueChanged<MarketSort> onSort;
  final ValueChanged<bool> onInStock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String label(MarketSort s) => switch (s) {
      MarketSort.nearest => l10n.marketSortNearest,
      MarketSort.price => l10n.marketSortPrice,
      MarketSort.availability => l10n.marketSortAvailability,
    };

    return PopupMenuButton<Object>(
      tooltip: l10n.marketSortBy,
      onSelected: (v) => v is MarketSort ? onSort(v) : onInStock(!inStock),
      itemBuilder: (_) => [
        for (final s in MarketSort.values)
          CheckedPopupMenuItem<Object>(
            value: s,
            checked: sort == s,
            enabled: s != MarketSort.nearest || canNearest,
            child: Text(label(s)),
          ),
        const PopupMenuDivider(),
        CheckedPopupMenuItem<Object>(
          value: 'in_stock',
          checked: inStock,
          child: Text(l10n.marketInStockOnly),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: DukaColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune, size: 15, color: DukaColors.ink),
            const SizedBox(width: 5),
            Text(
              label(sort),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
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
    child: Material(
      color: selected ? DukaColors.indigo : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? DukaColors.indigo : DukaColors.line),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : DukaColors.ink,
            ),
          ),
        ),
      ),
    ),
  );
}

/// A product as one easy-to-scan row: photo, name, maker and packs, price.
class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final MarketProduct product;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = product;
    final maker = p.producer?.name ?? p.brand;
    final details = [if (maker != null) 'by $maker', ?p.packRange].join(' · ');

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: DukaColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/market/products/${p.id}'),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 76,
                height: 76,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7EC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: p.photos.isEmpty
                    ? const Icon(
                        Icons.inventory_2_outlined,
                        color: DukaColors.muted,
                      )
                    : Image.network(p.photos.first, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (details.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          details,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: DukaColors.muted,
                          ),
                        ),
                      ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            p.minPrice != null
                                ? formatTzs(p.minPrice!)
                                : p.sellersCount > 0
                                ? l10n.marketOutOfStock
                                : l10n.marketNotInStoresYet,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: p.minPrice != null
                                ? GoogleFonts.montserrat(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: DukaColors.ink,
                                  )
                                : TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: p.sellersCount > 0
                                        ? DukaColors.rose
                                        : DukaColors.muted,
                                  ),
                          ),
                        ),
                        if (p.nearestLabel != null) ...[
                          const SizedBox(width: 6),
                          DistancePill(label: p.nearestLabel!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: DukaColors.leaf,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: DukaColors.ink,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
