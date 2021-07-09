import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../gesture_handler.dart';

abstract class TapHandler extends GestureHandler {
  const TapHandler();

  @override
  RecognizerFactories recognizerFactories() {
    return {
      TapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
          () => TapGestureRecognizer(debugOwner: this), initializeTapGestureRecognizer),
    };
  }

  void initializeTapGestureRecognizer(TapGestureRecognizer instance);
}

class TapHandlerDelegate extends TapHandler {
  const TapHandlerDelegate({
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onTapCancel,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onTertiaryTapDown,
    this.onTertiaryTapUp,
    this.onTertiaryTapCancel,
  }) : assert(onTapDown != null ||
            onTapUp != null ||
            onTap != null ||
            onTapCancel != null ||
            onSecondaryTap != null ||
            onSecondaryTapDown != null ||
            onSecondaryTapUp != null ||
            onSecondaryTapCancel != null ||
            onTertiaryTapDown != null ||
            onTertiaryTapUp != null ||
            onTertiaryTapCancel != null);

  @override
  void initializeTapGestureRecognizer(TapGestureRecognizer instance) {
    instance
      ..onTapDown = onTapDown
      ..onTapUp = onTapUp
      ..onTap = onTap
      ..onTapCancel = onTapCancel
      ..onSecondaryTap = onSecondaryTap
      ..onSecondaryTapDown = onSecondaryTapDown
      ..onSecondaryTapUp = onSecondaryTapUp
      ..onSecondaryTapCancel = onSecondaryTapCancel
      ..onTertiaryTapDown = onTertiaryTapDown
      ..onTertiaryTapUp = onTertiaryTapUp
      ..onTertiaryTapCancel = onTertiaryTapCancel;
  }

  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCallback? onTap;
  final GestureTapCancelCallback? onTapCancel;
  final GestureTapCallback? onSecondaryTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final GestureTapUpCallback? onSecondaryTapUp;
  final GestureTapCancelCallback? onSecondaryTapCancel;
  final GestureTapDownCallback? onTertiaryTapDown;
  final GestureTapUpCallback? onTertiaryTapUp;
  final GestureTapCancelCallback? onTertiaryTapCancel;
}
