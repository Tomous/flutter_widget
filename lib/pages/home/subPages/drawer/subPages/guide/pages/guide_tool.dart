import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// 引导组件试，[force] 有蒙层遮挡，[soft] 无蒙层遮挡
enum GuideMode { force, soft }

class GuideTipInfoBean {
  /// 引导标题
  final String title;

  /// 引导信息
  final String message;

  /// 引导图片
  final String imgUrl;

  GuideTipInfoBean({
    this.title = '',
    this.message = '',
    this.imgUrl = '',
  });
}

/// 通过阻断式的交互弹框，实现新手交互
/// 支持 强引导：界面变灰，引导框高亮| 弱引导：直接在界面浮现提示框两种
class Guide {
  bool _removed = false;
  late double _widgetWidth;
  late double _widgetHeight;
  late Offset _widgetOffset;
  OverlayEntry? _overlayEntry;
  int _currentStepIndex = 0;
  late Widget _stepWidget;
  final List<Map> _configMap = [];
  final List<GlobalKey> _globalKeys = [];
  final Color _maskColor = Colors.black.withOpacity(.6);
  final Duration _animationDuration = const Duration(milliseconds: 300);
  final _th = _Throttling(duration: const Duration(milliseconds: 500));
  late Size _lastScreenSize;

  /// 当前处于第几步
  int get currentStepIndex => _currentStepIndex;

  /// 每一步的具体引导 Widget
  final Widget Function(StepWidgetParams params) widgetBuilder;

  /// 高亮组件与目标组件的间距，默认是 10
  final EdgeInsets padding;

  /// 强提示下的高亮圆角，默认 BorderRadius.all(Radius.circular(4))
  final BorderRadiusGeometry borderRadius;

  /// 步骤数量，必传
  final int stepCount;

  /// 每次点击的下一步的时候的回调
  final void Function(int nextIndex)? onNextClick;

  /// 引导交互的模式
  GuideMode introMode;

  Guide({
    required this.introMode,
    required this.widgetBuilder,
    required this.stepCount,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.padding = const EdgeInsets.all(10),
    this.onNextClick,
  }) : assert(stepCount > 0) {
    for (int i = 0; i < stepCount; i++) {
      _globalKeys.add(GlobalKey());
      _configMap.add({});
    }
  }

  List<GlobalKey> get keys => _globalKeys;

  /// Set the configuration of the specified number of steps
  ///
  /// [stepIndex] Which step of configuration needs to be modified
  /// [padding] Padding setting
  /// [borderRadius] BorderRadius setting
  void setStepConfig(
    int stepIndex, {
    EdgeInsets? padding,
    BorderRadiusGeometry? borderRadius,
  }) {
    assert(stepIndex >= 0 && stepIndex < stepCount);
    _configMap[stepIndex] = {
      'padding': padding,
      'borderRadius': borderRadius,
    };
  }

  /// Set the configuration of multiple steps
  ///
  /// [stepsIndex] Which steps of configuration needs to be modified
  /// [padding] Padding setting
  /// [borderRadius] BorderRadius setting
  void setStepsConfig(
    List<int> stepsIndex, {
    EdgeInsets? padding,
    BorderRadiusGeometry? borderRadius,
  }) {
    assert(stepsIndex
        .every((stepIndex) => stepIndex >= 0 && stepIndex < stepCount));
    for (var index in stepsIndex) {
      setStepConfig(
        index,
        padding: padding,
        borderRadius: borderRadius,
      );
    }
  }

  void _getWidgetInfo(GlobalKey globalKey) {
    try {
      EdgeInsets? currentConfig = _configMap[_currentStepIndex]['padding'];
      RenderBox renderBox =
          globalKey.currentContext?.findRenderObject() as RenderBox;
      _widgetWidth = renderBox.size.width +
          (currentConfig?.horizontal ?? padding.horizontal);
      _widgetHeight =
          renderBox.size.height + (currentConfig?.vertical ?? padding.vertical);
      _widgetOffset = Offset(
        renderBox.localToGlobal(Offset.zero).dx -
            (currentConfig?.left ?? padding.left),
        renderBox.localToGlobal(Offset.zero).dy -
            (currentConfig?.top ?? padding.top),
      );
    } on Exception catch (e) {
      _widgetWidth = 0;
      _widgetHeight = 0;
      _widgetOffset = Offset.zero;
      debugPrint('get screen size error: ${e.toString()}');
    }
  }

  Widget _maskBuilder({
    double? width,
    double? height,
    BlendMode? backgroundBlendMode,
    required double left,
    required double top,
    double? bottom,
    double? right,
    BorderRadiusGeometry? borderRadiusGeometry,
    Widget? child,
  }) {
    final decoration = BoxDecoration(
      color: Colors.white,
      backgroundBlendMode: backgroundBlendMode,
      borderRadius: borderRadiusGeometry,
    );
    return AnimatedPositioned(
      duration: _animationDuration,
      left: left,
      top: top,
      bottom: bottom,
      right: right,
      child: AnimatedContainer(
        padding: padding,
        decoration: decoration,
        width: width,
        height: height,
        duration: _animationDuration,
        child: child,
      ),
    );
  }

  void _showOverlay(
    BuildContext context,
    GlobalKey globalKey,
  ) {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        Size screenSize = MediaQuery.of(context).size;

        if (screenSize.width != _lastScreenSize.width &&
            screenSize.height != _lastScreenSize.height) {
          _lastScreenSize = screenSize;
          _th.throttle(() {
            _createStepWidget(context);
            _overlayEntry?.markNeedsBuild();
          });
        }

        return _DelayRenderedWidget(
          removed: _removed,
          childPersist: true,
          duration: _animationDuration,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                introMode == GuideMode.force
                    ? ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          _maskColor,
                          BlendMode.srcOut,
                        ),
                        child: Stack(
                          children: [
                            _maskBuilder(
                              backgroundBlendMode: BlendMode.dstOut,
                              left: 0,
                              top: 0,
                              right: 0,
                              bottom: 0,
                            ),
                            _maskBuilder(
                              width: _widgetWidth,
                              height: _widgetHeight,
                              left: _widgetOffset.dx,
                              top: _widgetOffset.dy,
                              borderRadiusGeometry:
                                  _configMap[_currentStepIndex]
                                          ['borderRadius'] ??
                                      borderRadius,
                            ),
                          ],
                        ),
                      )
                    : const Row(),
                _DelayRenderedWidget(
                  child: _stepWidget,
                ),
              ],
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _onNext(BuildContext context) {
    _currentStepIndex++;
    if (_currentStepIndex < stepCount) {
      if (onNextClick != null) {
        onNextClick!(currentStepIndex);
      }
      _renderStep(context);
    }
  }

  void _onFinish() {
    if (_overlayEntry == null) return;
    _removed = true;
    _overlayEntry!.markNeedsBuild();
    Timer(_animationDuration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _createStepWidget(BuildContext context) {
    _getWidgetInfo(_globalKeys[_currentStepIndex]);
    Size screenSize = MediaQuery.of(context).size;
    Size widgetSize = Size(_widgetWidth, _widgetHeight);

    _stepWidget = widgetBuilder(
      StepWidgetParams(
        introMode: introMode,
        screenSize: screenSize,
        size: widgetSize,
        onNext: _currentStepIndex == stepCount - 1
            ? () => _onFinish()
            : () => _onNext(context),
        offset: _widgetOffset,
        currentStepIndex: _currentStepIndex,
        stepCount: stepCount,
        onFinish: _onFinish,
      ),
    );
  }

  void _renderStep(BuildContext context) {
    _createStepWidget(context);
    _overlayEntry?.markNeedsBuild();
  }

  /// 触发引导操作 [context]当前环境[BuildContext]的启动方法
  void start(BuildContext context) {
    _lastScreenSize = MediaQuery.of(context).size;
    _removed = false;
    _currentStepIndex = 0;
    _createStepWidget(context);
    _showOverlay(
      context,
      _globalKeys[_currentStepIndex],
    );
  }

  /// Destroy the guide page and release all resources
  void dispose() {
    _onFinish();
  }
}

class _Throttling {
  late Duration _duration;
  Timer? _timer;

  _Throttling({Duration duration = const Duration(seconds: 1)})
      : assert(!duration.isNegative) {
    _duration = duration;
  }

  void throttle(Function func) {
    _timer ??= Timer(_duration, () {
      Function.apply(func, []);
      _timer = null;
    });
  }
}

class StepWidgetParams {
  /// Enter the next guide page method, or null if there is no
  final VoidCallback? onNext;

  /// End all guide page methods
  final VoidCallback? onFinish;

  /// Which guide page is currently displayed, starting from 0
  final int currentStepIndex;

  /// Total number of guide pages
  final int stepCount;

  /// The width and height of the screen
  final Size screenSize;

  /// The width and height of the highlighted component
  final Size size;

  /// The coordinates of the upper left corner of the highlighted component
  final Offset offset;
  final GuideMode introMode;

  StepWidgetParams({
    required this.introMode,
    this.onNext,
    this.onFinish,
    required this.screenSize,
    required this.size,
    required this.currentStepIndex,
    required this.stepCount,
    required this.offset,
  });

  @override
  String toString() {
    return 'StepWidgetParams(currentStepIndex: $currentStepIndex, stepCount: $stepCount, size: $size, screenSize: $screenSize, offset: $offset)';
  }
}

/// 延时渲染一个 Widget
class _DelayRenderedWidget extends StatefulWidget {
  /// Sub-elements that need to fade in and out
  final Widget child;

  /// [child] Whether to continue rendering, that is, the animation will only be once
  final bool childPersist;

  /// Animation duration
  final Duration duration;

  /// [child] need to be removed (hidden)
  final bool removed;

  const _DelayRenderedWidget({
    Key? key,
    this.removed = false,
    this.duration = const Duration(milliseconds: 200),
    required this.child,
    this.childPersist = false,
  }) : super(key: key);

  @override
  _DelayRenderedWidgetState createState() => _DelayRenderedWidgetState();
}

class _DelayRenderedWidgetState extends State<_DelayRenderedWidget> {
  double opacity = 0;
  late Widget child;
  late Timer timer;

  /// Time interval between animations
  final Duration durationInterval = const Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    child = widget.child;
    timer = Timer(durationInterval, () {
      if (mounted) {
        setState(() {
          opacity = 1;
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(_DelayRenderedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    var duration = widget.duration;
    if (widget.removed) {
      setState(() {
        opacity = 0;
      });
      return;
    }
    if (!identical(oldWidget.child, widget.child)) {
      if (widget.childPersist) {
        setState(() {
          child = widget.child;
        });
      } else {
        setState(() {
          opacity = 0;
        });
        Timer(
          Duration(
            milliseconds:
                duration.inMilliseconds + durationInterval.inMilliseconds,
          ),
          () {
            setState(() {
              child = widget.child;
              opacity = 1;
            });
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: widget.duration,
      child: child,
    );
  }
}

/// 引导组件所处的方位
enum GuideDirection { left, right, topLeft, bottomLeft, topRight, bottomRight }

/// 单步引导组件
class StepWidgetBuilder {
  static Map _smartGetPosition(
      {required Size size,
      required Size screenSize,
      required Offset offset,
      required GuideMode introMode}) {
    double height = size.height;
    double width = size.width;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    double bottomArea = screenHeight - offset.dy - height;
    double topArea = screenHeight - height - bottomArea;
    double rightArea = screenWidth - offset.dx - width;
    double leftArea = screenWidth - width - rightArea;
    Map position = {};
    position['crossAxisAlignment'] = CrossAxisAlignment.start;
    bool alignTop = true;
    if (introMode == GuideMode.force) {
      // 强引导模式的计算规则
      // 根据上下剩余空间 先判断整个引导组件位于上还是下
      // 然后根据左右剩余空间，判断组件位于左还是右
      // 如果左边的剩余控件特别大，那么引导组件摆在目标的左侧比较合适，同理右边也一样
      if (topArea > bottomArea) {
        position['bottom'] = bottomArea + height + 4;
      } else {
        position['top'] = offset.dy + height + 4;
        alignTop = false;
      }
      if (leftArea > rightArea) {
        position['right'] = rightArea <= 0 ? 16.0 : rightArea;
        position['crossAxisAlignment'] = CrossAxisAlignment.end;
        position['width'] = min(leftArea + width - 16, screenWidth * 0.618);
        if (alignTop) {
          position['direction'] = GuideDirection.topLeft;
        } else {
          position['direction'] = GuideDirection.bottomLeft;
        }
      } else {
        position['left'] = offset.dx <= 0 ? 16.0 : offset.dx;
        position['width'] = min(rightArea + width - 16, screenWidth * 0.618);
        if (alignTop) {
          position['direction'] = GuideDirection.topRight;
        } else {
          position['direction'] = GuideDirection.bottomRight;
        }
      }

      // The distance on the right side is very large, it is more beautiful on the right side
      if (rightArea > 0.8 * topArea && rightArea > 0.8 * bottomArea) {
        position['left'] = offset.dx + width + 4;
        position['top'] = offset.dy;
        position['bottom'] = null;
        position['right'] = null;
        position['width'] = min<double>(position['width'], rightArea * 0.8);
        position['direction'] = GuideDirection.right;
      }

      // The distance on the left is large, it is more beautiful on the left side
      if (leftArea > 0.8 * topArea && leftArea > 0.8 * bottomArea) {
        position['right'] = rightArea + width + 4;
        position['top'] = offset.dy;
        position['bottom'] = null;
        position['left'] = null;
        position['crossAxisAlignment'] = CrossAxisAlignment.end;
        position['width'] = min<double>(position['width'], leftArea * 0.8);
        position['direction'] = GuideDirection.left;
      }
    }
    if (introMode == GuideMode.soft) {
      // 弱引导模式的计算规则
      // 根据上下剩余空间 先判断整个引导组件位于上还是下
      // 然后根据左右剩余空间，判断组件位于左还是右
      // 如果位置刚好居于中间，则采用强引导的对齐模式，改变小箭头的位置

      if (topArea > bottomArea) {
        position['bottom'] = bottomArea + height / 2 + 16;
      } else {
        position['top'] = offset.dy + height / 2 + 16;
        alignTop = false;
      }
      if (leftArea > rightArea) {
        position['right'] =
            rightArea + width / 2 - 20 <= 0 ? 16.0 : rightArea + width / 2 - 20;
        position['crossAxisAlignment'] = CrossAxisAlignment.end;
        position['width'] = min(leftArea + width - 16, screenWidth * 0.618);

        if (alignTop) {
          position['direction'] = GuideDirection.topLeft;
        } else {
          position['direction'] = GuideDirection.bottomLeft;
        }
      } else {
        position['left'] = offset.dx + width / 2 - 20 <= 0
            ? 16.0
            : offset.dx + size.width / 2 - 20;
        position['width'] = min(rightArea + width - 16, screenWidth * 0.618);

        if (alignTop) {
          position['direction'] = GuideDirection.topRight;
        } else {
          position['direction'] = GuideDirection.bottomRight;
        }
      }

      if (offset.dx + size.width / 2 > screenWidth * 1 / 3 &&
          offset.dx + size.width / 2 < screenWidth * 2 / 3) {
        //标记点位于中间的情况，保持某边对齐
        if (leftArea > rightArea) {
          position['right'] = rightArea;
          position['crossAxisAlignment'] = CrossAxisAlignment.end;
          position['width'] = min(leftArea + width - 16, screenWidth * 0.618);

          position['arrowPadding'] = size.width / 2 - 8;

          if (alignTop) {
            position['direction'] = GuideDirection.topLeft;
          } else {
            position['direction'] = GuideDirection.bottomLeft;
          }
        } else {
          position['left'] = leftArea;
          position['width'] = min(rightArea + width - 16, screenWidth * 0.618);
          position['arrowPadding'] = size.width / 2 - 8;

          if (alignTop) {
            position['direction'] = GuideDirection.topRight;
          } else {
            position['direction'] = GuideDirection.bottomRight;
          }
        }
      }

      /// The distance on the right side is very large, it is more beautiful on the right side
      if (rightArea > 0.8 * topArea && rightArea > 0.8 * bottomArea) {
        position['left'] = offset.dx + width / 2 + 16;
        position['top'] = offset.dy + size.height / 2 - 20;
        position['bottom'] = null;
        position['right'] = null;
        position['width'] = min<double>(position['width'], rightArea * 0.8);
        position['direction'] = GuideDirection.right;
      }

      /// The distance on the left is large, it is more beautiful on the left side
      if (leftArea > 0.8 * topArea && leftArea > 0.8 * bottomArea) {
        position['right'] = rightArea + width / 2 + 16;
        position['top'] = offset.dy + size.height / 2 - 20;
        position['bottom'] = null;
        position['left'] = null;
        position['crossAxisAlignment'] = CrossAxisAlignment.end;
        position['width'] = min<double>(position['width'], leftArea * 0.8);
        position['direction'] = GuideDirection.left;
      }
    }
    return position;
  }

  //默认的主题模式
  //其中tipInfo为每次引导的内容
  //buttonTextBuilder为底部提示下一步的文案
  //showStepLabel表示是否展示下一步的按钮
  //showSkipLabel表示是否展示跳过按钮
  //showClose表示是否展示关闭按钮
  static Widget Function(StepWidgetParams params) useDefaultTheme(
      {required List<GuideTipInfoBean> tipInfo,
      String Function(int currentStepIndex, int stepCount)? buttonTextBuilder,
      bool showStepLabel = true,
      bool showSkipLabel = true,
      bool showClose = true}) {
    return (StepWidgetParams stepWidgetParams) {
      int currentStepIndex = stepWidgetParams.currentStepIndex;
      int stepCount = stepWidgetParams.stepCount;
      Offset offset = stepWidgetParams.offset;
      Size size = stepWidgetParams.size;
      Map position = _smartGetPosition(
          screenSize: stepWidgetParams.screenSize,
          size: size,
          offset: offset,
          introMode: stepWidgetParams.introMode);
      return Stack(
        children: [
          Positioned(
            left: position['left'],
            top: position['top'],
            bottom: position['bottom'],
            right: position['right'],
            child: SizedBox(
                width: position['direction'] == GuideDirection.left ||
                        position['direction'] == GuideDirection.right
                    ? position['width'] + 8
                    : position['width'],
                child: BrnTipInfoWidget(
                  width: position['width'],
                  height: null,
                  info: tipInfo[currentStepIndex],
                  onNext: showStepLabel ? stepWidgetParams.onNext : null,
                  onSkip: showSkipLabel ? stepWidgetParams.onFinish : null,
                  onClose: showClose ? stepWidgetParams.onFinish : null,
                  currentStepIndex: currentStepIndex,
                  stepCount: stepCount,
                  direction: position['direction'],
                  mode: stepWidgetParams.introMode,
                  arrowPadding: position['arrowPadding'],
                  nextTip: buttonTextBuilder != null
                      ? buttonTextBuilder(currentStepIndex, stepCount)
                      : null,
                )),
          ),
          Positioned(
            left: offset.dx + size.width / 2 - 10,
            top: offset.dy + size.height / 2 - 10,
            child: stepWidgetParams.introMode == GuideMode.soft
                ? const PulseWidget(
                    width: 20,
                    height: 20,
                  )
                : const Row(),
          ),
        ],
      );
    };
  }
}

/// 默认的引导组件包含，强和弱两种交互模式
class BrnTipInfoWidget extends StatelessWidget {
  /// 引导组件的方向
  final GuideDirection direction;

  /// 关闭按钮的回调
  final void Function()? onClose;

  /// 下一步按钮的回调
  final void Function()? onNext;

  /// 跳过按钮的回调
  final void Function()? onSkip;

  /// 引导组件的宽度
  final double width;

  /// 引导组件的高度
  final double? height;

  /// 引导组件的内容
  final GuideTipInfoBean info;

  /// 引导模式
  final GuideMode mode;

  /// 当前的引导步数
  final int currentStepIndex;

  /// 引导步数
  final int stepCount;

  /// 箭头距离指示的边距
  final double? arrowPadding;

  /// 【下一步】的文案
  final String? nextTip;

  const BrnTipInfoWidget(
      {Key? key,
      this.onClose,
      this.onNext,
      this.onSkip,
      required this.width,
      this.height,
      this.currentStepIndex = 0,
      required this.stepCount,
      required this.info,
      this.mode = GuideMode.force,
      required this.direction,
      this.arrowPadding,
      this.nextTip})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor =
        mode == GuideMode.force ? Colors.transparent : const Color(0xFFCCCCCC);
    if (direction == GuideDirection.bottomLeft ||
        direction == GuideDirection.bottomRight) {
      return Column(
        verticalDirection: VerticalDirection.up,
        children: <Widget>[
          _buildContent(context),
          Container(
            alignment: direction == GuideDirection.bottomLeft
                ? Alignment.bottomRight
                : Alignment.bottomLeft,
            padding: direction == GuideDirection.bottomLeft
                ? EdgeInsets.only(right: arrowPadding ?? 12)
                : EdgeInsets.only(left: arrowPadding ?? 12),
            child: CustomPaint(
              size: const Size(14.0, 6.0),
              painter: CustomTrianglePainter(
                direction: Direction.top,
                borderColor: borderColor,
              ),
            ),
          ),
        ],
      );
    }
    if (direction == GuideDirection.topLeft ||
        direction == GuideDirection.topRight) {
      return Column(
        children: <Widget>[
          _buildContent(context),
          Container(
            alignment: direction == GuideDirection.topLeft
                ? Alignment.topRight
                : Alignment.topLeft,
            padding: direction == GuideDirection.topLeft
                ? EdgeInsets.only(right: arrowPadding ?? 12)
                : EdgeInsets.only(left: arrowPadding ?? 12),
            child: CustomPaint(
              size: const Size(14.0, 6.0),
              painter: CustomTrianglePainter(
                  borderColor: borderColor, direction: Direction.bottom),
            ),
          ),
        ],
      );
    }
    if (direction == GuideDirection.left) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildContent(context),
          Container(
            alignment: Alignment.topLeft,
            padding: const EdgeInsets.only(top: 12),
            child: CustomPaint(
              size: const Size(6.0, 14.0),
              painter: CustomTrianglePainter(
                  borderColor: borderColor, direction: Direction.right),
            ),
          ),
        ],
      );
    }
    if (direction == GuideDirection.right) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        textDirection: TextDirection.rtl,
        verticalDirection: VerticalDirection.up,
        children: <Widget>[
          _buildContent(context),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(top: 12),
            child: CustomPaint(
              size: const Size(6, 14.0),
              painter: CustomTrianglePainter(
                direction: Direction.left,
                borderColor: borderColor,
              ),
            ),
          ),
        ],
      );
    }
    return const Row();
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
              blurRadius: 5.0, //阴影模糊程度
              offset: Offset(0, 2),
              color: Color(0x15000000))
        ],
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        border: mode == GuideMode.force
            ? null
            : Border.all(color: const Color(0xFFCCCCCC), width: 0.5),
      ),
      width: width,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          buildImage(),
          buildTitle(),
          buildMessage(),
          mode == GuideMode.force
              ? _buildForceBottom(context)
              : _buildSoftBottom(context)
        ],
      ),
    );
  }

  Widget buildImage() {
    if (info.imgUrl.isEmpty) return const Row();
    double imageSize = width - 16;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Image.network(info.imgUrl,
          width: imageSize, height: imageSize, fit: BoxFit.cover),
    );
  }

  Widget buildTitle() {
    return Container(
      height: 18,
      margin: const EdgeInsets.only(top: 14),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: Text(
              info.title,
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0XFF222222),
                  fontWeight: FontWeight.w600),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: onClose == null
                ? const Row()
                : GestureDetector(
                    onTap: () {
                      onClose!();
                    },
                    child: const Icon(Icons.close),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildMessage() {
    if (info.message.isEmpty) return const Row();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(info.message,
          style: const TextStyle(
              fontSize: 14, color: Color(0xFF999999), height: 1.3),
          maxLines: 3),
    );
  }

  Widget _buildSoftBottom(BuildContext context) {
    if (onNext == null && onSkip == null) return const Row();
    return Container(
      height: 32,
      margin: const EdgeInsets.only(top: 12),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: onSkip != null && currentStepIndex + 1 != stepCount
                ? GestureDetector(
                    onTap: () {},
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          onSkip!();
                        },
                        child: Text(
                          '${'skip'} (${currentStepIndex + 1}/$stepCount)',
                          style: const TextStyle(
                              color: Color(0xFF999999), fontSize: 14),
                        ),
                      ),
                    ))
                : const Row(),
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: onNext != null
                ? GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.only(left: 14, right: 14),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          onNext!();
                        },
                        child: Text(
                          nextTip ??
                              (stepCount == currentStepIndex + 1
                                  ? 'known'
                                  : 'next'),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  )
                : const Row(),
          )
        ],
      ),
    );
  }

  Widget _buildForceBottom(BuildContext context) {
    if (onNext == null && onSkip == null) return const Row();
    return Container(
      height: 20,
      margin: const EdgeInsets.only(top: 12),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            child: onSkip != null && currentStepIndex + 1 != stepCount
                ? GestureDetector(
                    onTap: () {},
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          onSkip!();
                        },
                        child: Text(
                          '${'skip'} (${currentStepIndex + 1}/$stepCount)',
                          style: const TextStyle(
                              color: Color(0xFF999999), fontSize: 14),
                        ),
                      ),
                    ))
                : const Row(),
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: onNext != null
                ? GestureDetector(
                    onTap: () {},
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          onNext!();
                        },
                        child: Text(
                          nextTip ??
                              (stepCount == currentStepIndex + 1
                                  ? 'known'
                                  : 'next'),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                : const Row(),
          )
        ],
      ),
    );
  }
}

enum Direction {
  /// 文字在左边
  left,

  /// 文字在右边
  right,

  /// 文字在上边
  top,

  /// 文字在下边
  bottom,
}

///
/// 绘制箭头
///
class CustomTrianglePainter extends CustomPainter {
  Color color;
  Color borderColor;
  Direction direction;

  CustomTrianglePainter(
      {this.color = Colors.white,
      this.borderColor = const Color(0XFFCCCCCC),
      required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    Paint paint = Paint();
    paint.strokeWidth = 2.0;
    paint.color = color;
    paint.style = PaintingStyle.fill;
    Paint paintBorder = Paint();
    Path pathBorder = Path();
    paintBorder.strokeWidth = 0.5;
    paintBorder.color = borderColor;
    paintBorder.style = PaintingStyle.stroke;

    switch (direction) {
      case Direction.left:
        path.moveTo(size.width + 1, -1.3);
        path.lineTo(0, size.height / 2);
        path.lineTo(size.width + 1, size.height + 0.5);
        pathBorder.moveTo(size.width, -0.5);
        pathBorder.lineTo(0, size.height / 2 - 0.5);
        pathBorder.lineTo(size.width, size.height);
        break;
      case Direction.right:
        path.moveTo(-1, -1.3);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(-1, size.height + 0.5);
        pathBorder.moveTo(-0, -0.5);
        pathBorder.lineTo(size.width, size.height / 2);
        pathBorder.lineTo(-0, size.height);
        break;
      case Direction.top:
        path.moveTo(0.0, size.height + 1.5);
        path.lineTo(size.width / 2.0, 0.0);
        path.lineTo(size.width, size.height + 1.5);
        pathBorder.moveTo(0.5, size.height + 0.5);
        pathBorder.lineTo(size.width / 2.0, 0);
        pathBorder.lineTo(size.width - 0.5, size.height + 0.5);
        break;
      case Direction.bottom:
        path.moveTo(0.0, -1.5);
        path.lineTo(size.width / 2.0, size.height);
        path.lineTo(size.width, -1.5);
        pathBorder.moveTo(0.0, -0.5);
        pathBorder.lineTo(size.width / 2.0, size.height);
        pathBorder.lineTo(size.width, -0.5);
        break;
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(pathBorder, paintBorder);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

/// 脉冲组件, 样式为循环扩大的小圆点
class PulseWidget extends StatefulWidget {
  final double width;
  final double height;

  const PulseWidget({Key? key, required this.width, required this.height})
      : super(key: key);

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _alphaAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      upperBound: 1,
      lowerBound: 0,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      upperBound: 1,
      lowerBound: 0,
      vsync: this,
    );
    _alphaAnimation = Tween(begin: 0.0, end: 2.0).animate(_fadeController);
    _scaleController.repeat();
    _fadeController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _alphaAnimation,
              child: ScaleTransition(
                scale: _scaleController,
                child: CustomPaint(
                  painter: CirclePainter(Colors.blue),
                  size: Size(widget.width, widget.height),
                ),
              ),
            ),
          ),
          Positioned(
            top: widget.width / 4,
            left: widget.width / 4,
            bottom: widget.width / 4,
            right: widget.width / 4,
            child: CustomPaint(
              painter: CirclePainter(Colors.red),
              size: Size(widget.width / 2, widget.height / 2),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  final Color color;

  CirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
