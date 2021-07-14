import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gesture_handlers/gesture_handlers.dart';

void main() {
  // debugPrintRecognizerCallbacksTrace = true;
  // debugPrintPreventCancelPointer = true;

  /// [GestureBinding] implementation for prevent route [GestureHandler] active pointers canceling by [NavigatorState].
  NavigatorGesturesFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,

        /// override PageTransitionsTheme just for CupertinoPageTransition right to left animation.
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: RightToLeftTransitionBuilder(),
          TargetPlatform.iOS: RightToLeftTransitionBuilder(),
          TargetPlatform.fuchsia: RightToLeftTransitionBuilder(),
          TargetPlatform.linux: RightToLeftTransitionBuilder(),
        }),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late final AnimationController persistentBottomController;
  late final SwipeRouteHandler secondSwipeHandler;
  late final AnimationControllerGestureMixin horizontalSwipeHandler;
  late final GestureHandler handlerComposer;

  Size get size => MediaQuery.of(context).size;

  double get persistentBottomHeight => 0.3 * size.height;

  double get bottomSheetHeight => 0.8 * size.height;

  bool get isPersistentBottomOpened => persistentBottomController.value.round() > 0;

  @override
  void initState() {
    super.initState();
    persistentBottomController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    final persistentBottomSwipeHandler = AnimationControllerSwipeHandler(
      direction: DragDirection.vertical,
      reverse: true,
      controller: persistentBottomController,
      getChildSize: () => persistentBottomHeight,
    );
    secondSwipeHandler = SwipeRouteHandler(
      controllerFactory: () => AnimationController(duration: const Duration(milliseconds: 500), vsync: this),
      openRouteDelegate: createBottomSheetDelegate,
      direction: DragDirection.vertical,
      openProgressThreshold: 0.3,
      reverse: true,
      getChildSize: () => bottomSheetHeight,
    );
    horizontalSwipeHandler = SwipeRouteHandler(
      controllerFactory: () => AnimationController(duration: const Duration(milliseconds: 500), vsync: this),
      openRouteDelegate: openRightSheet,
      direction: DragDirection.horizontal,
      reverse: true,
      getChildSize: () => size.width,
    );

    handlerComposer = GestureHandlerComposer(
      handlers: [
        CascadeSwipeHandler(
          handlers: [
            persistentBottomSwipeHandler,
            secondSwipeHandler,
          ],
          reverse: true,
          direction: DragDirection.vertical,
        ),
        horizontalSwipeHandler,
        TapHandlerDelegate(onTap: () {
          // persistentBottomSwipeHandler.controller.animateTo(isPersistentBottomOpened ? 0.0 : 1.0);
          secondSwipeHandler.showRoute();
        }),
      ],
    );
  }

  @override
  void dispose() {
    persistentBottomController.dispose();
    handlerComposer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.headline6;
    return GestureListener(
      handler: handlerComposer,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Stack(
          children: [
            Center(
              child: Text('Swipe up \nSwipe left \nTap', textAlign: TextAlign.center, style: style),
            ),
          ],
        ),
        bottomNavigationBar: buildPersistentBottom(context),
      ),
    );
  }

  Widget buildPersistentBottom(BuildContext context) {
    return SizeTransition(
      sizeFactor: persistentBottomController,
      axisAlignment: -1.0,
      child: Card(
        margin: EdgeInsets.zero,
        color: Colors.white12,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22.0))),
        child: Container(
          height: persistentBottomHeight,
          padding: const EdgeInsets.all(16.0),
          child: Container(
            alignment: Alignment.center,
            child: const Text('swipe up to modal sheet'),
          ),
          // child: const Placeholder(),
        ),
      ),
    );
  }

  ShowGestureRouteDelegate createBottomSheetDelegate() {
    return createGestureBottomUpModalDelegate(
      context: context,
      constraints: BoxConstraints(maxHeight: bottomSheetHeight),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22.0))),
      builder: (ctx) => Container(
        alignment: Alignment.center,
        child: const Text('Gesture Modal Bottom Sheet Route'),
      ),
    );
  }

  ShowGestureRouteDelegate openRightSheet() {
    return (handler) => Navigator.push(
          context,
          MaterialGesturePageRoute(
            gestureDelegate: handler,
            builder: (ctx) => Scaffold(
              appBar: AppBar(title: const Text('Page Route')),
              body: Container(
                alignment: Alignment.center,
                child: const Text('Material Gesture Page Route'),
              ),
            ),
          ),
        );
  }
}

class RightToLeftTransitionBuilder extends PageTransitionsBuilder {
  const RightToLeftTransitionBuilder() : super();

  @override
  Widget buildTransitions<T>(ModalRoute<T> route, BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return CupertinoPageTransition(
      primaryRouteAnimation: animation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: true,
      child: child,
    );
  }
}
