import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Optional: For consistent typography

import '../core/design_tokens.dart';
import 'router.dart';

class CommunityApp extends ConsumerWidget {
  const CommunityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      title: 'Bayt-Ul-Noor',
      debugShowCheckedModeBanner: false,
      
      // 🎨 Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
          primary: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.headline.copyWith(fontSize: 18),
        ),
        cardTheme: const CardThemeData(
          color: AppColors.surfaceContainerLow,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      
      // 🌍 Localization & Typography
      localizationsDelegates: const [], // Add AppLocalizations.delegate here
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('ur')],
      
      // 🛡️ Global Error Handling
      builder: (context, child) {
        return MediaQuery(
          // Prevent system text scaling from breaking layout
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}