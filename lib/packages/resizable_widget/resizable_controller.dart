part of resizable_widget;

class ResizableController extends ChangeNotifier {
  /// Enable/disable the resizable widget.
  final bool isResizable;

  /// Compare to the screen size to define if it is single or multi screen.
  /// 
  /// If the max available size is < [sizeSeparator], it will show only the screen1.
  /// If the max available size is >= [sizeSeparator], it will show both screens.
  final double sizeSeparator;
  final Axis splitDirection;
  ResizableController({
    this.isResizable = true,
    this.sizeSeparator = 800,
    this.splitDirection = Axis.horizontal,
  });
  late double _maxWindowSize;

  /// The maximum widget size.
  double get maxWindowSize => _maxWindowSize;
  double get resizableBarThickness => 10;
  bool get _isHorizontal => splitDirection == Axis.horizontal;

  /// The maximum available size for both screens (size - resizableBarThickness).
  double get maxSize => _maxSize;
  late double _maxSize;
  void _setMaxSize(BoxConstraints constraints) {
    late double maxSize;
    if (_isHorizontal) {
      maxSize = constraints.maxWidth;
    } else {
      maxSize = constraints.maxHeight;
    }
    _maxWindowSize = maxSize;

    if (isShowingBothScreens && isResizable && showScreen2) {
      _maxSize = maxSize - resizableBarThickness;
    } else {
      _maxSize = maxSize;
    }
  }

  bool _firstExec = true;
  void calculateSizes({
    required BoxConstraints constraints,
    required ResizableScreen screen1,
    required ResizableScreen screen2,
  }) {
    _setMaxSize(constraints);

    if (maxWindowSize >= sizeSeparator &&
        maxWindowSize >=
            resizableBarThickness + screen1.minSize + screen2.minSize) {
      _setIsShowingBothScreens = true;
    } else {
      _setIsShowingBothScreens = false;
    }

    if (isShowingBothScreens && showScreen2) {
      double tempSize1 = screen1.percentSize * maxSize;
      double tempSize2 = (1 - screen1.percentSize) * maxSize;
      if (_firstExec) {
        if (screen1.beginningSize != null) {
          tempSize1 = screen1.beginningSize!;
          tempSize2 = maxSize - tempSize1;
        } else if (screen2.beginningSize != null) {
          tempSize2 = screen2.beginningSize!;
          tempSize1 = maxSize - tempSize2;
        } else {
          tempSize1 = screen1.initialPercentSize * maxSize;
          tempSize2 = maxSize - tempSize1;
        }
      }

      if (tempSize1 < screen1.minSize) {
        screen1.size = screen1.minSize;
        screen2.size = maxSize - screen1.size;
      } else if (tempSize2 < screen2.minSize) {
        screen2.size = screen2.minSize;
        screen1.size = maxSize - screen2.size;
      } else {
        if (_firstExec) {
          screen1.size = tempSize1;
          screen2.size = tempSize2;
        } else {
          if (screen1.fixedSizeWhenResizingWindow) {
            screen2.size = maxSize - screen1.size;
          } else if (screen2.fixedSizeWhenResizingWindow) {
            screen1.size = maxSize - screen2.size;
          } else {
            screen1.size = tempSize1;
            screen2.size = tempSize2;
          }
        }
      }
      screen1.percentSize = screen1.size / maxSize;
      screen2.percentSize = screen2.size / maxSize;
    } else {
      screen1.size = maxSize;
      screen1.percentSize = 1;
      screen2.size = 0;
      screen2.percentSize = 0;
    }

    if (_firstExec) _firstExec = false;
  }

  void onDragUpdate({
    required DragUpdateDetails drag,
    required ResizableScreen screen1,
    required ResizableScreen screen2,
  }) {
    late final double dragPosition;
    if (_isHorizontal) {
      dragPosition = drag.localPosition.dx;
    } else {
      dragPosition = drag.localPosition.dy;
    }

    if (dragPosition >= screen1.minSize) {
      if (dragPosition < maxSize - screen2.minSize + 1) {
        screen1.percentSize = dragPosition / maxSize;
        screen1.size = maxSize * screen1.percentSize;

        screen2.size = maxSize - screen1.size;
        screen1.percentSize = screen1.size / maxSize;
        screen2.percentSize = screen2.size / maxSize;
        notifyListeners();
      }
    }
  }

  /// While resizing the screens (not the whole window).
  bool get isResizing => _isResizing;
  bool _isResizing = false;
  set isResizing(bool value) {
    if (_isResizing == value) return;
    _isResizing = value;
    notifyListeners();
  }

  /// Check if both screens are being shown.
  bool get isShowingBothScreens => _isShowingBothScreens;
  bool _isShowingBothScreens = true;
  set _setIsShowingBothScreens(bool value) {
    if (_isShowingBothScreens == value) return;
    if (value) {
      _maxSize -= resizableBarThickness;
      if (maxWindowSize >= sizeSeparator) _isShowingBothScreens = value;
    } else {
      _maxSize += resizableBarThickness;
      _isShowingBothScreens = value;
    }
  }

  bool get showScreen2 => _showScreen2;
  bool _showScreen2 = true;

  /// Can show/hide screen2 if it has enough space (you can change).
  set showScreen2(bool value) {
    if (_showScreen2 == value) return;
    _showScreen2 = value;
    _firstExec = true;
    notifyListeners();
  }
}
