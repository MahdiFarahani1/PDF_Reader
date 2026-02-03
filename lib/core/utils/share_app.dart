import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  static void shareApp(BuildContext context) {
    final String appLink = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.dijlah.Sealedectar'
        : 'https://apps.apple.com/us/app/%D8%A7%D9%84%D8%B1%D8%AD%D9%8A%D9%82-%D8%A7%D9%84%D9%85%D8%AE%D8%AA%D9%88%D9%85/id6449500728';

    final box = context.findRenderObject() as RenderBox?;
    Share.share(
      appLink,
      subject: 'أدعوك للاطلاع على هذا التطبيق',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}
