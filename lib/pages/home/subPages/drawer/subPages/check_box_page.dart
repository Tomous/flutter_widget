import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CheckBoxPage extends StatefulWidget {
  const CheckBoxPage({super.key});

  @override
  State<CheckBoxPage> createState() => _CheckBoxPageState();
}

class _CheckBoxPageState extends State<CheckBoxPage> {
  final List<Map> _list = []; //数据源
  List<String> _deleteItems = []; //要删除的ID数组
  bool _isShowCheckBoxBtn = true; //相关组件显示隐藏控制，true代表隐藏
  bool _checkValue = false; //总的复选框控制开关

  //先初始化一些数据，当然这些数据实际中会调用接口的
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 20; i++) {
      _list.add({
        "id": i + 1,
        "name": "第${i + 1}条数据",
        "isChecked": false, //默认未选中
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkbox复选框'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              for (var item in _list) {
                item['isChecked'] = false; //列表设置为未选中
              }
              _deleteItems = []; //要删除的数组ID重置
              setState(() {
                _isShowCheckBoxBtn = !_isShowCheckBoxBtn; //显示隐藏总开关
                _checkValue = false; //复选框开关
              });
            },
          )
        ],
      ),
      body: _getContent(),
    );
  }

  //内容
  Widget _getContent() {
    if (_list.isEmpty) {
      return const Center(
        child: Text("暂无数据"),
      );
    }
    return Container(
      color: const Color.fromARGB(26, 188, 178, 178),
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: _isShowCheckBoxBtn ? 0 : 30.0),
            //列表
            child: ListView.builder(
              itemCount: _list.length,
              itemExtent: 80.0,
              itemBuilder: (context, index) {
                return _createListItem(_list[index]);
              },
            ),
          ),
          //底部操作样式
          Offstage(
            offstage: _isShowCheckBoxBtn,
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                color: Colors.red,
              ),
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.only(right: 10.0),
              height: 50.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        activeColor: Colors.blue, // 设置选中框的颜色
                        checkColor: Colors.white, // 设置选中标记的颜色
                        value: _checkValue,
                        onChanged: (isSelected) {
                          _deleteItems = []; //要删除的数组ID重置
                          for (var item in _list) {
                            item['isChecked'] = isSelected;
                            if (isSelected == true) {
                              //将数据ID放入数组
                              _deleteItems.add(item['id'].toString());
                            }
                          }
                          setState(() {
                            _checkValue = isSelected!;
                          });
                        },
                      ),
                      const Text('全选'),
                    ],
                  ),
                  InkWell(
                    child: const Text('删除'),
                    onTap: () {
                      EasyLoading.showToast('要删除的数据:$_deleteItems');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //列表item
  Widget _createListItem(item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
      //给Container添加点击手势，点击后改变isChecked的值
      child: GestureDetector(
        onTap: () {
          if (_isShowCheckBoxBtn) {
            return;
          }
          setState(() {
            item['isChecked'] = !item['isChecked'];
          });
          item['isChecked']
              ? _deleteItems.add(item['id'].toString())
              : _deleteItems.remove(item['id'].toString());
        },
        child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Row(
            children: [
              Offstage(
                offstage: _isShowCheckBoxBtn,
                child: Checkbox(
                  activeColor: Colors.blue, // 设置选中框的颜色
                  checkColor: Colors.white, // 设置选中标记的颜色
                  value: item['isChecked'],
                  onChanged: (value) {
                    if (value == false) {
                      _deleteItems.remove(item['id'].toString());
                    } else {
                      _deleteItems.add(item['id'].toString());
                    }
                    setState(() {
                      item['isChecked'] = value;
                    });
                  },
                ),
              ),
              Text(item['name']),
            ],
          ),
        ),
      ),
    );
  }
}
