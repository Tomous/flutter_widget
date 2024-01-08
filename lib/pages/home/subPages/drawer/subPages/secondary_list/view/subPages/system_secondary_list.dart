import 'package:flutter/material.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/secondary_list/controller/secondary_controller.dart';
import 'package:get/get.dart';

class SystemSecondaryListPage extends GetView<SecondaryListController> {
  const SystemSecondaryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('系统二级列表'),
      ),
      body: GetBuilder<SecondaryListController>(builder: (_) {
        return SingleChildScrollView(
          child: Container(
            child: _buildExpansionPanel(),
          ),
        );
      }),
    );
  }

  Widget _buildExpansionPanel() {
    return ExpansionPanelList.radio(
      initialOpenPanelValue: controller.dataList[0].id, //默认展开第一个
      expandIconColor:
          Colors.white, //设置icon的颜色，因为设置了canTapOnHeader: true，所以这里无效
      dividerColor: const Color.fromARGB(0, 233, 219, 219),
      expandedHeaderPadding: const EdgeInsets.all(0),
      materialGapSize: 0,
      // 设置底部阴影大小
      elevation: 0,
      children: controller.dataList.map<ExpansionPanelRadio>((item) {
        return ExpansionPanelRadio(
          canTapOnHeader: true, //点击区域
          backgroundColor: Colors.red,
          value: item.id!, //唯一标识
          headerBuilder: (context, isExpanded) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                item.title!,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            );
          },
          body: ListView.builder(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: item.subData!.length,
            itemExtent: 76.0,
            itemBuilder: (context, index) {
              return Container(
                color: Colors.green,
                child: ListTile(
                  title: Text(item.subData![index].title!),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
