import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/secondary_list/model/model.dart';
import 'package:get/get.dart';

class SecondaryListController extends GetxController {
  final RxList<ListModel> dataList = <ListModel>[].obs;

  @override
  void onReady() {
    super.onReady();
    _loadData(); // 加载数据
  }

  _loadData() async {
    dataList.clear();
    String jsonString = await rootBundle.loadString('assets/json/list.json');
    Map<String, dynamic> dict = jsonDecode(jsonString);
    dataList.addAll(
        dict['data'].map<ListModel>((e) => ListModel.fromJson(e)).toList());
    update();
  }
}
