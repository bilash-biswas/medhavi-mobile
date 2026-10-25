import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:medhavi_mobile/core/models/app_version_info.dart';

class AppUpdateService {
  static const String currentVersion = '1.0.0';
  static const int currentBuildNumber = 1;

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
    } catch (e) {
      // Ignore Firestore failure and fallback to Vercel API
    }

    // 2. Fallback to Vercel JSON API
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(
        Uri.parse('https://medhavi-nine.vercel.app/api/app-version'),
      );
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        return AppVersionInfo.fromJson(json);
      }
    } catch (e) {
      // Offline or network error
    }

    return null;
  }

  /// Download the APK from the remote URL with live progress callback
  Future<String> downloadApk(
    String apkUrl, {
    required void Function(int receivedBytes, int totalBytes) onProgress,
  }) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(apkUrl));
    final response = await request.close();

    if (response.statusCode != 200) {
      throw HttpException('Failed to download APK: HTTP ${response.statusCode}');
    }

    final totalBytes = response.contentLength;
    final tempDir = Directory.systemTemp;
    final apkFile = File('${tempDir.path}/medhavi_update.apk');

    if (await apkFile.exists()) {
      await apkFile.delete();
    }

    final sink = apkFile.openWrite();
    int receivedBytes = 0;

    await for (final chunk in response) {
      receivedBytes += chunk.length;
      sink.add(chunk);
      onProgress(receivedBytes, totalBytes);
    }

    await sink.flush();
    await sink.close();

    return apkFile.path;
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
