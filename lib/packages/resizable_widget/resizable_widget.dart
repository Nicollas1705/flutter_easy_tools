part of resizable_widget;

class ResizableWidget extends StatelessWidget {
  final ResizableController controller;

  final ResizableScreen screen1;
  final ResizableScreen screen2;

  /// The color of the 2 bars icon.
  final Color? resizableIconColor;
  final Color? resizableBarBackgroundColor;
  final Decoration? resizableBarDecoration;

  /// Set as true to use a long press to resize (ex: mobile).
  final bool dragOnLongPress;

  const ResizableWidget({
    Key? key,
    required this.controller,
    required this.screen1,
    required this.screen2,
    this.resizableBarBackgroundColor,
    this.resizableIconColor = Colors.black,
    this.resizableBarDecoration,
    this.dragOnLongPress = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    assert(
      !screen1.fixedSizeWhenResizingWindow ||
          !screen2.fixedSizeWhenResizingWindow,
      "Only one screen can have 'fixedSizeWhenResizingWindow' = true",
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return LayoutBuilder(builder: (context, constraints) {
          controller.calculateSizes(
            constraints: constraints,
            screen1: screen1,
            screen2: screen2,
          );

          return Stack(
            children: [
              _isHorizontal
                  ? Row(children: _children())
                  : Column(children: _children()),
              _resizableBar(context, constraints),
            ],
          );
        });
      },
    );
  }

  List<Widget> _children() {
    return [
      _singleScreen(screen1),
      _isShowingBoth
          ? SizedBox(
              width: _isHorizontal ? controller.resizableBarThickness : null,
              height: _isHorizontal ? null : controller.resizableBarThickness,
            )
          : const SizedBox(),
      _singleScreen(screen2),
    ];
  }

  Widget _singleScreen(ResizableScreen screen) {
    return SizedBox(
      width: _isHorizontal ? screen.size : null,
      height: _isHorizontal ? null : screen.size,
      child: Navigator(
        key: screen.key,
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) {
              return screen.screenBuilder();
            },
          );
        },
      ),
    );
  }

  Widget _resizableBar(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    return _isShowingBoth
        ? Positioned(
            left: _isHorizontal ? screen1.size : null,
            top: _isHorizontal ? null : screen1.size,
            child: Container(
              decoration: resizableBarDecoration ??
                  BoxDecoration(color: resizableBarBackgroundColor),
              width: _isHorizontal
                  ? controller.resizableBarThickness
                  : constraints.maxWidth,
              height: _isHorizontal
                  ? constraints.maxHeight
                  : controller.resizableBarThickness,
              child: Center(child: _resizableButton(context)),
            ),
          )
        : const SizedBox();
  }

  Widget _resizableButton(BuildContext context) {
    return MouseRegion(
      cursor: _resizableCursorStyle,
      child: dragOnLongPress
          ? LongPressDraggable(
              child: _resizableIcon(context),
              feedback: const SizedBox(),
              onDragUpdate: (dragUpdateDetails) {
                controller.onDragUpdate(
                  drag: dragUpdateDetails,
                  screen1: screen1,
                  screen2: screen2,
                );
              },
              onDragStarted: () => controller.isResizing = true,
              onDragEnd: (_) => controller.isResizing = false,
            )
          : Draggable(
              child: _resizableIcon(context),
              feedback: const SizedBox(),
              onDragUpdate: (dragUpdateDetails) {
                controller.onDragUpdate(
                  drag: dragUpdateDetails,
                  screen1: screen1,
                  screen2: screen2,
                );
              },
              onDragStarted: () => controller.isResizing = true,
              onDragEnd: (_) => controller.isResizing = false,
            ),
    );
  }

  Widget _resizableIcon(BuildContext context) {
    Widget verticalBar = Container(
      width: _isHorizontal ? 2 : null,
      height: _isHorizontal ? null : 2,
      color: resizableIconColor,
    );

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(2),
      width: _isHorizontal ? controller.resizableBarThickness : 20,
      height: _isHorizontal ? 20 : controller.resizableBarThickness,
      child: _isHorizontal
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                verticalBar,
                verticalBar,
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                verticalBar,
                verticalBar,
              ],
            ),
    );
  }

  bool get _isHorizontal => controller.splitDirection == Axis.horizontal;

  SystemMouseCursor get _resizableCursorStyle => _isHorizontal
      ? SystemMouseCursors.resizeColumn
      : SystemMouseCursors.resizeRow;

  bool get _isShowingBoth =>
      controller.isResizable &&
      controller.isShowingBothScreens &&
      controller.showScreen2;
}
