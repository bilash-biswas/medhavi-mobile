import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/presentation/screens/app_shell_scaffold.dart';
import '../../features/home/presentation/screens/home_dashboard_screen.dart';
import '../../features/question_bank/presentation/screens/question_bank_screen.dart';
import '../../features/practice/presentation/screens/practice_hub_screen.dart';
import '../../features/mistakes/presentation/screens/mistake_bank_screen.dart';
import '../../features/bookmarks/presentation/screens/bookmarks_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
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
