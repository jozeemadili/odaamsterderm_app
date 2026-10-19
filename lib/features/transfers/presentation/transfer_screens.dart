import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/api/api_exception.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../stores/presentation/current_store.dart';
import '../data/transfer_models.dart';
import '../data/transfer_repository.dart';

final transferRepositoryProvider = Provider(
  (ref) => TransferRepository(ref.watch(apiClientProvider)),
);

final transferListProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(transferRepositoryProvider).list(),
);

final transferDetailProvider = FutureProvider.autoDispose
    .family<StockTransfer, int>(
      (ref, id) => ref.watch(transferRepositoryProvider).get(id),
    );

final _dateFormat = DateFormat('d MMM yyyy, HH:mm');

/// Stock transfers in and out of the stores the person works in.
class TransferListScreen extends ConsumerWidget {
  const TransferListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(transferListProvider);
    final storeIds =
        (ref.watch(authControllerProvider).user?.stores ?? const [])
            .map((s) => s.id)
            .toSet();

    return Scaffold(
      appBar: AppBar(title: const Text('Stock transfers')),
      floatingActionButton: async.valueOrNull?.canSend == true
          ? FloatingActionButton.extended(
              onPressed: () async {
                final created = await context.push<StockTransfer>(
                  '/transfers/new',
                  extra: async.value,
                );
                ref.invalidate(transferListProvider);
                if (created != null && context.mounted) {
                  context.push('/transfers/${created.id}');
                }
              },
              icon: const Icon(Icons.swap_horiz),
              label: const Text('New transfer'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(transferListProvider),
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            children: [
              const SizedBox(height: 80),
              Center(
                child: Text(
                  'Could not load transfers.\n$e',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          data: (list) {
            if (list.items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'No transfers yet. Owners and managers can send stock from one store to another; staff at the other store then receive it.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: list.items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final t = list.items[index];
                final waitingForMe =
                    t.isOnTheWay && storeIds.contains(t.toStore.id);
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
                  title: Text('${t.fromStore.name} → ${t.toStore.name}'),
                  subtitle: Text(
                    '${t.number} · ${t.itemsCount ?? t.items.length} products · ${t.sentAt != null ? _dateFormat.format(t.sentAt!) : ''}',
                  ),
                  trailing: _StatusChip(
                    status: t.status,
                    waitingForMe: waitingForMe,
                  ),
                  onTap: () async {
                    await context.push('/transfers/${t.id}');
                    ref.invalidate(transferListProvider);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, this.waitingForMe = false});

  final String status;
  final bool waitingForMe;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'sent' => (waitingForMe ? 'Receive' : 'On the way', Colors.orange),
      'received' => ('Received', Colors.green),
      _ => ('Cancelled', Colors.redAccent),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class TransferDetailScreen extends ConsumerStatefulWidget {
  const TransferDetailScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<TransferDetailScreen> createState() =>
      _TransferDetailScreenState();
}

class _TransferDetailScreenState extends ConsumerState<TransferDetailScreen> {
  bool _busy = false;

  Future<void> _act(StockTransfer t, bool receive) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(receive ? 'Receive stock?' : 'Cancel transfer?'),
        content: Text(
          receive
              ? 'Confirm the products have arrived in ${t.toStore.name}. They will be added to its stock.'
              : 'The products go back into ${t.fromStore.name}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(receive ? 'Receive' : 'Cancel transfer'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _busy = true);
    try {
      final repo = ref.read(transferRepositoryProvider);
      await (receive ? repo.receive(t.id) : repo.cancel(t.id));
      ref.invalidate(transferDetailProvider(t.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              receive
                  ? 'Received. The stock is now in ${t.toStore.name}.'
                  : 'Cancelled. The stock is back in ${t.fromStore.name}.',
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(transferDetailProvider(widget.id));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(async.valueOrNull?.number ?? 'Transfer'),
        actions: [
          if (async.valueOrNull?.noteUrl != null)
            IconButton(
              tooltip: 'Transfer note',
              icon: const Icon(Icons.print_outlined),
              onPressed: () => launchUrl(
                Uri.parse(async.value!.noteUrl!),
                mode: LaunchMode.externalApplication,
              ),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load transfer.\n$e')),
        data: (t) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.fromStore.name,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const Icon(Icons.arrow_forward),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            t.toStore.name,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _StatusChip(status: t.status, waitingForMe: t.canReceive),
                    const SizedBox(height: 8),
                    if (t.sentAt != null)
                      Text(
                        'Sent ${_dateFormat.format(t.sentAt!)} by ${t.sentBy ?? '—'}',
                      ),
                    if (t.receivedAt != null)
                      Text(
                        'Received ${_dateFormat.format(t.receivedAt!)} by ${t.receivedBy ?? '—'}',
                      ),
                    if (t.notes != null && t.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(t.notes!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  for (final line in t.items)
                    ListTile(
                      dense: true,
                      title: Text(line.name),
                      trailing: Text(
                        '${formatQty(line.quantity)} ${line.unit ?? ''}'.trim(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (t.canReceive)
              FilledButton.icon(
                onPressed: _busy ? null : () => _act(t, true),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Receive stock'),
              ),
            if (t.canCancel)
              TextButton(
                onPressed: _busy ? null : () => _act(t, false),
                child: const Text('Cancel transfer'),
              ),
          ],
        ),
      ),
    );
  }
}

/// Owner/manager picks the two stores and the quantities to send.
class TransferFormScreen extends ConsumerStatefulWidget {
  const TransferFormScreen({super.key, this.list});

  final TransferList? list;

  @override
  ConsumerState<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends ConsumerState<TransferFormScreen> {
  int? _from;
  int? _to;
  final _notes = TextEditingController();
  final _search = TextEditingController();
  List<TransferStock> _stock = const [];
  final Map<int, double> _quantities = {};
  final Map<int, TransferStock> _picked = {};
  bool _loadingStock = false;
  bool _sending = false;
  String? _error;

  List<StoreRef> get _fromStores => widget.list?.fromStores ?? const [];
  List<StoreRef> get _toStores =>
      (widget.list?.toStores ?? const []).where((s) => s.id != _from).toList();

  @override
  void initState() {
    super.initState();
    final current = ref.read(currentStoreProvider);
    if (_fromStores.any((s) => s.id == current)) {
      _from = current;
    } else if (_fromStores.length == 1) {
      _from = _fromStores.first.id;
    }
    if (_from != null) _loadStock();
  }

  @override
  void dispose() {
    _notes.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadStock() async {
    if (_from == null) return;
    setState(() => _loadingStock = true);
    try {
      final stock = await ref
          .read(transferRepositoryProvider)
          .stock(_from!, search: _search.text.trim());
      if (mounted) setState(() => _stock = stock);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loadingStock = false);
    }
  }

  Future<void> _editQuantity(TransferStock item) async {
    final controller = TextEditingController(
      text: _quantities[item.id] != null
          ? formatQty(_quantities[item.id]!)
          : '',
    );
    final value = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Quantity to send',
            helperText:
                '${formatQty(item.available)} ${item.unit ?? ''} available'
                    .trim(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 0.0),
            child: const Text('Remove'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              double.tryParse(controller.text.trim()) ?? 0,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (value == null) return;
    setState(() {
      if (value <= 0) {
        _quantities.remove(item.id);
        _picked.remove(item.id);
      } else {
        _quantities[item.id] = value;
        _picked[item.id] = item;
      }
    });
  }

  Future<void> _send() async {
    if (_from == null || _to == null || _quantities.isEmpty) {
      setState(
        () => _error = 'Choose both stores and at least one product to send.',
      );
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final transfer = await ref
          .read(transferRepositoryProvider)
          .send(
            fromStoreId: _from!,
            toStoreId: _to!,
            quantities: _quantities,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
      if (mounted) context.pop(transfer);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New transfer')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _sending ? null : _send,
            icon: const Icon(Icons.send),
            label: Text(
              _quantities.isEmpty
                  ? 'Send transfer'
                  : 'Send ${_quantities.length} product${_quantities.length == 1 ? '' : 's'}',
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<int>(
            initialValue: _from,
            decoration: const InputDecoration(labelText: 'Send from'),
            items: [
              for (final s in _fromStores)
                DropdownMenuItem(value: s.id, child: Text(s.name)),
            ],
            onChanged: (id) {
              setState(() {
                _from = id;
                if (_to == id) _to = null;
                _quantities.clear();
                _picked.clear();
                _stock = const [];
              });
              _loadStock();
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: ValueKey('to-$_from'),
            initialValue: _to,
            decoration: const InputDecoration(labelText: 'Send to'),
            items: [
              for (final s in _toStores)
                DropdownMenuItem(value: s.id, child: Text(s.name)),
            ],
            onChanged: (id) => setState(() => _to = id),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'e.g. Driver Hamisi, Toyota T 123',
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_picked.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Sending', style: Theme.of(context).textTheme.titleSmall),
            for (final item in _picked.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.name),
                trailing: Text(
                  '${formatQty(_quantities[item.id]!)} ${item.unit ?? ''}'
                      .trim(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                onTap: () => _editQuantity(item),
              ),
          ],
          if (_from != null) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _search,
              decoration: InputDecoration(
                labelText: 'Find product',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _loadingStock
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              onSubmitted: (_) => _loadStock(),
              onChanged: (_) => _loadStock(),
            ),
            for (final item in _stock)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.name),
                subtitle: Text(
                  '${formatQty(item.available)} ${item.unit ?? ''} available'
                      .trim(),
                ),
                trailing: Icon(
                  _quantities.containsKey(item.id)
                      ? Icons.check_circle
                      : Icons.add_circle_outline,
                ),
                onTap: () => _editQuantity(item),
              ),
          ],
        ],
      ),
    );
  }
}
