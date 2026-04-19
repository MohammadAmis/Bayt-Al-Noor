import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/supabase_service.dart';

// Import your feature pages
import '../features/community/presentation/pages/community_page.dart';
import '../features/community/presentation/pages/chat_page.dart';
import '../features/community/presentation/pages/chat_info_page.dart';
import '../features/community/presentation/pages/add_members_page.dart';
import '../features/community/presentation/pages/resource_gallery_page.dart';

/// Auth state notifier (placeholder from your auth feature)
/// Replace with your actual auth provider
final authStateProvider = StateProvider<bool>((ref) => false);

/// Production-ready GoRouter configuration
final router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  
  // 🔒 Auth Guard: Redirect to login if not authenticated
  redirect: (context, state) {
    // In Riverpod 2, context.read(authStateProvider) returns the bool state directly if using flutter_riverpod >= 2.x
    // If it fails, it might need to be explicitly cast or use .state on the controller
    final isAuthenticated = ProviderScope.containerOf(context).read(authStateProvider);
    final isLoggingIn = state.matchedLocation == '/login';
    
    if (!isAuthenticated && !isLoggingIn) return '/login';
    if (isAuthenticated && isLoggingIn) return '/community';
    return null;
  },

  // 🔄 Rebuild router when auth state changes
  refreshListenable: GoRouterRefreshStream(SupabaseService.instance.authStateChanges),

  routes: [
    // 🌍 Community Entry Point
    GoRoute(
      path: '/',
      redirect: (_, __) => '/community',
    ),
    GoRoute(
      path: '/community',
      name: 'community',
      builder: (_, __) => const CommunityPage(),
      routes: [
        // 💬 Active Chat
        GoRoute(
          path: 'chat/:chatId',
          name: 'chat',
          builder: (_, state) {
            final chatId = state.pathParameters['chatId']!;
            // Extract query params if passed via deep link
            final title = state.uri.queryParameters['title'] ?? 'Community Chat';
            final avatar = state.uri.queryParameters['avatar'];
            return ChatPage(
              chatId: chatId,
              chatTitle: title,
              chatAvatar: avatar,
            );
          },
          routes: [
            // ℹ️ Chat Info & Settings
            GoRoute(
              path: 'info',
              name: 'chat_info',
              builder: (_, state) {
                final chatId = state.pathParameters['chatId']!;
                final name = state.uri.queryParameters['name'] ?? 'Chat Info';
                return ChatInfoPage(chatId: chatId, chatName: name);
              },
            ),
            // 📁 Shared Resources
            GoRoute(
              path: 'resources',
              name: 'chat_resources',
              builder: (_, state) {
                final chatId = state.pathParameters['chatId']!;
                return ResourceGalleryPage(chatId: chatId);
              },
            ),
          ],
        ),
        // ➕ Add Members
        GoRoute(
          path: 'add-members',
          name: 'add_members',
          builder: (_, state) {
            final chatId = state.uri.queryParameters['chatId'] ?? '';
            return AddMembersPage(chatId: chatId);
          },
        ),
      ],
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