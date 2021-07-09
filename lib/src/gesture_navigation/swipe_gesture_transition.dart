import 'package:flutter/widgets.dart';

final Animatable<Offset> kLeftRightTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(1.0, 0.0),
);
final Animatable<Offset> kRightLeftTween = Tween<Offset>(
  begin: const Offset(1.0, 0.0),
  end: Offset.zero,
);
final Animatable<Offset> kTopBottomTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(0.0, 1.0),
);
final Animatable<Offset> kBottomTopTween = Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: Offset.zero,
);

class SwipeGestureTransition extends StatelessWidget {
  SwipeGestureTransition({
    Key? key,
    required Animation<double> primaryRouteAnimation,
    required Animatable<Offset> direction,
    required this.child,
  })  : _primaryPositionAnimation = primaryRouteAnimation.drive(direction),
        super(key: key);

  /// When this page is coming in to cover another page.
  final Animation<Offset> _primaryPositionAnimation;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _primaryPositionAnimation,
      // transformHitTests: false,
      child: child,
    );
  }
}
