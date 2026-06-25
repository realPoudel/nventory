import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'design/app_theme.dart';
import 'persistence/hive_manager.dart';
import 'persistence/write_ahead_log.dart';
import 'providers.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await HiveManager.init();

  // Recover any pending transactions from a previous crash
  await WriteAheadLog.recover();

  runApp(const ProviderScope(child: NventoryApp()));
}

class NventoryApp extends ConsumerWidget {
  const NventoryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'nVentory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
