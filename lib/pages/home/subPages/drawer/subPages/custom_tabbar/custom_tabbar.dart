import 'package:flutter/material.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/custom_tabbar/pages/cus_tabbar.dart';

class CustomTabBarPage extends StatefulWidget {
  const CustomTabBarPage({super.key});

  @override
  State<CustomTabBarPage> createState() => _CustomTabBarPageState();
}

class _CustomTabBarPageState extends State<CustomTabBarPage>
    with TickerProviderStateMixin {
  late TabController controller;
  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: 3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '自定义tabBar',
        ),
      ),
      bottomNavigationBar: CustomTabBarWidget(
        tabs: ['1111', '2222', '3333'],
        controller: controller,
      ),
    );
  }
}
