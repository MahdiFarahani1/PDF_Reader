import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  static Future<String> getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String versionName = packageInfo.version;
      String versionCode = packageInfo.buildNumber;
      return 'Version: $versionName ($versionCode)';
    } catch (e) {
      return 'Version info not available';
    }
  }
}
