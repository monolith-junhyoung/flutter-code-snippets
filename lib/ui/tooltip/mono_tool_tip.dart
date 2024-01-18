import 'package:code_snippets/ui/tooltip/mono_tool_tip_bubble.dart';
import 'package:code_snippets/ui/tooltip/mono_tool_tip_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// MonoToolTip(
///   position: MonoToolTipPosition.leftStart,
///   distance: 8,
///   content: Text('ToolTip description'),
///   child: Container(
///     child: Button('Target'),
///   ),
/// )
class MonoToolTip extends StatefulWidget {
  const MonoToolTip({
    required this.position,
    this.controller,
    this.borderWidth = 0.0,
    this.borderRadius = 6.0,
    this.borderColor,
    this.backgroundColor,
    this.shadows,
    this.arrowWidth = 16.0,
    this.arrowHeight = 10.0,
    this.distance = 0.0,
    this.keepContentInScreen = true,
    this.child,
    required this.content,
    super.key,
  });

  final double borderWidth;
  final double? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final double arrowWidth;
  final double arrowHeight;
  final MonoToolTipPosition position;
  final double distance;

  /// keepContentInScreen will limit the extent of boundary that content widget can extend.
  /// this will only work in a horizontal space to limit the max width.
  final bool keepContentInScreen;
  final Widget? child;
  final Widget content;

  final MonoToolTipController? controller;

  @override
  State<MonoToolTip> createState() => _MonoToolTipState();
}

class _MonoToolTipState extends State<MonoToolTip> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Offset _offset = Offset.zero;

  late MonoToolTipController _controller;

  /// Opacity is not because of animation but because of initial location of tooltip
  /// widget that's going to be displayed on the [OverlayEntry] at the beginning,
  /// which it has located top left position of target. after this, it will calculate
  /// the location what users intent to place.
  double _opacity = 0;

  /// the value will be set to true when the ToolTip is rendered with the size of its own.
  bool _isToolTipRendered = false;

  /// visibility flag that will determine the status of tooltip for [MonoToolTip]
  bool _isToolTipVisible = false;

  @override
  void initState() {
    _controller = widget.controller ?? MonoToolTipController();
    _attachController(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addToolTip();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MonoToolTip oldWidget) {
    if (oldWidget.position != widget.position) {
      _removeToolTip();
      _addToolTip();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );
  }

  void _attachController(MonoToolTipController controller) {
    _controller.attach(showToolTip: _showToolTip, hideToolTip: _hideToolTip);
  }

  Future<void> _showToolTip() async {
    if (_overlayEntry == null) {
      _addToolTip();
    }
  }

  Future<void> _addToolTip() async {
    if (_overlayEntry != null) {
      return;
    }

    // calculate space to horizontal boundary(either left or right side of screen)
    final (space, targetSize) = _calculateSpaceToBoundary(
      context: context,
      position: widget.position,
      arrowHeight: widget.arrowHeight,
      borderWidth: widget.borderWidth,
      distance: widget.distance,
    );

    print('_addToolTip> _opacity: $_opacity, _isVisible: $_isToolTipRendered, _isToolTipVisible: $_isToolTipVisible');

    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return CompositedTransformFollower(
        showWhenUnlinked: false,
        link: _layerLink,
        offset: _offset,
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned(
                child: AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  onEnd: () {
                    print('onAnimationEnd! _opacity: $_opacity, _isToolTipVisible: $_isToolTipVisible');
                    // remove tooltip from the overlay when the animation finished.
                    if (!_isToolTipVisible) {
                      _removeToolTip();
                    }
                  },
                  child: MonoToolTipBubble(
                    position: widget.position,
                    borderWidth: widget.borderWidth,
                    borderRadius: widget.borderRadius,
                    borderColor: widget.borderColor,
                    backgroundColor: widget.backgroundColor,
                    arrowHeight: widget.arrowHeight,
                    shadows: widget.shadows,
                    child: MeasureWidgetSize(
                      onSizeChange: (Size? size) async {
                        // size of follower widget
                        if (size != null) {
                          final offset = _calculateOffsetByPosition(
                            widget.position,
                            targetSize: targetSize,
                            followerSize: size,
                            arrowHeight: widget.arrowHeight,
                            borderWidth: widget.borderWidth,
                            distance: widget.distance,
                          );

                          setState(() {
                            _offset = offset;
                            _isToolTipRendered = true;

                            _isToolTipVisible = _controller.value == ToolTipStatus.shown;
                            _opacity = _isToolTipVisible ? 1 : 0;
                          });

                          print('ToolTip.onSizeChange> _opacity: $_opacity, _isToolTipVisible: $_isToolTipVisible');

                          /// it is inevitable to render the overlay forcefully, because ToolTip's location is
                          /// determined after the first widget is first rendered to get the size of it.
                          /// and the overlay is not a part of build method which the widget does re-rendered it
                          /// by setState()
                          _overlayEntry?.markNeedsBuild();
                        }
                      },
                      child: Container(
                        constraints: widget.keepContentInScreen ? BoxConstraints(maxWidth: space) : null,
                        child: widget.content,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntry!);
  }

  Future<void> _hideToolTip() async {
    if (_isToolTipVisible) {
      setState(() {
        _opacity = 0.0;
        _isToolTipVisible = false;
      });
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _removeToolTip() {
    if (_overlayEntry != null) {
      setState(() {
        _isToolTipRendered = false;
      });
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  /// calculate space to horizontal boundary(either left or right side of screen) and the target size.
  /// Target will be decided by the context.
  /// [context] is the context of the widget that is going to calculate the size of space
  (double, Size) _calculateSpaceToBoundary({
    required BuildContext context,
    required MonoToolTipPosition position,
    required double arrowHeight,
    required double borderWidth,
    double distance = 0,
  }) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) {
      throw StateError('Cannot find child object for ToolTip!');
    }

    final screenSize = MediaQuery.of(context).size;
    final Size targetSize = box.getDryLayout(const BoxConstraints.tightForFinite());
    final space = _getHorizontalSpace(
      position: position,
      screenWidth: screenSize.width,
      targetBox: box,
      arrowHeight: arrowHeight,
      borderWidth: borderWidth,
      extraHorizontalSpace: distance,
    );

    return (space, targetSize);
  }

  /// calculate the offset of tooltip relative to the top left point of the target
  /// [distance] is the space between arrow and target widget
  Offset _calculateOffsetByPosition(
    MonoToolTipPosition position, {
    required Size targetSize,
    required Size followerSize,
    required double arrowHeight,
    double borderWidth = 0,
    double distance = 0,
  }) {
    switch (position) {
      case MonoToolTipPosition.topStart:
        return Offset(0, -(followerSize.height + borderWidth * 2 + arrowHeight + distance));
      case MonoToolTipPosition.topCenter:
        return Offset(
          -((followerSize.width * 0.5 + borderWidth) - (targetSize.width * 0.5)),
          -(followerSize.height + borderWidth * 2 + arrowHeight + distance),
        );
      case MonoToolTipPosition.topEnd:
        return Offset(
          -((followerSize.width + borderWidth * 2) - targetSize.width),
          -(followerSize.height + borderWidth * 2 + arrowHeight + distance),
        );

      case MonoToolTipPosition.rightStart:
        return Offset(targetSize.width + distance, 0);
      case MonoToolTipPosition.rightCenter:
        return Offset(
          targetSize.width + distance,
          -(followerSize.height * 0.5 + borderWidth) + (targetSize.height * 0.5),
        );
      case MonoToolTipPosition.rightEnd:
        return Offset(
          targetSize.width + distance,
          -(followerSize.height + borderWidth * 2 - targetSize.height),
        );

      case MonoToolTipPosition.bottomStart:
        return Offset(0, targetSize.height + distance);
      case MonoToolTipPosition.bottomCenter:
        return Offset(
          -((followerSize.width * 0.5 + borderWidth) - (targetSize.width * 0.5)),
          targetSize.height + distance,
        );
      case MonoToolTipPosition.bottomEnd:
        return Offset(
          -((followerSize.width + borderWidth * 2) - targetSize.width),
          targetSize.height + distance,
        );

      case MonoToolTipPosition.leftStart:
        return Offset(-(followerSize.width + borderWidth * 2 + arrowHeight + distance), 0);
      case MonoToolTipPosition.leftCenter:
        return Offset(
          -(followerSize.width + borderWidth * 2 + arrowHeight + distance),
          -(followerSize.height * 0.5 + borderWidth) + (targetSize.height * 0.5),
        );
      case MonoToolTipPosition.leftEnd:
        return Offset(
          -(followerSize.width + borderWidth * 2 + arrowHeight + distance),
          -(followerSize.height + borderWidth * 2 - targetSize.height),
        );
    }
  }

  /// calculate horizontal space between target and screen boundary
  double _getHorizontalSpace({
    required MonoToolTipPosition position,
    required double screenWidth,
    required RenderBox targetBox,
    required double arrowHeight,
    required double borderWidth,
    double extraHorizontalSpace = 0,
  }) {
    final spaceMargin = arrowHeight + borderWidth * 2 + extraHorizontalSpace;

    switch (position) {
      case MonoToolTipPosition.topStart:
      case MonoToolTipPosition.bottomStart:
        final target = targetBox.localToGlobal(targetBox.size.topLeft(Offset.zero));
        return screenWidth - target.dx - borderWidth * 2;
      case MonoToolTipPosition.bottomCenter:
      case MonoToolTipPosition.topCenter:
        return screenWidth;
      case MonoToolTipPosition.bottomEnd:
      case MonoToolTipPosition.topEnd:
        final target = targetBox.localToGlobal(targetBox.size.topRight(Offset.zero));
        return target.dx - borderWidth * 2;

      case MonoToolTipPosition.rightStart:
      case MonoToolTipPosition.rightCenter:
      case MonoToolTipPosition.rightEnd:
        final target = targetBox.localToGlobal(targetBox.size.topRight(Offset.zero));
        return screenWidth - target.dx - spaceMargin;

      case MonoToolTipPosition.leftStart:
      case MonoToolTipPosition.leftCenter:
      case MonoToolTipPosition.leftEnd:
        final target = targetBox.localToGlobal(targetBox.size.topLeft(Offset.zero));
        return target.dx - spaceMargin;
    }
  }
}

/// measure widget size when the widget layout
class MeasureWidgetSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onSizeChange;

  const MeasureWidgetSize({
    Key? key,
    required this.onSizeChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureWidgetSizeRenderObject(onSizeChange);
  }
}

typedef OnWidgetSizeChange = void Function(Size? size);

class MeasureWidgetSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  final OnWidgetSizeChange onSizeChange;

  MeasureWidgetSizeRenderObject(this.onSizeChange);

  @override
  void performLayout() {
    super.performLayout();

    var newSize = child?.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onSizeChange(newSize);
    });
  }
}
