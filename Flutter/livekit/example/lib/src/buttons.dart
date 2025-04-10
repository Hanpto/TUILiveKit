
import 'package:flutter/material.dart';
import 'package:tencent_live_uikit_example/src/screens.dart';

import 'loading_spinner.dart';

final List<String> imgList = [
  'https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover1.png',
];

// 全局 ValueNotifier 来控制悬浮按钮的可见性
// 使用Overlay和ValueNotifier实现全局可控悬浮按钮
final floatingButtonVisibility = ValueNotifier<bool>(false);

class FloatButtonOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? restoreCallback;
  final VoidCallback? exitCallback;

  const FloatButtonOverlay(
      {super.key,
      required this.child,
      this.restoreCallback,
      this.exitCallback});

  @override
  State<FloatButtonOverlay> createState() => _FloatButtonOverlayState();
}

class _FloatButtonOverlayState extends State<FloatButtonOverlay> {
  // 悬浮按钮的OverlayEntry
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // 延迟加载按钮位置并插入Overlay，确保在页面完全构建后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insertOverlay();
      // 监听ValueNotifier的变化，更新Overlay
      floatingButtonVisibility.addListener(_updateOverlay);
    });
  }

  @override
  void dispose() {
    // 移除监听器
    floatingButtonVisibility.removeListener(_updateOverlay);
    // 确保在widget销毁时移除overlay
    _removeOverlay();
    super.dispose();
  }

  // 插入悬浮按钮到Overlay
  void _insertOverlay() {
    _removeOverlay(); // 先移除已存在的overlay

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildFloatingButton(context),
    );

    final overlay = Overlay.of(context);
    overlay.insert(_overlayEntry!);
  }

  // 移除Overlay中的悬浮按钮
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // 更新悬浮按钮的位置和显示状态
  void _updateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
    }
  }

  // 构建悬浮按钮
  Widget _buildFloatingButton(BuildContext context) {
    // 使用ValueListenableBuilder监听可见性变化
    return ValueListenableBuilder<bool>(
      valueListenable: floatingButtonVisibility,
      builder: (context, isVisible, child) {
        // 当不可见时，返回空容器
        if (!isVisible) {
          return const SizedBox.shrink();
        }
        // 可见时显示悬浮按钮
        return FloatingDraggableWidget(
          size: 110.0,
          child: InkWell(
            onTap: () => widget.restoreCallback?.call(),
            child: Row(
              children: [
                LoadingSpinner(
                  child: CircleAvatar(
                      radius: 30,
                      backgroundImage: Image.network(imgList[0]).image),
                ),
                IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => widget.exitCallback?.call())
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class FloatingDraggableWidget extends StatefulWidget {
  final Widget child;
  final double size;

  const FloatingDraggableWidget({
    super.key,
    required this.child,
    this.size = 60.0,
  });

  @override
  State<FloatingDraggableWidget> createState() =>
      _FloatingDraggableWidgetState();
}

class _FloatingDraggableWidgetState extends State<FloatingDraggableWidget> {
  Offset _position = Offset(Screens.width - 100, Screens.height - 300);
  late double _screenWidth;
  late double _screenHeight;
  late double _safeAreaTop;
  late double _bottomNavBarHeight;

  @override
  Widget build(BuildContext context) {
    // 获取屏幕尺寸
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    _safeAreaTop = MediaQuery.of(context).padding.top;

    // 获取BottomNavigationBar高度 (通常是56dp + 底部安全区域)
    _bottomNavBarHeight =
        kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (details) {
          // 可以添加拖动开始的效果
        },
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(
              _position.dx + details.delta.dx,
              _position.dy + details.delta.dy,
            );
          });
        },
        onPanEnd: (details) {
          _snapToEdge();
        },
        child: Container(
          width: widget.size,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }

  void _snapToEdge2() {
    double newX = _position.dx;
    double newY = _position.dy;

    // 考虑底部导航栏的高度，确保不超出可见区域
    final double effectiveBottomEdge = _screenHeight - _bottomNavBarHeight;

    // 确保不超出屏幕边界
    newX = newX.clamp(0, _screenWidth - widget.size);
    newY = newY.clamp(_safeAreaTop, effectiveBottomEdge - widget.size);

    // 计算到四边的距离
    final double distToLeft = newX;
    final double distToRight = _screenWidth - newX - widget.size;
    final double distToTop = newY - _safeAreaTop;
    final double distToBottom = effectiveBottomEdge - newY - widget.size;

    // 找出最小距离
    final double minDist = [
      distToLeft,
      distToRight,
      distToTop,
      distToBottom,
    ].reduce((curr, next) => curr < next ? curr : next);

    // 根据最小距离贴附到相应的边
    if (minDist == distToLeft) {
      // 贴附左边
      newX = 0;
    } else if (minDist == distToRight) {
      // 贴附右边
      newX = _screenWidth - widget.size;
    } else if (minDist == distToTop) {
      // 贴附顶部
      newY = _safeAreaTop;
    } else {
      // 贴附底部，但在BottomNavigationBar上方
      newY = effectiveBottomEdge - widget.size;
    }

    // 使用动画平滑过渡到贴附位置
    setState(() {
      _position = Offset(newX, newY);
    });
  }

  void _snapToEdge() {
    double newX = _position.dx;
    double newY = _position.dy;

    // 考虑底部导航栏的高度，确保不超出可见区域
    final double effectiveBottomEdge = _screenHeight - _bottomNavBarHeight;

    // 确保不超出屏幕边界
    newX = newX.clamp(0, _screenWidth - widget.size);
    newY = newY.clamp(_safeAreaTop, effectiveBottomEdge - widget.size);

    // 计算到四边的距离
    final double distToLeft = newX;
    final double distToRight = _screenWidth - newX - widget.size;

    // 找出最小距离
    final double minDist = [
      distToLeft,
      distToRight,
    ].reduce((curr, next) => curr < next ? curr : next);

    // 根据最小距离贴附到相应的边
    if (minDist == distToLeft) {
      // 贴附左边
      newX = 0;
    } else {
      // 贴附右边
      newX = _screenWidth - widget.size;
    }

    // 使用动画平滑过渡到贴附位置
    setState(() {
      _position = Offset(newX, newY);
    });
  }
}
