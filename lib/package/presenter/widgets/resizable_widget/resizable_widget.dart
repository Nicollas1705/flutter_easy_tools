import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'resizable_screen.dart';
import 'resizable_controller.dart';

class ResizableWidget extends StatelessWidget {
  final ResizableController controller;

  final ResizableScreen screen1;
  final ResizableScreen screen2;

  /// By default, the color is Theme.of(context).scaffoldBackgroundColor
  final Color? resizableBarBackgroundColor;

  /// By default, the color is Theme.of(context).textTheme.headline1.color
  final Color? resizableIconColor;

  // TODO:
  // final double resizableBarShadow;
  // Mobile: Resize only on long press

  const ResizableWidget({
    Key? key,
    required this.controller,
    required this.screen1,
    required this.screen2,
    this.resizableBarBackgroundColor,
    this.resizableIconColor,
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

          return isHorizontal
              ? Row(children: _children(context))
              : Column(children: _children(context));
        });
      },
    );
  }

  List<Widget> _children(BuildContext context) {
    return [
      _singleScreen(screen1),
      _resizableBar(context),
      _singleScreen(screen2),
    ];
  }

  Widget _singleScreen(ResizableScreen screen) {
    return SizedBox(
      width: isHorizontal ? screen.size : null,
      height: isHorizontal ? null : screen.size,
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

  Widget _resizableBar(BuildContext context) {
    return controller.isResizable &&
            controller.isShowingBothScreens &&
            controller.showScreen2
        ? MouseRegion(
            cursor: controller.isResizing
                ? resizableCursorStyle
                : MouseCursor.defer,
            child: Container(
              color: resizableBarBackgroundColor ??
                  Theme.of(context).scaffoldBackgroundColor,
              child: isHorizontal
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _resizableButton(context),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _resizableButton(context),
                          ],
                        ),
                      ],
                    ),
            ),
          )
        : const SizedBox();
  }

  Widget _resizableButton(BuildContext context) {
    return MouseRegion(
      cursor: resizableCursorStyle,
      child: Draggable(
        child: _resizableIcon(context),
        feedback: const SizedBox(),
        onDragUpdate: (dragUpdateDetails) {
          controller.onDragUpdate(
            drag: dragUpdateDetails,
            screen1: screen1,
            screen2: screen2,
          );
        },
        onDragStarted: () {
          controller.isResizing = true;
        },
        onDragEnd: (_) {
          controller.isResizing = false;
        },
      ),
    );
  }

  Widget _resizableIcon(BuildContext context) {
    Widget verticalBar = Container(
      width: isHorizontal ? 2 : null,
      height: isHorizontal ? null : 2,
      color: resizableIconColor ??
          Theme.of(context).textTheme.headline1?.color ??
          Colors.black,
    );

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(2),
      width: isHorizontal ? controller.resizableBarThickness : 20,
      height: isHorizontal ? 20 : controller.resizableBarThickness,
      child: isHorizontal
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

  bool get isHorizontal => controller.splitDirection == Axis.horizontal;

  SystemMouseCursor get resizableCursorStyle => isHorizontal
      ? SystemMouseCursors.resizeColumn
      : SystemMouseCursors.resizeRow;
}
