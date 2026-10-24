import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medhavi_mobile/features/splash/presentation/screens/splash_screen.dart';
import 'package:medhavi_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:medhavi_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:medhavi_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:medhavi_mobile/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:medhavi_mobile/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:medhavi_mobile/features/live_quiz/presentation/screens/live_quiz_hub_screen.dart';
import 'package:medhavi_mobile/features/live_quiz/presentation/screens/active_quiz_screen.dart';
import 'package:medhavi_mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:medhavi_mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:medhavi_mobile/features/shell/presentation/screens/app_shell_scaffold.dart';
import 'package:medhavi_mobile/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/screens/question_bank_screen.dart';
import 'package:medhavi_mobile/features/practice/presentation/screens/practice_hub_screen.dart';
import 'package:medhavi_mobile/features/practice/presentation/screens/practice_session_screen.dart';
import 'package:medhavi_mobile/features/mistakes/presentation/screens/mistake_bank_screen.dart';
import 'package:medhavi_mobile/features/bookmarks/presentation/screens/bookmarks_screen.dart';
import 'package:medhavi_mobile/features/notifications/presentation/screens/notifications_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class _AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;

  _AuthNotifier(FirebaseAuth auth) {
    _subscription = auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final authNotifierProvider = Provider<_AuthNotifier>((ref) {
  final notifier = _AuthNotifier(FirebaseAuth.instance);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null && !user.isAnonymous;
      final location = state.matchedLocation;

      final isSplash = location == '/splash';
      final isOnboarding = location == '/onboarding';
      final isAuthRoute = location == '/login' || location == '/register';

      // 1. Allow splash and onboarding to display
      if (isSplash || isOnboarding) {
        return null;
      }

      // 2. Strict Authentication: without sign in, user cannot visit ANY screen
      if (!isLoggedIn) {
        return isAuthRoute ? null : '/login';
      }

      // 3. When signed in, redirect away from auth routes to home dashboard
      if (isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Onboarding Screen
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 3. Login Screen
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      // 4. Register Screen
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // 5. Leaderboard Screen
      GoRoute(
        path: '/leaderboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LeaderboardScreen(),
      ),

      // 6. Analytics Screen
      GoRoute(
        path: '/analytics',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AnalyticsScreen(),
      ),

      // 7. Live Quiz Hub Screen
      GoRoute(
        path: '/live-quiz',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LiveQuizHubScreen(),
      ),

      // 8. Active Quiz Exam Screen
      GoRoute(
        path: '/live-quiz/exam',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ActiveQuizScreen(),
      ),

      // 9. Profile Screen
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileScreen(),
      ),

      // 10. Settings Screen
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

      // 11. Practice Session Runner Screen
      GoRoute(
        path: '/practice/session',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PracticeSessionScreen(),
      ),

      // 11b. Notifications Center Screen
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),

      // 12. Main Application Shell (With persistent bottom nav bar)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home / Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),

          // Branch 1: Question Bank
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/question-bank',
                builder: (context, state) => const QuestionBankScreen(),
              ),
            ],
          ),

          // Branch 2: Practice Hub
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/practice',
                builder: (context, state) => const PracticeHubScreen(),
              ),
            ],
          ),

          // Branch 3: Mistake Bank
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mistakes',
                builder: (context, state) => const MistakeBankScreen(),
              ),
            ],
          ),

          // Branch 4: Bookmarks
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookmarks',
                builder: (context, state) => const BookmarksScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
