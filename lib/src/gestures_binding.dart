import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Prints information about preventing cancel pointer with [GestureBinding.cancelPointer].
///
/// This flag only has an effect in debug mode.
bool debugPrintPreventCancelPointer = false;

/// [GestureBinding] implementation for prevent route [GestureHandler] active pointers canceling by [NavigatorState].
///
/// [NavigatorState] cancel active pointers after navigation.
mixin NavigatorGesturesBinding on GestureBinding {
  final Map<int, int> _preventFromCancelPointers = {};

  int get _preventedCounts => _preventFromCancelPointers.length;

  void preventPointerFromCancel(int pointer, [GestureRecognizer? recognizer]) {
    final prevents = (_preventFromCancelPointers[pointer] ?? 0) + 1;
    _preventFromCancelPointers[pointer] = prevents;
    assert(() {
      if (debugPrintPreventCancelPointer) {
        _debugLogDiagnostic(
            '${recognizer ?? ''} \npreventPointerFromCancel($pointer), prevented counts: $_preventedCounts.');
      }
      return true;
    }());
  }

  void removePointerFromCancelPrevent(int pointer, [GestureRecognizer? recognizer]) {
    final prevents = (_preventFromCancelPointers[pointer] ?? 0) - 1;
    if (prevents <= 0) {
      _preventFromCancelPointers.remove(pointer);
    } else {
      _preventFromCancelPointers[pointer] = prevents;
    }
    assert(() {
      if (debugPrintPreventCancelPointer) {
        _debugLogDiagnostic(
            '${recognizer ?? ''} \nremovePointerFromCancelPrevent($pointer), prevented counts: $_preventedCounts.');
      }
      return true;
    }());
  }

  @override
  void cancelPointer(int pointer) {
    if (_preventFromCancelPointers.containsKey(pointer)) {
      assert(() {
        if (debugPrintPreventCancelPointer) {
          _debugLogDiagnostic('pointer: $pointer prevented from canceling.');
        }
        return true;
      }());
      return;
    }
    super.cancelPointer(pointer);
  }
}

/// A concrete binding for applications based on the Widgets framework.
///
/// This is the glue that binds the framework to the Flutter engine.
class NavigatorGesturesFlutterBinding extends WidgetsFlutterBinding with NavigatorGesturesBinding {
  /// Returns an instance of the [WidgetsBinding], creating and
  /// initializing it if necessary. If one is created, it will be a
  /// [NavigatorGesturesFlutterBinding]. If one was previously initialized, then
  /// it will at least implement [WidgetsBinding].
  ///
  /// You only need to call this method if you need the binding to be
  /// initialized before calling [runApp].
  ///
  /// In the `flutter_test` framework, [testWidgets] initializes the
  /// binding instance to a [TestWidgetsFlutterBinding], not a
  /// [NavigatorGesturesFlutterBinding].
  static WidgetsBinding ensureInitialized() {
    NavigatorGesturesFlutterBinding();
    return WidgetsBinding.instance!;
  }
}

bool _debugLogDiagnostic(String message) {
  assert(() {
    debugPrint('[NavigatorGesturesBinding]: $message');
    return true;
  }());
  return true;
}
