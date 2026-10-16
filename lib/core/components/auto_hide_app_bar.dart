import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/scroll_visibility_controller.dart';

/// A PreferredSizeWidget wrapper that smoothly slides the AppBar offscreen
/// when scrolling down and restores it when scrolling up.
class AutoHideAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final PreferredSizeWidget child;

  const AutoHideAppBar({
    super.key,
    required this.child,
  });

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVisible = ref.watch(scrollVisibilityProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final totalHeight = preferredSize.height + topPadding;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      height: isVisible ? totalHeight : 0.0,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.bottomCenter,
          minHeight: totalHeight,
          maxHeight: totalHeight,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            offset: isVisible ? Offset.zero : const Offset(0, -1.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isVisible ? 1.0 : 0.0,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
