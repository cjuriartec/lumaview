import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumaview/features/auth/presentation/pages/login_page.dart';
import 'package:lumaview/features/map/presentation/pages/map_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RootShellPage extends ConsumerStatefulWidget {
  const RootShellPage({super.key});

  @override
  ConsumerState<RootShellPage> createState() => _RootShellPageState();
}

class _RootShellPageState extends ConsumerState<RootShellPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mainContent = _currentIndex == 0
        ? const MapPage()
        : const _ProfileScreen();

    return Scaffold(
      body: Stack(
        children: [
          mainContent,
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black
                      : theme.colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavIcon(
                      icon: Icons.map,
                      label: 'Mapa',
                      selected: _currentIndex == 0,
                      onTap: () {
                        setState(() {
                          _currentIndex = 0;
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    _NavIcon(
                      icon: Icons.person,
                      label: 'Perfil',
                      selected: _currentIndex == 1,
                      onTap: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePanel extends StatefulWidget {
  const _ProfilePanel();

  @override
  State<_ProfilePanel> createState() => _ProfilePanelState();
}

class _ProfilePanelState extends State<_ProfilePanel> {
  late final Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = Supabase.instance.client.auth.onAuthStateChange;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: _authStream,
      initialData: AuthState(
        auth.currentUser == null
            ? AuthChangeEvent.signedOut
            : AuthChangeEvent.signedIn,
        auth.currentSession,
      ),
      builder: (context, snapshot) {
        final user = snapshot.data?.session?.user ?? auth.currentUser;

        if (user == null) {
          return const LoginPage();
        }

        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Material(
          color: isDark ? Colors.black : theme.colorScheme.surface,
          elevation: 8,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Perfil', style: theme.textTheme.titleLarge),
                    Icon(Icons.person, color: theme.colorScheme.primary),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.7,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        child: Text(
                          (user.email ?? 'U').substring(0, 1).toUpperCase(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.email ?? 'Usuario',
                              style: theme.textTheme.titleMedium,
                            ),
                            if (user.userMetadata?['name'] is String)
                              Text(
                                user.userMetadata?['name'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Cuenta', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout),
                  title: const Text('Cerrar sesión'),
                  onTap: () async {
                    await Supabase.instance.client.auth.signOut();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileScreen extends StatefulWidget {
  const _ProfileScreen();

  @override
  State<_ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<_ProfileScreen> {
  late final Stream<AuthState> _authStream;

  @override
  void initState() {
    super.initState();
    _authStream = Supabase.instance.client.auth.onAuthStateChange;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<AuthState>(
      stream: _authStream,
      initialData: AuthState(
        auth.currentUser == null
            ? AuthChangeEvent.signedOut
            : AuthChangeEvent.signedIn,
        auth.currentSession,
      ),
      builder: (context, snapshot) {
        final user = snapshot.data?.session?.user ?? auth.currentUser;

        if (user == null) {
          return Scaffold(
            backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
            body: const SafeArea(child: LoginPage()),
          );
        }

        final metadata = user.userMetadata ?? <String, dynamic>{};
        String? avatarUrl;
        if (metadata['avatar_url'] is String &&
            (metadata['avatar_url'] as String).isNotEmpty) {
          avatarUrl = metadata['avatar_url'] as String;
        } else if (metadata['picture'] is String &&
            (metadata['picture'] as String).isNotEmpty) {
          avatarUrl = metadata['picture'] as String;
        }

        final displayName =
            (metadata['name'] ??
                    metadata['full_name'] ??
                    metadata['user_name'] ??
                    user.email ??
                    'Usuario')
                .toString();
        final email = user.email ?? '';
        final initial = displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : (email.isNotEmpty ? email[0].toUpperCase() : 'U');

        return Scaffold(
          backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: isDark ? Colors.black : theme.colorScheme.surface,
            elevation: 0,
            title: const Text('Perfil'),
          ),
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      backgroundImage: avatarUrl != null
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null
                          ? Text(initial, style: theme.textTheme.headlineMedium)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        email,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 220,
                      child: FilledButton.icon(
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                      ),
                    ),
                    const SizedBox(height: 72),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
