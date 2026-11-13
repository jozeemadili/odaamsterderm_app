import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_client.dart';
import '../../../core/format/currency.dart';
import '../../../core/widgets/duka_logo_mark.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../l10n/l10n_extension.dart';
import '../../ai/data/ai_models.dart';
import '../../ai/presentation/ai_providers.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/market_models.dart';
import 'location_sheet.dart';
import 'market_controller.dart';

/// Amsterdam Group's own range, featured first on the home screen.
const _featuredBrand = 'Amsterdam Group';

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

/// Public marketplace. Search (with Ask AI inside the search bar), stores
/// as story circles, animal chips, Amsterdam Group picks, then every
/// product as an Instagram-style post that keeps loading as you scroll.
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
  final _scroll = ScrollController();

  // The feed: pages loaded so far.
  final List<MarketProduct> _items = [];
  int _page = 0;
  bool _hasMore = true;
  bool _loading = false;
  Object? _error;

  /// Bumped on every new query so answers to an old query are dropped.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_maybeLoadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// Without a location "nearest" can't apply — the API falls back to price.
  MarketSort _sortFor(MarketLocation? from) =>
      from == null && _sort == MarketSort.nearest ? MarketSort.price : _sort;

  /// Loads the next page once the reader is within a few posts of the end.
  void _maybeLoadMore() {
    // After an error, wait for the retry button rather than looping.
    if (_error == null &&
        _scroll.hasClients &&
        _scroll.position.extentAfter < 1200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    final generation = _generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final from = ref.read(marketLocationProvider);
      final result = await ref
          .read(marketRepositoryProvider)
          .productsPage(
            search: _search,
            animalTypeId: _animalTypeId,
            sort: _sortFor(from),
            inStock: _inStock,
            from: from,
            page: _page + 1,
          );
      if (!mounted || generation != _generation) return;
      setState(() {
        _items.addAll(result.items);
        _page++;
        _hasMore = result.hasMore;
        _loading = false;
      });
      // A short page may not fill the screen, so no scroll would follow.
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
    } catch (e) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  /// Starts the feed again from page one (new search, filter or sort).
  Future<void> _reload() {
    _generation++;
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _loading = false;
      _error = null;
    });
    if (_scroll.hasClients && _scroll.offset > 0) _scroll.jumpTo(0);
    return _loadMore();
  }

  void _update(VoidCallback change) {
    change();
    _reload();
  }

  /// Opens the farm assistant, with what's in the search box as the question.
  void _openAssistant([String? question]) {
    final q = (question ?? _searchController.text).trim();
    context.push(
      q.isEmpty
          ? '/market/ai-order'
          : '/market/ai-order?q=${Uri.encodeQueryComponent(q)}',
    );
  }

  void _showBrand(String brand) {
    _searchController.text = brand;
    _update(() => _search = brand);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final from = ref.watch(marketLocationProvider);
    ref.listen(marketLocationProvider, (_, _) => _reload());
    final user = ref.watch(authControllerProvider).user;
    final sort = _sortFor(from);
    final animals = ref.watch(marketFiltersProvider);
    final ai = ref.watch(aiConfigProvider).valueOrNull ?? AiConfig.off;
    final aiAvailable = ai.searchEnabled || ai.orderEnabled;
    final landing = _search.isEmpty && _animalTypeId == null;

    return Scaffold(
      backgroundColor: DukaColors.bg,
      appBar: AppBar(
        backgroundColor: DukaColors.card,
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
                  side: BorderSide(color: DukaColors.line),
                ),
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_cart_outlined, size: 20),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(92),
          child: Container(
            color: DukaColors.card,
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
                      () => _update(() => _search = value.trim()),
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
        onRefresh: () {
          ref.invalidate(_brandProvider);
          ref.invalidate(_storesProvider);
          ref.invalidate(aiConfigProvider);
          return _reload();
        },
        child: CustomScrollView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverList.list(
                children: [
                  if (landing)
                    ref
                        .watch(_storesProvider(from))
                        .maybeWhen(
                          data: (stores) => _StoriesRow(stores: stores),
                          loading: () => const Padding(
                            padding: EdgeInsets.only(bottom: 14),
                            child: SkeletonStrip.stories(),
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                  SizedBox(
                    height: 38,
                    child: animals.maybeWhen(
                      data: (f) => ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _Chip(
                            label: l10n.marketAllAnimals,
                            selected: _animalTypeId == null,
                            onTap: () => _update(() => _animalTypeId = null),
                          ),
                          for (final a in [
                            for (final g in f.animalTypes) ...[
                              g,
                              if (_animalTypeId != null &&
                                  (_animalTypeId == g.id ||
                                      g.children.any(
                                        (c) => c.id == _animalTypeId,
                                      )))
                                ...g.children,
                            ],
                          ])
                            _Chip(
                              label: _shortName(a.name),
                              selected: _animalTypeId == a.id,
                              onTap: () => _update(() => _animalTypeId = a.id),
                            ),
                        ],
                      ),
                      loading: () => const Shimmer(
                        child: Row(
                          children: [
                            Bone(width: 90, height: 38, radius: 19),
                            SizedBox(width: 8),
                            Bone(width: 70, height: 38, radius: 19),
                            SizedBox(width: 8),
                            Bone(width: 64, height: 38, radius: 19),
                            SizedBox(width: 8),
                            Bone(width: 80, height: 38, radius: 19),
                          ],
                        ),
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
                        onSort: (s) => _update(() => _sort = s),
                        onInStock: (v) => _update(() => _inStock = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList.builder(
                itemCount: _items.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FeedPost(
                    product: _items[i],
                    onAskAi: aiAvailable
                        ? () => _openAssistant(
                            l10n.marketAskAboutQuery(_items[i].displayName),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _FeedFooter(
                loading: _loading || (_hasMore && _error == null),
                error: _error,
                empty: _items.isEmpty,
                onRetry: _loadMore,
              ),
            ),
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
        color: DukaColors.soft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: DukaColors.muted),
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
            Icon(
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
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: DukaColors.ink,
                ),
              ),
            ),
            Icon(Icons.expand_more, size: 18, color: DukaColors.muted),
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
    if (list.isEmpty && !products.isLoading) return const SizedBox.shrink();

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
          if (list.isEmpty)
            const SkeletonStrip.cards()
          else
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
                      color: DukaColors.card,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: DukaColors.line),
                      ),
                      child: InkWell(
                        onTap: () => context.push('/market/products/${p.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 100,
                              color: DukaColors.soft,
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
                                        : TextStyle(
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
          color: DukaColors.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: DukaColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune, size: 15, color: DukaColors.ink),
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
      color: selected ? DukaColors.indigo : DukaColors.card,
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

/// Initials for a circle avatar: "Amsterdam Group" → "AG".
String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w[0].toUpperCase()).join();
}

/// A circle with the maroon-to-leaf ring, like a story on Instagram.
class _RingAvatar extends StatelessWidget {
  const _RingAvatar({required this.name, this.imageUrl, this.size = 64});

  final String name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ring = size > 40 ? 2.5 : 1.8;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ring),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [DukaColors.indigo, DukaColors.leaf],
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(ring),
        decoration: BoxDecoration(
          color: DukaColors.card,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.contain,
                  errorWidget: (_, _, _) => _initialsBox(),
                )
              : _initialsBox(),
        ),
      ),
    );
  }

  Widget _initialsBox() => Container(
    color: DukaColors.maroonTint,
    alignment: Alignment.center,
    child: Text(
      _initials(name),
      style: GoogleFonts.montserrat(
        fontSize: size * 0.28,
        fontWeight: FontWeight.w800,
        color: DukaColors.indigo,
      ),
    ),
  );
}

/// Stores as story circles across the top of the shop.
class _StoriesRow extends StatelessWidget {
  const _StoriesRow({required this.stores});

  final List<PublicStore> stores;

  @override
  Widget build(BuildContext context) {
    if (stores.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: stores.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final s = stores[i];
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => context.push('/market/stores/${s.id}'),
              child: SizedBox(
                width: 70,
                child: Column(
                  children: [
                    _RingAvatar(name: s.name, imageUrl: s.sellerLogoUrl),
                    const SizedBox(height: 6),
                    Text(
                      s.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A product as an Instagram-style post: maker on top, a big swipeable
/// photo, actions, then price, name and pack sizes as the caption.
class _FeedPost extends StatefulWidget {
  const _FeedPost({required this.product, this.onAskAi});

  final MarketProduct product;
  final VoidCallback? onAskAi;

  @override
  State<_FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<_FeedPost> {
  int _photo = 0;

  void _open() => context.push('/market/products/${widget.product.id}');

  void _share() {
    final p = widget.product;
    final site = apiBaseUrl.replaceFirst(RegExp(r'/api/v\d+/?$'), '');
    final link = p.slug != null ? '$site/products/${p.slug}' : site;
    SharePlus.instance.share(ShareParams(text: '${p.displayName}\n$link'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = widget.product;
    final maker = p.producer?.name ?? p.brand ?? 'Amsterdam Digital';
    final subtitle = [
      ?(p.category ?? p.animalType),
      ?p.nearestLabel,
    ].join(' · ');
    final photos = p.photos;

    return Container(
      decoration: BoxDecoration(
        color: DukaColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DukaColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Maker, like the account that posted it.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                _RingAvatar(
                  name: maker,
                  imageUrl: p.producer?.logoUrl,
                  size: 36,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        maker,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: DukaColors.muted,
                          ),
                        ),
                    ],
                  ),
                ),
                if (p.minPrice != null && p.availableQuantity > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: DukaColors.leafTint,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.marketAvailable,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: DukaColors.leafDeep,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // The photo — swipe for the back of the pack.
          GestureDetector(
            onTap: _open,
            child: AspectRatio(
              // No photo yet: a shorter placeholder instead of an empty square.
              aspectRatio: photos.isEmpty ? 2 : 1,
              child: Container(
                color: DukaColors.soft,
                child: photos.isEmpty
                    ? Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 56,
                          color: DukaColors.muted,
                        ),
                      )
                    : Stack(
                        children: [
                          PageView.builder(
                            itemCount: photos.length,
                            onPageChanged: (i) => setState(() => _photo = i),
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.all(20),
                              child: CachedNetworkImage(
                                imageUrl: photos[i],
                                fit: BoxFit.contain,
                                placeholder: (_, _) => const SizedBox.shrink(),
                                errorWidget: (_, _, _) => Icon(
                                  Icons.broken_image_outlined,
                                  color: DukaColors.muted,
                                ),
                              ),
                            ),
                          ),
                          if (photos.length > 1)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${_photo + 1}/${photos.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),

          // Actions, then the dots under the photo.
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
            child: Row(
              children: [
                if (widget.onAskAi != null)
                  IconButton(
                    tooltip: l10n.marketAskAbout,
                    onPressed: widget.onAskAi,
                    icon: Icon(
                      Icons.auto_awesome_outlined,
                      color: DukaColors.indigo,
                    ),
                  ),
                IconButton(
                  tooltip: l10n.marketShare,
                  onPressed: _share,
                  icon: Icon(Icons.send_outlined, color: DukaColors.ink),
                ),
                Expanded(
                  child: photos.length > 1
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < photos.length; i++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                width: i == _photo ? 7 : 6,
                                height: i == _photo ? 7 : 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == _photo
                                      ? DukaColors.indigo
                                      : DukaColors.line,
                                ),
                              ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                FilledButton(
                  onPressed: _open,
                  style: FilledButton.styleFrom(
                    backgroundColor: DukaColors.leaf,
                    foregroundColor: DukaColors.ink,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  child: Text(l10n.marketFeedView),
                ),
              ],
            ),
          ),

          // Caption: price, then name and pack sizes.
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.minPrice != null
                      ? formatTzs(p.minPrice!)
                      : p.sellersCount > 0
                      ? l10n.marketOutOfStock
                      : l10n.marketNotInStoresYet,
                  style: p.minPrice != null
                      ? GoogleFonts.montserrat(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: DukaColors.ink,
                        )
                      : TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: p.sellersCount > 0
                              ? DukaColors.rose
                              : DukaColors.muted,
                        ),
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: p.displayName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (p.packRange != null)
                        TextSpan(
                          text: '  ${p.packRange}',
                          style: TextStyle(color: DukaColors.muted),
                        ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Under the feed: a spinner while the next page loads, a retry on error,
/// or "all caught up" at the very end.
class _FeedFooter extends StatelessWidget {
  const _FeedFooter({
    required this.loading,
    required this.error,
    required this.empty,
    required this.onRetry,
  });

  final bool loading;
  final Object? error;
  final bool empty;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          children: [
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(color: DukaColors.muted),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: Text(l10n.marketRetry)),
          ],
        ),
      );
    }
    if (loading) {
      // The first page shows two placeholder posts; later pages one.
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        child: Column(
          children: [
            for (var i = 0; i < (empty ? 2 : 1); i++)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonFeedPost(),
              ),
          ],
        ),
      );
    }
    if (empty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          l10n.marketNoProducts,
          textAlign: TextAlign.center,
          style: TextStyle(color: DukaColors.muted),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 12, 32, 40),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [DukaColors.indigo, DukaColors.leaf],
              ),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.marketAllCaughtUp,
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.marketAllCaughtUpBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: DukaColors.muted),
          ),
        ],
      ),
    );
  }
}
