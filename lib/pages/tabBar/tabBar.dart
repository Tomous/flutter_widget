import 'package:flutter/material.dart';
import 'package:flutter_widget/pages/classRoom/class_room.dart';
import 'package:flutter_widget/pages/home/home.dart';
import 'package:flutter_widget/pages/profile/profile.dart';
import 'package:flutter_widget/pages/shopCar/shop_car.dart';
import 'package:flutter_widget/pages/store/store.dart';
import 'package:get/get.dart';
import 'package:proste_indexed_stack/proste_indexed_stack.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({super.key});

  @override
  State<TabBarPage> createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage>
    with SingleTickerProviderStateMixin {
  final _tabBarTitles = [
    'tab_home',
    'tab_class_room',
    'tab_store',
    'tab_shop_car',
    'tab_profile'
  ];
  final _tabBarIcons = [
    'tab_icon_cookbook',
    'tab_icon_course',
    'tab_icon_mall',
    'tab_icon_favo',
    'tab_icon_mine'
  ];
  List<BottomNavigationBarItem> _tabBarItems = [];
  List<IndexedStackChild> _tabBarBodies = [];
  int _currentIndex = 0; //当前索引
  //增加ViewPager滑动切换效果
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabBarItems = List.generate(_tabBarTitles.length, (index) {
      return BottomNavigationBarItem(
        icon: Image.asset(
          'assets/tabbar/${_tabBarIcons[index]}.png',
          width: 22.0,
          height: 22.0,
        ),
        activeIcon: Image.asset(
          'assets/tabbar/${_tabBarIcons[index]}_active.png',
          width: 22.0,
          height: 22.0,
        ),
        label: _tabBarTitles[index].tr,
      );
    });

    _tabBarBodies = [
      IndexedStackChild(child: const HomePage()),
      IndexedStackChild(child: const ClassRoomPage()),
      IndexedStackChild(child: const StorePage()),
      IndexedStackChild(child: const ShopCarPage()),
      IndexedStackChild(child: const ProfilePage()),
    ];
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        //ios 的 tabbar
        type: BottomNavigationBarType.fixed, //tabbar点击风格
        fixedColor: Colors.black, //被点击后的颜色
        unselectedItemColor: Colors.black45,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        currentIndex: _currentIndex, //当前点击的是哪个
        items: _tabBarItems,
      ),
      // body: ProsteIndexedStack(
      //   index: _currentIndex,
      //   children: _tabBarBodies,
      // ),
      //用PageView实现左右滑动切换效果
      body: PageView.builder(
        itemBuilder: (context, index) {
          return ProsteIndexedStack(
            index: _currentIndex,
            children: _tabBarBodies,
          );
        },
        controller: _pageController,
        itemCount: _tabBarBodies.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: Container(
        height: 50.0,
        width: 50.0,
        padding: const EdgeInsets.all(2.0),
        margin: const EdgeInsets.only(top: 30.0),
        decoration: BoxDecoration(
          // color: Colors.yellow,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _currentIndex = 2;
            });
          },
          backgroundColor: _currentIndex == 2 ? Colors.red : Colors.blue,
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
