import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class GestureListener extends StatefulWidget {
  final GestureHandler handler;
  final Widget child;
  final HitTestBehavior? behavior;
  final bool excludeFromSemantics;

  const GestureListener({
    Key? key,
    required this.handler,
    required this.child,
    this.behavior,
    this.excludeFromSemantics = false,
  }) : super(key: key);

  @override
  State<GestureListener> createState() => _GestureListenerState();
}

class _GestureListenerState extends State<GestureListener> {
  late Map<Type, GestureRecognizerFactory<GestureRecognizer>> gestures;

  @override
  void initState() {
    super.initState();
    initGestures();
  }

  @override
  void didUpdateWidget(covariant GestureListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.handler != widget.handler) {
      // if (oldWidget.disposeHandler) oldWidget.handler.dispose();
      initGestures();
    }
  }

  @override
  void dispose() {
    // if (widget.disposeHandler) widget.handler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: gestures,
      behavior: widget.behavior,
      excludeFromSemantics: widget.excludeFromSemantics,
      child: widget.child,
    );
  }

  void initGestures() {
    gestures = widget.handler.recognizerFactories();
  }
}

typedef RecognizerFactories = Map<Type, GestureRecognizerFactory>;

abstract class GestureHandler {
  const GestureHandler();

  // TODO: refactor?
  RecognizerFactories recognizerFactories();

  @mustCallSuper
  void dispose() {}
}

mixin GestureHandlerComposerMixin on GestureHandler {
  List<GestureHandler> get handlers;

  @override
  RecognizerFactories recognizerFactories() {
    final recognizer = <Type, GestureRecognizerFactory>{};
    for (final h in handlers) {
      final types = h.recognizerFactories();
      for (final type in types.keys) {
        assert(!recognizer.containsKey(type),
            'GestureRecognizerFactory of type $type already registered. Remove handler with this type or use another GestureHandlerComposer.');
        recognizer[type] = types[type]!;
      }
    }
    return recognizer;
  }

  @override
  void dispose() {
    for (final i in handlers) {
      i.dispose();
    }
    super.dispose();
  }
}

class GestureHandlerComposer extends GestureHandler with GestureHandlerComposerMixin {
  @override
  final List<GestureHandler> handlers;

  const GestureHandlerComposer({required this.handlers});
}

mixin AnimationGestureMixin on GestureHandler {
  double get value;

  set value(double value);

  double get lowerBound => 0.0;

  double get upperBound => 1.0;

  bool get isAtMin => value <= lowerBound;

  bool get isAtMax => value >= upperBound;

  bool get reverse => false;

  void reverseProgress();

  void forwardProgress();
}

mixin AnimationControllerGestureMixin implements AnimationGestureMixin {
  AnimationController get controller;

  @override
  double get value => controller.value;

  @override
  set value(double value) => controller.value = value;

  @override
  double get lowerBound => controller.lowerBound;

  @override
  double get upperBound => controller.upperBound;

  @override
  void reverseProgress() => controller.reverse();

  @override
  void forwardProgress() => controller.forward();
}

mixin DeactivatableGestureHandlerMixin on GestureHandler {
  bool get isDeactivated;

  // TODO: refactor
  @protected
  void onlyIfActivated<T>(Function callback, [List? args, Map<Symbol, dynamic>? kwargs]) {
    if (isDeactivated) return;
    Function.apply(callback, args, kwargs);
  }
}
