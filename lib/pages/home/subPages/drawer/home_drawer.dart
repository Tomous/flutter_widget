import 'package:flutter/material.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/check_box_page.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/city_choose/city_choose.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/drop_down_menu/drop_down_menu.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/publish_tweet_page.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/secondary_list/view/secondary_list.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/signature_page.dart';
import 'package:get/route_manager.dart';

// ignore: constant_identifier_names
const IconList = [
  Icons.send,
  Icons.check_box,
  Icons.home,
  Icons.menu,
  Icons.settings,
  Icons.menu,
];
// ignore: constant_identifier_names
const TitleList = [
  '瀑布流布局',
  'Checkbox复选框',
  '承诺签约',
  '自定义下拉选择框',
  '二级列表',
  '城市单选',
];
final List<Widget> menuPageList = [
  const PublishTweetPage(),
  const CheckBoxPage(),
  const SignaturePage(),
  const DropDownMenuPage(),
  const SecondaryListPage(),
  const CityChoosePage(
    appBarTitle: '城市单选',
    hotCityTitle: '这里是推荐城市',
    hotCityList: [
      "北京市",
      "广州市",
      "成都市",
      "深圳市",
      "杭州市",
      "武汉市",
    ],
  ),
];

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.separated(
        padding: const EdgeInsets.all(0.0), //解决状态栏问题
        itemBuilder: (context, index) {
          if (index == 0) {
            //第一个则显示顶部图片
            return Image.asset(
              'assets/images/image2.jpeg',
              fit: BoxFit.cover,
            );
          }
          index -= 1;
          return ListTile(
            leading: Icon(IconList[index]),
            title: Text(TitleList[index]),
            trailing: const Icon(Icons.arrow_forward_ios), //右箭头
            onTap: () {
              Get.to(menuPageList[index]);
            },
          );
        },
        separatorBuilder: (context, index) {
          //列表分隔线
          return Divider(height: index == 0 ? 0.0 : 1.0);
        },
        itemCount: IconList.length + 1,
      ),
    );
  }
}
