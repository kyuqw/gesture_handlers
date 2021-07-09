import 'package:flutter/widgets.dart';

import '../gesture_handler.dart';
import 'gesture_route_transition_mixin.dart';

mixin GestureRouteDelegate<T> {
  GestureHandler get gestureHandler;

  GestureHandler? get barrierGestureHandler => gestureHandler;

  @protected
  GestureRouteTransitionMixin<T?>? route;

  bool get hasRoute => route != null;

  Future<T?> showRoute();

  void closeRoute([T? result]) {
    assert(hasRoute);
    assert(route!.isCurrent);
    route!.navigator!.pop(result);
  }

  AnimationController createAnimationController();

  @mustCallSuper
  void initRoute(GestureRouteTransitionMixin<T?> route) {
    assert(route.gestureDelegate == this);
    this.route = route;
  }

  @mustCallSuper
  void didPop(T? result) {
    if (userGestureInProgress) stopUserGesture();
  }

  @mustCallSuper
  void disposeRoute() {
    assert(!userGestureInProgress);
    route = null;
  }

  @mustCallSuper
  void startUserGesture() {
    assert(route != null);
    route!.navigator!.didStartUserGesture();
  }

  @mustCallSuper
  void stopUserGesture() {
    assert(route != null);
    route!.navigator!.didStopUserGesture();
  }

  /// True if an gesture is currently underway for [route].
  ///
  /// This just check the route's [NavigatorState.userGestureInProgress].
  ///
  /// See also:
  ///
  ///  * [userGestureEnabled], which returns true if a user-triggered gesture would be allowed.
  static bool isUserGestureInProgress(ModalRoute<dynamic> route) {
    return route.navigator!.userGestureInProgress;
  }

  bool get userGestureInProgress => isUserGestureInProgress(route!);

  /// Whether a gesture can be started by the user.
  ///
  /// Returns true if the user can swipe to a previous route.
  ///
  /// Returns false once [isUserGestureInProgress] is true, but
  /// [isUserGestureInProgress] can only become true if [userGestureEnabled] was
  /// true first.
  ///
  /// This should only be used between frames, not during build.
  bool get userGestureEnabled => _isUserGestureEnabled(route!);

  @protected
  bool _isUserGestureEnabled<R>(ModalRoute<R> route) {
    // If there's nothing to go back to, then obviously we don't support
    // the back gesture.
    if (route.isFirst) return false;
    // If the route wouldn't actually pop if we popped it, then the gesture
    // would be really confusing (or would skip internal routes), so disallow it.
    if (route.willHandlePopInternally) return false;
    // If attempts to dismiss this route might be vetoed such as in a page
    // with forms, then do not allow the user to dismiss the route with a swipe.
    if (route.hasScopedWillPopCallback) return false;
    // If we're being popped into, we also cannot be swiped until the pop above
    // it completes. This translates to our secondary animation being
    // dismissed.
    if (route.secondaryAnimation!.status != AnimationStatus.dismissed) return false;
    // If we're in a gesture already, we cannot start another.
    if (isUserGestureInProgress(route)) return false;
    return true;
  }
}
