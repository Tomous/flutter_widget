import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter/material.dart';

//自定义EasyLoading的样式
void configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 1000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.white
    ..backgroundColor = const Color.fromRGBO(28, 34, 47, 1)
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false //防止点击
    ..dismissOnTap = false;
}
