import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget/other/constants/common.dart';
import 'package:flutter_widget/other/language/message.dart';
import 'package:flutter_widget/other/theme/appTheme.dart';
import 'package:flutter_widget/routers/routers.dart';
import 'package:get/route_manager.dart';

void main() {
  runApp(const MyApp());
  //自定义EasyLoading的样式
  configEasyLoading();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), //设计稿中设备的尺寸
      minTextAdapt: true, //是否根据宽度/高度中的最小值适配文字大小
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          translations: Messages(), //你的翻译
          locale: const Locale('zh', 'CN'), //按照此处指定的语言翻译
          fallbackLocale: const Locale('zh', 'CN'), //翻译不存在的时候使用次语言
          title: 'App Name',
          theme: appTheme,
          builder: EasyLoading.init(),
          initialRoute: RouterPage.tabBar,
          defaultTransition: Transition.rightToLeft,
          //默认跳转动画
          getPages: RouterPage.routes,
        );
      },
    );
  }
}
