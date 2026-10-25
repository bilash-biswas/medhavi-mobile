import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medhavi_mobile/core/models/app_version_info.dart';
import 'package:medhavi_mobile/core/services/app_update_service.dart';

enum AppUpdateStatus {
  idle,
  checking,
  available,
  upToDate,
  downloading,
  readyToInstall,
  error,
}

class AppUpdateState {
  final AppUpdateStatus status;
  final AppVersionInfo? versionInfo;
  final double downloadProgress;
  final int receivedBytes;
  final int totalBytes;
  final String? downloadedPath;
  final String? errorMessage;

  const AppUpdateState({
    this.status = AppUpdateStatus.idle,
    this.versionInfo,
    this.downloadProgress = 0.0,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.downloadedPath,
    this.errorMessage,
  });

  bool get isUpdateAvailable =>
      versionInfo != null &&
      versionInfo!.latestBuildNumber > AppUpdateService.currentBuildNumber;

  AppUpdateState copyWith({
    AppUpdateStatus? status,
    AppVersionInfo? versionInfo,
    double? downloadProgress,
    int? receivedBytes,
    int? totalBytes,
    String? downloadedPath,
    String? errorMessage,
  }) {
    return AppUpdateState(
      status: status ?? this.status,
      versionInfo: versionInfo ?? this.versionInfo,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      receivedBytes: receivedBytes ?? this.receivedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      downloadedPath: downloadedPath ?? this.downloadedPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService();
});

class AppUpdateController extends Notifier<AppUpdateState> {
  late final AppUpdateService _service;

  @override
  AppUpdateState build() {
    _service = ref.watch(appUpdateServiceProvider);
    return const AppUpdateState();
  }

  /// Check remote server for newer builds
  Future<AppVersionInfo?> checkForUpdate({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(status: AppUpdateStatus.checking);
    }

    try {
      final info = await _service.checkRemoteVersion();
      if (info != null &&
          info.latestBuildNumber > AppUpdateService.currentBuildNumber) {
        state = state.copyWith(
          status: AppUpdateStatus.available,
          versionInfo: info,
        );
        return info;
      } else {
        state = state.copyWith(
          status: AppUpdateStatus.upToDate,
          versionInfo: info,
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        status: AppUpdateStatus.error,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Start downloading the latest APK
  Future<void> startDownloadAndInstall() async {
    final info = state.versionInfo;
    if (info == null) return;

    state = state.copyWith(
      status: AppUpdateStatus.downloading,
      downloadProgress: 0.0,
      receivedBytes: 0,
      totalBytes: 0,
    );

    try {
      final path = await _service.downloadApk(
        info.apkUrl,
        onProgress: (received, total) {
          final progress =
              total > 0 ? (received / total).clamp(0.0, 1.0) : 0.0;
          state = state.copyWith(
            downloadProgress: progress,
            receivedBytes: received,
            totalBytes: total,
          );
        },
      );

      state = state.copyWith(
        status: AppUpdateStatus.readyToInstall,
        downloadedPath: path,
      );

      // Trigger installation
      await installDownloadedApk();
    } catch (e) {
      state = state.copyWith(
        status: AppUpdateStatus.error,
        errorMessage: 'ডাউনলোড ব্যর্থ হয়েছে: $e',
      );
    }
  }

  /// Request installation of the downloaded APK
  Future<void> installDownloadedApk() async {
    final path = state.downloadedPath;
    if (path == null) return;

    try {
      final canInstall = await _service.canInstallPackages();
      if (!canInstall) {
        await _service.openInstallPermissionSettings();
      }
      await _service.installApk(path);
    } catch (e) {
      state = state.copyWith(
        status: AppUpdateStatus.error,
        errorMessage: 'ইনস্টলেশন শুরু করতে সমস্যা হয়েছে: $e',
      );
    }
  }
}

final appUpdateControllerProvider =
    NotifierProvider<AppUpdateController, AppUpdateState>(
        AppUpdateController.new);
