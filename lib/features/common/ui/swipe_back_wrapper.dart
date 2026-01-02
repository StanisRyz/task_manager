import 'package:flutter/material.dart';

class SwipeBackWrapper extends StatefulWidget {
  const SwipeBackWrapper({
    super.key,
    required this.child,
    this.edgeWidth = 24,
    this.dragThreshold = 80,
    this.velocityThreshold = 800,
  });

  final Widget child;
  final double edgeWidth;
  final double dragThreshold;
  final double velocityThreshold;

  @override
  State<SwipeBackWrapper> createState() => _SwipeBackWrapperState();
}

class _SwipeBackWrapperState extends State<SwipeBackWrapper> {
  double _dragDistance = 0;
  bool _canDrag = false;

  void _handleDragStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? MediaQuery.of(context).size.width;
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    final startOffset = isLtr
        ? details.localPosition.dx
        : width - details.localPosition.dx;

    _canDrag = startOffset <= widget.edgeWidth;
    _dragDistance = 0;
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_canDrag) {
      return;
    }
    final delta = details.primaryDelta ?? 0;
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    final signedDelta = isLtr ? delta : -delta;
    if (signedDelta <= 0) {
      return;
    }
    _dragDistance += signedDelta;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_canDrag) {
      return;
    }
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    final velocity = details.primaryVelocity ?? 0;
    final signedVelocity = isLtr ? velocity : -velocity;
    final shouldPop = _dragDistance >= widget.dragThreshold ||
        signedVelocity >= widget.velocityThreshold;
    _dragDistance = 0;
    _canDrag = false;

    if (shouldPop) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: widget.child,
    );
  }
}
