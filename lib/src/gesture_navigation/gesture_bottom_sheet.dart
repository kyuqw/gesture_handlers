import 'package:flutter/material.dart';

import 'gesture_route_delegate.dart';
import 'gesture_route_transition_mixin.dart';
import 'swipe_gesture_transition.dart';
import 'swipe_route_handler.dart';

const Duration _bottomSheetEnterDuration = Duration(milliseconds: 350);
const Duration _bottomSheetExitDuration = Duration(milliseconds: 200);

class GestureModalBottomSheetRoute<T> extends PopupRoute<T> with GestureRouteTransitionMixin<T> {
  GestureModalBottomSheetRoute({
    required this.gestureDelegate,
    required this.builder,
    required this.capturedThemes,
    this.barrierLabel,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
    this.modalBarrierColor,
    this.isDismissible = true,
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  final GestureRouteDelegate gestureDelegate;
  final WidgetBuilder builder;
  final CapturedThemes capturedThemes;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;
  final Color? modalBarrierColor;
  final bool isDismissible;

  @override
  Duration get transitionDuration => _bottomSheetEnterDuration;

  @override
  Duration get reverseTransitionDuration => _bottomSheetExitDuration;

  @override
  bool get barrierDismissible => isDismissible;

  @override
  final String? barrierLabel;

  @override
  Color get barrierColor => modalBarrierColor ?? Colors.black54;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    // By definition, the bottom sheet is aligned to the bottom of the page
    // and isn't exposed to the top padding of the MediaQuery.
    final Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Builder(
        builder: (BuildContext context) {
          final BottomSheetThemeData sheetTheme = Theme.of(context).bottomSheetTheme;
          return ModalBottomSheet<T>(
            route: this,
            backgroundColor: backgroundColor ?? sheetTheme.modalBackgroundColor ?? sheetTheme.backgroundColor,
            elevation: elevation ?? sheetTheme.modalElevation ?? sheetTheme.elevation,
            shape: shape,
            clipBehavior: clipBehavior,
            constraints: constraints,
          );
        },
      ),
    );
    return capturedThemes.wrap(bottomSheet);
  }

  @override
  Widget buildPageTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeGestureTransition(primaryRouteAnimation: animation, direction: kBottomTopTween, child: child),
    );
  }
}

class ModalBottomSheet<T> extends StatefulWidget {
  const ModalBottomSheet({
    Key? key,
    required this.route,
    this.backgroundColor,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.constraints,
  }) : super(key: key);

  final GestureModalBottomSheetRoute<T> route;
  final Color? backgroundColor;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final BoxConstraints? constraints;

  @override
  _ModalBottomSheetState<T> createState() => _ModalBottomSheetState<T>();
}

class _ModalBottomSheetState<T> extends State<ModalBottomSheet<T>> {
  GestureModalBottomSheetRoute<T> get route => widget.route;

  String _getRouteLabel(MaterialLocalizations localizations) {
    switch (Theme.of(context).platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return '';
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return localizations.dialogLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    assert(debugCheckHasMaterialLocalizations(context));
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final String routeLabel = _getRouteLabel(localizations);

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      label: routeLabel,
      explicitChildNodes: true,
      child: ClipRect(
        child: BottomSheet(
          // animationController: route.controller,
          onClosing: () {
            if (route.isCurrent) {
              Navigator.pop(context);
            }
          },
          builder: route.builder,
          backgroundColor: widget.backgroundColor,
          elevation: widget.elevation,
          shape: widget.shape,
          clipBehavior: widget.clipBehavior,
          constraints: widget.constraints,
          enableDrag: false,
        ),
      ),
    );
  }
}

Future<T?> showGestureBottomUpModal<T>({
  required BuildContext context,
  required GestureRouteDelegate<T> gestureDelegate,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool useRootNavigator = false,
  bool isDismissible = true,
  RouteSettings? routeSettings,
}) {
  return createGestureBottomUpModalDelegate<T>(
    context: context,
    builder: builder,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  )(gestureDelegate);
}

ShowGestureRouteDelegate<T> createGestureBottomUpModalDelegate<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool useRootNavigator = false,
  bool isDismissible = true,
  RouteSettings? routeSettings,
}) {
  assert(debugCheckHasMediaQuery(context));
  assert(debugCheckHasMaterialLocalizations(context));

  return (GestureRouteDelegate<T> gestureDelegate) {
    final NavigatorState navigator = Navigator.of(context, rootNavigator: useRootNavigator);
    return navigator.push(GestureModalBottomSheetRoute<T>(
      gestureDelegate: gestureDelegate,
      builder: builder,
      capturedThemes: InheritedTheme.capture(from: context, to: navigator.context),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shape: shape,
      clipBehavior: clipBehavior,
      constraints: constraints,
      isDismissible: isDismissible,
      modalBarrierColor: barrierColor,
      settings: routeSettings,
    ));
  };
}
