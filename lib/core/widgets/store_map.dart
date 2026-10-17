import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme.dart';

/// Dar es Salaam — where the map opens before a location is chosen.
const defaultMapCenter = LatLng(-6.7924, 39.2083);

TileLayer _tiles() => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.odaamsterderm.app',
);

Widget _attribution() => const RichAttributionWidget(
  attributions: [TextSourceAttribution('OpenStreetMap contributors')],
);

Marker _pin(LatLng point) => Marker(
  point: point,
  width: 40,
  height: 40,
  alignment: Alignment.topCenter,
  child: const Icon(Icons.location_on, size: 40, color: DukaColors.rose),
);

/// Opens the point in Google Maps (app if installed, otherwise browser).
Future<void> openInMaps(double latitude, double longitude) => launchUrl(
  Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
  ),
  mode: LaunchMode.externalApplication,
);

/// Read-only map with a single pin.
class StoreMapView extends StatelessWidget {
  const StoreMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 200,
  });

  final double latitude;
  final double longitude;
  final double height;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 16,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            _tiles(),
            MarkerLayer(markers: [_pin(point)]),
            _attribution(),
          ],
        ),
      ),
    );
  }
}

/// Map the user taps to place a pin, with a "use my current location"
/// shortcut. Reports every change through [onChanged].
class LocationPickerMap extends StatefulWidget {
  const LocationPickerMap({
    super.key,
    required this.value,
    required this.onChanged,
    required this.useMyLocationLabel,
    required this.locationDeniedMessage,
    this.height = 280,
  });

  final LatLng? value;
  final ValueChanged<LatLng> onChanged;
  final String useMyLocationLabel;
  final String locationDeniedMessage;
  final double height;

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  final _controller = MapController();
  bool _locating = false;

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const PermissionDeniedException('Location services are off');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const PermissionDeniedException('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      final point = LatLng(position.latitude, position.longitude);
      widget.onChanged(point);
      _controller.move(point, 17);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(widget.locationDeniedMessage)));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: widget.height,
            child: FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: value ?? defaultMapCenter,
                initialZoom: value != null ? 16 : 11,
                onTap: (_, point) => widget.onChanged(point),
              ),
              children: [
                _tiles(),
                if (value != null) MarkerLayer(markers: [_pin(value)]),
                _attribution(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                value != null
                    ? '${value.latitude.toStringAsFixed(6)}, ${value.longitude.toStringAsFixed(6)}'
                    : '',
                style: const TextStyle(fontSize: 12, color: DukaColors.muted),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _locating ? null : _useMyLocation,
              icon: _locating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(widget.useMyLocationLabel),
            ),
          ],
        ),
      ],
    );
  }
}
