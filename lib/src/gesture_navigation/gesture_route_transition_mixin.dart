import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import '../gesture_handler.dart';
import 'gesture_route_delegate.dart';

mixin GestureRouteTransitionMixin<T> on ModalRoute<T> {
  GestureRouteDelegate get gestureDelegate;

  HitTestBehavior? get gestureBehavior => null;

  GestureHandler get gestureHandler => gestureDelegate.gestureHandler;

  GestureHandler? get barrierGestureHandler =>
      gestureDelegate.barrierGestureHandler;

  @override
  AnimationController createAnimationController() =>
      gestureDelegate.createAnimationController();

  @override
  void install() {
    gestureDelegate.initRoute(this);
    super.install();
  }

  @override
  bool didPop(T? result) {
    gestureDelegate.didPop(result);
    return super.didPop(result);
  }

  @override
  void dispose() {
    gestureDelegate.disposeRoute();
    super.dispose();
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final transitionChild =
        buildPageTransitions(context, animation, secondaryAnimation, child);
    return buildGestureListener(
        context, animation, secondaryAnimation, transitionChild);
  }

  Widget buildGestureListener(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return GestureListener(
      handler: gestureDelegate.gestureHandler,
      behavior: gestureBehavior,
      excludeFromSemantics: true,
      child: child,
    );
  }

  Widget buildPageTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child);

  @override
  void changedInternalState() {
    super.changedInternalState();
    _modalBarrier?.markNeedsBuild();
  }

  @override
  void changedExternalState() {
    super.changedExternalState();
    _modalBarrier?.markNeedsBuild();
  }

  // override ModalRoute behavior
  late OverlayEntry? _modalBarrier;

  Widget buildGestureModalBarrier(BuildContext context) {
    final gestureHandler = barrierGestureHandler;
    Widget barrier = buildModalBarrier();
    if (gestureHandler != null) {
      barrier = Stack(
        children: [
          barrier,
          GestureListener(
            handler: gestureHandler,
            behavior: HitTestBehavior.opaque,
            excludeFromSemantics: true,
            child: Container(),
          ),
        ],
      );
    }
    return barrier;
  }

  // Widget buildModalBarrier(BuildContext context, bool barrierDismissible) {
  //   Widget barrier;
  //   if (barrierColor != null && barrierColor!.alpha != 0 && !offstage) {
  //     // changedInternalState is called if barrierColor or offstage updates
  //     assert(barrierColor != barrierColor!.withOpacity(0.0));
  //     final Animation<Color?> color = animation!.drive(
  //       ColorTween(
  //         begin: barrierColor!.withOpacity(0.0),
  //         end: barrierColor, // changedInternalState is called if barrierColor updates
  //       ).chain(CurveTween(curve: barrierCurve)), // changedInternalState is called if barrierCurve updates
  //     );
  //     barrier = AnimatedModalBarrier(
  //       color: color,
  //       dismissible: barrierDismissible, // changedInternalState is called if barrierDismissible updates
  //       semanticsLabel: barrierLabel, // changedInternalState is called if barrierLabel updates
  //       barrierSemanticsDismissible: semanticsDismissible,
  //     );
  //   } else {
  //     barrier = ModalBarrier(
  //       dismissible: barrierDismissible, // changedInternalState is called if barrierDismissible updates
  //       semanticsLabel: barrierLabel, // changedInternalState is called if barrierLabel updates
  //       barrierSemanticsDismissible: semanticsDismissible,
  //     );
  //   }
  //   if (filter != null) {
  //     barrier = BackdropFilter(
  //       filter: filter!,
  //       child: barrier,
  //     );
  //   }
  //   barrier = IgnorePointer(
  //     ignoring: animation!.status ==
  //             AnimationStatus.reverse || // changedInternalState is called when animation.status updates
  //         animation!.status == AnimationStatus.dismissed, // dismissed is possible when doing a manual pop gesture
  //     child: barrier,
  //   );
  //   if (semanticsDismissible && this.barrierDismissible) {
  //     // To be sorted after the _modalScope.
  //     barrier = Semantics(
  //       sortKey: const OrdinalSortKey(1.0),
  //       child: barrier,
  //     );
  //   }
  //   return barrier;
  // }

  @override
  Iterable<OverlayEntry> createOverlayEntries() {
    final modalOverlays =
        List<OverlayEntry>.from(super.createOverlayEntries(), growable: false);
    if (barrierGestureHandler != null) {
      _modalBarrier =
          OverlayEntry(builder: (context) => buildGestureModalBarrier(context));
      modalOverlays[0] = _modalBarrier!;
    }
    return modalOverlays;
  }
}
