import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/core/localization/app_strings.dart';
import 'package:medhavi_mobile/core/localization/locale_controller.dart';
import 'package:medhavi_mobile/core/services/preferences_service.dart';
import 'package:medhavi_mobile/core/theme/theme_controller.dart';
import 'package:medhavi_mobile/features/app_update/presentation/controllers/app_update_controller.dart';
import 'package:medhavi_mobile/features/app_update/presentation/widgets/app_update_dialog.dart';
import 'package:medhavi_mobile/core/services/app_update_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _hapticEnabled = true;
  bool _katexEnabled = true;
  String _selectedBatch = '47th-bcs';

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesServiceProvider);
    _hapticEnabled = prefs.hapticEnabled;
    _katexEnabled = prefs.katexEnabled;
    _selectedBatch = prefs.targetBatch;
  }

  Future<void> _handleClearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'ক্যাশ মুছে ফেলতে চান?',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'অ্যাপের সাময়িক ফাইল ও অফলাইন ডাটা মুছে ফেলা হবে। বুকমার্ক ও প্রগ্রেস নিরাপদ থাকবে।',
          style: GoogleFonts.hindSiliguri(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rose,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('মুছে ফেলুন'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'ক্যাশ মেমোরি সফলভাবে পরিষ্কার করা হয়েছে।',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeControllerProvider);
    final locale = ref.watch(localeControllerProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          AppStrings.tr(ref, 'settings_title'),
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Theme Selection
            _SectionLabel(title: AppStrings.tr(ref, 'theme_title')),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  _ThemeRadioTile(
                    title: AppStrings.tr(ref, 'theme_system'),
                    icon: LucideIcons.smartphone,
                    isSelected: themeMode == ThemeMode.system,
                    onTap: () {
                      ref
                          .read(themeModeControllerProvider.notifier)
                          .setThemeMode(ThemeMode.system);
                    },
                  ),
                  const Divider(height: 1),
                  _ThemeRadioTile(
                    title: AppStrings.tr(ref, 'theme_light'),
                    icon: LucideIcons.sun,
                    isSelected: themeMode == ThemeMode.light,
                    onTap: () {
                      ref
                          .read(themeModeControllerProvider.notifier)
                          .setThemeMode(ThemeMode.light);
                    },
                  ),
                  const Divider(height: 1),
                  _ThemeRadioTile(
                    title: AppStrings.tr(ref, 'theme_dark'),
                    icon: LucideIcons.moon,
                    isSelected: themeMode == ThemeMode.dark,
                    onTap: () {
                      ref
                          .read(themeModeControllerProvider.notifier)
                          .setThemeMode(ThemeMode.dark);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Language Selection
            _SectionLabel(title: AppStrings.tr(ref, 'language_title')),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  _LanguageRadioTile(
                    title: 'বাংলা (Bengali)',
                    subtitle: 'ডিফল্ট ভাষা ও পরিভাষাসমূহ',
                    isSelected: locale.languageCode == 'bn',
                    onTap: () {
                      ref
                          .read(localeControllerProvider.notifier)
                          .setLocale('bn');
                    },
                  ),
                  const Divider(height: 1),
                  _LanguageRadioTile(
                    title: 'English (ইংরেজি)',
                    subtitle: 'International terms & navigation',
                    isSelected: locale.languageCode == 'en',
                    onTap: () {
                      ref
                          .read(localeControllerProvider.notifier)
                          .setLocale('en');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Exam & Interactive Preferences
            _SectionLabel(title: AppStrings.tr(ref, 'exam_preferences')),
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
                  // Target Batch Selector
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.target,
                          color: AppColors.primary, size: 20),
                    ),
                    title: Text(
                      'টার্গেট বিসিএস ব্যাচ',
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      'হোম ও কুইজে অগ্রাধিকার নির্ধারণের জন্য',
                      style: GoogleFonts.hindSiliguri(fontSize: 12),
                    ),
                    trailing: DropdownButton<String>(
                      value: _selectedBatch,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                            value: '47th-bcs', child: Text('৪৭তম বিসিএস')),
                        DropdownMenuItem(
                            value: '48th-bcs', child: Text('৪৮তম বিসিএস')),
                        DropdownMenuItem(
                            value: '49th-bcs', child: Text('৪৯তম বিসিএস')),
                        DropdownMenuItem(
                            value: '50th-bcs', child: Text('৫০তম বিসিএস')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedBatch = val);
                          ref
                              .read(preferencesServiceProvider)
                              .setTargetBatch(val);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1),

                  // KaTeX Toggle
                  SwitchListTile.adaptive(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.sigma,
                          color: Colors.teal, size: 20),
                    ),
                    title: Text(
                      AppStrings.tr(ref, 'katex_rendering'),
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      AppStrings.tr(ref, 'katex_desc'),
                      style: GoogleFonts.hindSiliguri(fontSize: 12),
                    ),
                    value: _katexEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _katexEnabled = val);
                      ref
                          .read(preferencesServiceProvider)
                          .setKatexEnabled(val);
                    },
                  ),
                  const Divider(height: 1),

                  // Haptic Toggle
                  SwitchListTile.adaptive(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.vibrate,
                          color: Colors.indigo, size: 20),
                    ),
                    title: Text(
                      AppStrings.tr(ref, 'haptic_feedback'),
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      AppStrings.tr(ref, 'haptic_desc'),
                      style: GoogleFonts.hindSiliguri(fontSize: 12),
                    ),
                    value: _hapticEnabled,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _hapticEnabled = val);
                      ref
                          .read(preferencesServiceProvider)
                          .setHapticEnabled(val);
                      if (val) HapticFeedback.mediumImpact();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Cache & Storage
            _SectionLabel(title: 'স্টোরেজ ও ক্যাশ'),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.rose.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.trash2,
                      color: AppColors.rose, size: 20),
                ),
                title: Text(
                  AppStrings.tr(ref, 'clear_cache'),
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.rose,
                  ),
                ),
                subtitle: Text(
                  AppStrings.tr(ref, 'clear_cache_desc'),
                  style: GoogleFonts.hindSiliguri(fontSize: 12),
                ),
                trailing: const Icon(LucideIcons.chevronRight, size: 18),
                onTap: _handleClearCache,
              ),
            ),
            const SizedBox(height: 24),

            // 5. About & Version
            _SectionLabel(title: AppStrings.tr(ref, 'about_app')),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset('assets/images/app_logo.png'),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'মেধাবী (Medhavi)',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'স্মার্ট বিসিএস ও ক্যারিয়ার প্রস্তুতি প্ল্যাটফর্ম',
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'v${AppUpdateService.currentVersion}+${AppUpdateService.currentBuildNumber}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  InkWell(
                    onTap: () async {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            AppStrings.t(ref, 'আপডেট চেক করা হচ্ছে...',
                                'Checking for updates...'),
                            style: GoogleFonts.hindSiliguri(),
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      final info = await ref
                          .read(appUpdateControllerProvider.notifier)
                          .checkForUpdate();

                      if (!context.mounted) return;

                      if (info != null) {
                        AppUpdateDialog.show(context, info);
                      } else {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              AppStrings.t(
                                ref,
                                'আপনার অ্যাপটি লেটেস্ট সংস্করণে রয়েছে (v${AppUpdateService.currentVersion}) ✓',
                                'Your app is already up to date (v${AppUpdateService.currentVersion}) ✓',
                              ),
                              style: GoogleFonts.hindSiliguri(
                                  fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              LucideIcons.refreshCw,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.t(ref, 'অ্যাপের নতুন আপডেট চেক করুন',
                                      'Check for App Updates'),
                                  style: GoogleFonts.hindSiliguri(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  AppStrings.t(
                                    ref,
                                    'ইন-অ্যাপ স্বয়ংক্রিয় ডাউনলোড ও ইনস্টল',
                                    'In-app automatic download & install',
                                  ),
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
                          const Icon(LucideIcons.chevronRight,
                              size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'নির্মাতা ও ডেভেলপমেন্ট',
                        style: GoogleFonts.hindSiliguri(fontSize: 12),
                      ),
                      Text(
                        'বিলাশ বিশ্বাস & টিম',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.hindSiliguri(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.textSecondaryLight,
      ),
    );
  }
}

class _ThemeRadioTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeRadioTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
          size: 20),
      title: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      trailing: isSelected
          ? const Icon(LucideIcons.checkCircle2,
              color: AppColors.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}

class _LanguageRadioTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageRadioTile({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.hindSiliguri(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      subtitle: Text(subtitle, style: GoogleFonts.hindSiliguri(fontSize: 11)),
      trailing: isSelected
          ? const Icon(LucideIcons.checkCircle2,
              color: AppColors.primary, size: 20)
          : null,
      onTap: onTap,
    );
  }
}
