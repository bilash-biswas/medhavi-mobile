import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/core/services/preferences_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      badge: '১০ম থেকে ৫০তম বিসিএস',
      title: 'বিসিএস প্রশ্ন ব্যাংকের সম্পূর্ণ ভাণ্ডার',
      description:
          '১০ম থেকে ৫০তম বিসিএস প্রিলিমিনারি পরীক্ষার ৫,৪২৩+ নির্ভুল প্রশ্ন, প্রতিটি বিষয়ের স্ট্যান্ডার্ড উত্তর ও বিস্তারিত সমাধান এখন আপনার হাতের মুঠোয়।',
      icon: LucideIcons.bookOpen,
      gradientColors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
      chips: ['১০টি বিষয়', 'ব্যাচ ফিল্টার', 'অফলাইন রিভিশন'],
    ),
    _OnboardingData(
      badge: 'সেলফ-টেস্টিং ও সমীকরণ',
      title: 'স্মার্ট অনুশীলন ও KaTeX গণিত সমাধান',
      description:
          'প্রশ্ন পড়ার সাথে সাথেই অপশনে ট্যাপ করে নিজের জ্ঞান যাচাই করুন। গণিত ও বিজ্ঞানের জটিল সমীকরণ ও সূত্র সরাসরি ক্যানভাসে নিখুঁতভাবে প্রদর্শিত হয়।',
      icon: LucideIcons.sparkles,
      gradientColors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
      chips: ['হ্যাপটিক ফিডব্যাক', 'KaTeX ম্যাথ সূত্র', 'ধাপে ধাপে ব্যাখ্যা'],
    ),
    _OnboardingData(
      badge: 'দুর্বলতা দূরীকরণ',
      title: 'ভুল ব্যাংক ও স্মার্ট বুকমার্কস',
      description:
          'ভুল উত্তরগুলো স্বয়ংক্রিয়ভাবে ভুল ব্যাংকে জমা হবে। পূর্বে দেওয়া ভুল উত্তরের সাথে সঠিক সমাধানের তুলনামূলক পর্যালোচনা দেখে নিশ্চিত করুন ১০০% প্রস্তুতি।',
      icon: LucideIcons.alertTriangle,
      gradientColors: [Color(0xFFF43F5E), Color(0xFFBE123C)],
      chips: ['তুলনামূলক মূল্যায়ন', 'ভুল সংশোধন ড্রিল', 'কাস্টম বুকমার্ক'],
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = ref.read(preferencesServiceProvider);
    await prefs.setHasSeenOnboarding(true);
    if (!mounted) return;
    context.go('/');
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header (Logo & Skip button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'মেধাবী',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),

                  // Skip Button
                  if (!isLastPage)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'স্কিপ করুন',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. PageView Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Visual Feature Graphic Box
                        Container(
                          width: double.infinity,
                          height: 250,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: page.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: page.gradientColors.first
                                    .withValues(alpha: 0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Decorative background icon
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Icon(
                                  page.icon,
                                  size: 160,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),

                              // Central emblem
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      page.icon,
                                      size: 54,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      page.badge,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Feature Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: page.chips.map((chip) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.cardDark
                                    : AppColors.primaryBgLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.borderDark
                                      : AppColors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                chip,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 3. Bottom Controls (Page Indicator & Action Button)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Animated Page Indicator Pills
                  Row(
                    children: List.generate(_pages.length, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : (isDark ? Colors.white24 : Colors.black12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),

                  // Action Button
                  if (!isLastPage)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        backgroundColor: AppColors.primary,
                      ),
                      onPressed: _nextPage,
                      child: const Icon(
                        LucideIcons.chevronRight,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(LucideIcons.sparkles, size: 18),
                      label: Text(
                        'শুরু করুন',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: _completeOnboarding,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String badge;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final List<String> chips;

  const _OnboardingData({
    required this.badge,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.chips,
  });
}
