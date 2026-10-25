import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/theme_controller.dart';
import 'package:medhavi_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:medhavi_mobile/features/analytics/presentation/controllers/analytics_controller.dart';
import 'package:medhavi_mobile/features/bookmarks/presentation/controllers/bookmarks_controller.dart';
import 'package:medhavi_mobile/features/mistakes/presentation/controllers/mistakes_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = AppStrings.isBn(ref);
    final analytics = ref.watch(analyticsControllerProvider);
    final bmState = ref.watch(bookmarksControllerProvider);
    final mbState = ref.watch(mistakesControllerProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    final isAuthenticated = user != null && !user.isAnonymous;
    final displayName = isAuthenticated && user.displayName?.isNotEmpty == true
        ? user.displayName!
        : (isAuthenticated
            ? AppStrings.t(ref, 'মেধাবী শিক্ষার্থী', 'Medhavi Learner')
            : AppStrings.t(
                ref, 'গেস্ট শিক্ষার্থী (Guest)', 'Guest Learner'));
    final email = isAuthenticated && user.email?.isNotEmpty == true
        ? user.email!
        : AppStrings.t(
            ref,
            'অগ্রগতি ব্যাকআপ রাখতে সাইন ইন করুন',
            'Sign in to back up your progress to the cloud',
          );
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M';
    final accuracyPercent = (analytics.overallAccuracy * 100).round();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          AppStrings.tr(ref, 'profile_title'),
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: AppStrings.t(ref, 'সেটিংস', 'Settings'),
            icon: const Icon(LucideIcons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.wait([
            ref.read(analyticsControllerProvider.notifier).refreshStats(),
            ref.read(bookmarksControllerProvider.notifier).loadBookmarks(),
            ref.read(mistakesControllerProvider.notifier).loadMistakes(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
          children: [
            // 1. Profile Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            initial,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              email,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Cadre & Streak Pill Row
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.award,
                                          size: 12, color: Colors.amber),
                                      const SizedBox(width: 5),
                                      Text(
                                        AppStrings.t(
                                          ref,
                                          '৪৭তম বিসিএস ক্যাডার প্রত্যাশী',
                                          '47th BCS Cadre Aspirant',
                                        ),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: analytics.streakDays > 0
                                        ? Colors.orange.withValues(alpha: 0.28)
                                        : Colors.white.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('🔥',
                                          style: TextStyle(fontSize: 10)),
                                      const SizedBox(width: 4),
                                      Text(
                                        isBn
                                            ? '${AppStrings.num(ref, analytics.streakDays)} দিন স্ট্রিক'
                                            : '${analytics.streakDays}d Streak',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Real-Time Prep Stats Grid
            Row(
              children: [
                Expanded(
                  child: _StatMiniBox(
                    label: AppStrings.t(ref, 'সমাধান', 'Solved'),
                    value: AppStrings.num(ref, analytics.totalSolved),
                    icon: LucideIcons.layers,
                    color: AppColors.primary,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatMiniBox(
                    label: AppStrings.t(ref, 'নির্ভুলতা', 'Accuracy'),
                    value: '${AppStrings.num(ref, accuracyPercent)}%',
                    icon: LucideIcons.checkCircle2,
                    color: AppColors.success,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatMiniBox(
                    label: AppStrings.t(ref, 'স্ট্রিক', 'Streak'),
                    value: isBn
                        ? '${AppStrings.num(ref, analytics.streakDays)} দিন'
                        : '${analytics.streakDays}d',
                    icon: LucideIcons.flame,
                    color: Colors.orange,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatMiniBox(
                    label: AppStrings.t(ref, 'ভুল প্রশ্ন', 'Mistakes'),
                    value: AppStrings.num(ref, mbState.questions.length),
                    icon: LucideIcons.alertTriangle,
                    color: AppColors.rose,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Quick Actions Group
            _SectionHeader(
              title: AppStrings.t(
                  ref, 'প্রস্তুতি ও অগ্রগতি ট্র্যাকিং', 'Progress & Preparation'),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  _ProfileTile(
                    title: AppStrings.t(ref, 'পারফরম্যান্স অ্যানালিটিক্স',
                        'Performance Analytics'),
                    subtitle: AppStrings.t(
                        ref,
                        'বিষয়ভিত্তিক নির্ভুলতা ও শক্তির চিত্র',
                        'Subject-wise accuracy and mastery breakdown'),
                    icon: LucideIcons.barChart2,
                    iconColor: AppColors.primary,
                    onTap: () => context.push('/analytics'),
                  ),
                  const Divider(height: 1),
                  _ProfileTile(
                    title: AppStrings.t(
                        ref, 'শীর্ষ লিডারবোর্ড', 'Top Leaderboard'),
                    subtitle: AppStrings.t(
                        ref,
                        'অন্যান্য বিসিএস প্রার্থীদের সাথে র‍্যাংকিং',
                        'Compare your ranking with BCS aspirants'),
                    icon: LucideIcons.trophy,
                    iconColor: Colors.amber,
                    onTap: () => context.push('/leaderboard'),
                  ),
                  const Divider(height: 1),
                  _ProfileTile(
                    title: AppStrings.t(ref, 'লাইভ কুইজ ও মডেল টেস্ট',
                        'Live Quiz & Model Tests'),
                    subtitle: AppStrings.t(
                        ref,
                        'টাইমড রিয়েল বিসিএস প্রিলিমিনারি পরীক্ষা',
                        'Timed BCS Preliminary simulation exams'),
                    icon: LucideIcons.playCircle,
                    iconColor: Colors.red,
                    onTap: () => context.push('/live-quiz'),
                  ),
                  const Divider(height: 1),
                  _ProfileTile(
                    title: AppStrings.t(ref, 'সংরক্ষিত প্রশ্নসমূহ (বুকমার্ক)',
                        'Saved Bookmarks'),
                    subtitle: isBn
                        ? '${AppStrings.num(ref, bmState.questions.length)}টি প্রশ্ন সংরক্ষিত আছে'
                        : '${bmState.questions.length} saved questions',
                    icon: LucideIcons.bookmark,
                    iconColor: Colors.teal,
                    onTap: () => context.go('/bookmarks'),
                  ),
                  const Divider(height: 1),
                  _ProfileTile(
                    title: AppStrings.t(ref, 'ভুল ব্যাংক', 'Mistake Bank'),
                    subtitle: isBn
                        ? '${AppStrings.num(ref, mbState.questions.length)}টি সমাধানযোগ্য ভুল'
                        : '${mbState.questions.length} mistakes to review',
                    icon: LucideIcons.alertTriangle,
                    iconColor: AppColors.rose,
                    onTap: () => context.go('/mistakes'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Quick Preferences Group
            _SectionHeader(
              title: AppStrings.t(ref, 'অ্যাপ ও সেটিংস', 'App & Preferences'),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        themeMode == ThemeMode.dark
                            ? LucideIcons.moon
                            : LucideIcons.sun,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      AppStrings.t(ref, 'থিম পরিবর্তন', 'Theme Appearance'),
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      themeMode == ThemeMode.dark
                          ? AppStrings.t(ref, 'ডার্ক মোড সক্রিয়', 'Dark Mode')
                          : (themeMode == ThemeMode.light
                              ? AppStrings.t(
                                  ref, 'লাইট মোড সক্রিয়', 'Light Mode')
                              : AppStrings.t(
                                  ref, 'সিস্টেম ডিফল্ট', 'System Default')),
                      style: GoogleFonts.hindSiliguri(fontSize: 12),
                    ),
                    trailing: Switch.adaptive(
                      value: isDark,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        ref
                            .read(themeModeControllerProvider.notifier)
                            .toggleTheme();
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.languages,
                          color: Colors.purple, size: 20),
                    ),
                    title: Text(
                      AppStrings.t(ref, 'অ্যাপের ভাষা', 'App Language'),
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      locale.languageCode == 'bn'
                          ? 'বাংলা (Bengali)'
                          : 'English (ইংরেজি)',
                      style: GoogleFonts.hindSiliguri(fontSize: 12),
                    ),
                    trailing: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        ref
                            .read(localeControllerProvider.notifier)
                            .toggleLocale();
                      },
                      child: Text(
                        locale.languageCode == 'bn' ? 'English' : 'বাংলা',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _ProfileTile(
                    title: AppStrings.t(
                        ref, 'পূর্ণাঙ্গ সেটিংস', 'Advanced Settings'),
                    subtitle: AppStrings.t(
                        ref,
                        'ক্যাশে ক্লিয়ার, KaTeX সূত্র ও নোটিফিকেশন',
                        'Cache clear, KaTeX math & notifications'),
                    icon: LucideIcons.settings,
                    iconColor: Colors.blueGrey,
                    onTap: () => context.push('/settings'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 5. Auth Action Button
            if (isAuthenticated)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(LucideIcons.logOut, size: 18),
                  label: Text(
                    AppStrings.t(ref, 'লগআউট করুন', 'Sign Out'),
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signOut();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppStrings.t(ref, 'সফলভাবে লগআউট হয়েছেন',
                                'Signed out successfully'),
                            style: GoogleFonts.hindSiliguri(),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(LucideIcons.logIn, size: 18),
                  label: Text(
                    AppStrings.t(ref, 'সাইন ইন করুন / একাউন্ট খুলুন',
                        'Sign In / Create Account'),
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => context.push('/login'),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class _StatMiniBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatMiniBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.hindSiliguri(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.hindSiliguri(
              fontSize: 10,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.hindSiliguri(fontSize: 11),
      ),
      trailing: const Icon(LucideIcons.chevronRight, size: 18),
      onTap: onTap,
    );
  }
}
