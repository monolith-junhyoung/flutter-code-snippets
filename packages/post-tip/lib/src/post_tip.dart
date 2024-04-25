import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'post_tip_bubble.dart';
import 'post_tip_controller.dart';

/// final _controller = PostTipController(value: PostTipStatus.shown)
///
/// PostTip(
///   controller: _controller
///   position: PostTipPosition.leftStart,
///   borderWidth: 4,
///   borderRadius: 6,
///   borderColor: Colors.blueGrey,
///   backgroundColor: Colors.blue,
///   shadows: <BoxShadow>[
///     BoxShadow(
///       color: Colors.black.withOpacity(0.2),
///       blurRadius: 8,
///       offset: const Offset(0, 8),
///     ),
///   ],
///   distance: 8,
///   arrowWidth: 8,
///   arrowHeight: 5,
///   keepContentInScreen: false,
///   content: Text('ToolTip description'),
///   child: Container(
///     child: Button('Target'),
///   ),
/// )
class PostTip extends StatefulWidget {
  const PostTip({
    required this.position,
    this.controller,
    this.borderWidth = 0.0,
    this.borderRadius = 4.0,
    this.borderColor,
    this.backgroundColor,
    this.shadows,
    this.arrowWidth = 8.0,
    this.arrowHeight = 5.0,
    this.distance = 0.0,
    this.keepContentInScreen = true,
    this.child,
    required this.content,
    super.key,
  });

  /// stroke of border
  final double borderWidth;

  /// radius of border for the round rect shape. put 0 you want rectangle.
  final double? borderRadius;

  /// border color
  final Color? borderColor;

  /// background color of ToolTip
  final Color? backgroundColor;

  /// shadows of ToolTip shape
  final List<BoxShadow>? shadows;

  /// arrow size
  final double arrowWidth;
  final double arrowHeight;

  /// ToolTip's position which will be placed around the target(child) widget
  final PostTipPosition position;

  /// space between content and child widget(from arrow and target widget)
  final double distance;

  /// keepContentInScreen will limit the extent of boundary that content widget can extend.
  /// this will only work in a horizontal space to limit the max width.
  final bool keepContentInScreen;

  /// target widget which content widget is going to describe.
  final Widget? child;

  /// ToolTip overlay widget that internally has CompositedTransformFollower to be placed around
  /// the CompositedTransformTarget widget(child)
  final Widget content;

  final PostTipController? controller;

  @override
  State<PostTip> createState() => _PostTipState();
}

class _PostTipState extends State<PostTip> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Offset _offset = Offset.zero;

  late PostTipController _controller;

  /// Opacity is not because of animation but because of initial location of tooltip
  /// widget that's going to be displayed on the [OverlayEntry] at the beginning,
  /// which it has located top left position of target. after this, it will calculate
  /// the location what users intent to place.
  double _opacity = 0;

  /// the value will be set to true when the ToolTip is rendered with the size of its own.
  bool _isToolTipRendered = false;

  /// visibility flag that will determine the status of tooltip for [PostTip]
  bool _isToolTipVisible = false;

  @override
  void initState() {
    _controller = widget.controller ?? PostTipController();
    _attachController(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addTip();
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PostTip oldWidget) {
    if (oldWidget.position != widget.position) {
      _updateTip();
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

  void _attachController(PostTipController controller) {
    _controller.attach(showTip: _showTip, hideTip: _hideTip);
  }

  Future<void> _showTip() async {
    if (_overlayEntry == null) {
      _addTip();
    } else if (_isToolTipRendered) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  Future<void> _addTip() async {
    if (_overlayEntry != null) {
      return;
    }

    // calculate space to horizontal boundary(either left or right side of screen)
    final bubbleSpace = _calculateSpaceToBoundary(
      context: context,
      position: widget.position,
      arrowHeight: widget.arrowHeight,
      borderWidth: widget.borderWidth,
      distance: widget.distance,
    );
    final space = bubbleSpace.space;
    final targetSize = bubbleSpace.size;

    final overlayEntry = OverlayEntry(builder: (BuildContext context) {
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
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  onEnd: () {
                    // remove tooltip from the overlay when the animation finished.
                    if (!_isToolTipVisible) {
                      _removeTip();
                    }
                  },
                  child: PostTipBubble(
                    position: widget.position,
                    borderWidth: widget.borderWidth,
                    borderRadius: widget.borderRadius,
                    borderColor: widget.borderColor,
                    backgroundColor: widget.backgroundColor,
                    arrowWidth: widget.arrowWidth,
                    arrowHeight: widget.arrowHeight,
                    shadows: widget.shadows,
                    child: MeasureWidgetSize(
                      onSizeChange: (Size? size) {
                        // size of follower widget
                        if (size != null) {
                          final offset = _calculateOffsetByPosition(
                            position: widget.position,
                            targetSize: targetSize,
                            followerSize: size,
                            arrowHeight: widget.arrowHeight,
                            borderWidth: widget.borderWidth,
                            distance: widget.distance,
                          );

                          _offset = offset;
                          _isToolTipRendered = true;
                          _isToolTipVisible = _controller.value == PostTipStatus.shown;
                          _opacity = _isToolTipVisible ? 1 : 0;

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
    _overlayEntry = overlayEntry;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Overlay.maybeOf(context)?.insert(overlayEntry);
    });
  }

  Future<void> _hideTip() async {
    if (_isToolTipRendered && _isToolTipVisible) {
      _opacity = 0.0;
      _isToolTipVisible = false;
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _updateTip() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _showTip();
    }
  }

  void _removeTip() {
    if (_overlayEntry != null) {
      _isToolTipVisible = false;
      _isToolTipRendered = false;
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  /// calculate space to horizontal boundary(either left or right side of screen) and the target size.
  /// Target will be decided by the context.
  /// [context] is the context of the widget that is going to calculate the size of space
  BubbleSpace _calculateSpaceToBoundary({
    required BuildContext context,
    required PostTipPosition position,
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

    return BubbleSpace(space: space, size: targetSize);
    // return (space, targetSize);
  }

  /// calculate the offset of tooltip relative to the top left point of the target
  /// [distance] is the space between arrow and target widget
  Offset _calculateOffsetByPosition({
    required PostTipPosition position,
    required Size targetSize,
    required Size followerSize,
    required double arrowHeight,
    double borderWidth = 0,
    double distance = 0,
  }) {
    switch (position) {
      case PostTipPosition.topStart:
        return Offset(0, -(followerSize.height + borderWidth * 2 + arrowHeight + distance));
      case PostTipPosition.topCenter:
        return Offset(
          -((followerSize.width * 0.5 + borderWidth) - (targetSize.width * 0.5)),
          -(followerSize.height + borderWidth * 2 + arrowHeight + distance),
        );
      case PostTipPosition.topEnd:
        return Offset(
          -((followerSize.width + borderWidth * 2) - targetSize.width),
          -(followerSize.height + borderWidth * 2 + arrowHeight + distance),
        );

      case PostTipPosition.rightStart:
        return Offset(targetSize.width + distance, 0);
      case PostTipPosition.rightCenter:
        return Offset(
          targetSize.width + distance,
          -(followerSize.height * 0.5 + borderWidth) + (targetSize.height * 0.5),
        );
      case PostTipPosition.rightEnd:
        return Offset(
          targetSize.width + distance,
          -(followerSize.height + borderWidth * 2 - targetSize.height),
        );

      case PostTipPosition.bottomStart:
        return Offset(0, targetSize.height + distance);
      case PostTipPosition.bottomCenter:
        return Offset(
          -((followerSize.width * 0.5 + borderWidth) - (targetSize.width * 0.5)),
          targetSize.height + distance,
        );
      case PostTipPosition.bottomEnd:
        return Offset(
          -((followerSize.width + borderWidth * 2) - targetSize.width),
          targetSize.height + distance,
        );

      case PostTipPosition.leftStart:
        return Offset(-(followerSize.width + borderWidth * 2 + arrowHeight + distance), 0);
      case PostTipPosition.leftCenter:
        return Offset(
          -(followerSize.width + borderWidth * 2 + arrowHeight + distance),
          -(followerSize.height * 0.5 + borderWidth) + (targetSize.height * 0.5),
        );
      case PostTipPosition.leftEnd:
        return Offset(
          -(followerSize.width + borderWidth * 2 + arrowHeight + distance),
          -(followerSize.height + borderWidth * 2 - targetSize.height),
        );
    }
  }

  /// calculate horizontal space between target and screen boundary
  double _getHorizontalSpace({
    required PostTipPosition position,
    required double screenWidth,
    required RenderBox targetBox,
    required double arrowHeight,
    required double borderWidth,
    double extraHorizontalSpace = 0,
  }) {
    final spaceMargin = arrowHeight + borderWidth * 2 + extraHorizontalSpace;

    switch (position) {
      case PostTipPosition.topStart:
      case PostTipPosition.bottomStart:
        final target = targetBox.localToGlobal(targetBox.size.topLeft(Offset.zero));
        return screenWidth - target.dx - borderWidth * 2;
      case PostTipPosition.bottomCenter:
      case PostTipPosition.topCenter:
        return screenWidth;
      case PostTipPosition.bottomEnd:
      case PostTipPosition.topEnd:
        final target = targetBox.localToGlobal(targetBox.size.topRight(Offset.zero));
        return target.dx - borderWidth * 2;

      case PostTipPosition.rightStart:
      case PostTipPosition.rightCenter:
      case PostTipPosition.rightEnd:
        final target = targetBox.localToGlobal(targetBox.size.topRight(Offset.zero));
        return screenWidth - target.dx - spaceMargin;

      case PostTipPosition.leftStart:
      case PostTipPosition.leftCenter:
      case PostTipPosition.leftEnd:
        final target = targetBox.localToGlobal(targetBox.size.topLeft(Offset.zero));
        return target.dx - spaceMargin;
    }
  }
}

/// measure widget size when the widget layout
class MeasureWidgetSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onSizeChange;

  const MeasureWidgetSize({
    super.key,
    required this.onSizeChange,
    required Widget super.child,
  });

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

class BubbleSpace {
  final double space;
  final Size size;

  BubbleSpace({required this.space, required this.size});
}
