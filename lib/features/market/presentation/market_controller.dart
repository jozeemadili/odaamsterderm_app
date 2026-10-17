import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/market_models.dart';
import '../data/market_repository.dart';

final marketRepositoryProvider = Provider(
  (ref) => MarketRepository(ref.watch(apiClientProvider)),
);

final marketFiltersProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(marketRepositoryProvider).filters(),
);

const _prefsKey = 'odaamsterderm.market_location';

/// The location the marketplace ranks stores from. Restored from the device
/// (or the signed-in customer's saved location) and persisted on change;
/// customers' choices are also saved to their profile.
class MarketLocationController extends StateNotifier<MarketLocation?> {
  MarketLocationController(this._ref) : super(null) {
    _restore();
  }

  final Ref _ref;

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey);
    if (saved != null && saved.length >= 2) {
      final lat = double.tryParse(saved[0]);
      final lng = double.tryParse(saved[1]);
      if (lat != null && lng != null) {
        state = MarketLocation(
          latitude: lat,
          longitude: lng,
          label: saved.length > 2 ? saved[2] : null,
        );
        return;
      }
    }

    final user = _ref.read(authControllerProvider).user;
    if (user?.latitude != null && user?.longitude != null) {
      state = MarketLocation(
        latitude: user!.latitude!,
        longitude: user.longitude!,
        label: user.locationLabel,
      );
    }
  }

  Future<void> set(MarketLocation location) async {
    state = location;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, [
      '${location.latitude}',
      '${location.longitude}',
      location.label ?? '',
    ]);

    final auth = _ref.read(authControllerProvider);
    if (auth.user?.isCustomer ?? false) {
      try {
        final user = await _ref
            .read(authRepositoryProvider)
            .updateCustomerProfile(
              latitude: location.latitude,
              longitude: location.longitude,
              locationLabel: location.label,
            );
        _ref.read(authControllerProvider.notifier).updateUser(user);
      } catch (_) {
        // Saving to the profile is a convenience; the local choice stands.
      }
    }
  }
}

final marketLocationProvider =
    StateNotifierProvider<MarketLocationController, MarketLocation?>(
      (ref) => MarketLocationController(ref),
    );
