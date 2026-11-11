import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/app_router.dart';

/// Root-Widget: MaterialApp mit Material-3-Themes (Light/Dark) und
/// go_router-Navigation (Auth-Guard inklusive).
class HealthPlatformApp extends ConsumerWidget {
  const HealthPlatformApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Gesundheitsplattform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}

/// Light/Dark-Mode (persistiert in SharedPreferences).
final darkModeProvider = NotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool('dark_mode') ?? false;

  /// Setzt den Modus und persistiert die Präferenz.
  void set(bool value) {
    state = value;
    ref.read(sharedPreferencesProvider).setBool('dark_mode', value);
  }
}

/// Setzt den Dark-Mode und persistiert die Präferenz.
void setDarkMode(WidgetRef ref, bool value) {
  ref.read(darkModeProvider.notifier).set(value);
}
