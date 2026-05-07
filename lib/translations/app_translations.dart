import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'dark_mode': 'Dark Mode',
          'enabled': 'Enabled',
          'disabled': 'Disabled',
          'language': 'Language',
        },
        'km': {
          'dark_mode': 'របៀបងងឹត',
          'enabled': 'បើក',
          'disabled': 'បិទ',
          'language': 'ភាសា',
        },
        'zh': {
          'dark_mode': '深色模式',
          'enabled': '开启',
          'disabled': '关闭',
          'language': '语言',
        },
      };
}