import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../gesture_handler.dart';
import '../gesture_navigation/navigator_gesture_recognizer.dart';

enum DragDirection { horizontal, vertical, both }

abstract class DragHandler extends GestureHandler {
  final DragDirection direction;
  final DragStartBehavior dragStartBehavior;

  DragHandler({required this.direction, this.dragStartBehavior = DragStartBehavior.start});

  bool get handleHorizontal => direction != DragDirection.vertical;

  bool get handleVertical => direction != DragDirection.horizontal;

  @override
  RecognizerFactories recognizerFactories() {
    final recognizers = <Type, GestureRecognizerFactory>{};
    if (handleHorizontal) {
      recognizers[HorizontalDragGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
              () => HorizontalDragGestureRecognizer(debugOwner: this), initializeDragGestureRecognizer);
    }
    if (handleVertical) {
      recognizers[VerticalDragGestureRecognizer] = GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer(debugOwner: this), initializeDragGestureRecognizer);
    }
    return recognizers;
  }

  void initializeDragGestureRecognizer(DragGestureRecognizer instance);
}

class DragHandlerDelegate extends DragHandler {
  DragHandlerDelegate({
    required DragDirection direction,
    this.onDragDown,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.onDragCancel,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) : super(direction: direction, dragStartBehavior: dragStartBehavior);

  @override
  void initializeDragGestureRecognizer(DragGestureRecognizer instance) {
    instance
      ..onDown = onDragDown
      ..onStart = onDragStart
      ..onUpdate = onDragUpdate
      ..onEnd = onDragEnd
      ..onCancel = onDragCancel
      ..dragStartBehavior = dragStartBehavior;
  }

  final GestureDragDownCallback? onDragDown;
  final GestureDragStartCallback? onDragStart;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;
  final GestureDragCancelCallback? onDragCancel;
}

abstract class SwipeHandler extends DragHandler with DeactivatableGestureHandlerMixin {
  SwipeHandler({
    required DragDirection direction,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) : super(direction: direction, dragStartBehavior: dragStartBehavior);

  @override
  bool get isDeactivated => false;

  @override
  void initializeDragGestureRecognizer(DragGestureRecognizer instance) {
    instance
      ..onDown = ((e) => onlyIfActivated(onDragDown, [e]))
      ..onStart = ((e) => onlyIfActivated(onDragStart, [e]))
      ..onUpdate = ((e) => onlyIfActivated(onDragUpdate, [e]))
      ..onEnd = ((e) => onlyIfActivated(onDragEnd, [e]))
      ..onCancel = (() => onlyIfActivated(onDragCancel))
      ..dragStartBehavior = dragStartBehavior;
  }

  void onDragDown(DragDownDetails e) {}

  void onDragStart(DragStartDetails e) {}

  void onDragUpdate(DragUpdateDetails e) {}

  void onDragEnd(DragEndDetails e) {}

  void onDragCancel() {}
}

const kSwipeProgressThreshold = 0.5;
const kSwipeFlingVelocity = 700.0;

mixin AnimationSwipeHandlerMixin on SwipeHandler implements AnimationGestureMixin {
  double get minOpenFlingVelocity => kSwipeFlingVelocity;

  double get minCloseFlingVelocity => kSwipeFlingVelocity;

  double get openProgressThreshold => kSwipeProgressThreshold;

  double get closeProgressThreshold => kSwipeProgressThreshold;

  double get childSize;

  DragUpdateDetails? _lastUpdate;

  @override
  void onDragStart(DragStartDetails e) {
    _lastUpdate = null;
  }

  @override
  void onDragUpdate(DragUpdateDetails e) {
    _lastUpdate = e;
    final delta = e.primaryDelta! / childSize * (reverse ? -1.0 : 1.0);
    final newValue = (value + delta).clamp(lowerBound, upperBound);
    if (newValue == value) return;
    value = newValue;
  }

  @override
  void onDragEnd(DragEndDetails e) {
    final velocity = e.primaryVelocity! * (reverse ? -1.0 : 1.0);
    final minFlingVelocity = isForwardDirection(e, velocity) ? minOpenFlingVelocity : minCloseFlingVelocity;
    final progressThreshold = isForwardDirection(e, velocity) ? openProgressThreshold : closeProgressThreshold;
    if (velocity.abs() > minFlingVelocity) {
      if (!isAtMin && !isAtMax) flingVelocityAnimate(e, velocity);
    } else if (value < progressThreshold) {
      if (!isAtMin) reverseProgress();
    } else {
      if (!isAtMax) forwardProgress();
    }
  }

  bool isForwardDirection(DragEndDetails e, double velocity) {
    if (velocity != 0.0) return velocity > 0.0;
    if (_lastUpdate != null) return (_lastUpdate!.primaryDelta! * (reverse ? -1.0 : 1.0)) >= 0.0;
    return true;
  }

  void flingVelocityAnimate(DragEndDetails e, double velocity);

  @protected
  bool canAnimate(DragUpdateDetails e) {
    if (isDeactivated) return false;
    final delta = e.primaryDelta! * (reverse ? -1.0 : 1.0);
    return (delta > 0 && !isAtMax) || (delta < 0 && !isAtMin);
  }
}

mixin AnimationControllerSwipeHandlerMixin implements AnimationSwipeHandlerMixin, AnimationControllerGestureMixin {
  @override
  void flingVelocityAnimate(DragEndDetails e, double velocity) {
    final flingVelocity = velocity / childSize;
    controller.fling(velocity: flingVelocity);
  }

  @override
  void reverseProgress() => controller.reverse(); // or use controller.fling(velocity: -1.0); ?

  @override
  void forwardProgress() => controller.forward();
}

class AnimationControllerSwipeHandler extends SwipeHandler
    with
        AnimationGestureMixin,
        AnimationControllerGestureMixin,
        AnimationSwipeHandlerMixin,
        AnimationControllerSwipeHandlerMixin {
  AnimationControllerSwipeHandler({
    required this.controller,
    required this.getChildSize,
    this.openProgressThreshold = kSwipeProgressThreshold,
    this.closeProgressThreshold = kSwipeProgressThreshold,
    this.minOpenFlingVelocity = kSwipeFlingVelocity,
    this.minCloseFlingVelocity = kSwipeFlingVelocity,
    this.reverse = false,
    ValueGetter<bool>? isDeactivated,
    required DragDirection direction,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  })  : _isDeactivated = isDeactivated,
        super(direction: direction, dragStartBehavior: dragStartBehavior);

  @override
  final AnimationController controller;
  @override
  final double openProgressThreshold;
  @override
  final double closeProgressThreshold;
  @override
  final double minOpenFlingVelocity;
  @override
  final double minCloseFlingVelocity;
  @override
  final bool reverse;

  @override
  double get childSize => getChildSize();
  final ValueGetter<double> getChildSize;

  @override
  bool get isDeactivated => _isDeactivated?.call() ?? false;
  final ValueGetter<bool>? _isDeactivated;
}

class CascadeSwipeHandler extends SwipeHandler {
  final List<AnimationSwipeHandlerMixin> handlers;
  final bool reverse;

  CascadeSwipeHandler({
    required this.handlers,
    this.reverse = false,
    required DragDirection direction,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  })  : assert(handlers.every((i) => i.direction == direction)),
        super(direction: direction, dragStartBehavior: dragStartBehavior);

  @override
  RecognizerFactories recognizerFactories() {
    final recognizers = <Type, GestureRecognizerFactory>{};
    if (handleHorizontal) {
      recognizers[RouteHorizontalDragGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<RouteHorizontalDragGestureRecognizer>(
              () => RouteHorizontalDragGestureRecognizer(debugOwner: this), initializeDragGestureRecognizer);
    }
    if (handleVertical) {
      recognizers[RouteVerticalDragGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<RouteVerticalDragGestureRecognizer>(
              () => RouteVerticalDragGestureRecognizer(debugOwner: this), initializeDragGestureRecognizer);
    }
    return recognizers;
  }

  @override
  void dispose() {
    for (final i in handlers) {
      i.dispose();
    }
    super.dispose();
  }

  AnimationSwipeHandlerMixin? _activeHandler;

  @override
  void onDragDown(DragDownDetails e) => _activeHandler?.onDragDown(e);

  @override
  void onDragStart(DragStartDetails e) => _activeHandler?.onDragStart(e);

  @override
  void onDragUpdate(DragUpdateDetails e) {
    if (_activeHandler == null) _activeHandler = selectHandler(e);
    _activeHandler?.onDragUpdate(e);
  }

  @override
  void onDragEnd(DragEndDetails e) {
    _activeHandler?.onDragEnd(e);
    _activeHandler = null;
  }

  @override
  void onDragCancel() {
    _activeHandler?.onDragCancel();
    _activeHandler = null;
  }

  AnimationSwipeHandlerMixin? selectHandler(DragUpdateDetails e) {
    if (handlers.isEmpty) return null;

    final delta = e.primaryDelta! * (reverse ? -1.0 : 1.0);
    if (delta == 0) return null;
    final items = delta > 0 ? handlers : handlers.reversed;
    for (final i in items) {
      if (canAnimate(i, e)) return i;
    }
    return null;
  }

  @protected
  bool canAnimate(AnimationSwipeHandlerMixin handler, DragUpdateDetails e) => handler.canAnimate(e);
}
