import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:medhavi_mobile/core/models/app_version_info.dart';

class AppUpdateService {
  static const String currentVersion = '1.0.2';
  static const int currentBuildNumber = 3;

  static const MethodChannel _channel =
      MethodChannel('bd.medhavi.medhavi_mobile/app_updater');

  final FirebaseFirestore _firestore;

  AppUpdateService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Check whether an update is available compared to the current build
  Future<AppVersionInfo?> checkRemoteVersion() async {
    // 1. Try Firestore First
    try {
      final doc = await _firestore
          .collection('system_config')
          .doc('mobile_app')
          .get();

      if (doc.exists && doc.data() != null) {
        return AppVersionInfo.fromJson(doc.data()!);
      }
    } catch (_) {
      // Ignore Firestore failure and fallback to Vercel API
    }

    // 2. Fallback to Vercel JSON API
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(
        Uri.parse('https://medhavi-nine.vercel.app/api/app-version'),
      );
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        return AppVersionInfo.fromJson(json);
      }
    } catch (_) {
      // Offline or network error
    }

    return null;
  }

  /// Download the APK from the remote URL with automatic retry and HTTP Range resume support
  Future<String> downloadApk(
    String apkUrl, {
    required void Function(int receivedBytes, int totalBytes) onProgress,
    void Function(String message)? onStatusChange,
  }) async {
    final tempDir = Directory.systemTemp;
    final apkFile = File('${tempDir.path}/medhavi_update.apk');

    int totalBytes = 0;
    int receivedBytes = 0;

    // Check if partial download already exists from previous attempt
    if (await apkFile.exists()) {
      receivedBytes = await apkFile.length();
    }

    const int maxRetries = 10;
    int retries = 0;

    while (retries < maxRetries) {
      HttpClient? client;
      IOSink? sink;
      try {
        client = HttpClient()
          ..idleTimeout = const Duration(minutes: 5)
          ..connectionTimeout = const Duration(seconds: 30)
          ..autoUncompress = false;

        final request = await client.getUrl(Uri.parse(apkUrl));
        request.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 (Linux; Android) MedhaviApp');
        request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
        request.headers.set(HttpHeaders.connectionHeader, 'keep-alive');

        // If we already have some bytes, request the remaining range
        if (receivedBytes > 0) {
          request.headers.set(HttpHeaders.rangeHeader, 'bytes=$receivedBytes-');
        }

        final response = await request.close();

        // 200 OK (fresh download) or 206 Partial Content (resumed download)
        if (response.statusCode != 200 && response.statusCode != 206) {
          // If server rejects range (e.g. 416), reset to 0 and try fresh full download
          if (response.statusCode == 416 || response.statusCode == 412) {
            if (await apkFile.exists()) await apkFile.delete();
            receivedBytes = 0;
            retries++;
            continue;
          }
          throw HttpException('HTTP ${response.statusCode}');
        }

        if (response.statusCode == 200) {
          totalBytes = response.contentLength;
          if (await apkFile.exists() && receivedBytes > 0) {
            await apkFile.delete();
            receivedBytes = 0;
          }
          sink = apkFile.openWrite(mode: FileMode.write);
        } else if (response.statusCode == 206) {
          final remaining = response.contentLength;
          totalBytes = receivedBytes + (remaining > 0 ? remaining : 0);
          sink = apkFile.openWrite(mode: FileMode.append);
        }

        onProgress(receivedBytes, totalBytes);

        await for (final chunk in response) {
          receivedBytes += chunk.length;
          sink?.add(chunk);
          onProgress(receivedBytes, totalBytes);
        }

        await sink?.flush();
        await sink?.close();
        client.close();

        // Verify file was fully downloaded
        if (totalBytes > 0 && receivedBytes >= totalBytes) {
          return apkFile.path;
        }

        if (totalBytes > 0 && receivedBytes < totalBytes) {
          retries++;
          onStatusChange?.call('সংযোগ বিঘ্নিত হয়েছিল, পুনরায় চেষ্টা চলছে ($retries/$maxRetries)...');
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }

        return apkFile.path;
      } catch (e) {
        retries++;
        try {
          await sink?.flush();
          await sink?.close();
        } catch (_) {}
        client?.close(force: true);

        // Update received bytes from disk so next attempt resumes exactly
        if (await apkFile.exists()) {
          receivedBytes = await apkFile.length();
        }

        if (retries >= maxRetries) {
          throw HttpException('ইন্টারনেট সংযোগ বিচ্ছিন্ন হয়েছে। অনুগ্রহ করে পুনরায় চেষ্টা করুন বা ব্রাউজারে ডাউনলোড করুন।');
        }

        onStatusChange?.call('সংযোগ বিঘ্নিত হয়েছিল, পুনরায় চেষ্টা চলছে ($retries/$maxRetries)...');
        await Future.delayed(const Duration(milliseconds: 1500));
      }
    }

    if (await apkFile.exists() && await apkFile.length() > 0) {
      return apkFile.path;
    }
    throw HttpException('ডাউনলোড সম্পন্ন করা যায়নি।');
  }

  /// Open external browser download page or direct link
  Future<bool> openBrowserDownload(String url) async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('openBrowserDownload', {'url': url});
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Download via Android's native system DownloadManager
  Future<bool> downloadViaSystemManager(String url, {String? title}) async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>('downloadViaSystemManager', {
        'url': url,
        'title': title ?? 'মেধাবী অ্যাপ আপডেট (Medhavi Update)',
      });
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Check if the app has permission to install unknown APKs
  Future<bool> canInstallPackages() async {
    if (!Platform.isAndroid) return false;
    try {
      final canInstall =
          await _channel.invokeMethod<bool>('canInstallPackages');
      return canInstall ?? false;
    } catch (_) {
      return true;
    }
  }

  /// Open Android System Settings for "Install Unknown Apps"
  Future<bool> openInstallPermissionSettings() async {
    if (!Platform.isAndroid) return false;
    try {
      final res =
          await _channel.invokeMethod<bool>('openInstallPermissionSettings');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Launch Android Package Installer for the downloaded APK
  Future<bool> installApk(String filePath) async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _channel.invokeMethod<bool>(
        'installApk',
        {'filePath': filePath},
      );
      return res ?? false;
    } catch (e) {
      rethrow;
    }
  }
}
