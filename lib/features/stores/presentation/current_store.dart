import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/theme.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/presentation/auth_controller.dart';

const _prefsKey = 'odaamsterderm.current_store';

/// The store a seller's staff member is working in (null = all their
/// stores). Saved on the phone and sent with every API request, so lists,
/// POS and reports show that store only.
class CurrentStoreController extends StateNotifier<int?> {
  CurrentStoreController(this._ref) : super(null) {
    _restore();
    _ref.listen(authControllerProvider, (_, next) => _fit(next.user));
  }

  final Ref _ref;

  List<StoreRef> get stores =>
      _ref.read(authControllerProvider).user?.stores ?? const [];

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _apply(prefs.getInt(_prefsKey));
    _fit(_ref.read(authControllerProvider).user);
  }

  /// Keeps the choice valid: one store → that store; a store the person
  /// lost access to → none.
  void _fit(DukaUser? user) {
    final ids = user?.stores.map((s) => s.id).toList() ?? const <int>[];
    if (ids.length == 1) {
      _apply(ids.first);
    } else if (state != null && !ids.contains(state)) {
      _apply(null);
    }
  }

  void _apply(int? id) {
    _ref.read(apiClientProvider).storeId = id;
    state = id;
  }

  Future<void> choose(int? id) async {
    _apply(id);
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setInt(_prefsKey, id);
    }
  }
}

final currentStoreProvider =
    StateNotifierProvider<CurrentStoreController, int?>(
      (ref) => CurrentStoreController(ref),
    );

/// "Working in: Mwenge ▾" — shown when the person has more than one store.
class StoreSwitcherChip extends ConsumerWidget {
  const StoreSwitcherChip({super.key, required this.allLabel});

  final String allLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stores = ref.watch(
      authControllerProvider.select(
        (a) => a.user?.stores ?? const <StoreRef>[],
      ),
    );
    final current = ref.watch(currentStoreProvider);
    if (stores.isEmpty) return const SizedBox.shrink();

    final name =
        stores.where((s) => s.id == current).map((s) => s.name).firstOrNull ??
        allLabel;
    if (stores.length == 1) {
      return Chip(
        avatar: const Icon(Icons.storefront_outlined, size: 16),
        label: Text(stores.first.name),
      );
    }

    return PopupMenuButton<int>(
      initialValue: current ?? 0,
      onSelected: (id) =>
          ref.read(currentStoreProvider.notifier).choose(id == 0 ? null : id),
      itemBuilder: (_) => [
        PopupMenuItem(value: 0, child: Text(allLabel)),
        for (final s in stores) PopupMenuItem(value: s.id, child: Text(s.name)),
      ],
      child: Chip(
        avatar: const Icon(Icons.storefront_outlined, size: 16),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(name, overflow: TextOverflow.ellipsis)),
            const Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: DukaColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
