import 'package:flutter/material.dart';

class CustomTabBarWidget extends StatefulWidget {
  /// tabList
  final List<String> tabs;

  /// 是否可滑动  (居左)
  final bool? isScrollable;

  /// 高亮文字大小
  final double? textSize;

  /// 非高亮文字大小
  final double? unTextSize;

  /// 小线颜色
  final Color? tabColors;

  /// 文字高亮颜色
  final Color? labelColor;

  /// 非高亮文字颜色
  final Color? unselectedLabelColor;

  /// controller 必传
  final TabController? controller;

  /// tab间距
  final double? horizontal;

  /// 下划线颜色，根据文字大小  根据tab大小
  final double lineBottom;

  final TabBarIndicatorSize? indicatorSize;

  /// page List
  final List<Widget> tabbarViewList;
  final Function(int)? didSelectIndex;

  /// 是否显示分割线
  final bool? showLine;
  const CustomTabBarWidget({
    super.key,
    required this.tabs,
    required this.controller,
    this.tabbarViewList = const [],
    this.unselectedLabelColor,
    this.isScrollable,
    this.textSize = 16.0,
    this.unTextSize = 16.0,
    this.tabColors,
    this.labelColor,
    this.horizontal,
    this.lineBottom = 0,
    this.indicatorSize,
    this.didSelectIndex,
    this.showLine = true,
  });

  @override
  State<CustomTabBarWidget> createState() => _CustomTabBarWidgetState();
}

class _CustomTabBarWidgetState extends State<CustomTabBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        getTabbarWidget(),
        widget.showLine == true
            ? Container(
                height: 0.5,
                color: const Color(0xffe5e5e5),
              )
            : Container(),
        getTabbarViewWidget(),
      ],
    );
  }

  Widget getTabbarWidget() {
    return TabBar(
        isScrollable: widget.isScrollable ?? false,
        controller: widget.controller,
        indicatorColor: widget.tabColors ?? Colors.red,
        // indicatorWeight:10,
        indicatorSize: widget.indicatorSize ?? TabBarIndicatorSize.label,
        indicatorPadding: const EdgeInsets.only(left: 0),
        indicator: UnderlineTabIndicator(
          insets: EdgeInsets.only(bottom: widget.lineBottom),
          borderRadius: const BorderRadius.all(Radius.circular(1)),
          borderSide: BorderSide(
            color: widget.tabColors ?? Colors.red,
            width: 2, //高度
          ),
        ),
        labelColor: widget.labelColor ?? Colors.red,
        unselectedLabelColor: widget.unselectedLabelColor ?? Colors.red,
        labelPadding: EdgeInsets.symmetric(
          horizontal: widget.horizontal ?? 20.0,
        ),
        labelStyle: TextStyle(
          fontSize: widget.textSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(fontSize: widget.unTextSize),
        onTap: (value) {
          if (widget.didSelectIndex != null) {
            widget.didSelectIndex!(value);
          }
        },
        tabs: widget.tabs.map<Tab>((String tab) {
          return Tab(
            text: tab,
          );
        }).toList());
  }

  Widget getTabbarViewWidget() {
    if (widget.tabbarViewList.isNotEmpty) {
      return Expanded(
        child: TabBarView(
          controller: widget.controller,
          children: widget.tabbarViewList,
        ),
      );
    } else {
      return Container();
    }
  }
}
