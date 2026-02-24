import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumaview/config/env/env_config.dart';
import 'package:lumaview/core/theme/app_theme.dart';
import 'package:lumaview/core/theme/providers/theme_provider.dart';
import 'package:lumaview/features/shell/presentation/pages/root_shell_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.config.supabaseUrl,
    anonKey: Env.config.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeNotifierProvider);
    final themeMode = themeModeAsync.asData?.value ?? ThemeMode.system;

    return MaterialApp(
      title: 'Lumaview',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const RootShellPage(),
    );
  }
}
