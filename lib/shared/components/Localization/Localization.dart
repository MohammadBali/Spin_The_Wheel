import 'package:flutter/material.dart';

import 'languages.dart';

class Localization
{
  static Map<String, String> localizedValues = {};

  static Future<void> load(Locale locale) async {
    final String langCode = locale.languageCode;
    switch (langCode) {
      case 'ar':
        localizedValues = ar;
        break;

      default:
        localizedValues = en;
    }
  }

  static String translate(String key) {
    return localizedValues[key] ?? key;
  }
}