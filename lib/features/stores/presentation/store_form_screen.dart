import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/widgets/store_map.dart';
import '../../../l10n/l10n_extension.dart';
import '../data/store_models.dart';
import 'store_controller.dart';

/// Edits a store's contact details, map location, opening hours, pickup
/// instructions and marketplace switch. Pops with the saved [Store].
class StoreFormScreen extends ConsumerStatefulWidget {
  const StoreFormScreen({super.key, required this.store});

  final Store store;

  @override
  ConsumerState<StoreFormScreen> createState() => _StoreFormScreenState();
}

class _StoreFormScreenState extends ConsumerState<StoreFormScreen> {
  late final _name = TextEditingController(text: widget.store.name);
  late final _phone = TextEditingController(text: widget.store.phone);
  late final _email = TextEditingController(text: widget.store.email);
  late final _address = TextEditingController(text: widget.store.address);
  late final _city = TextEditingController(text: widget.store.city);
  late final _pickup = TextEditingController(
    text: widget.store.pickupInstructions,
  );
  late LatLng? _location = widget.store.hasLocation
      ? LatLng(widget.store.latitude!, widget.store.longitude!)
      : null;
  late bool _marketplaceEnabled = widget.store.isMarketplaceEnabled;
  late final Map<String, DayHours?> _hours = {
    for (final day in storeDays.keys)
      day: widget.store.openingHours == null
          ? const DayHours(open: '08:00', close: '18:00')
          : widget.store.openingHours![day],
  };
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _address, _city, _pickup]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _text(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _pickTime(String day, bool isOpen) async {
    final current = _hours[day]!;
    final parts = (isOpen ? current.open : current.close).split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      ),
    );
    if (picked == null) return;
    final value =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    setState(
      () => _hours[day] = isOpen
          ? DayHours(open: value, close: current.close)
          : DayHours(open: current.open, close: value),
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final saved = await ref
          .read(storeRepositoryProvider)
          .update(
            widget.store.id,
            name: _name.text.trim(),
            phone: _text(_phone),
            email: _text(_email),
            address: _text(_address),
            city: _text(_city),
            latitude: _location?.latitude,
            longitude: _location?.longitude,
            pickupInstructions: _text(_pickup),
            openingHours: _hours,
            isMarketplaceEnabled: _marketplaceEnabled,
          );
      ref.invalidate(storesProvider);
      ref.invalidate(storeDetailProvider(widget.store.id));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.storeSaved)));
        context.pop(saved);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.storeEditTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: InputDecoration(labelText: l10n.storeNameLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(labelText: l10n.storePhoneLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: l10n.storeEmailLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _address,
            decoration: InputDecoration(labelText: l10n.storeAddressLabel),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _city,
            decoration: InputDecoration(labelText: l10n.storeCityLabel),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.storeLocationTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.storeLocationHint,
            style: const TextStyle(fontSize: 12, color: DukaColors.muted),
          ),
          const SizedBox(height: 8),
          LocationPickerMap(
            value: _location,
            onChanged: (point) => setState(() => _location = point),
            useMyLocationLabel: l10n.storeUseMyLocation,
            locationDeniedMessage: l10n.storeLocationDenied,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.storeOpeningHoursTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          for (final entry in storeDays.entries)
            Row(
              children: [
                SizedBox(width: 92, child: Text(entry.value)),
                Switch(
                  value: _hours[entry.key] != null,
                  onChanged: (open) => setState(
                    () => _hours[entry.key] = open
                        ? const DayHours(open: '08:00', close: '18:00')
                        : null,
                  ),
                ),
                const SizedBox(width: 4),
                if (_hours[entry.key] == null)
                  Text(
                    l10n.storeClosed,
                    style: const TextStyle(color: DukaColors.muted),
                  )
                else ...[
                  TextButton(
                    onPressed: () => _pickTime(entry.key, true),
                    child: Text(_hours[entry.key]!.open),
                  ),
                  const Text('–'),
                  TextButton(
                    onPressed: () => _pickTime(entry.key, false),
                    child: Text(_hours[entry.key]!.close),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 16),
          TextField(
            controller: _pickup,
            maxLines: 3,
            decoration: InputDecoration(labelText: l10n.storePickupLabel),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _marketplaceEnabled,
            onChanged: (v) => setState(() => _marketplaceEnabled = v),
            title: Text(l10n.storeMarketplaceSwitch),
            subtitle: Text(
              l10n.storeMarketplaceSwitchHint,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
