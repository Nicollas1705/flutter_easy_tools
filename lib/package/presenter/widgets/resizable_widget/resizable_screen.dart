import 'package:flutter/material.dart';

class ResizableScreen {
  late double size;
  double percentSize;

  final double minSize;
  final bool fixedSizeWhenResizingWindow;
  final Widget Function() screenBuilder;

  /// Use it to navigate: key.currentContext
  final GlobalKey<NavigatorState> key;

  /// Defines the initial value to the screen size
  // final double? beginningSize;

  ResizableScreen({
    required this.screenBuilder,
    this.minSize = 100,
    this.percentSize = 0.3,
    this.fixedSizeWhenResizingWindow = false,
  })  : key = GlobalKey<NavigatorState>(),
        _initialPercentSize = percentSize;

  late final double _initialPercentSize;
  double get initialPercentSize => _initialPercentSize;

  /// Use it instead of Navigot.pop(...);
  void pop() {
    if (key.currentState != null && key.currentContext != null) {
      if (key.currentState!.canPop()) {
        Navigator.pop(key.currentContext!);
      }
    }
  }

  /// Back to initial page
  void popAll() {
    if (key.currentState != null && key.currentContext != null) {
      while (key.currentState!.canPop()) {
        Navigator.pop(key.currentContext!);
      }
    }
  }

  /// Check if can use Navigot.pop(...);
  bool canPop() {
    if (key.currentState != null) {
      return key.currentState!.canPop();
    }
    return false;
  }
}
