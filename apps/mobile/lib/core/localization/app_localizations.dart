import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('hi'), Locale('ta')];

  static const _values = {
    'en': {
      'home': 'Home',
      'medicines': 'Medicines',
      'scan': 'Scan',
      'doctors': 'Doctors',
      'records': 'Records',
    },
    'hi': {
      'home': 'Home',
      'medicines': 'Medicines',
      'scan': 'Scan',
      'doctors': 'Doctors',
      'records': 'Records',
    },
    'ta': {
      'home': 'Home',
      'medicines': 'Medicines',
      'scan': 'Scan',
      'doctors': 'Doctors',
      'records': 'Records',
    },
  };

  String t(String key) => _values[locale.languageCode]?[key] ?? key;
}
