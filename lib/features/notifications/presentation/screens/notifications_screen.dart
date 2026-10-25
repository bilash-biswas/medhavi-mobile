import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/core/localization/locale_controller.dart';
import 'package:medhavi_mobile/features/notifications/presentation/controllers/notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = ref.watch(localeControllerProvider);
    final isBn = locale.languageCode == 'bn';
    final notifState = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isBn ? 'নোটিফিকেশন ও স্ট্রিক অ্যালার্ট' : 'Notifications & Alerts',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (notifState.unreadCount > 0)
            TextButton.icon(
              onPressed: () => controller.markAllAsRead(),
              icon: const Icon(LucideIcons.checkCheck, size: 16),
              label: Text(
                isBn ? 'সব পঠিত করুন' : 'Mark all read',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await controller.refresh();
        },
        child: notifState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : notifState.notifications.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  LucideIcons.bell,
                                  size: 36,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isBn
                                    ? 'এখনো কোনো নোটিফিকেশন নেই'
                                    : 'No notifications yet',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isBn
                                    ? 'নতুন মক টেস্ট, প্রশ্ন সংযোজন এবং আপনার স্ট্রিক অ্যালার্ট এখানে দেখা যাবে।'
                                    : 'New mock exams, question updates, and streak alerts will appear here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isBn
                                    ? 'নতুন নোটিফিকেশন চেক করতে নিচে টানুন (Pull to refresh)'
                                    : 'Pull down to check for new alerts',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: notifState.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = notifState.notifications[index];
                      final isUnread = !notifState.readIds.contains(item.id);

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        controller.markAsRead(item.id);
                        context.go(item.mobileRoute);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isUnread
                              ? (isDark
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.primary.withValues(alpha: 0.06))
                              : (isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isUnread
                                ? AppColors.primary.withValues(alpha: 0.45)
                                : (isDark
                                    ? Colors.white12
                                    : Colors.black.withValues(alpha: 0.08)),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _categoryColor(item.category)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _categoryIcon(item.category),
                                size: 20,
                                color: _categoryColor(item.category),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      if (item.targetStreakSegment != 'all')
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.deepOrange
                                                .withValues(alpha: 0.14),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '🔥 ${item.streakBadgeLabel}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        ),
                                      if (item.isPinned)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            '📌 Pinned',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.body,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      height: 1.4,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isUnread)
                              Container(
                                margin: const EdgeInsets.only(left: 8, top: 4),
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'streak_alert':
        return LucideIcons.flame;
      case 'exam_alert':
        return LucideIcons.fileCheck;
      case 'daily_challenge':
        return LucideIcons.zap;
      case 'new_questions':
        return LucideIcons.bookOpen;
      case 'live_quiz':
        return LucideIcons.users;
      default:
        return LucideIcons.bell;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'streak_alert':
        return Colors.deepOrange;
      case 'exam_alert':
        return AppColors.primary;
      case 'daily_challenge':
        return Colors.amber.shade700;
      case 'new_questions':
        return Colors.teal;
      case 'live_quiz':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }
}
