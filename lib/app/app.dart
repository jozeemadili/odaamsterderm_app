import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../features/auth/presentation/auth_controller.dart';
import 'locale_controller.dart';
import 'router.dart';
import 'theme.dart';

class OdaamsterdermApp extends ConsumerWidget {
  const OdaamsterdermApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);
    // Sellers see their own brand colours (Settings → Business profile).
    final merchant = ref.watch(
      authControllerProvider.select((a) => a.merchant),
    );

    return MaterialApp.router(
      title: 'Odaamsterderm Hub',
      debugShowCheckedModeBanner: false,
      theme: merchant == null
          ? buildDukaTheme()
          : buildDukaTheme(
              primary: colorFromHex(merchant.brandColor) ?? DukaColors.indigo,
              onPrimary: colorFromHex(merchant.brandTextColor) ?? Colors.white,
              accent:
                  colorFromHex(merchant.brandAccentColor) ?? DukaColors.gold,
              onAccent:
                  colorFromHex(merchant.brandAccentTextColor) ?? DukaColors.ink,
            ),
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
