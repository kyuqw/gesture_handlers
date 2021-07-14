import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

import '../gestures_binding.dart';

mixin NavigatorGesturesPreventingCancelingMixin on GestureRecognizer {
  static NavigatorGesturesBinding? getGestureBinding() {
    if (GestureBinding.instance is NavigatorGesturesBinding) return GestureBinding.instance as NavigatorGesturesBinding;
    return null;
  }

  void preventPointerFromCancel(int pointer) {
    getGestureBinding()?.preventPointerFromCancel(pointer, this);
  }

  void removePointerFromCancelPrevent(int pointer) {
    getGestureBinding()?.removePointerFromCancelPrevent(pointer, this);
  }
}

mixin NavigatorGesturesOneSequenceMixin on OneSequenceGestureRecognizer
    implements NavigatorGesturesPreventingCancelingMixin {
  @override
  void startTrackingPointer(int pointer, [Matrix4? transform]) {
    preventPointerFromCancel(pointer);
    super.startTrackingPointer(pointer, transform);
  }

  @override
  void stopTrackingPointer(int pointer) {
    removePointerFromCancelPrevent(pointer);
    super.stopTrackingPointer(pointer);
  }
}

class RouteHorizontalDragGestureRecognizer extends HorizontalDragGestureRecognizer
    with NavigatorGesturesPreventingCancelingMixin, NavigatorGesturesOneSequenceMixin {
  RouteHorizontalDragGestureRecognizer({Object? debugOwner, PointerDeviceKind? kind /*, Set<PointerDeviceKind>? supportedDevices */})
      : super(debugOwner: debugOwner, kind: kind/*, supportedDevices: supportedDevices */);
}

class RouteVerticalDragGestureRecognizer extends VerticalDragGestureRecognizer
    with NavigatorGesturesPreventingCancelingMixin, NavigatorGesturesOneSequenceMixin {
  RouteVerticalDragGestureRecognizer({Object? debugOwner, PointerDeviceKind? kind /*, Set<PointerDeviceKind>? supportedDevices */})
      : super(debugOwner: debugOwner, kind: kind/*, supportedDevices: supportedDevices */);
}
