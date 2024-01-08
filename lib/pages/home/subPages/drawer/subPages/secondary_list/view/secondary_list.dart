import 'package:flutter/material.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/secondary_list/view/subPages/custom_secondary_list.dart';
import 'package:flutter_widget/routers/routers.dart';
import 'package:get/get.dart';

class SecondaryListPage extends StatelessWidget {
  const SecondaryListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('二级列表'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Get.to(const CustomSecondaryListPage());
              },
              child: const Text('自定义二级列表'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed(RouterPage.systemSecondaryList);
              },
              child: const Text('系统二级列表'),
            ),
          ],
        ),
      ),
    );
  }
}
