import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:medhavi_mobile/core/constants/app_colors.dart';
import 'package:medhavi_mobile/core/localization/app_strings.dart';
import 'package:medhavi_mobile/core/models/app_version_info.dart';
import 'package:medhavi_mobile/core/utils/bengali_numeral_converter.dart';
import 'package:medhavi_mobile/features/app_update/presentation/controllers/app_update_controller.dart';

class AppUpdateDialog extends ConsumerWidget {
  final AppVersionInfo versionInfo;

  const AppUpdateDialog({super.key, required this.versionInfo});

  static Future<void> show(BuildContext context, AppVersionInfo info) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (ctx) => AppUpdateDialog(versionInfo: info),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = AppStrings.isBn(ref);
    final updateState = ref.watch(appUpdateControllerProvider);
    final isDownloading = updateState.status == AppUpdateStatus.downloading;
    final isReady = updateState.status == AppUpdateStatus.readyToInstall;

    final progressPct = (updateState.downloadProgress * 100).toInt();
    final downloadedMb =
        (updateState.receivedBytes / (1024 * 1024)).toStringAsFixed(1);
    final totalMb =
        (updateState.totalBytes / (1024 * 1024)).toStringAsFixed(1);

    return PopScope(
      canPop: !versionInfo.forceUpdate && !isDownloading,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Icon & Version Pill
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.sparkles,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn
                              ? 'নতুন আপডেট উপলব্ধ!'
                              : 'New Update Available!',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : Colors.black12,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'v${versionInfo.latestVersion}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${versionInfo.apkSize}',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Release Notes Box
              Text(
                isBn ? 'কী কী নতুন এসেছে:' : 'What\'s New:',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Text(
                  isBn
                      ? versionInfo.releaseNotesBn
                      : versionInfo.releaseNotesEn,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Downloading Progress Bar
              if (isDownloading) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? 'ডাউনলোড হচ্ছে...' : 'Downloading update...',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      isBn
                          ? '${BengaliNumeralConverter.toBengaliNumber(progressPct)}% ($downloadedMb / $totalMb MB)'
                          : '$progressPct% ($downloadedMb / $totalMb MB)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: updateState.downloadProgress,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Error display
              if (updateState.status == AppUpdateStatus.error) ...[
                Text(
                  updateState.errorMessage ?? 'Error updating app',
                  style: const TextStyle(fontSize: 11, color: AppColors.error),
                ),
                const SizedBox(height: 10),
              ],

              // Action Buttons
              Row(
                children: [
                  if (!versionInfo.forceUpdate && !isDownloading) ...[
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          isBn ? 'পরে' : 'Later',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isDownloading
                          ? null
                          : () {
                              if (isReady) {
                                ref
                                    .read(appUpdateControllerProvider.notifier)
                                    .installDownloadedApk();
                              } else {
                                ref
                                    .read(appUpdateControllerProvider.notifier)
                                    .startDownloadAndInstall();
                              }
                            },
                      child: Text(
                        isDownloading
                          ? (isBn ? 'ডাউনলোড হচ্ছে...' : 'Downloading...')
                          : isReady
                              ? (isBn ? 'ইনস্টল করুন ➔' : 'Install Now ➔')
                              : (isBn ? 'এখনই আপডেট করুন' : 'Update Now'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
