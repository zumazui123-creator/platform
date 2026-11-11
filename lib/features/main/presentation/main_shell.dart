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

/// Haupt-Hülle der App (nach Login):
///
/// - **Desktop (≥900 px):** NavigationRail (80 px) | Dashboard (~580) |
///   Chat-Spalte (340 px) — das 80/20-Layout.
/// - **Mobil:** NavigationBar unten, Chat als Bottom-Sheet über FAB.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  static const double _chatBreakpoint = 900;
  static const double _chatWidth = 340;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _areaIndex = 0;
  bool _editing = false;

  HealthArea get _area => HealthArea.values[_areaIndex];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStateProvider).value;
    final isDemo =
        auth is Authenticated && ref.watch(authRepositoryProvider).isDemo;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= MainShell._chatBreakpoint;
        return Scaffold(
          appBar: AppBar(
            titleSpacing: 8,
            title: Row(
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
          body: Row(
            children: [
              if (wide)
                NavigationRail(
                  selectedIndex: _areaIndex,
                  onDestinationSelected: (i) => setState(() => _areaIndex = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final area in HealthArea.values)
                      NavigationRailDestination(
                        icon: iconForArea(area),
                        label: Text(area.label),
                      ),
                  ],
                ),
              Expanded(
                child: DashboardScreen(area: _area, editing: _editing),
              ),
              if (wide) ...[
                const VerticalDivider(width: 1),
                SizedBox(
                  width: MainShell._chatWidth,
                  child: ChatPanel(area: _area),
                ),
              ],
            ],
          ),
          bottomNavigationBar: !wide
              ? NavigationBar(
                  selectedIndex: _areaIndex,
                  onDestinationSelected: (i) => setState(() => _areaIndex = i),
                  destinations: [
                    for (final area in HealthArea.values)
                      NavigationDestination(
                        icon: iconForArea(area),
                        label: area.label,
                      ),
                  ],
                )
              : null,
          floatingActionButton: !wide
              ? FloatingActionButton(
                  tooltip: 'Coach-Chat',
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    builder: (ctx) => SizedBox(
                      height: MediaQuery.of(ctx).size.height * 0.75,
                      child: ChatPanel(area: _area, inSheet: true),
                    ),
                  ),
                  child: const Icon(Icons.chat_bubble_outline),
                )
              : null,
        );
      },
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
