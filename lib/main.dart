import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/env.dart';
import 'core/providers.dart';

/// App-Bootstrap:
/// 1. Supabase initialisieren (nur wenn konfiguriert)
/// 2. SharedPreferences initialisieren (imperativ, vor dem ProviderScope)
/// 3. ProviderScope mit Overrides + App
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Env.isSupabaseConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
      debug: false,
    );
  }

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const HealthPlatformApp(),
    ),
  );
}
