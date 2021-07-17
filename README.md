# Gesture handlers

[![Pub Version](https://img.shields.io/pub/v/gesture_handlers?logo=dart&logoColor=white)](https://pub.dev/packages/gesture_handlers)
[![Pub Likes](https://badgen.net/pub/likes/gesture_handlers)](https://pub.dev/packages/gesture_handlers)
[![Pub popularity](https://badgen.net/pub/popularity/gesture_handlers)](https://pub.dev/packages/gesture_handlers/score)
[![Flutter Platform](https://badgen.net/pub/flutter-platform/gesture_handlers)](https://pub.dev/packages/gesture_handlers)

Gesture handlers Flutter project.

Provide reusable gesture handler and Support interactive transitions between routes (i.e., controlled by gesture).

## Preview

[<img src="https://raw.githubusercontent.com/kyuqw/gesture_handlers/master/example/media/bottom_sheet_demo.gif" width="250" alt="bottom sheet demo"/>](https://pub.dev/packages/gesture_handlers/example)
[<img src="https://raw.githubusercontent.com/kyuqw/gesture_handlers/master/example/media/right_sheet_demo.gif" width="250" alt="right sheet demo"/>](https://pub.dev/packages/gesture_handlers/example)


## Installation

Add [*`gesture_handlers`*](https://pub.dev/packages/gesture_handlers/install)
as a dependency in [your pubspec.yaml file](https://flutter.dev/using-packages).

```shell
flutter pub add gesture_handlers
```
Import it in your Dart code
```dart
import 'package:gesture_handlers/gesture_handlers.dart';
```

## Usage

### Basic usage

Initialize concrete `GestureHandler` implementation.

```dart
final tapHandler = TapHandlerDelegate(onTap: () => print('tap handled'));
```

Pass handler to `GestureListener`.

```dart
@override
Widget build(BuildContext context) {
  return GestureListener(
    handler: tapHandler,
    child: Scaffold(body: Center(child: Text('Tap'))),
  );
}
```

Dispose it at the end.

```dart
@override
void dispose() {
  tapHandler.dispose();
  super.dispose();
}
```

### Route gesture transition

* Initialize `NavigatorGesturesFlutterBinding`
  or use your own `NavigatorGesturesBinding` implementation
  for prevent route `GestureHandler` active pointers canceling by `NavigatorState`.

```dart
import 'package:gesture_handlers/gesture_handlers.dart';

void main() {
  /// Prints information about preventing cancel pointer with [GestureBinding.cancelPointer].
  // debugPrintPreventCancelPointer = true;

  NavigatorGesturesFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
```

* Initialize `SwipeRouteHandler` or your own `GestureRouteDelegate` implementation.
* Use `GestureModalBottomSheetRoute`, `MaterialGesturePageRoute`
  or create custom gesture route with `GestureRouteTransitionMixin`.
