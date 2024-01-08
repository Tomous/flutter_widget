import 'package:flutter/material.dart';
import 'package:flutter_widget/other/constants/constants.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.white, // 主题色
  // Android 风格
  platform: TargetPlatform.iOS,
  scaffoldBackgroundColor: AppColors.white, // 脚手架下的页面背景色(self.view.color)
  indicatorColor: AppColors.yellow, // 指示器颜色
  // ElevatedButton 主题
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      // 文字颜色
      foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.white;
        } else {
          return null;
        }
      }),
      // 背景色
      // backgroundColor: MaterialStateProperty.resolveWith((states) {
      //   if (states.contains(MaterialState.disabled)) {
      //     return AppColors.danger.withOpacity(0.5);
      //   } else {
      //     return AppColors.danger;
      //   }
      // }),
    ),
  ),
  // 小部件的前景色（旋钮，文本，过度滚动边缘效果等）
  splashColor: Colors.transparent, // 取消水波纹效果
  highlightColor: Colors.transparent, // 取消水波纹效果
  hoverColor: Colors.white.withOpacity(0.5),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: Colors.black, // 文字颜色
    ),
  ),

  // tabbar的样式
  tabBarTheme: const TabBarTheme(
    unselectedLabelColor: AppColors.deepTextColor,
    labelColor: AppColors.black,
    indicatorSize: TabBarIndicatorSize.label,
    unselectedLabelStyle: TextStyle(
      fontSize: 16,
    ),
    labelStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    labelPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
  ),

/*
  * 导航栏相关配置
  * */
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundColor,
    centerTitle: true, // 设置标题居中
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 16.0,
    ),
    elevation: 0, //去掉标题栏的阴影
  ),
  // 导航栏按钮颜色
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.white,
    unselectedItemColor: Color.fromRGBO(158, 174, 208, 0.5),
    selectedLabelStyle: TextStyle(fontSize: 12.0),
    unselectedLabelStyle: TextStyle(fontSize: 12.0),
  ),
  // 文字主题
  colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.primary),
  unselectedWidgetColor:
      const Color.fromRGBO(116, 137, 182, 0.43), //修改checkbox的显示框颜色
  inputDecorationTheme: const InputDecorationTheme(
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
          color: Color.fromRGBO(158, 174, 208, 0.2)), // 设置没有焦点时的下划线颜色
    ),
  ),
);
