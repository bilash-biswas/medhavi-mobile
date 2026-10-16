import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AppShellScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.home),
            selectedIcon: Icon(LucideIcons.home, color: Color(0xFF4F46E5)),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.bookOpen),
            selectedIcon: Icon(LucideIcons.bookOpen, color: Color(0xFF4F46E5)),
            label: 'প্রশ্ন ব্যাংক',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.playCircle),
            selectedIcon: Icon(LucideIcons.playCircle, color: Color(0xFF4F46E5)),
            label: 'অনুশীলন',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.alertTriangle),
            selectedIcon: Icon(LucideIcons.alertTriangle, color: Color(0xFF4F46E5)),
            label: 'ভুল ব্যাংক',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.bookmark),
            selectedIcon: Icon(LucideIcons.bookmark, color: Color(0xFF4F46E5)),
            label: 'বুকমার্ক',
          ),
        ],
      ),
    );
  }
}
