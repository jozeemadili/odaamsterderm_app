import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme.dart';
import '../../../l10n/l10n_extension.dart';

/// Average city speed for a car or boda boda, used for a rough travel time.
const _cityKmPerHour = 25.0;

/// "3.4 km from you right now" — follows the customer's phone location while
/// the order page is open, with a button for turn-by-turn directions.
class LiveStoreDistance extends StatefulWidget {
  const LiveStoreDistance({
    super.key,
    required this.storeLatitude,
    required this.storeLongitude,
  });

  final double storeLatitude;
  final double storeLongitude;

  @override
  State<LiveStoreDistance> createState() => _LiveStoreDistanceState();
}

enum _Status { finding, ready, permissionDenied, serviceOff, failed }

class _LiveStoreDistanceState extends State<LiveStoreDistance> {
  StreamSubscription<Position>? _subscription;
  _Status _status = _Status.finding;
  double? _meters;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    _subscription?.cancel();
    setState(() => _status = _Status.finding);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) setState(() => _status = _Status.serviceOff);
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _status = _Status.permissionDenied);
        return;
      }

      _subscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 20,
            ),
          ).listen(
            (p) {
              if (!mounted) return;
              setState(() {
                _meters = Geolocator.distanceBetween(
                  p.latitude,
                  p.longitude,
                  widget.storeLatitude,
                  widget.storeLongitude,
                );
                _status = _Status.ready;
              });
            },
            onError: (_) {
              if (mounted) setState(() => _status = _Status.failed);
            },
          );
    } catch (_) {
      if (mounted) setState(() => _status = _Status.failed);
    }
  }

  String _distanceLabel(double meters) => meters < 1000
      ? '${(meters / 10).round() * 10} m'
      : '${(meters / 1000).toStringAsFixed(meters < 10000 ? 1 : 0)} km';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final meters = _meters;

    final Widget body = switch (_status) {
      _Status.finding => Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(l10n.orderDistanceFinding),
        ],
      ),
      _Status.ready when meters != null && meters < 80 => Text(
        l10n.orderDistanceAtStore,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      _Status.ready when meters != null => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderDistanceFromYou(_distanceLabel(meters)),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          Text(
            l10n.orderDistanceEta(
              (meters / 1000 / _cityKmPerHour * 60).ceil().clamp(1, 999),
            ),
            style: const TextStyle(fontSize: 12, color: DukaColors.muted),
          ),
        ],
      ),
      _Status.serviceOff => Text(l10n.orderDistanceServiceOff),
      _Status.permissionDenied => Text(l10n.orderDistanceNeedsPermission),
      _ => Text(l10n.orderDistanceFailed),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.near_me_outlined,
                  size: 18,
                  color: DukaColors.indigo,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.orderDistanceTitle,
                  style: const TextStyle(fontSize: 12, color: DukaColors.muted),
                ),
              ],
            ),
            const SizedBox(height: 6),
            body,
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&destination=${widget.storeLatitude},${widget.storeLongitude}',
                    ),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.directions, size: 18),
                  label: Text(l10n.orderDirections),
                ),
                if (_status == _Status.permissionDenied ||
                    _status == _Status.serviceOff ||
                    _status == _Status.failed)
                  OutlinedButton(
                    onPressed: () async {
                      if (_status == _Status.serviceOff) {
                        await Geolocator.openLocationSettings();
                      } else if (await Geolocator.checkPermission() ==
                          LocationPermission.deniedForever) {
                        await Geolocator.openAppSettings();
                      }
                      _start();
                    },
                    child: Text(l10n.orderDistanceRetry),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
