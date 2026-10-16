import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_strings.dart';

class AppShellScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShellScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          NavigationDestination(
            icon: const Icon(LucideIcons.home),
            selectedIcon: const Icon(LucideIcons.home, color: AppColors.primary),
            label: AppStrings.tr(ref, 'nav_home'),
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.bookOpen),
            selectedIcon: const Icon(LucideIcons.bookOpen, color: AppColors.primary),
            label: AppStrings.tr(ref, 'nav_qbank'),
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.playCircle),
            selectedIcon: const Icon(LucideIcons.playCircle, color: AppColors.primary),
            label: AppStrings.tr(ref, 'nav_practice'),
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.alertTriangle),
            selectedIcon: const Icon(LucideIcons.alertTriangle, color: AppColors.primary),
            label: AppStrings.tr(ref, 'nav_mistakes'),
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.bookmark),
            selectedIcon: const Icon(LucideIcons.bookmark, color: AppColors.primary),
            label: AppStrings.tr(ref, 'nav_bookmarks'),
          ),
        ],
      ),
    );
  }
}
