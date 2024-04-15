import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/guide/pages/guide_tool.dart';

class StartGuidePage extends StatefulWidget {
  const StartGuidePage({super.key});

  @override
  State<StartGuidePage> createState() => _StartGuidePageState();
}

class _StartGuidePageState extends State<StartGuidePage> {
  late Guide intro;
  _StartGuidePageState() {
    intro = Guide(
        stepCount: 7,
        introMode: GuideMode.force,
        widgetBuilder: StepWidgetBuilder.useDefaultTheme(
          showClose: false,
          tipInfo: [
            GuideTipInfoBean(
              title: "标题栏",
              message: "这里是标题栏，显示当前页面的名称",
              imgUrl: "",
            ),
            GuideTipInfoBean(
              title: "标签组件",
              message: "这里是标签组件，你可以动态添加或者删除组件，当你点击后会将结果给你回传",
              imgUrl: "",
            ),
            GuideTipInfoBean(
              title: "左边的按钮",
              message: "这里是按钮，点击他试试",
              imgUrl: '',
            ),
            GuideTipInfoBean(
              title: "右边的按钮",
              message: "这里是按钮，点击他试试",
              imgUrl: '',
            ),
            GuideTipInfoBean(
              title: "左边的文本 ",
              message: "这是一个朴实无华的文本",
              imgUrl: '',
            ),
            GuideTipInfoBean(
              title: "右边文本 ",
              message: "这是一个枯燥文本",
              imgUrl: "",
            ),
            GuideTipInfoBean(
              title: "开始按钮 ",
              message: "点击开启引导动画",
              imgUrl: '',
            ),
          ],
        ));
  }
  @override
  void initState() {
    super.initState();
    Timer(const Duration(microseconds: 0), () {
      intro.start(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '强引导语组件',
          key: intro.keys[0],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BrnSelectTagWidget',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                '流式布局的自适应标签(最小宽度75)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                key: intro.keys[1],
                child: const Column(
                  children: [
                    Text('这是一条很长很长很长很长很长很长很长很长很长很长的标签'),
                    Text('标签么么么么么'),
                    Text('标签么么没没没么么么'),
                    Text('标签么么么么么'),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    key: intro.keys[2],
                    onPressed: () {},
                    child: const Text("需求1"),
                  ),
                  ElevatedButton(
                    key: intro.keys[3],
                    onPressed: () {},
                    child: const Text("需求2"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: 14,
                    padding: const EdgeInsets.only(top: 20),
                    alignment: Alignment.center,
                    child: Text(
                      '左边的文字',
                      key: intro.keys[4],
                    ),
                  ),
                  Container(
                    width: 14,
                    padding: const EdgeInsets.only(top: 20),
                    alignment: Alignment.center,
                    child: Text(
                      '右边的文字',
                      key: intro.keys[5],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: intro.keys[6],

        /// 1st guide
        child: const Icon(
          Icons.add,
        ),
        onPressed: () {
          intro.start(context);
        },
      ),
    );
  }
}
