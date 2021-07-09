import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../gesture_handler.dart';
import '../gesture_handlers/any_tap_handler.dart';
import '../gesture_handlers/swipe_handler.dart';
import 'gesture_route_delegate.dart';
import 'gesture_route_transition_mixin.dart';
import 'navigator_gesture_recognizer.dart';

typedef ShowGestureRouteDelegate<T> = Future<T?> Function(GestureRouteDelegate<T> gestureDelegate);

class SwipeRouteHandler<T> extends SwipeHandler
    with
        AnimationGestureMixin,
        AnimationControllerGestureMixin,
        AnimationSwipeHandlerMixin,
        AnimationControllerSwipeHandlerMixin,
        GestureRouteDelegate<T> {
  SwipeRouteHandler({
    required this.controllerFactory,
    required this.openRouteDelegate,
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
  RecognizerFactories recognizerFactories() {
    // TODO: calls on each route. move to internal handler ?
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
  GestureHandler get gestureHandler => this;

  GestureHandler? _anyTapHandler;

  @override
  GestureHandler? get barrierGestureHandler {
    if (!hasRoute || !route!.barrierDismissible) return this;
    _anyTapHandler ??= AnyTapHandlerDelegate(onAnyTapUp: onDismiss);
    return GestureHandlerComposer(handlers: [this, _anyTapHandler!]);
  }

  @override
  bool get userGestureInProgress => hasRoute && super.userGestureInProgress;

  @override
  bool get userGestureEnabled => !isDeactivated && (!hasRoute || (route!.isActive && super.userGestureEnabled));

  final ValueGetter<AnimationController> controllerFactory;

  @override
  AnimationController get controller => _controller!;
  AnimationController? _controller;

  bool get _hasController => _controller != null;

  @override
  double get value => _controller?.value ?? 0.0;
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

  @override
  bool canAnimate(DragUpdateDetails e) {
    if (!userGestureEnabled) return false;
    final delta = e.primaryDelta! * (reverse ? -1.0 : 1.0);
    if (!_hasController) return delta > 0;
    return super.canAnimate(e);
  }

  final ValueGetter<ShowGestureRouteDelegate<T>> openRouteDelegate;

  @override
  Future<T?> showRoute() {
    final future = openRouteDelegate()(this);
    assert(hasRoute);
    return future;
  }

  @override
  void closeRoute([T? result]) {
    if (!hasRoute || !route!.isActive) return;
    super.closeRoute(result);
  }

  @override
  void onDragUpdate(DragUpdateDetails e) {
    if (!hasRoute) {
      if (!userGestureEnabled) return;
      if (!canAnimate(e)) return;
      showRoute();
      if (!userGestureInProgress) startUserGesture();
    } else {
      if (!userGestureInProgress) {
        if (!userGestureEnabled) return;
        startUserGesture();
      }
      super.onDragUpdate(e);
    }
  }

  @override
  void onDragEnd(DragEndDetails e) {
    if (!userGestureInProgress) return;
    super.onDragEnd(e);
    if (userGestureInProgress) stopUserGesture();
    checkControllerStatusAndPopIfNeeded(_controller?.status);
  }

  @override
  void onDragCancel() {
    if (!userGestureInProgress) return;
    super.onDragCancel();
    if (userGestureInProgress) stopUserGesture();
  }

  void onDismiss() {
    if (!hasRoute || !userGestureEnabled) return;
    startUserGesture();
    reverseProgress();
    stopUserGesture();
  }

  @override
  AnimationController createAnimationController() {
    assert(_controller == null);
    _controller = controllerFactory();
    _controller!.addStatusListener(checkControllerStatusAndPopIfNeeded);
    return _controller!;
  }

  void checkControllerStatusAndPopIfNeeded(AnimationStatus? status) {
    if (status == AnimationStatus.dismissed) {
      if ((route?.isActive ?? false) && userGestureInProgress) return;
      if (userGestureInProgress) stopUserGesture();
      controller.removeStatusListener(checkControllerStatusAndPopIfNeeded);
      // preventing [TransitionRoute._handleStatusChanged] finalizeRoute conflict.
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        closeRoute();
      });
    }
  }

  @override
  void disposeRoute() {
    _controller = null;
    super.disposeRoute();
  }

  @override
  void dispose() {
    _anyTapHandler?.dispose();
    super.dispose();
  }
}
