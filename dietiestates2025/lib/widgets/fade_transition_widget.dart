import 'package:flutter/material.dart';

class FadeTransitionWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final VoidCallback? onEnd;

  const FadeTransitionWidget({
    super.key,
    required this.child,
    required this.duration,
    this.onEnd,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FadeTransitionWidgetState createState() => _FadeTransitionWidgetState();
}

class _FadeTransitionWidgetState extends State<FadeTransitionWidget> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() => _opacity = 0.0);
      }
      Future.delayed(widget.duration, () => widget.onEnd?.call());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.duration,
      child: widget.child,
    );
  }
}
