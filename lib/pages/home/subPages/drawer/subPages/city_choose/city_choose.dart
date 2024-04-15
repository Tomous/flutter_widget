import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget/pages/home/subPages/drawer/subPages/city_choose/model.dart';
import 'package:lpinyin/lpinyin.dart';

const double cellHeaderHeight = 40.0;
// cell的高度
const double cellHeight = 50.0;
// cell的高度
const double indexBarWidth = 130.0;
//高亮状态
const TextStyle highlightStyle = TextStyle(color: Colors.blue, fontSize: 16.0);
//正常状态
const TextStyle normalStyle = TextStyle(color: Colors.black, fontSize: 16.0);

const INDEX_WORDS = [
  '🔍',
  '⭐️',
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V',
  'W',
  'X',
  'Y',
  'Z',
];

class CityChoosePage extends StatefulWidget {
  /// 页面标题，默认空
  final String? appBarTitle;

  /// 热门推荐标题，默认空
  final String? hotCityTitle;

  /// 热门推荐城市列表
  final List hotCityList;

  /// 空页面中间展位图展示
  final Image? emptyImage;
  const CityChoosePage({
    super.key,
    this.appBarTitle = '',
    this.hotCityTitle = '',
    required this.hotCityList,
    this.emptyImage,
  });

  @override
  State<CityChoosePage> createState() => _CityChoosePageState();
}

class _CityChoosePageState extends State<CityChoosePage> {
  /// 城市列表
  final List<CityModel> _cityList = [];

  ///根据关键字搜索获取的数据
  final List<CityModel> _dataList = [];

  late ScrollController _scrollController;

  ///字典 里面放item和高度对应的数据
  final Map<String, double> _groupOffsetMap = {
    INDEX_WORDS[0]: 0.0, //放大镜
    INDEX_WORDS[1]: 0.0, //⭐️
  };

  ///搜索的文案
  String searchStr = "";

  @override
  void initState() {
    super.initState();

    ///加载数据
    _loadData();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() async {
    //加载城市列表
    String cityString = await rootBundle.loadString('assets/json/china.json');
    Map countyMap = json.decode(cityString);
    List list = countyMap['china'];

    List myCityList = [];
    for (var value in list) {
      ///汉字转拼音
      String pinyin = PinyinHelper.getPinyinE(value['name']);

      ///拿到拼音大写首字母
      String indexLetter = pinyin.substring(0, 1).toUpperCase();
      myCityList.add(
        {
          'name': value['name'],
          'pinyin': pinyin,
          'indexLetter': indexLetter,
        },
      );
    }
    _cityList.clear();
    _cityList.addAll(myCityList.map((e) => CityModel.fromJson(e)));

    ///排序
    _cityList.sort((a, b) => a.indexLetter!.compareTo(b.indexLetter!));

    ///第一次进来，搜索关键字为空，将数据赋值给_dataList
    _dataList.addAll(_cityList);

    /// 循环计算，将每个头的位置算出来，放入字典
    var groupOffset = 0.0;
    for (int i = 0; i < _dataList.length; i++) {
      if (i < 1) {
        //第一个cell一定有头
        _groupOffsetMap.addAll({_dataList[i].indexLetter!: groupOffset});
        groupOffset += cellHeight + cellHeaderHeight;
      } else if (_dataList[i].indexLetter == _dataList[i - 1].indexLetter) {
        // 相同的时候只需要加cell的高度
        groupOffset += cellHeight;
      } else {
        //第一个cell一定有头
        _groupOffsetMap.addAll({_dataList[i].indexLetter!: groupOffset});
        groupOffset += cellHeight + cellHeaderHeight;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.appBarTitle ?? ''),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Stack(
            children: <Widget>[
              ///内容
              Column(
                children: [
                  ///搜索框// 搜索框
                  SearchWidget(
                    onSearchChange: (text) {
                      _dataList.clear();
                      searchStr = text;
                      if (text.isNotEmpty) {
                        for (int i = 0; i < _cityList.length; i++) {
                          String name = _cityList[i].name!;
                          if (name.contains(text)) {
                            _dataList.add(_cityList[i]);
                          }
                        }
                      } else {
                        _dataList.addAll(_cityList);
                      }
                      setState(() {});
                    },
                  ),

                  ///热门城市+城市列表
                  Expanded(
                    child: Column(
                      children: [
                        ///热门城市
                        _buildHotCityWidget(),

                        ///城市列表
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: _dataList.length,
                            // itemExtent: 40.0,
                            itemBuilder: _itemForRow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              /// 索引条
              Positioned(
                right: 0.0,
                top: MediaQuery.of(context).size.height / 8,
                height: MediaQuery.of(context).size.height / 2,
                width: indexBarWidth,
                child: IndexBarWidget(
                  indexBarCallBack: (str) {
                    print('拿到索引条选中的字符：$str');
                    if (_groupOffsetMap[str] != null) {
                      _scrollController.animateTo(
                        _groupOffsetMap[str]!,
                        duration: const Duration(microseconds: 100),
                        curve: Curves.easeIn,
                      );
                    } else {}
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///热门城市widget
  Widget _buildHotCityWidget() {
    double width = (MediaQuery.of(context).size.width - 60) / 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding:
              const EdgeInsets.only(left: 20, right: 10, top: 20, bottom: 0),
          child: Text(
            widget.hotCityTitle ?? 'hotCityTitle',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 10),
          child: Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            spacing: 10.0,
            children: widget.hotCityList.map((e) {
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  side: const BorderSide(color: Color(0xFFF8F8F8), width: .5),
                  backgroundColor: const Color(0xFFF8F8F8),
                ),
                child: Container(
                  alignment: Alignment.center,
                  height: 36.0,
                  width: width,
                  padding: const EdgeInsets.all(0),
                  color: const Color(0xFFF8F8F8),
                  child: Text(
                    e,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF222222),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                onPressed: () {
                  debugPrint("OnItemClick: $e");
                  // if (widget.onValueChanged != null) {
                  //   widget.onValueChanged!(e);
                  // }
                  Navigator.pop(context, e);
                },
              );
            }).toList(),
          ),
        )
      ],
    );
  }

  ///城市列表的cell
  Widget? _itemForRow(BuildContext context, int index) {
    CityModel model = _dataList[index];
    //是否显示组名字
    bool hiddenTitle = index > 0 &&
        _dataList[index].indexLetter == _dataList[index - 1].indexLetter;
    return ItemCell(
      name: model.name!,
      groupTitle: hiddenTitle ? null : model.indexLetter,
      searchStr: searchStr,
    );
  }
}

///城市列表cell
class ItemCell extends StatelessWidget {
  final String name;
  final String? groupTitle;
  final String? searchStr;
  const ItemCell({
    super.key,
    required this.name,
    this.groupTitle,
    this.searchStr,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 15.0),
          height: groupTitle != null ? cellHeaderHeight : 0.0,
          color: const Color(0xFFF8F8F8),
          child: groupTitle != null
              ? Text(
                  groupTitle!,
                  style: const TextStyle(
                    fontSize: 19.0,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
        ),
        SizedBox(
          height: cellHeight,
          child: ListTile(
            title: _title(
              name,
              searchStr!,
            ),
          ),
        ),
      ],
    );
  }

  Widget _title(String name, String searchStr) {
    ///根据搜索关键字显示高亮状态文字
    List<TextSpan> spans = [];
    List<String> strs = name.split(searchStr);
    for (int i = 0; i < strs.length; i++) {
      String str = strs[i];
      if (str == '' && i < strs.length - 1) {
        spans.add(TextSpan(text: searchStr, style: highlightStyle));
      } else {
        spans.add(TextSpan(text: str, style: normalStyle));
        if (i < strs.length - 1) {
          spans.add(TextSpan(text: searchStr, style: highlightStyle));
        }
      }
    }
    return RichText(text: TextSpan(children: spans));

    ///直接返回文字
    // return Text(name);
  }
}

///搜索框
class SearchWidget extends StatefulWidget {
  final void Function(String) onSearchChange;
  const SearchWidget({
    super.key,
    required this.onSearchChange,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  bool _isShowClear = false;
  final TextEditingController _textEditingController = TextEditingController();
  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: Colors.red,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 20,
            height: 34,
            margin: const EdgeInsets.only(left: 10, right: 10.0),
            padding: const EdgeInsets.only(left: 10, right: 10.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search),
                Expanded(
                  child: TextField(
                    onChanged: _onChange,
                    controller: _textEditingController,
                    decoration: const InputDecoration(
                      hintText: '请输入搜索内容',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        left: 10,
                        bottom: 12,
                      ),
                    ),
                  ),
                ),
                if (_isShowClear)
                  GestureDetector(
                    onTap: () {
                      _textEditingController.clear();
                      setState(() {
                        _onChange('');
                      });
                    },
                    child: const Icon(Icons.cancel),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _onChange(String text) {
    _isShowClear = text.isNotEmpty;
    widget.onSearchChange(text);
  }
}

///右侧索引条
class IndexBarWidget extends StatefulWidget {
  final void Function(String str) indexBarCallBack;
  const IndexBarWidget({
    super.key,
    required this.indexBarCallBack,
  });

  @override
  State<IndexBarWidget> createState() => _IndexBarWidgetState();
}

class _IndexBarWidgetState extends State<IndexBarWidget> {
  Color _bkColor = const Color.fromRGBO(1, 1, 1, 0.0);
  Color _textColor = Colors.black;

  double _indicatorY = 0.0;
  String _indicatorStr = 'A';
  bool _indicatorShow = false;
  @override
  void initState() {
    super.initState();
  }

  /// 获取选中的字符
  int getIndex(BuildContext context, Offset globalPosition) {
    /// 拿到点前小部件(Container)的盒子
    RenderBox renderBox = context.findRenderObject() as RenderBox;

    /// 拿到y值
    double y = renderBox.globalToLocal(globalPosition).dy;

    /// 算出字符高度
    double itemHeight = renderBox.size.height / INDEX_WORDS.length;

    /// 算出第几个item
    /// int index = y ~/ itemHeight;
    /// 为了防止滑出区域后出现问题，所以index应该有个取值范围
    int index = (y ~/ itemHeight).clamp(0, INDEX_WORDS.length - 1);
    return index;
  }

  @override
  Widget build(BuildContext context) {
    //索引条
    final List<Widget> wordsList = [];
    for (var i = 0; i < INDEX_WORDS.length; i++) {
      wordsList.add(
        Expanded(
          child: Text(
            INDEX_WORDS[i],
            style: TextStyle(
              color: _textColor,
              fontSize: 14.0,
            ),
          ),
        ),
      );
    }
    return Row(
      children: [
        Container(
          alignment: Alignment(0.0, _indicatorY),
          width: indexBarWidth - 20.0,
          child: _indicatorShow
              ? Stack(
                  alignment: const Alignment(-0.1, 0),
                  children: [
                    //应该放一张图片，没找到合适的，就用Container代替
                    Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.all(
                          Radius.circular(30.0),
                        ),
                      ),
                    ),
                    Text(
                      _indicatorStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                )
              : null,
        ),
        GestureDetector(
          onVerticalDragDown: (details) {
            int index = getIndex(context, details.globalPosition);
            widget.indexBarCallBack(INDEX_WORDS[index]);
            setState(() {
              _bkColor = const Color.fromRGBO(1, 1, 1, 0.5);
              _textColor = Colors.white;

              //显示气泡
              _indicatorY = 2.2 / INDEX_WORDS.length * index - 1.1;
              _indicatorStr = INDEX_WORDS[index];
              _indicatorShow = true;
            });
          },
          onVerticalDragEnd: (details) {
            setState(() {
              _bkColor = const Color.fromRGBO(1, 1, 1, 0.0);
              _textColor = Colors.black;

              // 隐藏气泡
              _indicatorShow = false;
            });
          },
          onVerticalDragUpdate: (details) {
            int index = getIndex(context, details.globalPosition);
            widget.indexBarCallBack(INDEX_WORDS[index]);

            //显示气泡
            setState(() {
              _indicatorY = 2.2 / INDEX_WORDS.length * index - 1.1;
              _indicatorStr = INDEX_WORDS[index];
              _indicatorShow = true;
            });
          },
          child: Container(
            color: _bkColor,
            width: 20.0,
            child: Column(
              children: wordsList,
            ),
          ),
        ),
      ],
    );
  }
}
