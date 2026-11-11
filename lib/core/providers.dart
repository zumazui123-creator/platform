import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

/// Core-Provider: Infrastruktur (Preferences, Supabase), feature-unabhängig.

/// SharedPreferences-Instanz.
/// Wird in main.dart vor dem ProviderScope initialisiert und per
/// ProviderScope.overrides injiziert (imperative Init vor dem Scope).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError(
    'sharedPreferencesProvider muss in main.dart über '
    'ProviderScope(overrides: [...]) initialisiert werden.',
  );
});

/// Ist Supabase für diese Build-Konfiguration aktiv?
final supabaseEnabledProvider = Provider<bool>(
  (ref) => Env.isSupabaseConfigured,
);

/// SupabaseClient — existiert nur, wenn konfiguriert.
/// Initialisierung erfolgt in main.dart vor dem ProviderScope.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!ref.watch(supabaseEnabledProvider)) {
    throw StateError(
      'Supabase ist nicht konfiguriert (Env.isSupabaseConfigured=false).',
    );
  }
  return Supabase.instance.client;
});

/// ID-Generator für Client-Objekte (Layouts, Bausteine).
/// UUID-artig, deterministisch genug für Client-IDs (kein Security-Kontext).
String newId(String prefix) {
  final now = DateTime.now();
  final time = now.millisecondsSinceEpoch.toRadixString(36);
  final rand = _idCounter = (_idCounter + 1) & 0xFFFFF;
  return '$prefix-$time${rand.toRadixString(36).padLeft(4, '0')}';
}

int _idCounter = 0;
