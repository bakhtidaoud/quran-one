import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_one/app/router/router.dart';
import 'package:quran_one/core/theme/theme.dart';
import 'package:quran_one/presentation/theme/theme_controller.dart';

class QuranOneApp extends ConsumerWidget {
  const QuranOneApp({super.key});

  /// Twelve UI languages at launch. Six of them are right-to-left.
  static const supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
    Locale('id'),
    Locale('ur'),
    Locale('tr'),
    Locale('ms'),
    Locale('bn'),
    Locale('es'),
    Locale('de'),
    Locale('ru'),
    Locale('fa'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final controller = ref.watch(themeControllerProvider.notifier);
    ref.watch(themeControllerProvider);
    final sizes = ref.watch(readingSizeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final mode = controller.resolveWithPlatform(platformBrightness);

    // Honours the OS "reduce motion" switch. Reading this here rather than
    // per-animation is what makes the setting reliable.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final effectiveLocale =
        locale ?? Locale(Localizations.maybeLocaleOf(context)?.languageCode ?? 'en');

    final theme = buildTheme(
      QThemeInput(
        mode: mode,
        locale: effectiveLocale,
        mushafSize: sizes.mushaf,
        translationSize: sizes.translation,
        reduceMotion: reduceMotion,
      ),
    );

    return MaterialApp.router(
      title: 'Quran One',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: theme,
      darkTheme: theme,
      locale: locale,
      supportedLocales: supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Text scale is never clamped. A user at 200% has chosen 200%.
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
