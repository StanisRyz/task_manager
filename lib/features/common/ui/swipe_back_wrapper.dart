import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SwipeBackWrapper extends StatefulWidget {
  const SwipeBackWrapper({
    super.key,
    required this.child,
    this.dragThreshold = 80,
    this.velocityThreshold = 800,
  });

  final Widget child;
  final double dragThreshold;
  final double velocityThreshold;

  @override
  State<SwipeBackWrapper> createState() => _SwipeBackWrapperState();
}

class _SwipeBackWrapperState extends State<SwipeBackWrapper> {
  double _dragDistance = 0;
  bool _canDrag = false;

  bool _isInteractiveInput(Offset globalPosition) {
    final result = HitTestResult();
    final view = View.of(context);
    WidgetsBinding.instance.hitTestInView(result, globalPosition, view);
    for (final entry in result.path) {
      final target = entry.target;
      if (target is RenderEditable) {
        return true;
      }
      final debugCreator = (target as RenderObject).debugCreator;
      if (debugCreator is DebugCreator) {
        final widget = debugCreator.element.widget;
        if (widget is TextField ||
            widget is TextFormField ||
            widget is EditableText ||
            widget is Slider ||
            widget is RangeSlider ||
            widget is Switch ||
            widget is Checkbox ||
            widget is Radio) {
          return true;
        }
      }
    }
    return false;
  }

  void _handleDragStart(DragStartDetails details) {
    _canDrag = !_isInteractiveInput(details.globalPosition);
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
