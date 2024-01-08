import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///颜色
abstract class AppColors {
  //应用主题色
  // ignore: constant_identifier_names
  static const APP_THEME_COLOR = 0xff63ca6c;

  // ignore: constant_identifier_names
  static const APP_TABBAR_BACK_COLOR = 0x16181EFF;

  static const buttonColor = Color.fromRGBO(43, 82, 255, 1);
  static const textColor = Color.fromRGBO(158, 174, 208, 1);
  //标题栏颜色
  // ignore: constant_identifier_names
  static const APP_BAR_COLOR = 0xffffffff;

  static const Color primary = Color(0xfffbfbfb);

  static const Color success = Color(0xff07c160);

  static const Color danger = Color(0xffee0a24);

  static const Color warning = Color(0xffffba00);

  static const Color info = Color(0xff00a1d6);

  static const Color active = Colors.amber;

  static const Color black = Color.fromRGBO(61, 57, 58, 1.0);

  static const Color backgroundColor = Color.fromRGBO(18, 20, 25, 1);

  static const Color titleTextColor = Color.fromRGBO(158, 174, 208, 1);

  static const Color containerBackgroundColor = Color.fromRGBO(21, 24, 31, 1);

  static const Color qianTextColor = Color.fromRGBO(153, 153, 153, 1);

  static const Color deepTextColor = Color.fromRGBO(18, 24, 38, 1);

  static const Color yellow = Colors.amber;

  static const Color unactive = Color(0xff7b7b7b);

  static const Color un2active = Color(0xff8d8d8d);

  static const Color un3active = Color(0xffb1b1b1);

  static const Color page = Color(0xfff7f7f7);

  static const Color nav = Color(0xfffbfbfb);

  static const Color border = Color(0xfff5f5f5);

  static const Color line = Color.fromRGBO(239, 239, 239, 1);

  static const Color white = Color.fromRGBO(245, 245, 245, 1);

  static const Color background = Color.fromRGBO(248, 248, 248, 1);

  static const Color buttonColorBlue = Color.fromRGBO(43, 82, 255, 1);

  static const Color dialogBackColor = Color.fromRGBO(28, 34, 47, 1);

  static const Color borderColor = Color.fromRGBO(116, 137, 182, 0.2);

  static Color text1 = const Color(0xFF191D32);
  static Color text2 = const Color(0xFF344156);
  static Color text3 = const Color(0xFF474D66);
  static Color text4 = const Color(0xFF6B748F);
  static Color text5 = const Color(0xFF8B99AF);
  static Color text6 = const Color(0xFFA3B4CC);
  // 颜色值转换
  // static Color string2Color(String colorString) {
  //   int value = 0x00000000;
  //   if (colorString.isNotEmpty) {
  //     if (colorString[0] == '#') {
  //       colorString = colorString.substring(1);
  //     }
  //     value = int.tryParse(colorString, radix: 16);
  //     if (value != null) {
  //       if (value < 0xFF000000) {
  //         value += 0xFF000000;
  //       }
  //     }
  //   }
  //   return Color(value);
  // }
}

abstract class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

/// 本地保存的 key 名称
class StorageKeys {
  /// token
  // ignore: non_constant_identifier_names
  static String TOKEN = 'token';

  /// 用户email
  static String USER_EMAIL = 'user_email';

  ///用户密码
  static String PASSWORD = 'password';

  ///用户ID
  static String USER_ID = 'user_id';

  ///是否记住密码
  static String IS_REMEMBER = 'isRemember';

  ///是否同意隐私协议
  static String IS_AGREE = 'isAgree';

  ///是否同意隐私协议
  static String IS_FIRST = 'isFirst';

  ///记录选中的语言
  static String LANGUAGE = 'language';

  //承诺签署协议
  static String SIGNATUREFILE =
      '为了保证您在签署协议过程中，所签署的协议内容准确无误，请您仔细阅读本协议并确保您已充分理解本协议各条款。\n\n1. 签署本协议即表示您同意并接受本协议的全部内容。\n2. 签署本协议即表示您同意并接受本协议的全部内容。\n3. 签署本协议即表示您同意并接受本协议的全部内容。\n';
}

abstract class AppTextStyles {
  //标题
  // ignore: constant_identifier_names
  static const APP_TITLE_TEXT_STYLE = TextStyle(
    color: Colors.black,
    fontSize: 20,
  );
  //正文
  // ignore: constant_identifier_names
  static const APP_BODY_TEXT_STYLE = TextStyle(
    color: Colors.grey,
    fontSize: 16,
  );
}

const Divider divider = Divider(
    height: 0, color: Color.fromRGBO(158, 174, 208, 0.05), thickness: 1);

// const Divider divider = Divider(height: 0, color: Colors.red, thickness: 0.3);

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double statusBarHeight(BuildContext context) =>
    MediaQuery.of(context).padding.top;
double bottomHeight(BuildContext context) =>
    MediaQuery.of(context).padding.bottom;

SizedBox fitDivider({required double height}) =>
    SizedBox(height: ScreenUtil().setHeight(height));
double fitWidth(double width) => ScreenUtil().setWidth(width);
double fitHeight(double height) => ScreenUtil().setHeight(height);
