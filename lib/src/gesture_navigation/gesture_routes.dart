import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'gesture_route_delegate.dart';
import 'gesture_route_transition_mixin.dart';

class MaterialGesturePageRoute<T> extends MaterialPageRoute<T> with GestureRouteTransitionMixin<T> {
  MaterialGesturePageRoute({
    required this.gestureDelegate,
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(builder: builder, settings: settings, maintainState: maintainState, fullscreenDialog: fullscreenDialog);

  @override
  GestureRouteDelegate gestureDelegate;

  @override
  Widget buildPageTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final PageTransitionsTheme theme = Theme.of(context).pageTransitionsTheme;
    return theme.buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }
}
