import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/providers/auth_state.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../widgets/placeholder_screen.dart';

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
      final isPublicRoute =
          location == '/splash' ||
          location == '/login' ||
          location == '/register' ||
          location == '/otp-verify';

      if (claims == null) {
        return isPublicRoute ? null : '/login';
      }

      if (isPublicRoute) return _defaultAuthenticatedRoute(claims);
      if (location == '/provider' && !_hasCapability(claims, 'provider_verified')) {
        return '/home';
      }
      if (location == '/booking' && !_hasCapability(claims, 'client_verified')) {
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
        builder: (context, state) => LoginScreen(prefillPhone: state.extra as String?),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp-verify',
        builder: (context, state) => OtpVerifyScreen(localPhone: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const PlaceholderScreen(title: 'Home'),
      ),
      GoRoute(
        path: '/booking',
        builder: (context, state) => const PlaceholderScreen(title: 'Booking'),
      ),
      GoRoute(
        path: '/provider',
        builder: (context, state) => const PlaceholderScreen(title: 'Provider'),
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
  if (_hasCapability(claims, 'provider_verified')) return '/provider';
  return '/home';
}

bool _hasCapability(Map<String, dynamic> claims, String key) {
  final value = claims[key];
  return value == true || value == 1 || value == '1' || value == 'true';
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
