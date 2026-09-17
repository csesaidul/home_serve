import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_verify_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../widgets/placeholder_screen.dart';

/// Route stubs from D1-T5, wired up for real in D2-T4 (auth) and to be
/// extended with the capability-based guard in D2-T5.
final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
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
      path: '/admin',
      builder: (context, state) => const PlaceholderScreen(title: 'Admin'),
    ),
  ],
);
