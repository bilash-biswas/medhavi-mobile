import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'locale_controller.dart';

class AppStrings {
  static const Map<String, Map<String, String>> _localizedValues = {
    'bn': {
      // Navigation
      'nav_home': 'হোম',
      'nav_qbank': 'প্রশ্ন ব্যাংক',
      'nav_practice': 'অনুশীলন',
      'nav_mistakes': 'ভুল ব্যাংক',
      'nav_bookmarks': 'বুকমার্ক',
      'nav_leaderboard': 'লিডারবোর্ড',
      'nav_analytics': 'অ্যানালিটিক্স',
      'nav_live_quiz': 'লাইভ কুইজ',
      'nav_profile': 'প্রোফাইল',
      'nav_settings': 'সেটিংস',

      // App Branding & General
      'app_name': 'মেধাবী',
      'app_subtitle': 'স্মার্ট বিসিএস ও ক্যারিয়ার প্রস্তুতি',
      'all_batches': 'সব বিসিএস ব্যাচ',
      'search_placeholder': 'প্রশ্ন বা টপিক খুঁজুন...',
      'login': 'লগইন',
      'register': 'রেজিস্ট্রেশন',
      'logout': 'লগআউট',
      'guest_mode': 'গেস্ট মোড',
      'cancel': 'বাতিল',
      'confirm': 'নিশ্চিত করুন',
      'save': 'সংরক্ষণ',
      'view_all': 'সবগুলো দেখুন',

      // Theme & Language
      'theme_title': 'থিম সেটিংস',
      'theme_system': 'সিস্টেম ডিফল্ট',
      'theme_light': 'লাইট মোড',
      'theme_dark': 'ডার্ক মোড',
      'language_title': 'ভাষা নির্বাচন',
      'lang_bengali': 'বাংলা (Bengali)',
      'lang_english': 'English (ইংরেজি)',

      // Leaderboard
      'leaderboard_title': 'শীর্ষ লিডারবোর্ড',
      'leaderboard_subtitle': 'বিসিএস প্রার্থীদের রিয়েল-টাইম র‍্যাংকিং ও পয়েন্ট',
      'tab_weekly': 'সাপ্তাহিক',
      'tab_monthly': 'মাসিক',
      'tab_all_time': 'সর্বকালের',
      'your_rank': 'আপনার অবস্থান',
      'pts': 'পয়েন্ট',
      'streak_days': 'দিনের স্ট্রিক',

      // Analytics
      'analytics_title': 'পারফরম্যান্স অ্যানালিটিক্স',
      'analytics_subtitle': 'আপনার প্রস্তুতি ও বিষয়ভিত্তিক শক্তির সামগ্রিক চিত্র',
      'overall_accuracy': 'গড় নির্ভুলতা',
      'total_solved': 'মোট সমাধান',
      'correct_answers': 'সঠিক উত্তর',
      'mistakes_rectified': 'ভুল সংশোধন',
      'subject_mastery': 'বিষয়ভিত্তিক দক্ষতা',
      'weak_areas': 'যে বিষয়ে মনোযোগ প্রয়োজন',
      'strong_areas': 'শক্তিশালী বিষয়সমূহ',

      // Live Quiz
      'live_quiz_title': 'লাইভ কুইজ ও মডেল টেস্ট',
      'live_quiz_subtitle': 'টাইমড রিয়েল বিসিএস প্রিলিমিনারি পরীক্ষা সিমুলেশন',
      'active_now': 'চলমান লাইভ পরীক্ষা',
      'upcoming_quizzes': 'আসন্ন লাইভ কুইজ',
      'speed_drill': '৫ মিনিটের স্পিড ড্রিল',
      'start_exam': 'পরীক্ষা শুরু করুন',
      'submit_exam': 'সাবমিট করুন',
      'time_remaining': 'বাকি সময়',
      'question_counter': 'প্রশ্ন',
      'negative_marking': 'নেগেটিভ মার্কিং: -০.৫০',
      'scorecard_title': 'পরীক্ষার ফলাফল ও মূল্যায়ন',
      'total_score': 'মোট প্রাপ্ত নম্বর',
      'accuracy_rate': 'নির্ভুলতার হার',

      // Profile
      'profile_title': 'আমার প্রোফাইল',
      'target_cadre': 'টার্গেট বিসিএস ব্যাচ',
      'study_stats': 'স্টাডি পরিসংখ্যান',
      'account_verified': 'যাচাইকৃত অ্যাকাউন্ট',
      'cloud_sync': 'ক্লাউড ডেটা সিঙ্ক',

      // Settings
      'settings_title': 'অ্যাপ সেটিংস',
      'exam_preferences': 'পরীক্ষার পছন্দসমূহ',
      'katex_rendering': 'KaTeX গণিত সূত্র রেন্ডারিং',
      'katex_desc': 'জটিল সমীকরণ ও সূত্র ক্যানভাসে প্রদর্শন',
      'haptic_feedback': 'হ্যাপটিক ভাইব্রেশন',
      'haptic_desc': 'অপশনে ট্যাপে সূক্ষ্ম স্পর্শ ফিডব্যাক',
      'clear_cache': 'অফলাইন ক্যাশ মুছে ফেলুন',
      'clear_cache_desc': 'মেমোরি খালি করতে সাময়িক ডেটা ডিলিট করুন',
      'about_app': 'অ্যাপ সম্পর্কিত তথ্য',
      'version': 'সংস্করণ',
      'terms_privacy': 'শর্তাবলী ও গোপনীয়তা নীতি',
    },
    'en': {
      // Navigation
      'nav_home': 'Home',
      'nav_qbank': 'Question Bank',
      'nav_practice': 'Practice',
      'nav_mistakes': 'Mistake Bank',
      'nav_bookmarks': 'Bookmarks',
      'nav_leaderboard': 'Leaderboard',
      'nav_analytics': 'Analytics',
      'nav_live_quiz': 'Live Quiz',
      'nav_profile': 'Profile',
      'nav_settings': 'Settings',

      // App Branding & General
      'app_name': 'Medhavi',
      'app_subtitle': 'Smart BCS & Career Prep',
      'all_batches': 'All BCS Batches',
      'search_placeholder': 'Search questions or topics...',
      'login': 'Login',
      'register': 'Register',
      'logout': 'Logout',
      'guest_mode': 'Guest Mode',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'view_all': 'View All',

      // Theme & Language
      'theme_title': 'Theme Settings',
      'theme_system': 'System Default',
      'theme_light': 'Light Mode',
      'theme_dark': 'Dark Mode',
      'language_title': 'Select Language',
      'lang_bengali': 'বাংলা (Bengali)',
      'lang_english': 'English',

      // Leaderboard
      'leaderboard_title': 'Top Leaderboard',
      'leaderboard_subtitle': 'Real-time ranking & points of BCS aspirants',
      'tab_weekly': 'Weekly',
      'tab_monthly': 'Monthly',
      'tab_all_time': 'All-Time',
      'your_rank': 'Your Position',
      'pts': 'Points',
      'streak_days': 'Day Streak',

      // Analytics
      'analytics_title': 'Performance Analytics',
      'analytics_subtitle': 'Comprehensive preparation & subject mastery overview',
      'overall_accuracy': 'Overall Accuracy',
      'total_solved': 'Total Solved',
      'correct_answers': 'Correct Answers',
      'mistakes_rectified': 'Mistakes Rectified',
      'subject_mastery': 'Subject-wise Mastery',
      'weak_areas': 'Areas Needing Focus',
      'strong_areas': 'Strong Subjects',

      // Live Quiz
      'live_quiz_title': 'Live Quiz & Mock Tests',
      'live_quiz_subtitle': 'Timed authentic BCS Preliminary exam simulations',
      'active_now': 'Active Live Exams',
      'upcoming_quizzes': 'Upcoming Live Quizzes',
      'speed_drill': '5-Minute Speed Drill',
      'start_exam': 'Start Exam',
      'submit_exam': 'Submit Exam',
      'time_remaining': 'Time Left',
      'question_counter': 'Question',
      'negative_marking': 'Negative marking: -0.50',
      'scorecard_title': 'Exam Scorecard & Review',
      'total_score': 'Total Marks',
      'accuracy_rate': 'Accuracy Rate',

      // Profile
      'profile_title': 'My Profile',
      'target_cadre': 'Target BCS Batch',
      'study_stats': 'Study Statistics',
      'account_verified': 'Verified Account',
      'cloud_sync': 'Cloud Data Sync',

      // Settings
      'settings_title': 'App Settings',
      'exam_preferences': 'Exam Preferences',
      'katex_rendering': 'KaTeX Math Formula Rendering',
      'katex_desc': 'Render LaTeX equations on canvas',
      'haptic_feedback': 'Haptic Vibration',
      'haptic_desc': 'Subtle tactile feedback on option tap',
      'clear_cache': 'Clear Offline Cache',
      'clear_cache_desc': 'Free up storage by clearing cached items',
      'about_app': 'About Medhavi',
      'version': 'Version',
      'terms_privacy': 'Terms & Privacy Policy',
    },
  };

  /// Returns localized string by key based on current Riverpod locale
  static String tr(WidgetRef ref, String key) {
    final locale = ref.watch(localeControllerProvider);
    final lang = locale.languageCode;
    return _localizedValues[lang]?[key] ??
        _localizedValues['bn']?[key] ??
        key;
  }

  /// Non-reactive lookup
  static String get(String lang, String key) {
    return _localizedValues[lang]?[key] ??
        _localizedValues['bn']?[key] ??
        key;
  }
}
