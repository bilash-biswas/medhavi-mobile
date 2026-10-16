import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reactive controller that coordinates auto-hiding the AppBar and BottomNavigationBar
/// when scrolling down (for immersive reading like LinkedIn/Twitter/Chrome)
/// and restoring them when scrolling back up.
class ScrollVisibilityController extends Notifier<bool> {
  @override
  bool build() => true; // true = visible, false = hidden

  void show() {
    if (!state) state = true;
  }

  void hide() {
    if (state) state = false;
  }

  void handleScrollNotification(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return;

    // When near the top (within 40 pixels), always ensure bars are visible
    if (notification.metrics.pixels <= 40) {
      show();
      return;
    }

    if (notification.direction == ScrollDirection.reverse) {
      // User is scrolling down into content -> hide bars to maximize reading space
      hide();
    } else if (notification.direction == ScrollDirection.forward) {
      // User is scrolling back up towards top -> show bars immediately
      show();
    }
  }
}

final scrollVisibilityProvider =
    NotifierProvider<ScrollVisibilityController, bool>(
  ScrollVisibilityController.new,
);
