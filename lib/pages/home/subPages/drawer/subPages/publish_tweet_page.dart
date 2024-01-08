import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PublishTweetPage extends StatefulWidget {
  const PublishTweetPage({super.key});

  @override
  State<PublishTweetPage> createState() => _PublishTweetPageState();
}

class _PublishTweetPageState extends State<PublishTweetPage> {
  final List<String> _titles = [
    '长亭外古道边',
    '我们跟党走',
    '小路通车',
    '烽火连三月',
    '家书抵万金',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('瀑布流布局'),
      ),
      body: Container(
        color: Colors.grey[200],
        //如果不用singleChildScrollView包裹的话，滚动MasonryGridView会出现数据刷新的情况，后续如果遇到解决方法再回来处理
        child: SingleChildScrollView(
          child: MasonryGridView.count(
            physics:
                const NeverScrollableScrollPhysics(), //本身不滚动，让外面的singlescrollview来滚动
            shrinkWrap: true, //收缩，让外面的singlescrollview来滚动
            padding: const EdgeInsets.all(10.0),
            itemCount: 30, //数据条数
            crossAxisCount: 2, //横轴的个数
            crossAxisSpacing: 10.0, //横轴之间的间距
            mainAxisSpacing: 15.0, //竖轴之间的间距
            itemBuilder: (context, index) {
              //添加点击手势包裹
              return GestureDetector(
                onTap: () {
                  Fluttertoast.showToast(
                    msg: '点击了第$index条数据',
                    gravity: ToastGravity.CENTER,
                  );
                },
                child: Container(
                  //裁剪Container上面为圆角
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        //裁剪Image上面为圆角
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                        child: Image.asset(
                          './assets/images/image${Random().nextInt(10) + 1}.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          _titles[Random().nextInt(5)],
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.only(left: 10.0, bottom: 10.0),
                        // color: Colors.blue,
                        child: Row(
                          children: [
                            ClipOval(
                              child: Image.asset(
                                './assets/images/image${Random().nextInt(10) + 1}.jpeg',
                                width: 30.0,
                                height: 30.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            const Text(
                              '这是一个名称',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
