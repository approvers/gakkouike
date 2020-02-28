import 'dart:ui';

import 'package:flutter/material.dart';

class FloatButtonBackground extends StatelessWidget {
  final Color color;

  FloatButtonBackground({this.color});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
      child: Container(
        color: color,
      ),
    );
  }
}

class FoldAnimationWrap extends StatefulWidget {
  final Duration duration;
  final Curve animationCurve;
  final bool isExpanded;

  final Widget child;

  FoldAnimationWrap({
    @required this.duration,
    this.animationCurve = Curves.ease,
    @required this.isExpanded,
    this.child
  });

  @override
  State<StatefulWidget> createState() {
    return _FoldAnimationWrapState();
  }
}

class _FoldAnimationWrapState extends State<FoldAnimationWrap> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _expandAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
      reverseDuration: widget.duration
    );
    _expandAnimation = _controller.drive(
        CurveTween(curve: widget.animationCurve)
    );
    if(widget.isExpanded){
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(FoldAnimationWrap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.isExpanded != widget.isExpanded){
      if(widget.isExpanded){
        _controller.forward();
      }
      else {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context){
    return FadeTransition(
      opacity: _expandAnimation,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}

class FoldFloatButtonWrap extends StatelessWidget {
  final bool isExpanded;

  final Widget floatButton;

  final List<Widget> expandedWidget;
  final Duration foldAnimationDuration = Duration(milliseconds: 400);

  FoldFloatButtonWrap({
    @required this.isExpanded,
    @required this.floatButton,
    @required this.expandedWidget
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: <Widget>[
        // 背景
        isExpanded ?
        Positioned(
          top: -32,
          left: -32,
          right: -32,
          bottom: -32,
          child: FoldAnimationWrap(
            duration: foldAnimationDuration,
            isExpanded: isExpanded,
            child: FloatButtonBackground(
              color: Color.fromARGB(50, 0, 0, 0),
            ),
          ),
        ) : Container(),

        Positioned(
          bottom: -10,
          right: -10,
          child: Column(
            children: <Widget>[
              FoldAnimationWrap(
                isExpanded: isExpanded,
                duration: foldAnimationDuration,
                child: Card(
                  child: Padding(child:
                  Column(
                    children: expandedWidget,
                  ),
                  padding: EdgeInsets.all(5.0),
                  )
                ),
              ),
              floatButton
            ],
          ),
        )
      ],
    );
  }
}