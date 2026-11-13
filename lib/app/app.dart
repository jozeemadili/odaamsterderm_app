import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/generated/app_localizations.dart';
import '../features/auth/presentation/auth_controller.dart';
import 'locale_controller.dart';
import 'router.dart';
import 'theme.dart';
import 'theme_mode_controller.dart';

class OdaamsterdermApp extends ConsumerWidget {
  const OdaamsterdermApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeControllerProvider);
    final mode = ref.watch(themeModeProvider);
    // The palette is read while building, so set it before anything builds.
    DukaColors.dark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
    // Sellers see their own brand colours (Settings → Business profile).
    final merchant = ref.watch(
      authControllerProvider.select((a) => a.merchant),
    );

    return MaterialApp.router(
      title: 'Amsterdam Digital',
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
      // Rebuild every screen when light/dark flips, so widgets that read
      // the palette directly pick up the new colours too.
      builder: (context, child) =>
          KeyedSubtree(key: ValueKey(DukaColors.dark), child: child!),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
