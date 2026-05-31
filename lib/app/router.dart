import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/profile/presentation/pages/self_profile_page.dart';
import '../features/forum/presentation/pages/forum_page.dart';
import '../features/forum/presentation/pages/forum_post_detail_page.dart';
import '../features/profile/presentation/pages/public_profile_page.dart';
import '../features/forum/presentation/pages/create_post_page.dart';
import '../features/forum/presentation/pages/forum_search_page.dart';
import '../features/forum/domain/entities/post_entity.dart';

// Import Auth pages
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/otp_verification_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/new_password_page.dart';

//
import '../core/widgets/common_widgets.dart';
import '../core/providers/services_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Provider for the production-ready GoRouter configuration
final routerProvider = Provider<GoRouter>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);

  return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: false,

      // 🔒 Auth Guard: Redirect to login if not authenticated
      redirect: (context, state) {
        final isAuthenticated = supabaseService.currentUser != null;
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isAuthenticated && !isLoggingIn) return '/login';
        if (isAuthenticated && isLoggingIn) return '/home';
        return null;
      },

      // 🔄 Rebuild router when auth state changes
      refreshListenable:
          GoRouterRefreshStream(supabaseService.authStateChanges),
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

            // 👥 Community (Forum) Branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/community',
                  name: 'community',
                  builder: (context, state) => const ForumPage(),
                  routes: [
                    GoRoute(
                      path: 'detail',
                      name: 'forum_detail',
                      builder: (context, state) {
                        final post = state.extra as PostEntity;
                        return ForumPostDetailPage(post: post);
                      },
                    ),
                    GoRoute(
                      path: 'community-profile/:communityId',
                      name: 'community_profile',
                      builder: (context, state) {
                        final communityId =
                            state.pathParameters['communityId']!;
                        final name =
                            state.uri.queryParameters['name'] ?? 'Community';
                        return PublicProfilePage(
                          communityId: communityId,
                          communityName: name,
                        );
                      },
                    ),
                    GoRoute(
                      path: 'search',
                      name: 'forum_search',
                      builder: (context, state) => const ForumSearchPage(),
                    ),
                    GoRoute(
                      path: 'create-post',
                      name: 'create_post',
                      parentNavigatorKey: _rootNavigatorKey,
                      builder: (context, state) => const CreatePostPage(),
                    ),
                    GoRoute(
                      path: 'user-profile',
                      name: 'user_profile',
                      builder: (context, state) {
                        final userId = state.uri.queryParameters['userId'];
                        final name =
                            state.uri.queryParameters['name'] ?? 'User';
                        final avatar =
                            state.uri.queryParameters['avatar'] ?? '';
                        final bio = state.uri.queryParameters['bio'] ?? '';

                        return SelfProfilePage(
                          userId: userId,
                          name: name,
                          avatarUrl: avatar,
                          bio: bio,
                          isOwnProfile: false, // 👁️ viewing someone else
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),

            // 💬 Circle Branch
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/circle',
                  name: 'circle',
                  builder: (context, state) => const CirclePage(),
                  routes: [
                    GoRoute(
                      path: 'chat/:chatId',
                      name: 'chat',
                      builder: (context, state) {
                        final chatId = state.pathParameters['chatId']!;
                        final title =
                            state.uri.queryParameters['title'] ?? 'Chat';
                        final avatar = state.uri.queryParameters['avatar'];
                        final type =
                            state.uri.queryParameters['type'] ?? 'group';
                        return ChatPage(
                          chatId: chatId,
                          chatTitle: title,
                          chatAvatar: avatar,
                          chatType: type,
                        );
                      },
                      routes: [
                        GoRoute(
                          path: 'info',
                          name: 'chat_info',
                          builder: (context, state) {
                            final chatId = state.pathParameters['chatId']!;
                            final name = state.uri.queryParameters['name'] ??
                                'Chat Info';
                            final type =
                                state.uri.queryParameters['type'] ?? 'group';
                            return ChatInfoPage(
                              chatId: chatId,
                              chatName: name,
                              chatType: type,
                            );
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
                        final chatId =
                            state.uri.queryParameters['chatId'] ?? '';
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
        // ⚙️ Settings Route
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
        ),
        // 👤 Profile Routes
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return SelfProfilePage(
              userId: extra?['userId'] as String?,
              name: extra?['name'] ?? 'Guest',
              avatarUrl: extra?['avatarUrl'] ??
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBTsguL1thXHygl49n-buglmiegAxbwbxDG_0bz8DyMlY4B9PpbOsKMGjNK9LK1xRQeDx8dUwdqiVdvRz_FYFD5Uqqk2-bY4xdF1eQf9RqHESqq4ypt0k7zaDjDKLW0ELh8RVEnj-u2McOpnuf_39Nx27EZlDnizOq3GYfaQ45eQibevgJ3MnbdMjy0DpTxF_Hrc-tke3MtJ981TVt7wVc1CzSGJ70wPDhNo111GDqA5JnVPqhTyUjwaaGOpXZbKdmE3YxkoveBb4Y',
              bio: extra?['bio'] ??
                  'Seeking tranquility through reflection and prayer.',
              isOwnProfile: true, // 🙋 own account
            );
          },
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
          )
      );
});

/// Helper: Convert Riverpod Provider to Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}
