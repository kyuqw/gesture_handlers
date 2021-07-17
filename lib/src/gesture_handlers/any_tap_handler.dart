import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../gesture_handler.dart';

class AnyTapHandlerDelegate extends GestureHandler {
  const AnyTapHandlerDelegate({this.onAnyTapDown, this.onAnyTapUp});

  final VoidCallback? onAnyTapDown;
  final VoidCallback? onAnyTapUp;

  @override
  RecognizerFactories recognizerFactories() {
    return {
      AnyTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<AnyTapGestureRecognizer>(
          () => AnyTapGestureRecognizer(debugOwner: this), initializeAnyTapGestureRecognizer),
    };
  }

  void initializeAnyTapGestureRecognizer(AnyTapGestureRecognizer instance) {
    instance.onAnyTapUp = onAnyTapUp;
    instance.onAnyTapDown = onAnyTapDown;
  }
}

/// Recognizes tap down by any pointer button.
///
/// It is similar to [TapGestureRecognizer.onTapDown], but accepts any single
/// button, which means the gesture also takes parts in gesture arenas.
class AnyTapGestureRecognizer extends BaseTapGestureRecognizer {
  AnyTapGestureRecognizer({Object? debugOwner}) : super(debugOwner: debugOwner);

  VoidCallback? onAnyTapDown;
  VoidCallback? onAnyTapUp;

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (onAnyTapDown == null && onAnyTapUp == null) return false;
    return super.isPointerAllowed(event);
  }

  @override
  void handleTapDown({PointerDownEvent? down}) {
    onAnyTapDown?.call();
  }

  @override
  void handleTapUp({PointerDownEvent? down, PointerUpEvent? up}) {
    onAnyTapUp?.call();
  }

  @override
  void handleTapCancel({PointerDownEvent? down, PointerCancelEvent? cancel, String? reason}) {}

  @override
  String get debugDescription => 'any tap';
}
