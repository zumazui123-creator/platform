import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart'
    show supabaseEnabledProvider, supabaseClientProvider;
import 'data/demo_auth_repository.dart';
import 'data/supabase_auth_repository.dart';
import 'domain/auth_models.dart';

/// Repository-Wahl: Supabase wenn konfiguriert, sonst Demo.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (ref.watch(supabaseEnabledProvider)) {
    return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
  }
  final demo = DemoAuthRepository();
  demo.emitInitial();
  ref.onDispose(demo.dispose);
  return demo;
});

/// Auth-Zustand (Stream → AsyncValue).
final authStateProvider = StreamProvider<AuthStatus>(
  (ref) => ref.watch(authRepositoryProvider).authState,
);
