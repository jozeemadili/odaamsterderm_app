import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_exception.dart';
import '../../auth/data/auth_models.dart';
import '../../auth/presentation/auth_controller.dart';
import 'settings_controller.dart';

const _brandColorSwatches = [
  '#01162F',
  '#14532D',
  '#0C4A6E',
  '#7F1D1D',
  '#78350F',
  '#1F2937',
  '#0B5FFF',
  '#8E24AA',
];

const _accentColorSwatches = [
  '#C9972E',
  '#84CC16',
  '#F97316',
  '#FDE68A',
  '#38BDF8',
  '#DC2626',
  '#F4B400',
  '#10B981',
];

/// Ready-made [main, accent] pairs.
const _palettes = {
  'Navy & gold': ['#01162F', '#C9972E'],
  'Forest & lime': ['#14532D', '#84CC16'],
  'Ocean & coral': ['#0C4A6E', '#F97316'],
  'Maroon & cream': ['#7F1D1D', '#FDE68A'],
  'Earth & sky': ['#78350F', '#38BDF8'],
  'Charcoal & red': ['#1F2937', '#DC2626'],
};

Color _hex(String hex) => Color(int.parse('FF${hex.substring(1)}', radix: 16));

/// White or dark text, whichever reads better on [c].
Color _inkOn(Color c) =>
    c.computeLuminance() > 0.45 ? const Color(0xFF01162F) : Colors.white;

class MerchantProfileScreen extends ConsumerWidget {
  const MerchantProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final merchantAsync = ref.watch(merchantProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Business profile')),
      body: merchantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Could not load your business profile.\n$e',
            textAlign: TextAlign.center,
          ),
        ),
        data: (merchant) => _MerchantProfileForm(merchant: merchant),
      ),
    );
  }
}

class _MerchantProfileForm extends ConsumerStatefulWidget {
  const _MerchantProfileForm({required this.merchant});

  final DukaMerchant merchant;

  @override
  ConsumerState<_MerchantProfileForm> createState() =>
      _MerchantProfileFormState();
}

class _MerchantProfileFormState extends ConsumerState<_MerchantProfileForm> {
  late final _businessNameController = TextEditingController(
    text: widget.merchant.businessName,
  );
  late final _ownerNameController = TextEditingController(
    text: widget.merchant.ownerName ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.merchant.phone ?? '',
  );
  late final _addressController = TextEditingController(
    text: widget.merchant.physicalAddress ?? '',
  );
  late final _cityController = TextEditingController(
    text: widget.merchant.city ?? '',
  );
  late int? _businessTypeId = widget.merchant.businessTypeId;
  late int? _regionId = widget.merchant.regionId;
  late String _brandColor = widget.merchant.brandColor;
  late String _accentColor = widget.merchant.brandAccentColor;
  bool _submitting = false;
  bool _uploadingLogo = false;
  String? _error;

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _pickLogo() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _uploadingLogo = true);
    try {
      final updated = await ref
          .read(merchantSettingsRepositoryProvider)
          .uploadLogo(File(picked.path));
      ref.read(authControllerProvider.notifier).updateMerchant(updated);
      ref.invalidate(merchantProfileProvider);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _uploadingLogo = false);
    }
  }

  Future<void> _submit() async {
    if (_businessNameController.text.trim().isEmpty) {
      setState(() => _error = 'Business name is required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final updated = await ref
          .read(merchantSettingsRepositoryProvider)
          .update(
            businessName: _businessNameController.text.trim(),
            ownerName: _ownerNameController.text.trim().isEmpty
                ? null
                : _ownerNameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            businessTypeId: _businessTypeId,
            physicalAddress: _emptyToNull(_addressController.text),
            regionId: _regionId,
            city: _emptyToNull(_cityController.text),
            brandColor: _brandColor,
            brandAccentColor: _accentColor,
          );
      ref.read(authControllerProvider.notifier).updateMerchant(updated);
      ref.invalidate(merchantProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessTypesAsync = ref.watch(businessTypesProvider);
    final regionsAsync = ref.watch(regionsProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _uploadingLogo ? null : _pickLogo,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    backgroundImage: widget.merchant.logoUrl != null
                        ? CachedNetworkImageProvider(widget.merchant.logoUrl!)
                        : null,
                    child: widget.merchant.logoUrl == null
                        ? const Icon(Icons.storefront_outlined, size: 36)
                        : null,
                  ),
                  if (_uploadingLogo) const CircularProgressIndicator(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _businessNameController,
            decoration: const InputDecoration(labelText: 'Business name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ownerNameController,
            decoration: const InputDecoration(labelText: 'Owner name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          businessTypesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
            data: (types) => DropdownButtonFormField<int?>(
              initialValue: _businessTypeId,
              decoration: const InputDecoration(
                labelText: 'Business type (optional)',
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Not set')),
                for (final t in types)
                  DropdownMenuItem(value: t.id, child: Text(t.name)),
              ],
              onChanged: (v) => setState(() => _businessTypeId = v),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              labelText: 'Physical address (optional)',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: regionsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (regions) => DropdownButtonFormField<int?>(
                    initialValue: _regionId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Region (optional)',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Not set'),
                      ),
                      for (final r in regions)
                        DropdownMenuItem(value: r.id, child: Text(r.name)),
                    ],
                    onChanged: (v) => setState(() => _regionId = v),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(
                    labelText: 'City (optional)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Brand colours', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          const Text(
            'Used on your receipts, invoices, your store page and this app.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in _palettes.entries)
                ActionChip(
                  avatar: CircleAvatar(
                    backgroundColor: _hex(entry.value[0]),
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: _hex(entry.value[1]),
                    ),
                  ),
                  label: Text(entry.key),
                  onPressed: () => setState(() {
                    _brandColor = entry.value[0];
                    _accentColor = entry.value[1];
                  }),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Main colour',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _Swatches(
            colors: _brandColorSwatches,
            selected: _brandColor,
            onSelect: (hex) => setState(() => _brandColor = hex),
          ),
          const SizedBox(height: 14),
          const Text(
            'Accent colour',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          _Swatches(
            colors: _accentColorSwatches,
            selected: _accentColor,
            onSelect: (hex) => setState(() => _accentColor = hex),
          ),
          const SizedBox(height: 14),
          _BrandPreview(
            name: widget.merchant.businessName,
            logoUrl: widget.merchant.logoUrl,
            main: _hex(_brandColor),
            accent: _hex(_accentColor),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save changes'),
          ),
        ],
      ),
    );
  }
}

class _Swatches extends StatelessWidget {
  const _Swatches({
    required this.colors,
    required this.selected,
    required this.onSelect,
  });

  final List<String> colors;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 10,
    runSpacing: 10,
    children: [
      for (final hex in colors)
        GestureDetector(
          onTap: () => onSelect(hex),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: _hex(hex),
            child: selected.toUpperCase() == hex.toUpperCase()
                ? Icon(Icons.check, color: _inkOn(_hex(hex)), size: 18)
                : null,
          ),
        ),
    ],
  );
}

/// How a receipt header looks in the chosen colours.
class _BrandPreview extends StatelessWidget {
  const _BrandPreview({
    required this.name,
    required this.logoUrl,
    required this.main,
    required this.accent,
  });

  final String name;
  final String? logoUrl;
  final Color main;
  final Color accent;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: main,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (logoUrl != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: logoUrl!,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: _inkOn(main),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 5, color: accent),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Expanded(child: Text('Total')),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'TZS 90,000',
                  style: TextStyle(
                    color: _inkOn(accent),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
