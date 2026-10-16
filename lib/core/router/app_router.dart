import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:medhavi_mobile/features/splash/presentation/screens/splash_screen.dart';
import 'package:medhavi_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:medhavi_mobile/features/shell/presentation/screens/app_shell_scaffold.dart';
import 'package:medhavi_mobile/features/home/presentation/screens/home_dashboard_screen.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/screens/question_bank_screen.dart';
import 'package:medhavi_mobile/features/practice/presentation/screens/practice_hub_screen.dart';
import 'package:medhavi_mobile/features/mistakes/presentation/screens/mistake_bank_screen.dart';
import 'package:medhavi_mobile/features/bookmarks/presentation/screens/bookmarks_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      // 1. Splash Screen (Root Navigator, no bottom nav bar)
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Onboarding Screen (Root Navigator, no bottom nav bar)
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 3. Main Application Shell (With persistent bottom nav bar)
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
