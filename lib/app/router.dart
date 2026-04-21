import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/supabase_service.dart';
import '../features/splash/presentation/pages/splash_screen_page.dart';

// Import your feature pages
import '../features/home/presentation/pages/home_page.dart';
import '../features/deen/presentation/pages/deen_hub_page.dart';
import '../features/qibla/presentation/pages/qibla_page.dart';
import '../features/circle/presentation/pages/circle_page.dart';
import '../features/circle/presentation/pages/chat_page.dart';
import '../features/circle/presentation/pages/chat_info_page.dart';
import '../features/circle/presentation/pages/add_members_page.dart';
import '../features/circle/presentation/pages/resource_gallery_page.dart';
import '../features/shorts/presentation/screens/shorts_screen.dart';
import '../features/shorts/presentation/screens/shorts_discovery_screen.dart';
import '../features/shorts/presentation/screens/create_short_screen.dart';
import '../features/shorts/presentation/screens/creator_profile_screen.dart';

// Import Auth pages
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/otp_verification_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/new_password_page.dart';
import '../core/widgets/common_widgets.dart';

// Removed mock authStateProvider

/// Production-ready GoRouter configuration
final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,

  // 🔒 Auth Guard: Redirect to login if not authenticated
  redirect: (context, state) {
    final isAuthenticated = SupabaseService.instance.currentUser != null;
    final isLoggingIn = state.matchedLocation == '/login';

    if (!isAuthenticated && !isLoggingIn) return '/login';
    if (isAuthenticated && isLoggingIn) return '/home';
    return null;
  },

  // 🔄 Rebuild router when auth state changes
  refreshListenable:
      GoRouterRefreshStream(SupabaseService.instance.authStateChanges),

  routes: [
    // 🔐 Authentication Routes
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/otp-verification',
      name: 'otp_verification',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final email = extra?['email'] as String?;
        final isRecovery = extra?['isRecovery'] as bool? ?? false;
        return OtpVerificationPage(
          email: email,
          isRecovery: isRecovery,
        );
      },
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot_password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/new-password',
      name: 'new_password',
      builder: (context, state) => const NewPasswordPage(),
    ),

    // 📱 Main Application Shell (Bottom Navigation)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationContainer(navigationShell: navigationShell);
      },
      branches: [
        // 🏠 Home Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),

        // 🕋 Deen Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/deen',
              name: 'deen',
              builder: (context, state) => const DeenHubPage(),
            ),
          ],
        ),

        // 🧭 Qibla Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/qibla',
              name: 'qibla',
              builder: (context, state) => const QiblaPage(),
            ),
          ],
        ),

        // Create Shorts
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/create',
              name: 'create',
              builder: (context, state) => const CreateShortScreen(),
            ),
          ],
        ),

        // 🎥 Shorts Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/shorts',
              name: 'shorts',
              builder: (context, state) => const ShortsScreen(),
              routes: [
                GoRoute(
                  path: 'discovery',
                  name: 'shorts_discovery',
                  builder: (context, state) => const ShortsDiscoveryScreen(),
                ),
                GoRoute(
                  path: 'create',
                  name: 'shorts_create',
                  builder: (context, state) => const CreateShortScreen(),
                ),
                GoRoute(
                  path: 'profile',
                  name: 'shorts_profile',
                  builder: (context, state) => const CreatorProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        // 👥 Community Branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              name: 'community',
              builder: (context, state) => const CommunityPage(),
              routes: [
                GoRoute(
                  path: 'chat/:chatId',
                  name: 'chat',
                  builder: (context, state) {
                    final chatId = state.pathParameters['chatId']!;
                    final title =
                        state.uri.queryParameters['title'] ?? 'Community Chat';
                    final avatar = state.uri.queryParameters['avatar'];
                    return ChatPage(
                      chatId: chatId,
                      chatTitle: title,
                      chatAvatar: avatar,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'info',
                      name: 'chat_info',
                      builder: (context, state) {
                        final chatId = state.pathParameters['chatId']!;
                        final name =
                            state.uri.queryParameters['name'] ?? 'Chat Info';
                        return ChatInfoPage(chatId: chatId, chatName: name);
                      },
                    ),
                    GoRoute(
                      path: 'resources',
                      name: 'chat_resources',
                      builder: (context, state) {
                        final chatId = state.pathParameters['chatId']!;
                        return ResourceGalleryPage(chatId: chatId);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'add-members',
                  name: 'add_members',
                  builder: (context, state) {
                    final chatId = state.uri.queryParameters['chatId'] ?? '';
                    return AddMembersPage(chatId: chatId);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // 🌍 Root / Splash
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreenPage(),
    ),
    // 🔄 Legacy Redirects
    GoRoute(
      path: '/main',
      redirect: (_, __) => '/home',
    ),
  ],

  // 🛑 Error Route
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Page not found: ${state.matchedLocation}',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/community'),
            child: const Text('Return to Community'),
          ),
        ],
      ),
    ),
  ),
);

/// Helper: Convert Riverpod Provider to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}
