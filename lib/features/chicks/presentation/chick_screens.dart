import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/customer_google.dart';
import '../../market/presentation/product_post.dart';
import '../../orders/presentation/order_controller.dart';
import '../data/chick_models.dart';
import '../data/chick_repository.dart';

final chickRepositoryProvider = Provider(
  (ref) => ChickRepository(ref.watch(apiClientProvider)),
);

/// Types, hatcheries and open hatch dates; refreshed when a screen opens.
final chickCatalogueProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(chickRepositoryProvider).catalogue(),
);

String _lang(BuildContext context) =>
    Localizations.localeOf(context).languageCode;

String _day(BuildContext context, DateTime d) =>
    DateFormat('EEE d MMM', _lang(context)).format(d);

/// Shared frame: loading skeleton, error with retry, then [builder].
class _ChickFrame extends ConsumerWidget {
  const _ChickFrame({required this.title, required this.builder});

  final String title;
  final Widget Function(BuildContext context, ChickCatalogue c) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogue = ref.watch(chickCatalogueProvider);
    return Scaffold(
      backgroundColor: DukaColors.bg,
      appBar: AppBar(title: Text(title)),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(chickCatalogueProvider.future),
        child: catalogue.when(
          data: (c) => builder(context, c),
          loading: () => ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              Shimmer(
                child: Column(
                  children: [
                    Bone(height: 120, radius: 18),
                    SizedBox(height: 12),
                    Bone(height: 120, radius: 18),
                    SizedBox(height: 12),
                    Bone(height: 120, radius: 18),
                  ],
                ),
              ),
            ],
          ),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton(
                  onPressed: () => ref.invalidate(chickCatalogueProvider),
                  child: Text(context.l10n.marketRetry),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text, {this.good = true});

  final String text;
  final bool good;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: good ? DukaColors.leafTint : DukaColors.soft,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: good ? DukaColors.leafDeep : DukaColors.muted,
      ),
    ),
  );
}

BoxDecoration _card() => BoxDecoration(
  color: DukaColors.card,
  borderRadius: BorderRadius.circular(18),
  border: Border.all(color: DukaColors.line),
);

/// Step 1: Broiler, Layers, Sasso, Tanbro.
class ChickTypesScreen extends StatelessWidget {
  const ChickTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _ChickFrame(
      title: l10n.chicksTitle,
      builder: (context, c) {
        final lang = _lang(context);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              l10n.chicksIntro(c.boxSize),
              style: TextStyle(color: DukaColors.muted, height: 1.4),
            ),
            const SizedBox(height: 14),
            for (final t in c.types)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  key: Key('chick-type-${t.code}'),
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => context.push('/market/chicks/${t.code}'),
                  child: Ink(
                    padding: const EdgeInsets.all(16),
                    decoration: _card(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.name,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: DukaColors.ink,
                                    ),
                                  ),
                                  if (t.nameSw != null && t.nameSw != t.name)
                                    Text(
                                      t.nameSw!,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        color: DukaColors.muted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            _Pill(t.purposeFor(lang)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.summaryFor(lang),
                          style: const TextStyle(height: 1.35),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          t.hatcheries.isEmpty
                              ? l10n.chicksHatcheryCount(0)
                              : '${l10n.chicksHatcheryCount(t.hatcheries.length)} · ${l10n.chicksBoxesLeft(t.boxesAvailable)}',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: t.hatcheries.isEmpty
                                ? DukaColors.muted
                                : DukaColors.leafDeep,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Step 2: the type's description and the hatcheries that make it.
class ChickHatcheriesScreen extends StatelessWidget {
  const ChickHatcheriesScreen({super.key, required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _ChickFrame(
      title: l10n.chicksTitle,
      builder: (context, c) {
        final lang = _lang(context);
        final t = c.type(type);
        if (t == null) return Center(child: Text(l10n.chicksNoDates));
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _card(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.subtitleFor(lang),
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _Pill(t.purposeFor(lang)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.descriptionFor(lang),
                    style: const TextStyle(height: 1.45),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.chicksHatcheries,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            if (t.hatcheries.isEmpty)
              Text(
                l10n.chicksNoDates,
                style: TextStyle(color: DukaColors.muted),
              ),
            for (final h in t.hatcheries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  key: Key('chick-hatchery-${h.slug}'),
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => context.push('/market/chicks/$type/${h.slug}'),
                  child: Ink(
                    padding: const EdgeInsets.all(12),
                    decoration: _card(),
                    child: Row(
                      children: [
                        RingAvatar(name: h.name, imageUrl: h.logoUrl, size: 50),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              if (h.location != null)
                                Text(
                                  h.location!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: DukaColors.muted,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                h.nextHatchDate != null
                                    ? '${l10n.chicksNextHatch(_day(context, h.nextHatchDate!))} · ${l10n.chicksBoxesLeft(h.boxesAvailable)}'
                                    : l10n.chicksFullyBooked,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: h.nextHatchDate != null
                                      ? DukaColors.leafDeep
                                      : DukaColors.rose,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: DukaColors.muted),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Step 3 and 4: the hatchery's hatch dates; tapping an open one books it.
class ChickDatesScreen extends ConsumerWidget {
  const ChickDatesScreen({
    super.key,
    required this.type,
    required this.hatchery,
  });

  final String type;
  final String hatchery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _ChickFrame(
      title: l10n.chicksChooseDate,
      builder: (context, c) {
        final lang = _lang(context);
        final t = c.type(type);
        final h = t?.hatcheries.where((x) => x.slug == hatchery).firstOrNull;
        if (t == null || h == null) {
          return Center(child: Text(l10n.chicksNoDates));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                RingAvatar(name: h.name, imageUrl: h.logoUrl, size: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${h.name} · ${t.name}',
                    style: GoogleFonts.montserrat(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            if (h.description != null) ...[
              const SizedBox(height: 8),
              Text(h.description!, style: TextStyle(color: DukaColors.muted)),
            ],
            const SizedBox(height: 14),
            for (final d in h.dates)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  key: Key('chick-date-${d.id}'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: d.isOpen
                      ? () => _book(context, ref, c, t, h, d)
                      : null,
                  child: Opacity(
                    opacity: d.isOpen ? 1 : 0.6,
                    child: Ink(
                      padding: const EdgeInsets.all(14),
                      decoration: _card(),
                      child: Row(
                        children: [
                          Icon(
                            Icons.egg_outlined,
                            color: d.isOpen
                                ? DukaColors.indigo
                                : DukaColors.muted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _day(context, d.hatchDate),
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  l10n.chicksOrderBy(
                                    _day(context, d.orderCutoffDate),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: DukaColors.muted,
                                  ),
                                ),
                                if (c.showPrices && d.pricePerBox != null)
                                  Text(
                                    l10n.chicksPerBox(
                                      formatTzs(d.pricePerBox!),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                if (d.notes != null)
                                  Text(
                                    d.notes!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          _Pill(
                            d.isOpen
                                ? l10n.chicksBoxesLeft(d.boxesAvailable)
                                : d.statusFor(lang),
                            good: d.isOpen,
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

  Future<void> _book(
    BuildContext context,
    WidgetRef ref,
    ChickCatalogue c,
    ChickTypeInfo t,
    Hatchery h,
    HatchDate d,
  ) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      context.push('/login');
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: DukaColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _BookSheet(catalogue: c, type: t, hatchery: h, date: d),
    );
  }
}

class _BookSheet extends ConsumerStatefulWidget {
  const _BookSheet({
    required this.catalogue,
    required this.type,
    required this.hatchery,
    required this.date,
  });

  final ChickCatalogue catalogue;
  final ChickTypeInfo type;
  final Hatchery hatchery;
  final HatchDate date;

  @override
  ConsumerState<_BookSheet> createState() => _BookSheetState();
}

class _BookSheetState extends ConsumerState<_BookSheet> {
  int _boxes = 1;
  int? _storeId;
  late final TextEditingController _phone;
  final _note = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(
      text: ref.read(authControllerProvider).user?.phone ?? '',
    );
    _storeId = widget.catalogue.pickupStores.firstOrNull?.id;
  }

  @override
  void dispose() {
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final storeId = _storeId;
    if (storeId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final order = await ref
          .read(chickRepositoryProvider)
          .book(
            hatchDateId: widget.date.id,
            boxes: _boxes,
            storeId: storeId,
            phone: _phone.text.trim(),
            note: _note.text.trim(),
          );
      ref.invalidate(chickCatalogueProvider);
      ref.invalidate(myOrdersProvider);
      if (!mounted) return;
      final message = context.l10n.chicksBooked(order.reference);
      Navigator.of(context).pop();
      showAuthToast(context, message);
      context.push('/my-orders/${order.id}');
    } on ApiException catch (e) {
      setState(
        () => _error =
            e.fieldError('boxes') ??
            e.fieldError('hatch_date') ??
            e.fieldError('store') ??
            e.message,
      );
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = widget.catalogue;
    final d = widget.date;
    final max = d.boxesAvailable;
    final isCustomer = ref.watch(
      authControllerProvider.select((a) => a.user?.isCustomer ?? false),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.type.name} · ${widget.hatchery.name}',
              style: GoogleFonts.montserrat(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${_day(context, d.hatchDate)} · ${l10n.chicksBoxesLeft(max)}',
              style: TextStyle(color: DukaColors.muted),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.chicksBoxes(c.boxSize),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton.outlined(
                  key: const Key('chick-boxes-minus'),
                  onPressed: _boxes > 1 ? () => setState(() => _boxes--) : null,
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    '$_boxes',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton.outlined(
                  key: const Key('chick-boxes-plus'),
                  onPressed: _boxes < max
                      ? () => setState(() => _boxes++)
                      : null,
                  icon: const Icon(Icons.add),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.chicksTotalChicks(_boxes * c.boxSize),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            if (c.showPrices && d.pricePerBox != null) ...[
              const SizedBox(height: 4),
              Text(
                formatTzs(d.pricePerBox! * _boxes),
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              initialValue: _storeId,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.chicksCollectAt),
              items: [
                for (final s in c.pickupStores)
                  DropdownMenuItem(
                    value: s.id,
                    child: Text(s.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _storeId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: l10n.chicksPhone),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              decoration: InputDecoration(labelText: l10n.chicksNote),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: TextStyle(color: DukaColors.rose)),
            ],
            const SizedBox(height: 12),
            Text(
              c.showPrices
                  ? l10n.chicksPayAtPickup
                  : l10n.cartPriceConfirmedByStore,
              style: TextStyle(fontSize: 12, color: DukaColors.muted),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('chick-book'),
                onPressed: _busy || _storeId == null
                    ? null
                    : isCustomer
                    ? _submit
                    : () {
                        Navigator.of(context).pop();
                        context.push('/login');
                      },
                child: Text(
                  isCustomer ? l10n.chicksBook : l10n.chicksSignInToBook,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
