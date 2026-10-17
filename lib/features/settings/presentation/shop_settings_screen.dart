import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/locale_controller.dart';
import '../../../app/theme.dart';
import '../../../l10n/l10n_extension.dart';
import '../../auth/presentation/auth_controller.dart';

class ShopSettingsScreen extends ConsumerWidget {
  const ShopSettingsScreen({super.key});

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final currentLocale = ref.read(localeControllerProvider) ??
        Localizations.localeOf(context);

    final picked = await showModalBottomSheet<Locale>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.languagePickerTitle,
                    style: Theme.of(context).textTheme.titleSmall),
              ),
            ),
            ListTile(
              title: Text(l10n.languageEnglish),
              trailing: currentLocale.languageCode == 'en'
                  ? const Icon(Icons.check, color: DukaColors.indigo)
                  : null,
              onTap: () => Navigator.pop(context, const Locale('en')),
            ),
            ListTile(
              title: Text(l10n.languageKiswahili),
              trailing: currentLocale.languageCode == 'sw'
                  ? const Icon(Icons.check, color: DukaColors.indigo)
                  : null,
              onTap: () => Navigator.pop(context, const Locale('sw')),
            ),
          ],
        ),
      ),
    );

    if (picked != null) {
      await ref.read(localeControllerProvider.notifier).setLocale(picked);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isOwner =
        ref.watch(authControllerProvider).user?.role == 'merchant_owner';
    final currentLocale =
        ref.watch(localeControllerProvider) ?? Localizations.localeOf(context);
    final languageSubtitle = currentLocale.languageCode == 'sw'
        ? l10n.languageKiswahili
        : l10n.languageEnglish;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopSettingsTitle)),
      body: ListView(
        children: [
          _SettingsTile(
            icon: Icons.storefront_outlined,
            title: l10n.shopSettingsProfileTitle,
            subtitle: l10n.shopSettingsProfileSubtitle,
            onTap: () => context.push('/settings/profile'),
          ),
          _SettingsTile(
            icon: Icons.badge_outlined,
            title: l10n.shopSettingsStaffTitle,
            subtitle: isOwner
                ? l10n.shopSettingsStaffSubtitleOwner
                : l10n.shopSettingsStaffSubtitleStaff,
            onTap: () => context.push('/settings/staff'),
          ),
          _SettingsTile(
            icon: Icons.fact_check_outlined,
            title: l10n.shopSettingsKycTitle,
            subtitle: l10n.shopSettingsKycSubtitle,
            onTap: () => context.push('/settings/kyc'),
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: l10n.shopSettingsLanguageTitle,
            subtitle: languageSubtitle,
            onTap: () => _pickLanguage(context, ref),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
