import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/drop_down_menu/pages/drop_menu_widget.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/drop_down_menu/pages/popup_list_window.dart';

class DropDownMenuPage extends StatelessWidget {
  const DropDownMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey actionKey = GlobalKey();
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义下拉选择框'),
        actions: [
          Container(
            padding: const EdgeInsets.only(right: 20.0),
            child: TextButton(
              key: actionKey,
              onPressed: () {
                PopupListWindow.showPopListWindow(
                  context,
                  actionKey,
                  offset: 10,
                  data: ["aaaa", "bbbbb"],
                  onItemClick: (index, item) {
                    EasyLoading.showToast("点击了第$index个，内容是$item");
                    return true;
                  },
                );
              },
              child: const Text(
                '弹出菜单',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          color: Colors.grey,
          width: 130,
          height: 50,
          alignment: Alignment.centerLeft,
          child: DropMenuWidget(
            leading: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text('当前选中:'),
            ),
            data: const [
              {'label': '华为', 'value': '1'},
              {'label': '小米', 'value': '2'},
              {'label': 'Apple', 'value': '3'},
              {'label': '乔布斯', 'value': '4'},
              {'label': '啦啦啦啦啦', 'value': '5'},
              {'label': '呵呵', 'value': '7'},
              {'label': '乐呵乐呵', 'value': '7'},
            ],
            selectCallBack: (value) {
              print('选中的value是：$value');
            },
            offset: const Offset(0, 50),
            selectedValue: '3', //默认选中第三个
          ),
        ),
      ),
    );
  }
}
