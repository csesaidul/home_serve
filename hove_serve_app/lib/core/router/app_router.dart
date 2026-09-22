import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/provider/screens/provider_home_screen.dart';
import '../../features/provider/screens/provider_profile_screen.dart';
import '../../features/provider/models/provider_models.dart';
import '../../features/booking/screens/booking_screen.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _RouterRefreshNotifier();
  ref.onDispose(refreshNotifier.dispose);
  ref.listen<AuthState>(authProvider, (_, __) => refreshNotifier.notify());

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final claims = authState.claims;
      final location = state.matchedLocation;
      final isPublicRoute = location == '/splash' ||
          location == '/login' ||
          location == '/register' ||
          location == '/otp-verify';

      if (claims == null) {
        return isPublicRoute ? null : '/login';
      }

      if (isPublicRoute) return _defaultAuthenticatedRoute(claims);
      if (location == '/provider' &&
          !_hasCapability(claims, 'provider_verified')) {
        return '/home';
      }
      if (location == '/admin' && !_hasCapability(claims, 'is_admin')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginScreen(prefillPhone: state.extra as String?),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) =>
            OtpVerifyScreen(localPhone: state.extra as String? ?? ''),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const ProviderHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/booking',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Bookings'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Messages'),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Profile'),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/provider/:userId',
        builder: (context, state) => ProviderProfileScreen(
          userId: int.parse(state.pathParameters['userId']!),
        ),
      ),
      GoRoute(
        path: '/booking/new',
        builder: (context, state) => BookingScreen(
          provider: state.extra as ProviderProfileItem,
        ),
      ),
      GoRoute(
        path: '/provider',
        redirect: (context, state) => '/provider/3',
      ),
      GoRoute(
        path: '/provider-profile',
        redirect: (context, state) => '/provider',
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const PlaceholderScreen(title: 'Admin'),
      ),
    ],
  );
});

String _defaultAuthenticatedRoute(Map<String, dynamic> claims) {
  if (_hasCapability(claims, 'is_admin')) return '/admin';
  return '/home';
}

bool _hasCapability(Map<String, dynamic> claims, String key) {
  final value = claims[key];
  return value == true || value == 1 || value == '1' || value == 'true';
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
