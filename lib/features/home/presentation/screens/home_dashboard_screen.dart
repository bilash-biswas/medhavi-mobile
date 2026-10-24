import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/core/components/auto_hide_app_bar.dart';
import 'package:medhavi_mobile/core/localization/app_strings.dart';
import 'package:medhavi_mobile/core/theme/theme_controller.dart';
import 'package:medhavi_mobile/core/localization/locale_controller.dart';
import 'package:medhavi_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:medhavi_mobile/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:medhavi_mobile/features/question_bank/presentation/controllers/question_bank_controller.dart';
import 'package:medhavi_mobile/features/bookmarks/presentation/controllers/bookmarks_controller.dart';
import 'package:medhavi_mobile/features/mistakes/presentation/controllers/mistakes_controller.dart';
import 'package:medhavi_mobile/features/notifications/presentation/controllers/notifications_controller.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = AppStrings.isBn(ref);
    final currentUser = ref.watch(currentUserProvider);
    final locale = ref.watch(localeControllerProvider);
    final qbState = ref.watch(questionBankControllerProvider);
    final bmState = ref.watch(bookmarksControllerProvider);
    final mbState = ref.watch(mistakesControllerProvider);
    final notifState = ref.watch(notificationsControllerProvider);
    final analytics = ref.watch(analyticsControllerProvider);

    final totalQuestions = (qbState.subjectCounts['all'] ?? 0) > 0
        ? qbState.subjectCounts['all']!
        : 5423;
    final userName = currentUser != null &&
            !currentUser.isAnonymous &&
            currentUser.displayName?.isNotEmpty == true
        ? currentUser.displayName!
        : AppStrings.t(ref, 'শিক্ষার্থী', 'Learner');

    return Scaffold(
      appBar: AutoHideAppBar(
        child: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.graduationCap,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.t(ref, 'মেধাবী (Medhavi)', 'Medhavi'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      AppStrings.t(
                        ref,
                        'স্মার্ট বিসিএস ও ক্যারিয়ার প্রস্তুতি',
                        'Smart BCS & Career Prep',
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            // Notification Bell Icon with Live Unread Badge
            IconButton(
              tooltip: AppStrings.t(ref, 'নোটিফিকেশন', 'Notifications'),
              onPressed: () => context.push('/notifications'),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(LucideIcons.bell, size: 20),
                  if (notifState.unreadCount > 0)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${notifState.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Theme Toggle Icon
            IconButton(
              tooltip: AppStrings.t(ref, 'থিম পরিবর্তন', 'Toggle Theme'),
              icon: Icon(
                isDark ? LucideIcons.sun : LucideIcons.moon,
                size: 20,
              ),
              onPressed: () {
                ref.read(themeModeControllerProvider.notifier).toggleTheme();
              },
            ),

            // Language Toggle Button
            IconButton(
              tooltip: AppStrings.t(
                  ref, 'ভাষা পরিবর্তন (Language)', 'Switch Language'),
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.white30 : Colors.black26,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  locale.languageCode == 'bn' ? 'EN' : 'বাং',
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              onPressed: () {
                ref.read(localeControllerProvider.notifier).toggleLocale();
              },
            ),

            // Profile / Account
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: AppStrings.t(ref, 'প্রোফাইল', 'Profile'),
                icon: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (currentUser != null &&
                                currentUser.displayName?.isNotEmpty == true
                            ? currentUser.displayName![0]
                            : 'M')
                        .toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                onPressed: () => context.push('/profile'),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 0. Pinned Admin Notification / Streak Alert Banner
            if (notifState.pinnedNotifications.isNotEmpty) ...[
              for (final pin in notifState.pinnedNotifications.take(2))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      ref
                          .read(notificationsControllerProvider.notifier)
                          .markAsRead(pin.id);
                      context.go(pin.mobileRoute);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primary.withValues(alpha: 0.18)
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              LucideIcons.bell,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  pin.title,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pin.body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            LucideIcons.chevronRight,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],

            // 0.5 Live Welcome & Continuous Streak Status Card
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: analytics.streakDays > 0 && !analytics.practicedToday
                      ? Colors.amber.withValues(alpha: 0.6)
                      : (isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: analytics.streakDays > 0
                          ? Colors.orange.withValues(alpha: 0.14)
                          : Colors.grey.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      LucideIcons.flame,
                      color: analytics.streakDays > 0
                          ? Colors.orange
                          : Colors.grey,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                isBn
                                    ? 'স্বাগতম, $userName!'
                                    : 'Welcome, $userName!',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: analytics.streakDays > 0
                                    ? Colors.orange.withValues(alpha: 0.14)
                                    : Colors.grey.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isBn
                                    ? '🔥 ${AppStrings.num(ref, analytics.streakDays)} দিন'
                                    : '🔥 ${analytics.streakDays}d',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: analytics.streakDays > 0
                                      ? Colors.orange.shade800
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          analytics.practicedToday
                              ? AppStrings.t(
                                  ref,
                                  '✅ আজকের স্ট্রিক সুরক্ষিত! ধারাবাহিকতা বজায় রাখুন।',
                                  '✅ Today\'s streak is protected! Keep it going.',
                                )
                              : (analytics.streakDays > 0
                                  ? AppStrings.t(
                                      ref,
                                      '⏳ আজ এখনো অনুশীলন হয়নি — মিস করলে স্ট্রিক ০ হয়ে যাবে!',
                                      '⏳ Practice today or your streak resets to 0!',
                                    )
                                  : AppStrings.t(
                                      ref,
                                      '🚀 আজ অনুশীলন করে নতুন ধারাবাহিক স্ট্রিক শুরু করুন!',
                                      '🚀 Practice today to start a new daily streak!',
                                    )),
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11.5,
                            color: analytics.streakDays > 0 &&
                                    !analytics.practicedToday
                                ? Colors.amber.shade800
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => context.go('/practice'),
                    child: Text(
                      AppStrings.t(ref, 'অনুশীলন', 'Practice'),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 1. Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.sparkles,
                                size: 13, color: Colors.amber),
                            const SizedBox(width: 5),
                            Text(
                              AppStrings.t(
                                ref,
                                '১০ম - ৫০তম বিসিএস সংগ্রহ',
                                '10th - 50th BCS Archive',
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isBn
                        ? '${AppStrings.num(ref, totalQuestions)}+ বিসিএস প্রশ্ন ও বিস্তারিত ব্যাখ্যা'
                        : '$totalQuestions+ BCS Questions & Explanations',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.t(
                      ref,
                      'প্রতিটি প্রশ্নের নির্ভুল ব্যাখ্যা, গণিত ও বিজ্ঞানের KaTeX সূত্র এবং সেলফ-টেস্টিং সুবিধা।',
                      'Verified explanations, KaTeX math & science formulas, and interactive self-testing.',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                    icon: const Icon(LucideIcons.bookOpen, size: 18),
                    label: Text(
                      AppStrings.t(
                          ref, 'প্রশ্ন ব্যাংকে পড়ুন', 'Explore Question Bank'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => context.go('/question-bank'),
                  ),
                ],
              ),
            ),

            // Guest Sync Reminder Banner
            if (currentUser == null || currentUser.isAnonymous) ...[
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1B4B).withValues(alpha: 0.6)
                      : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.cloudUpload,
                          size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.t(ref, 'অগ্রগতি স্থায়ী করুন',
                                'Save Your Progress'),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.primary,
                            ),
                          ),
                          Text(
                            AppStrings.t(
                              ref,
                              'বুকমার্ক ও ভুল প্রশ্নের হিস্ট্রি ক্লাউডে ব্যাকআপ রাখতে সাইন ইন করুন।',
                              'Sign in to sync bookmarks, mistakes, and streaks across devices.',
                            ),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => context.push('/login'),
                      child: Text(
                        AppStrings.t(ref, 'লগইন', 'Sign In'),
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // 2. Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: AppStrings.t(ref, 'প্রশ্ন ব্যাংক', 'Question Bank'),
                    value: isBn
                        ? '${AppStrings.num(ref, totalQuestions)}টি'
                        : '$totalQuestions',
                    subtitle: AppStrings.t(
                        ref, '১০ম - ৫০তম বিসিএস', '10th - 50th BCS'),
                    icon: LucideIcons.layers,
                    color: AppColors.primary,
                    onTap: () => context.go('/question-bank'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: AppStrings.t(ref, 'বুকমার্কসমূহ', 'Bookmarks'),
                    value: isBn
                        ? '${AppStrings.num(ref, bmState.questions.length)}টি'
                        : '${bmState.questions.length}',
                    subtitle: AppStrings.t(
                        ref, 'সংরক্ষিত প্রশ্ন', 'Saved Questions'),
                    icon: LucideIcons.bookmark,
                    color: AppColors.amber,
                    onTap: () => context.go('/bookmarks'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: AppStrings.t(ref, 'ভুল ব্যাংক', 'Mistake Bank'),
                    value: isBn
                        ? '${AppStrings.num(ref, mbState.questions.length)}টি'
                        : '${mbState.questions.length}',
                    subtitle: AppStrings.t(
                        ref, 'পুনরাবৃত্তি সংশোধন', 'Review & Fix'),
                    icon: LucideIcons.alertTriangle,
                    color: AppColors.rose,
                    onTap: () => context.go('/mistakes'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: AppStrings.t(ref, 'অনুশীলন হাব', 'Practice Hub'),
                    value: AppStrings.t(ref, '১০টি বিষয়', '10 Subjects'),
                    subtitle: AppStrings.t(
                        ref, 'কাস্টম পরীক্ষা', 'Custom Mock Tests'),
                    icon: LucideIcons.playCircle,
                    color: AppColors.emerald,
                    onTap: () => context.go('/practice'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Smart Hub Features (Live Quiz, Leaderboard, Analytics)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.t(ref, 'স্মার্ট ফিচার ও প্রতিযোগিতা',
                      'Smart Features & Arena'),
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppStrings.t(ref, 'লাইভ ও রিয়েল-টাইম', 'Live & Real-Time'),
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Live Quiz Hub Card
            GestureDetector(
              onTap: () => context.push('/live-quiz'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.radio,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  AppStrings.t(ref, 'লাইভ কুইজ ও মডেল টেস্ট',
                                      'Live Quiz & Model Tests'),
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.t(
                              ref,
                              'টাইমড প্রিলিমিনারি পরীক্ষা, নেগেটিভ মার্কিং ও স্কোরকার্ড',
                              'Timed preliminary exams, negative marking & instant scorecard',
                            ),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.chevronRight,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Leaderboard & Analytics Pair
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/leaderboard'),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.trophy,
                                color: Colors.amber, size: 20),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppStrings.t(
                                ref, 'শীর্ষ লিডারবোর্ড', 'Leaderboard'),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AppStrings.t(
                                ref, 'র‍্যাংকিং ও অবস্থান', 'Rankings & Score'),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/analytics'),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.barChart2,
                                color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppStrings.t(ref, 'পারফরম্যান্স', 'Analytics'),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            AppStrings.t(ref, 'নির্ভুলতা ও দক্ষতা',
                                'Accuracy & Mastery'),
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Quick BCS Batch Selector
            Text(
              AppStrings.t(
                  ref, 'জনপ্রিয় বিসিএস প্রশ্নব্যাচ', 'Popular BCS Batches'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final b in const [
                  {'tag': '50th-bcs', 'bn': '৫০তম বিসিএস', 'en': '50th BCS'},
                  {'tag': '49th-bcs', 'bn': '৪৯তম বিসিএস', 'en': '49th BCS'},
                  {'tag': '48th-bcs', 'bn': '৪৮তম বিসিএস', 'en': '48th BCS'},
                  {'tag': '47th-bcs', 'bn': '৪৭তম বিসিএস', 'en': '47th BCS'},
                  {'tag': '46th-bcs', 'bn': '৪৬তম বিসিএস', 'en': '46th BCS'},
                  {'tag': '45th-bcs', 'bn': '৪৫তম বিসিএস', 'en': '45th BCS'},
                  {'tag': '44th-bcs', 'bn': '৪৪তম বিসিএস', 'en': '44th BCS'},
                  {'tag': '43rd-bcs', 'bn': '৪৩তম বিসিএস', 'en': '43rd BCS'},
                  {'tag': '41st-bcs', 'bn': '৪১তম বিসিএস', 'en': '41st BCS'},
                  {'tag': '40th-bcs', 'bn': '৪০তম বিসিএস', 'en': '40th BCS'},
                ])
                  _BatchChip(
                    label: isBn ? b['bn']! : b['en']!,
                    tag: b['tag']!,
                    onTap: () {
                      ref
                          .read(questionBankControllerProvider.notifier)
                          .setBatch(b['tag']!);
                      context.go('/question-bank');
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // 5. BCS Subjects Explorer with Live Counts
            Text(
              AppStrings.t(ref, 'বিসিএস প্রিলিমিনারি বিষয়সমূহ',
                  'BCS Preliminary Subjects'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (qbState.subjects.isNotEmpty) ...[
              Column(
                children: qbState.subjects.map((sub) {
                  final subId = sub['id'] as String? ?? '';
                  final count = qbState.subjectCounts[subId] ?? 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.book,
                            color: AppColors.primary, size: 18),
                      ),
                      title: Text(
                        isBn
                            ? (sub['name'] ?? '')
                            : ((sub['nameEn'] as String?)?.isNotEmpty == true
                                ? sub['nameEn']
                                : (sub['name'] ?? '')),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        isBn ? (sub['nameEn'] ?? '') : (sub['name'] ?? ''),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (count > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isBn
                                    ? '${AppStrings.num(ref, count)}টি'
                                    : '$count MCQs',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          const Icon(LucideIcons.chevronRight, size: 16),
                        ],
                      ),
                      onTap: () {
                        ref
                            .read(questionBankControllerProvider.notifier)
                            .setSubject(subId);
                        context.go('/question-bank');
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const Icon(LucideIcons.chevronRight,
                      size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchChip extends StatelessWidget {
  final String label;
  final String tag;
  final VoidCallback onTap;

  const _BatchChip({
    required this.label,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar:
          const Icon(LucideIcons.sparkles, size: 14, color: AppColors.primary),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
