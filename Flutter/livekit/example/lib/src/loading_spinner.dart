import 'package:flutter/material.dart';

class LoadingSpinner extends StatefulWidget {
  final Widget? child;
  final AnimationController? controller;  // 可选：允许外部控制动画
  const LoadingSpinner({
    super.key,
    this.child,
    this.controller,
  });

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = widget.controller ?? AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
    );

    _animationController.repeat(); // 开始无限循环动画
  }

  @override
  void dispose() {
    if (widget.controller == null) { // 如果是组件自己创建的controller才dispose
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: widget.child,
    );
  }
}
