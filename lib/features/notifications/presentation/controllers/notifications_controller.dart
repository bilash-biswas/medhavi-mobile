import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AppNotificationModel {
  final String id;
  final String title;
  final String body;
  final String category;
  final String targetExamId;
  final String targetStreakSegment;
  final int? minStreak;
  final int? maxStreak;
  final String actionUrl;
  final bool isPinned;
  final int sentAt;

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.targetExamId,
    required this.targetStreakSegment,
    this.minStreak,
    this.maxStreak,
    required this.actionUrl,
    required this.isPinned,
    required this.sentAt,
  });

  factory AppNotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return AppNotificationModel(
      id: doc.id,
      title: (data['title'] ?? '').toString(),
      body: (data['body'] ?? '').toString(),
      category: (data['category'] ?? 'announcement').toString(),
      targetExamId: (data['targetExamId'] ?? 'all').toString(),
      targetStreakSegment: (data['targetStreakSegment'] ?? 'all').toString(),
      minStreak: data['minStreak'] is num ? (data['minStreak'] as num).toInt() : null,
      maxStreak: data['maxStreak'] is num ? (data['maxStreak'] as num).toInt() : null,
      actionUrl: (data['actionUrl'] ?? '/').toString(),
      isPinned: data['isPinned'] == true,
      sentAt: data['sentAt'] is num ? (data['sentAt'] as num).toInt() : 0,
    );
  }

  bool matchesStreak(int userStreak) {
    final s = userStreak < 0 ? 0 : userStreak;
    switch (targetStreakSegment) {
      case 'all':
        return true;
      case 'streak_zero':
        return s == 0;
      case 'streak_beginner':
        return s >= 1 && s <= 3;
      case 'streak_rising':
        return s >= 4 && s <= 6;
      case 'streak_champion':
        return s >= 7;
      case 'streak_legend':
        return s >= 30;
      case 'custom':
        final minS = minStreak ?? 0;
        final maxS = (maxStreak != null && maxStreak! >= minS) ? maxStreak! : 99999;
        return s >= minS && s <= maxS;
      default:
        return true;
    }
  }

  String get streakBadgeLabel {
    switch (targetStreakSegment) {
      case 'streak_zero':
        return '০ দিন স্ট্রিক (Comeback)';
      case 'streak_beginner':
        return '১–৩ দিন স্ট্রিক';
      case 'streak_rising':
        return '৪–৬ দিন স্ট্রিক';
      case 'streak_champion':
        return '৭+ দিন চ্যাম্পিয়ন';
      case 'streak_legend':
        return '৩০+ দিন লিজেন্ড';
      case 'custom':
        return 'স্ট্রিক: ${minStreak ?? 0}–${maxStreak ?? '∞'} দিন';
      default:
        return 'সকল স্ট্রিক';
    }
  }

  /// Maps web routes (/live, /dashboard, /exams) to mobile GoRouter routes
  String get mobileRoute {
    switch (actionUrl) {
      case '/dashboard':
      case '/':
        return '/';
      case '/question-bank':
        return '/question-bank';
      case '/practice':
      case '/exams':
        return '/practice';
      case '/live':
      case '/live-quiz':
        return '/live-quiz';
      case '/leaderboard':
        return '/leaderboard';
      default:
        return '/';
    }
  }
}

class NotificationsState {
  final List<AppNotificationModel> notifications;
  final Set<String> readIds;
  final int userStreak;
  final bool isLoading;

  const NotificationsState({
    this.notifications = const [],
    this.readIds = const {},
    this.userStreak = 0,
    this.isLoading = true,
  });

  int get unreadCount =>
      notifications.where((n) => !readIds.contains(n.id)).length;

  List<AppNotificationModel> get pinnedNotifications =>
      notifications.where((n) => n.isPinned).toList();

  NotificationsState copyWith({
    List<AppNotificationModel>? notifications,
    Set<String>? readIds,
    int? userStreak,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      readIds: readIds ?? this.readIds,
      userStreak: userStreak ?? this.userStreak,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationsController extends Notifier<NotificationsState> {
  static const _channel =
      MethodChannel('bd.medhavi.medhavi_mobile/notifications');
  static const _boxName = 'medhavi_notifications_box';

  StreamSubscription<QuerySnapshot>? _notifSub;
  StreamSubscription<DocumentSnapshot>? _userSub;
  bool _isFirstSnapshot = true;

  @override
  NotificationsState build() {
    ref.onDispose(() {
      _notifSub?.cancel();
      _userSub?.cancel();
    });
    Future.microtask(() => _init());
    return const NotificationsState();
  }

  Future<void> _init() async {
    try {
      await _channel.invokeMethod('requestPermission');
    } catch (e) {
      debugPrint('Notification permission request notice: $e');
    }

    final box = await Hive.openBox(_boxName);
    final savedRead =
        (box.get('read_ids', defaultValue: <dynamic>[]) as List).cast<String>();

    state = state.copyWith(readIds: Set<String>.from(savedRead));

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _userSub = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists) {
          final data = doc.data() ?? {};
          final rawStreak = data['currentStreak'] ?? data['streak'] ?? 0;
          final parsedStreak =
              rawStreak is num ? rawStreak.toInt() : int.tryParse('$rawStreak') ?? 0;
          if (parsedStreak != state.userStreak) {
            state = state.copyWith(userStreak: parsedStreak);
          }
        }
      });
    }

    _subscribeToFirestoreNotifications(box);
  }

  void _subscribeToFirestoreNotifications(Box box) {
    _notifSub?.cancel();
    _notifSub = FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(30)
        .snapshots()
        .listen((snapshot) async {
      final allItems = snapshot.docs
          .map((d) => AppNotificationModel.fromDoc(d))
          .toList();

      final matching = allItems
          .where((item) => item.matchesStreak(state.userStreak))
          .toList();

      state = state.copyWith(
        notifications: matching,
        isLoading: false,
      );

      final pushedList =
          (box.get('pushed_sigs', defaultValue: <dynamic>[]) as List)
              .cast<String>();
      final pushedSet = Set<String>.from(pushedList);

      if (_isFirstSnapshot) {
        for (final item in matching) {
          pushedSet.add('${item.id}_${item.sentAt}');
        }
        await box.put('pushed_sigs', pushedSet.toList());
        _isFirstSnapshot = false;
        return;
      }

      for (final item in matching) {
        final sig = '${item.id}_${item.sentAt}';
        if (!pushedSet.contains(sig)) {
          pushedSet.add(sig);
          await box.put('pushed_sigs', pushedSet.toList());
          await _triggerNativeAndroidNotification(item);
          break;
        }
      }
    }, onError: (err) {
      debugPrint('Firestore notifications stream error: $err');
      state = state.copyWith(isLoading: false);
    });
  }

  Future<void> _triggerNativeAndroidNotification(
      AppNotificationModel item) async {
    try {
      await _channel.invokeMethod('showNotification', {
        'id': item.id.hashCode.abs() % 100000,
        'title': item.title,
        'body': item.body,
      });
    } catch (e) {
      debugPrint('Failed to show native Android notification: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    if (state.readIds.contains(id)) return;
    final nextRead = Set<String>.from(state.readIds)..add(id);
    state = state.copyWith(readIds: nextRead);
    final box = await Hive.openBox(_boxName);
    await box.put('read_ids', nextRead.toList());
  }

  Future<void> markAllAsRead() async {
    final nextRead = Set<String>.from(state.readIds)
      ..addAll(state.notifications.map((n) => n.id));
    state = state.copyWith(readIds: nextRead);
    final box = await Hive.openBox(_boxName);
    await box.put('read_ids', nextRead.toList());
  }
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
        NotificationsController.new);
