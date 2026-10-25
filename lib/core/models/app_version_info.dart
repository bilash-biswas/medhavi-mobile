class AppVersionInfo {
  final String latestVersion;
  final int latestBuildNumber;
  final int minSupportedBuildNumber;
  final String apkUrl;
  final String apkSize;
  final bool forceUpdate;
  final String releaseNotesBn;
  final String releaseNotesEn;
  final String? publishedAt;

  const AppVersionInfo({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.minSupportedBuildNumber,
    required this.apkUrl,
    required this.apkSize,
    required this.forceUpdate,
    required this.releaseNotesBn,
    required this.releaseNotesEn,
    this.publishedAt,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      latestVersion: json['latestVersion'] as String? ?? '1.0.1',
      latestBuildNumber: (json['latestBuildNumber'] as num?)?.toInt() ?? 2,
      minSupportedBuildNumber:
          (json['minSupportedBuildNumber'] as num?)?.toInt() ?? 1,
      apkUrl: json['apkUrl'] as String? ??
          'https://medhavi-nine.vercel.app/downloads/medhavi-app.apk',
      apkSize: json['apkSize'] as String? ?? '58.2 MB',
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      releaseNotesBn: json['releaseNotesBn'] as String? ??
          '• প্রশ্ন ব্যাংকের নতুন মিনিমাল ডিজাইন\n• দ্রুত নেভিগেশন ও অ্যানিমেশন',
      releaseNotesEn: json['releaseNotesEn'] as String? ??
          '• Minimal Question Bank UI\n• Performance improvements',
      publishedAt: json['publishedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latestVersion': latestVersion,
      'latestBuildNumber': latestBuildNumber,
      'minSupportedBuildNumber': minSupportedBuildNumber,
      'apkUrl': apkUrl,
      'apkSize': apkSize,
      'forceUpdate': forceUpdate,
      'releaseNotesBn': releaseNotesBn,
      'releaseNotesEn': releaseNotesEn,
      'publishedAt': publishedAt,
    };
  }
}
