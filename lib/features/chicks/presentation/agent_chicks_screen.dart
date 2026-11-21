import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/format/currency.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/customer_google.dart';
import '../data/chick_models.dart';
import 'chick_screens.dart';

/// The agent's contracts and upcoming order days.
final agentChickSetupProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(chickRepositoryProvider).setup(),
);

const _weekdayKeys = [1, 2, 3, 4, 5, 6, 7];

String _weekdayName(BuildContext context, int iso) => DateFormat(
  'EEE',
  Localizations.localeOf(context).languageCode,
).format(DateTime(2026, 11, 22 + iso)); // 23 Nov 2026 is a Monday

/// Day-old chick sales for an agent: order days and hatchery contracts.
class AgentChicksScreen extends ConsumerWidget {
  const AgentChicksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final setup = ref.watch(agentChickSetupProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.chicksTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.agentChicksDaysTab),
              Tab(text: l10n.agentChicksContractsTab),
            ],
          ),
        ),
        floatingActionButton: setup.maybeWhen(
          data: (s) => FloatingActionButton.extended(
            key: const Key('agent-chicks-add-contract'),
            onPressed: () => _editContract(context, ref, s),
            icon: const Icon(Icons.add),
            label: Text(l10n.agentChicksAddContract),
          ),
          orElse: () => null,
        ),
        body: setup.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('$e', textAlign: TextAlign.center),
            ),
          ),
          data: (s) => TabBarView(
            children: [
              _DaysTab(setup: s),
              _ContractsTab(setup: s),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaysTab extends ConsumerWidget {
  const _DaysTab({required this.setup});

  final AgentChickSetup setup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    if (setup.days.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            setup.contracts.isEmpty
                ? l10n.agentChicksNoContracts
                : l10n.agentChicksNoDays,
            textAlign: TextAlign.center,
            style: TextStyle(color: DukaColors.muted),
          ),
        ),
      );
    }

    final byDate = <DateTime, List<AgentOrderDay>>{};
    for (final d in setup.days) {
      byDate.putIfAbsent(d.hatchDate, () => []).add(d);
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(agentChickSetupProvider.future),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          for (final entry in byDate.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Text(
                DateFormat('EEEE d MMM', lang).format(entry.key),
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final d in entry.value)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  key: Key('agent-day-${d.id}'),
                  onTap: () => _dayActions(context, ref, setup, d),
                  title: Text(
                    '${d.producer} · ${d.chickType}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: d.capBoxes == 0
                              ? 0
                              : d.bookedBoxes / d.capBoxes,
                          minHeight: 6,
                          backgroundColor: DukaColors.line,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.agentChicksBooked(d.bookedBoxes, d.capBoxes)),
                    ],
                  ),
                  trailing: Text(
                    d.statusLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: d.status == 'open'
                          ? DukaColors.leafDeep
                          : DukaColors.muted,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ContractsTab extends ConsumerWidget {
  const _ContractsTab({required this.setup});

  final AgentChickSetup setup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (setup.contracts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            l10n.agentChicksNoContracts,
            textAlign: TextAlign.center,
            style: TextStyle(color: DukaColors.muted),
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        for (final c in setup.contracts)
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              key: Key('agent-contract-${c.id}'),
              onTap: () => _editContract(context, ref, setup, contract: c),
              title: Text(
                '${c.producerName} · ${c.chickTypeName}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: c.isActive ? null : DukaColors.muted,
                ),
              ),
              subtitle: Text(
                [
                  c.weekdays.map((d) => _weekdayName(context, d)).join(', '),
                  l10n.agentChicksCap(c.capBoxes),
                  if (c.pricePerChick != null)
                    l10n.agentChicksPricePerChick(formatTzs(c.pricePerChick!)),
                  if (!c.isActive) l10n.agentChicksPaused,
                ].join(' · '),
              ),
              trailing: const Icon(Icons.edit_outlined),
            ),
          ),
      ],
    );
  }
}

Future<void> _editContract(
  BuildContext context,
  WidgetRef ref,
  AgentChickSetup setup, {
  ChickContractInfo? contract,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: DukaColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _ContractSheet(setup: setup, contract: contract),
  );
  if (saved == true) ref.invalidate(agentChickSetupProvider);
}

class _ContractSheet extends ConsumerStatefulWidget {
  const _ContractSheet({required this.setup, this.contract});

  final AgentChickSetup setup;
  final ChickContractInfo? contract;

  @override
  ConsumerState<_ContractSheet> createState() => _ContractSheetState();
}

class _ContractSheetState extends ConsumerState<_ContractSheet> {
  int? _producerId;
  final _newHatchery = TextEditingController();
  int? _typeId;
  late Set<int> _weekdays;
  late Set<int> _stores;
  late final TextEditingController _cap;
  late final TextEditingController _price;
  bool _active = true;
  bool _busy = false;
  String? _error;

  /// The "not listed" choice in the hatchery menu.
  static const _newId = -1;

  @override
  void initState() {
    super.initState();
    final c = widget.contract;
    _producerId = c?.producerId;
    _typeId = c?.chickTypeId;
    _weekdays = {...?c?.weekdays};
    if (_weekdays.isEmpty) _weekdays = {1, 4};
    _stores = {...?c?.branchIds};
    _cap = TextEditingController(text: '${c?.capBoxes ?? 100}');
    _price = TextEditingController(
      text: c?.pricePerChick != null
          ? c!.pricePerChick!.toStringAsFixed(0)
          : '',
    );
    _active = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _newHatchery.dispose();
    _cap.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    if ((_producerId == null || _producerId == _newId) &&
        _newHatchery.text.trim().isEmpty) {
      setState(() => _error = l10n.agentChicksChooseHatchery);
      return;
    }
    if (_typeId == null) {
      setState(() => _error = l10n.agentChicksChooseType);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(chickRepositoryProvider).saveContract({
        if (_producerId != null && _producerId != _newId)
          'producer_id': _producerId
        else
          'new_hatchery': _newHatchery.text.trim(),
        'chick_type_id': _typeId,
        'weekdays': (_weekdays.toList()..sort()),
        'branch_ids': _stores.toList(),
        'cap_boxes': int.tryParse(_cap.text.trim()) ?? 100,
        'price_per_chick': _price.text.trim().isEmpty
            ? null
            : double.tryParse(_price.text.trim()),
        'is_active': _active,
      }, id: widget.contract?.id);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAuthToast(context, l10n.agentChicksSaved);
    } on ApiException catch (e) {
      setState(
        () => _error =
            e.fieldError('producer_id') ??
            e.fieldError('weekdays') ??
            e.fieldError('cap_boxes') ??
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
    final s = widget.setup;

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
              widget.contract == null
                  ? l10n.agentChicksAddContract
                  : l10n.agentChicksEditContract,
              style: GoogleFonts.montserrat(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              initialValue: _producerId,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.agentChicksHatchery),
              items: [
                for (final h in s.hatcheries)
                  DropdownMenuItem(value: h.id, child: Text(h.name)),
                DropdownMenuItem(
                  value: _newId,
                  child: Text(l10n.agentChicksNewHatchery),
                ),
              ],
              onChanged: (v) => setState(() => _producerId = v),
            ),
            if (_producerId == _newId) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _newHatchery,
                decoration: InputDecoration(
                  labelText: l10n.agentChicksNewHatcheryName,
                ),
              ),
            ],
            const SizedBox(height: 10),
            DropdownButtonFormField<int>(
              initialValue: _typeId,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.agentChicksType),
              items: [
                for (final t in s.chickTypes)
                  DropdownMenuItem(value: t.id, child: Text(t.name)),
              ],
              onChanged: (v) => setState(() => _typeId = v),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.agentChicksArriveOn,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final d in _weekdayKeys)
                  FilterChip(
                    label: Text(_weekdayName(context, d)),
                    selected: _weekdays.contains(d),
                    onSelected: (on) => setState(
                      () => on ? _weekdays.add(d) : _weekdays.remove(d),
                    ),
                  ),
              ],
            ),
            if (s.stores.length > 1) ...[
              const SizedBox(height: 14),
              Text(
                l10n.agentChicksStores,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final st in s.stores)
                    FilterChip(
                      label: Text(st.name),
                      selected: _stores.contains(st.id),
                      onSelected: (on) => setState(
                        () => on ? _stores.add(st.id) : _stores.remove(st.id),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cap,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.agentChicksCapLabel,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.agentChicksPriceLabel,
                    ),
                  ),
                ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _active,
              onChanged: (v) => setState(() => _active = v),
              title: Text(l10n.agentChicksSellingNow),
            ),
            if (_error != null)
              Text(_error!, style: TextStyle(color: DukaColors.rose)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('agent-contract-save'),
                onPressed: _busy ? null : _save,
                child: Text(l10n.agentChicksSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Edit cap / price, close or reopen, delete, or see bookings of a day.
Future<void> _dayActions(
  BuildContext context,
  WidgetRef ref,
  AgentChickSetup setup,
  AgentOrderDay day,
) async {
  final changed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: DukaColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _DaySheet(setup: setup, day: day),
  );
  if (changed == true) ref.invalidate(agentChickSetupProvider);
}

class _DaySheet extends ConsumerStatefulWidget {
  const _DaySheet({required this.setup, required this.day});

  final AgentChickSetup setup;
  final AgentOrderDay day;

  @override
  ConsumerState<_DaySheet> createState() => _DaySheetState();
}

class _DaySheetState extends ConsumerState<_DaySheet> {
  late final TextEditingController _cap;
  late final TextEditingController _price;
  bool _busy = false;
  String? _error;
  List<ChickBooking>? _bookings;

  @override
  void initState() {
    super.initState();
    _cap = TextEditingController(text: '${widget.day.capBoxes}');
    _price = TextEditingController(
      text: widget.day.pricePerChick?.toStringAsFixed(0) ?? '',
    );
    if (widget.day.bookedBoxes > 0) _loadBookings();
  }

  Future<void> _loadBookings() async {
    final list = await ref
        .read(chickRepositoryProvider)
        .bookings(widget.day.id);
    if (mounted) setState(() => _bookings = list);
  }

  @override
  void dispose() {
    _cap.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.fieldError('cap_boxes') ?? e.message);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = widget.day;
    final repo = ref.read(chickRepositoryProvider);
    final lang = Localizations.localeOf(context).languageCode;

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
              '${d.producer} · ${d.chickType}',
              style: GoogleFonts.montserrat(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${DateFormat('EEEE d MMM', lang).format(d.hatchDate)} · ${l10n.agentChicksBooked(d.bookedBoxes, d.capBoxes)}',
              style: TextStyle(color: DukaColors.muted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cap,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.agentChicksCapLabel,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.agentChicksPriceLabel,
                    ),
                  ),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: DukaColors.rose)),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          () => repo.updateDay(d.id, {
                            'cap_boxes':
                                int.tryParse(_cap.text.trim()) ?? d.capBoxes,
                            'price_per_chick': _price.text.trim().isEmpty
                                ? null
                                : double.tryParse(_price.text.trim()),
                            'notes': d.notes,
                          }),
                        ),
                  child: Text(l10n.agentChicksSave),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          () =>
                              repo.updateDay(d.id, {'is_closed': !d.isClosed}),
                        ),
                  child: Text(
                    d.isClosed ? l10n.agentChicksReopen : l10n.agentChicksClose,
                  ),
                ),
                if (d.bookedBoxes == 0)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => _run(() => repo.deleteDay(d.id)),
                    child: Text(
                      l10n.agentChicksDelete,
                      style: TextStyle(color: DukaColors.rose),
                    ),
                  ),
              ],
            ),
            if (d.bookedBoxes > 0) ...[
              const SizedBox(height: 16),
              Text(
                l10n.agentChicksBookings,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (_bookings == null)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                for (final b in _bookings!)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text('${b.customerName} · ${b.reference}'),
                    subtitle: Text(
                      [?b.customerPhone, ?b.store, b.statusLabel].join(' · '),
                    ),
                    trailing: Text(
                      l10n.chicksBoxesOf(
                        b.boxes,
                        b.boxes * widget.setup.boxSize,
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
