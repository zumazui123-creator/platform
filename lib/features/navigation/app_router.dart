import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/health_area.dart';
import '../auth/domain/auth_models.dart';
import '../auth/providers.dart';
import '../main/presentation/main_shell.dart';
import 'area_icon.dart';

/// go_router-Instanz mit Auth-Guard:
/// - nicht angemeldet → /login
/// - angemeldet auf /login → /
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterRefresh(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authStateProvider).value;
      final isAuthed = auth is Authenticated;
      final goingToAuth = state.matchedLocation == '/login';
      if (!isAuthed && !goingToAuth) return '/login';
      if (isAuthed && goingToAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const AuthGate()),
      GoRoute(path: '/', builder: (context, state) => const MainShell()),
    ],
  );
});

/// Refresh-Trigger für den Guard (auth-Zustandswechsel → notify).
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    _sub = ref.listen(authStateProvider, (_, _) => notifyListeners());
  }

  late final ProviderSubscription _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

/// Auth-Gate: zeigt Loading oder den Login-Bildschirm.
/// (Angemeldete User werden per Guard direkt nach '/' geleitet.)
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider);
    return auth.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth-Fehler: $e'))),
      data: (status) {
        if (status is Authenticated) {
          // Guard leitet um; kurzer Zwischenzustand.
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const LoginScreen();
      },
    );
  }
}

/// Login/Registrierung (nur relevant im Supabase-Modus; im Demo-Modus
/// ist die App bereits als Demo-Nutzer angemeldet).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _signUp = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final repo = ref.read(authRepositoryProvider);
    try {
      if (_signUp) {
        await repo.signUp(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      } else {
        await repo.signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
      }
      // Auth-Stream löst den Router-Guard-Redirect aus.
    } on Object catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDemo = ref.watch(authRepositoryProvider).isDemo;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconForArea(HealthArea.gesundheit),
                  const SizedBox(height: 8),
                  Text(
                    'Gesundheitsplattform',
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isDemo
                        ? 'Demo-Modus — keine echte Anmeldung'
                        : (_signUp ? 'Konto erstellen' : 'Anmelden'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_signUp)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name'),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'E-Mail'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'Gültige E-Mail eingeben'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: const InputDecoration(labelText: 'Passwort'),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Mindestens 6 Zeichen'
                        : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_signUp ? 'Konto erstellen' : 'Anmelden'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() => _signUp = !_signUp),
                    child: Text(
                      _signUp
                          ? 'Stattdessen anmelden'
                          : 'Noch kein Konto? Registrieren',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
