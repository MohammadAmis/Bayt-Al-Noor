import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/secrets.dart';
import 'core/design_tokens.dart';
import 'features/splash/presentation/pages/splash_screen_page.dart';
import 'features/home/presentation/pages/main_navigation_container.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/otp_verification_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/new_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseSecrets.url,
    anonKey: SupabaseSecrets.anonKey,
  );

  runApp(const ProviderScope(child: NamazTimerApp()));
}

class NamazTimerApp extends StatelessWidget {
  const NamazTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreenPage(),
        '/main': (context) => const MainNavigationContainer(),
        '/settings': (context) => const SettingsPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/otp-verification': (context) => const OtpVerificationPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/new-password': (context) => const NewPasswordPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
            builder: (context) => const SplashScreenPage());
      },
    );
  }
}

// Global Navigator Key for context-less navigation if needed
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
