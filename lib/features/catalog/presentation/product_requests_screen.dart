import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../l10n/l10n_extension.dart';
import '../../stores/presentation/store_controller.dart';
import '../data/agent_catalog_models.dart';
import 'catalog_controller.dart';

/// The agent's product requests and their review status.
class ProductRequestsScreen extends ConsumerWidget {
  const ProductRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final requests = ref.watch(productRequestsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogYourRequests)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/product-requests/new');
          ref.invalidate(productRequestsProvider);
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(l10n.catalogRequestProduct),
      ),
      body: requests.when(
        loading: () => const SkeletonList(),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(
                child: Text(
                  l10n.requestNone,
                  style: TextStyle(color: DukaColors.muted),
                ),
              )
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(productRequestsProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) => _RequestTile(request: list[i]),
                ),
              ),
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});

  final ProductRequestInfo request;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = request;
    final color = r.isPending
        ? Colors.orange
        : r.isRejected
        ? DukaColors.rose
        : Colors.green;
    return ListTile(
      leading: r.frontUrl == null
          ? null
          : ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: r.frontUrl!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
      title: Text(r.name),
      subtitle: Text(
        [
          [r.producer, r.packSize].whereType<String>().join(' · '),
          if (r.productName != null) l10n.requestInCatalogue(r.productName!),
          if (r.isRejected && r.reviewNotes != null) r.reviewNotes!,
        ].where((s) => s.isNotEmpty).join('\n'),
      ),
      isThreeLine: r.productName != null || r.isRejected,
      trailing: Text(
        r.statusLabel,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }
}

/// Request a missing product: name, company, pack size and two label
/// photos. Close catalogue matches are shown first.
class RequestProductScreen extends ConsumerStatefulWidget {
  const RequestProductScreen({super.key, this.initialName});

  final String? initialName;

  @override
  ConsumerState<RequestProductScreen> createState() =>
      _RequestProductScreenState();
}

class _RequestProductScreenState extends ConsumerState<RequestProductScreen> {
  late final _name = TextEditingController(text: widget.initialName ?? '');
  final _pack = TextEditingController();
  final _company = TextEditingController();
  final _notes = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController();
  int? _producerId;
  Uint8List? _front;
  Uint8List? _back;
  bool _addStock = true;
  int? _branchId;
  bool _saving = false;
  List<PickProduct> _matches = const [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if ((widget.initialName ?? '').length >= 3) _lookup();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    for (final c in [_name, _pack, _company, _notes, _price, _qty]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onNameChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _lookup);
  }

  Future<void> _lookup() async {
    final name = _name.text.trim();
    if (name.length < 3) {
      setState(() => _matches = const []);
      return;
    }
    try {
      final found = await ref
          .read(catalogRepositoryProvider)
          .similar(name, producerId: _producerId);
      if (mounted) setState(() => _matches = found);
    } on ApiException {
      // Matches are a convenience; the request still works without them.
    }
  }

  Future<void> _photo(bool front) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => front ? _front = bytes : _back = bytes);
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    if (_name.text.trim().isEmpty ||
        _pack.text.trim().isEmpty ||
        (_producerId == null && _company.text.trim().isEmpty) ||
        _front == null ||
        _back == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.requestNeedFields)));
      return;
    }
    final price = double.tryParse(_price.text.trim());
    if (_addStock && (price == null || _branchId == null)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pickNeedPriceQty)));
      return;
    }

    setState(() => _saving = true);
    try {
      await ref
          .read(catalogRepositoryProvider)
          .requestProduct(
            name: _name.text.trim(),
            producerId: _producerId,
            producerName: _company.text.trim(),
            packSize: _pack.text.trim(),
            notes: _notes.text.trim(),
            front: _front!,
            back: _back!,
            branchId: _addStock ? _branchId : null,
            unitPrice: _addStock ? price : null,
            quantity: _addStock
                ? (double.tryParse(_qty.text.trim()) ?? 0)
                : null,
          );
      ref.invalidate(productRequestsProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.requestSent)));
      if (mounted) context.pop();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _photoBox(String label, Uint8List? bytes, bool front) {
    return Expanded(
      child: InkWell(
        onTap: () => _photo(front),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            border: Border.all(color: DukaColors.muted.withAlpha(80)),
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: bytes != null
              ? Image.memory(bytes, fit: BoxFit.cover)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_camera_outlined),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final producers = ref.watch(producersProvider);
    final stores = ref.watch(storesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.requestTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            l10n.requestIntro,
            style: TextStyle(fontSize: 13, color: DukaColors.muted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            onChanged: _onNameChanged,
            decoration: InputDecoration(labelText: l10n.requestName),
          ),
          if (_matches.isNotEmpty) ...[
            const SizedBox(height: 10),
            Card(
              color: Colors.amber.withAlpha(30),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                      child: Text(
                        l10n.requestMatches,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    for (final m in _matches)
                      ListTile(
                        dense: true,
                        title: Text(m.name),
                        subtitle: Text(
                          [
                            m.producer,
                            m.variants.map((v) => v.name).join(', '),
                          ].whereType<String>().join(' · '),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.pushReplacement('/inventory/add'),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _pack,
            decoration: InputDecoration(labelText: l10n.requestPackSize),
          ),
          const SizedBox(height: 12),
          producers.maybeWhen(
            data: (list) => DropdownButtonFormField<int?>(
              initialValue: _producerId,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.requestCompany),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(l10n.requestCompanyNotListed),
                ),
                for (final p in list)
                  DropdownMenuItem(value: p.id, child: Text(p.name)),
              ],
              onChanged: (v) {
                setState(() => _producerId = v);
                _lookup();
              },
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          if (_producerId == null) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _company,
              decoration: InputDecoration(labelText: l10n.requestCompanyName),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              _photoBox(l10n.requestFront, _front, true),
              const SizedBox(width: 12),
              _photoBox(l10n.requestBack, _back, false),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notes,
            decoration: InputDecoration(labelText: l10n.requestNote),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _addStock,
            title: Text(
              l10n.requestAddStock,
              style: const TextStyle(fontSize: 13.5),
            ),
            onChanged: (v) => setState(() => _addStock = v ?? false),
          ),
          if (_addStock) ...[
            stores.maybeWhen(
              data: (list) {
                if (_branchId == null && list.isNotEmpty) {
                  _branchId = list.first.id;
                }
                return list.length < 2
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DropdownButtonFormField<int>(
                          initialValue: _branchId,
                          decoration: InputDecoration(
                            labelText: l10n.pickStore,
                          ),
                          items: [
                            for (final s in list)
                              DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              ),
                          ],
                          onChanged: (v) => setState(() => _branchId = v),
                        ),
                      );
              },
              orElse: () => const SizedBox.shrink(),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.requestSellingPrice,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _qty,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.requestQuantity,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: Text(l10n.requestSend),
          ),
        ],
      ),
    );
  }
}
