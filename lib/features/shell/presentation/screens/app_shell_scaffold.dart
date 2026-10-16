import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/controllers/scroll_visibility_controller.dart';
import '../../../../core/localization/app_strings.dart';

class AppShellScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShellScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(WidgetRef ref, int index) {
    // When switching tabs, always restore bars to visible
    ref.read(scrollVisibilityProvider.notifier).show();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(scrollVisibilityProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          ref
              .read(scrollVisibilityProvider.notifier)
              .handleScrollNotification(notification);
          return false;
        },
        child: navigationShell,
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: isVisible ? 80.0 + bottomPadding : 0.0,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minHeight: 80.0 + bottomPadding,
            maxHeight: 80.0 + bottomPadding,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              offset: isVisible ? Offset.zero : const Offset(0, 1.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isVisible ? 1.0 : 0.0,
                child: NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) =>
                      _onDestinationSelected(ref, index),
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(LucideIcons.home),
                      selectedIcon: const Icon(LucideIcons.home,
                          color: AppColors.primary),
                      label: AppStrings.tr(ref, 'nav_home'),
                    ),
                    NavigationDestination(
                      icon: const Icon(LucideIcons.bookOpen),
                      selectedIcon: const Icon(LucideIcons.bookOpen,
                          color: AppColors.primary),
                      label: AppStrings.tr(ref, 'nav_qbank'),
                    ),
                    NavigationDestination(
                      icon: const Icon(LucideIcons.playCircle),
                      selectedIcon: const Icon(LucideIcons.playCircle,
                          color: AppColors.primary),
                      label: AppStrings.tr(ref, 'nav_practice'),
                    ),
                    NavigationDestination(
                      icon: const Icon(LucideIcons.alertTriangle),
                      selectedIcon: const Icon(LucideIcons.alertTriangle,
                          color: AppColors.primary),
                      label: AppStrings.tr(ref, 'nav_mistakes'),
                    ),
                    NavigationDestination(
                      icon: const Icon(LucideIcons.bookmark),
                      selectedIcon: const Icon(LucideIcons.bookmark,
                          color: AppColors.primary),
                      label: AppStrings.tr(ref, 'nav_bookmarks'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
