import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/secrets.dart';
import 'core/design_tokens.dart';
import 'app/router.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'core/utils/app_lifecycle_notifier.dart';
import 'core/providers/notification_orchestrator_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('settingsBox');
  await Hive.openBox('forum_drafts');
  await Hive.openBox('submission_queue');

  await Supabase.initialize(
    url: SupabaseSecrets.url,
    anonKey: SupabaseSecrets.anonKey,
  );

  // ✅ Initialize timezones
  tz.initializeTimeZones();
  try {
    tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
  } catch (e) {
    debugPrint('⚠️ Could not set local timezone from name: $e. Falling back to UTC.');
  }

  runApp(
    ProviderScope(
      child: Builder(
        builder: (context) {
          // ✅ Attach lifecycle observer early
          final ref = ProviderScope.containerOf(context);
          AppLifecycleNotifier(ref);
          return const NamazTimerApp();
        },
      ),
    ),
  );
}

class NamazTimerApp extends ConsumerWidget {
  const NamazTimerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Activate orchestrator to start listening for setting changes
    ref.watch(notificationOrchestratorProvider);
    
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      routerConfig: router,
      title: 'Bayt-Al-Noor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
          error: AppColors.error,
        ),
        textTheme: TextTheme(
          displayLarge:
              AppTypography.display.copyWith(color: AppColors.onSurface),
          headlineLarge:
              AppTypography.headline.copyWith(color: AppColors.onSurface),
          headlineMedium: AppTypography.headline
              .copyWith(color: AppColors.onSurface, fontSize: 24),
          titleLarge: AppTypography.title.copyWith(color: AppColors.onSurface),
          titleMedium: AppTypography.title
              .copyWith(color: AppColors.onSurface, fontSize: 16),
          bodyLarge: AppTypography.body.copyWith(color: AppColors.onSurface),
          bodyMedium: AppTypography.body
              .copyWith(color: AppColors.onSurface, fontSize: 14),
          labelLarge:
              AppTypography.label.copyWith(color: AppColors.onSurfaceVariant),
        ),
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
          space: 1,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceContainerLowest,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppShapes.lgRadius,
          ),
        ),
      ),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}


