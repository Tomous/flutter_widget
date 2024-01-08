import 'package:get/get.dart';

class LanguageOption {
  final String value;
  final String label;

  LanguageOption(this.value, this.label);
}

final List<LanguageOption> languageOptions = [
  LanguageOption('zh_CN', '默认'),
  LanguageOption('zh_CN', '中文简体'),
  LanguageOption('en_US', 'English'),
];

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': {
          //tabBar
          'tab_home': '首页',
          'tab_class_room': '课堂',
          'tab_store': '商城',
          'tab_shop_car': '购物车',
          'tab_profile': "我的",
        },
        'en_US': {
          //tabBar
          'tab_home': 'Home',
          'tab_class_room': 'ClassRoom',
          'tab_store': 'Store',
          'tab_shop_car': 'ShopCar',
          'tab_profile': "Profile",
        }
      };
}
