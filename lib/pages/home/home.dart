import 'package:flutter/material.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/home_drawer.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class HomePage extends GetView {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        centerTitle: true, //文字居中显示
      ),
      drawer: const HomeDrawer(),
      body: Container(),
    );
  }
}
