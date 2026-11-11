import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/domain/health_area.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/providers.dart';
import '../../chat/presentation/chat_panel.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../navigation/area_icon.dart';

/// Haupt-Hülle der App (nach Login) — **Mobile First**:
///
/// - **Bottom-Bar mit 4 Tabs:** Gesundheit / Fitness / Psychologie + **Coach**.
/// - **Coach-Chat unten im Tab-Bereich:** Der Chat ist ein eigener Tab und
///   ersetzt dabei das Dashboard — kein Seiten-Layout, kein FAB, kein Sheet.
/// - Kein Desktop-Sidebar-Layout: Das Smartphone-Layout skaliert unverändert
///   auf größere Bildschirme (dort einfach breiter nutzbar).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  /// Index des Coach-Tabs in der Bottom-Bar (nach den drei Health-Areas).
  static const int chatTab = 3;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  /// Aktiver Tab: 0..2 = Health-Areas, [MainShell.chatTab] = Coach-Chat.
  int _tabIndex = 0;

  /// Zuletzt gewählte Health-Area — bleibt als Chat-Kontext erhalten,
  /// wenn der User den Coach-Tabs wechselt und wieder zurückkommt.
  int _areaIndex = 0;

  bool _editing = false;

  bool get _isChat => _tabIndex == MainShell.chatTab;
  HealthArea get _area => HealthArea.values[_areaIndex];

  void _selectTab(int i) {
    setState(() {
      _tabIndex = i;
      if (i != MainShell.chatTab) _areaIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStateProvider).value;
    final isDemo =
        auth is Authenticated && ref.watch(authRepositoryProvider).isDemo;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: _isChat
            ? const Row(
                children: [
                  Icon(Icons.forum_outlined),
                  SizedBox(width: 10),
                  Text('Coach-Chat'),
                ],
              )
            : Row(
                children: [
                  iconForArea(_area),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _area.label,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _area.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        actions: [
          if (isDemo)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('Demo-Daten', style: TextStyle(fontSize: 11)),
                visualDensity: VisualDensity.compact,
              ),
            ),
          if (!_isChat)
            IconButton(
              tooltip: 'Layout bearbeiten',
              icon: Icon(
                _editing ? Icons.check : Icons.dashboard_customize_outlined,
              ),
              color: _editing ? theme.colorScheme.primary : null,
              onPressed: () => setState(() => _editing = !_editing),
            ),
          IconButton(
            tooltip: 'Darstellung wechseln',
            icon: Icon(
              ref.watch(darkModeProvider)
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => setDarkMode(ref, !ref.read(darkModeProvider)),
          ),
          _UserMenu(auth: auth),
        ],
      ),
      body: _isChat
          ? ChatPanel(area: _area)
          : DashboardScreen(area: _area, editing: _editing),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: _selectTab,
        destinations: [
          for (final area in HealthArea.values)
            NavigationDestination(icon: iconForArea(area), label: area.label),
          const NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            label: 'Coach',
          ),
        ],
      ),
    );
  }
}

class _UserMenu extends ConsumerWidget {
  const _UserMenu({required this.auth});

  final AuthStatus? auth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = auth is Authenticated ? (auth as Authenticated).user : null;
    return PopupMenuButton<String>(
      tooltip: 'Konto',
      onSelected: (action) async {
        switch (action) {
          case 'signout':
            await ref.read(authRepositoryProvider).signOut();
          case 'login':
            context.go('/login');
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Text(
            user != null ? (user.email ?? user.name) : 'Nicht angemeldet',
            style: TextStyle(color: theme.colorScheme.outline, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (user == null)
          const PopupMenuItem(value: 'login', child: Text('Anmelden'))
        else
          const PopupMenuItem(value: 'signout', child: Text('Abmelden')),
      ],
    );
  }
}
