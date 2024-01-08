import 'package:flutter_widget/pages/home/home.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/secondary_list/controller/binding.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/secondary_list/view/subPages/system_secondary_list.dart';
import 'package:flutter_widget/pages/profile/profile.dart';
import 'package:flutter_widget/pages/tabBar/tabBar.dart';
import 'package:get/route_manager.dart';

class RouterPage {
  static const String tabBar = '/tab'; //tabBar
  static const String login = '/'; //登录页面
  static const String home = '/home'; //首页
  static const String profile = '/profile'; //我的页面
  static const String systemSecondaryList = '/systemSecondaryList'; //二级列表
  static final routes = [
    GetPage(
      name: tabBar,
      page: () => const TabBarPage(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
    ),
    GetPage(
      name: systemSecondaryList,
      binding: SecondaryBindings(),
      page: () => const SystemSecondaryListPage(),
    ),
  ];
}
