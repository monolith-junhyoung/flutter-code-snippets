import 'dart:math' as math;
import 'package:flutter/material.dart';

const d2r = math.pi / 180.0;

double radians(double degrees) => degrees * d2r;

enum MonoToolTipPosition {
  topStart,
  topCenter,
  topEnd,
  rightStart,
  rightCenter,
  rightEnd,
  bottomStart,
  bottomCenter,
  bottomEnd,
  leftStart,
  leftCenter,
  leftEnd,
}

/// ToolTip widget
class MonoToolTipBubble extends StatelessWidget {
  const MonoToolTipBubble({
    required this.position,
    this.borderWidth = 0.0,
    this.borderRadius = 6.0,
    this.borderColor,
    this.backgroundColor,
    this.shadows,
    this.arrowWidth = 16.0,
    this.arrowHeight = 10.0,
    this.child,
    Key? key,
  })  : assert(borderWidth >= 0),
        assert((borderRadius == null) || (borderRadius >= 0)),
        super(key: key);

  final double borderWidth;
  final double? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final double arrowWidth;
  final double arrowHeight;
  final MonoToolTipPosition position;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _computeMarginByPosition(position, arrowHeight),
      padding: const EdgeInsets.all(0),
      decoration: ShapeDecoration(
        shadows: shadows,
        shape: ToolTipShape(
          position: position,
          borderWidth: borderWidth,
          borderRadius: borderRadius,
          borderColor: borderColor,
          backgroundColor: backgroundColor,
          arrowWidth: arrowWidth,
          arrowHeight: arrowHeight,
        ),
      ),
      child: child,
    );
  }

  EdgeInsets _computeMarginByPosition(MonoToolTipPosition position, double value) {
    switch (position) {
      case MonoToolTipPosition.topStart:
      case MonoToolTipPosition.topCenter:
      case MonoToolTipPosition.topEnd:
        return EdgeInsets.only(bottom: value);
      case MonoToolTipPosition.rightStart:
      case MonoToolTipPosition.rightCenter:
      case MonoToolTipPosition.rightEnd:
        return EdgeInsets.only(left: value);
      case MonoToolTipPosition.bottomStart:
      case MonoToolTipPosition.bottomCenter:
      case MonoToolTipPosition.bottomEnd:
        return EdgeInsets.only(top: value);
      case MonoToolTipPosition.leftStart:
      case MonoToolTipPosition.leftCenter:
      case MonoToolTipPosition.leftEnd:
        return EdgeInsets.only(right: value);
    }
  }
}

/// ToolTip shape
class ToolTipShape extends ShapeBorder {
  final double borderWidth;
  final double? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final double arrowWidth;
  final double arrowHeight;
  final MonoToolTipPosition position;

  static const Color defaultBorderColor = Colors.blue;
  static const Color defaultContentColor = Colors.white;

  const ToolTipShape({
    required this.position,
    this.borderWidth = 0,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.arrowWidth = 0,
    this.arrowHeight = 0,
  })  : assert(borderWidth >= 0),
        assert((borderRadius == null) || (borderRadius >= 0));

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderWidth);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    // if (borderRadius != null) {
    //   final radius = BorderRadius.all(Radius.circular(borderRadius!));
    //   final RRect borderRect = radius.resolve(textDirection).toRRect(rect);
    //   final RRect adjustedRect = borderRect.deflate(borderWidth);
    //   return Path()..addRRect(adjustedRect);
    // } else {
    //   return Path()..addRect(rect.deflate(borderWidth));
    // }

    return getOuterPath(rect, textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final radius = borderRadius != null ? borderRadius! : 0.0;
    final r = BorderRadius.all(Radius.circular(radius));
    final RRect region = r.resolve(textDirection).toRRect(rect.inflate(borderWidth));

    return _computeBubbleArea(region, radius, position, arrowWidth, arrowHeight);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final radius = borderRadius != null ? borderRadius! : 0.0;
    final r = BorderRadius.all(Radius.circular(radius));
    final RRect region = r.resolve(textDirection).toRRect(rect);

    _renderBubble(
      canvas,
      region,
      radius,
      borderPainter: Paint()
        ..color = borderColor ?? defaultBorderColor
        ..style = PaintingStyle.fill,
      contentPainter: Paint()
        ..color = backgroundColor ?? defaultContentColor
        ..style = PaintingStyle.fill,
      position: position,
      arrowWidth: arrowWidth,
      arrowHeight: arrowHeight,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return ToolTipShape(
      position: position,
      borderWidth: borderWidth,
      borderRadius: borderRadius,
    );
  }

  void _renderBubble(
    Canvas canvas,
    RRect rect,
    double radius, {
    required Paint borderPainter,
    required Paint contentPainter,
    required MonoToolTipPosition position,
    required arrowWidth,
    required arrowHeight,
  }) {
    final inner = rect.deflate(borderWidth);
    final ir = radius - borderWidth;
    final innerRadius = ir < 0 ? .0 : ir;

    final arrowRatio = arrowHeight / arrowWidth;

    final innerArea = _computeBubbleArea(
      inner,
      innerRadius,
      position,
      arrowWidth - borderWidth,
      arrowHeight - borderWidth * arrowRatio,
    );

    if (borderWidth > 0.0) {
      final outerArea = _computeBubbleArea(rect, radius, position, arrowWidth, arrowHeight);
      final borderArea = Path.combine(PathOperation.difference, outerArea, innerArea);
      canvas.drawPath(borderArea, borderPainter);
    }
    canvas.drawPath(innerArea, contentPainter);
  }

  Path _computeBubbleArea(
    RRect region,
    double radius,
    MonoToolTipPosition position,
    double arrowWidth,
    double arrowHeight,
  ) {
    final path = Path();

    ///-- starting point: top left corner --
    if (position == MonoToolTipPosition.rightStart) {
      _addArrowCornerAtTopOfLeftSide(region, path, arrowWidth, arrowHeight);
    } else if (position == MonoToolTipPosition.bottomStart) {
      _addArrowCornerAtLeftOfTopSide(region, path, arrowWidth, arrowHeight);
    } else {
      _addRoundCornerAtTopLeft(region, path, radius);
    }

    ///-- top center --
    if (position == MonoToolTipPosition.bottomCenter) {
      _addArrowAtTopCenter(region, path, arrowWidth, arrowHeight);
    }

    ///-- top right corner --
    if (position == MonoToolTipPosition.bottomEnd) {
      _addArrowCornerAtRightOfTopSide(region, path, arrowWidth, arrowHeight);
    } else if (position == MonoToolTipPosition.leftStart) {
      _addArrowCornerAtTopOfRightSide(region, path, arrowWidth, arrowHeight);
    } else {
      _addRoundCornerAtTopRight(region, path, radius);
    }

    ///-- right center --
    if (position == MonoToolTipPosition.leftCenter) {
      _addArrowAtRightCenter(region, path, arrowWidth, arrowHeight);
    }

    ///-- bottom right corner --
    if (position == MonoToolTipPosition.leftEnd) {
      _addArrowCornerAtBottomOfRightSide(region, path, arrowWidth, arrowHeight);
    } else if (position == MonoToolTipPosition.topEnd) {
      _addArrowCornerAtRightOfBottomSide(region, path, arrowWidth, arrowHeight);
    } else {
      _addRoundCornerAtBottomRight(region, path, radius);
    }

    ///-- bottom center --
    if (position == MonoToolTipPosition.topCenter) {
      _addArrowAtBottomCenter(region, path, arrowWidth, arrowHeight);
    }

    ///-- bottom left corner --
    if (position == MonoToolTipPosition.topStart) {
      _addArrowCornerAtLeftOfBottomSide(region, path, arrowWidth, arrowHeight);
    } else if (position == MonoToolTipPosition.rightEnd) {
      _addArrowCornerAtBottomOfLeftSide(region, path, arrowWidth, arrowHeight);
    } else {
      _addRoundCornerAtBottomLeft(region, path, radius);
    }

    ///-- left center --
    if (position == MonoToolTipPosition.rightCenter) {
      _addArrowAtLeftCenter(region, path, arrowWidth, arrowHeight);
    }

    path.close();

    return path;
  }

  ///-- top side --
  /// starting point
  void _addArrowCornerAtLeftOfTopSide(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final left = bound.left;
    final top = bound.top;

    path.moveTo(left, top);

    path.lineTo(left, top - arrowHeight);
    path.lineTo(left + arrowWidth, top);
  }

  void _addArrowAtTopCenter(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final top = bound.top;
    final center = bound.center;

    // bottom line to bottom center
    final halfArrowWidth = arrowWidth * 0.5;
    path.lineTo(center.dx - halfArrowWidth, top);

    // arrow
    path.lineTo(center.dx, top - arrowHeight);
    path.lineTo(center.dx + halfArrowWidth, top);
  }

  void _addArrowCornerAtRightOfTopSide(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final top = bound.top;
    final right = bound.right;

    path.lineTo(right - arrowWidth, top);

    // arrow
    path.lineTo(right, top - arrowHeight);
    path.lineTo(right, top);
  }

  void _addRoundCornerAtTopRight(RRect bound, Path path, double radius) {
    final right = bound.right;
    final top = bound.top;

    path.lineTo(right - radius, top);

    // top right round corner
    path.arcTo(
      Rect.fromCircle(center: Offset(right - radius, top + radius), radius: radius),
      radians(-90),
      radians(90),
      false,
    );
  }

  ///-- right side --
  void _addArrowCornerAtTopOfRightSide(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final top = bound.top;
    final right = bound.right;

    path.lineTo(right + arrowHeight, top);
    path.lineTo(right, top + arrowWidth);
  }

  void _addArrowAtRightCenter(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final right = bound.right;
    final center = bound.center;
    final halfArrowWidth = arrowWidth * 0.5;

    // right line to right center
    path.lineTo(right, center.dy - halfArrowWidth);

    // arrow
    path.lineTo(right + arrowHeight, center.dy);
    path.lineTo(right, center.dy + halfArrowWidth);
  }

  void _addArrowCornerAtBottomOfRightSide(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final right = bound.right;
    final bottom = bound.bottom;

    path.lineTo(right, bottom - arrowWidth);

    // arrow
    path.lineTo(right + arrowHeight, bottom);
    path.lineTo(right, bottom);
  }

  void _addRoundCornerAtBottomRight(RRect bound, Path path, double radius) {
    final right = bound.right;
    final bottom = bound.bottom;

    path.lineTo(right, bottom - radius);

    path.arcTo(
      Rect.fromCircle(center: Offset(right - radius, bottom - radius), radius: radius),
      radians(0),
      radians(90),
      false,
    );
  }

  ///-- bottom side --

  void _addArrowCornerAtRightOfBottomSide(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final right = bound.right;
    final bottom = bound.bottom;

    path.lineTo(right, bottom + arrowHeight);
    path.lineTo(right - arrowWidth, bottom);
  }

  void _addArrowAtBottomCenter(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final bottom = bound.bottom;
    final center = bound.center;

    // bottom line to bottom center
    final halfArrowWidth = arrowWidth * 0.5;
    path.lineTo(center.dx + halfArrowWidth, bottom);

    // arrow
    path.lineTo(center.dx, bottom + arrowHeight);
    path.lineTo(center.dx - halfArrowWidth, bottom);
  }

  /// [radiusWeight] weight for the edge of the arrow in the bottom left corner, ranged from 0 to 1 double value [0~1]
  void _addArrowCornerAtLeftOfBottomSide(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final left = bound.left;
    final bottom = bound.bottom;

    // bottom line to start point of arrow
    path.lineTo(left + arrowWidth, bottom);

    path.lineTo(left, bottom + arrowHeight);
    path.lineTo(left, bottom);
  }

  void _addRoundCornerAtBottomLeft(RRect bound, Path path, double radius) {
    final left = bound.left;
    final bottom = bound.bottom;

    // bottom line
    path.lineTo(left + radius, bottom);

    path.arcTo(
      Rect.fromCircle(center: Offset(left + radius, bottom - radius), radius: radius),
      radians(90),
      radians(90),
      false,
    );
  }

  ///-- left side --
  /// starting point
  void _addArrowCornerAtTopOfLeftSide(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final left = bound.left;
    final top = bound.top;

    path.moveTo(left, top + arrowWidth);

    path.lineTo(left - arrowHeight, top);
    path.lineTo(left, top);
  }

  void _addArrowAtLeftCenter(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final left = bound.left;
    final center = bound.center;
    final halfArrowWidth = arrowWidth * 0.5;

    // right line to right center
    path.lineTo(left, center.dy + halfArrowWidth);

    // arrow
    path.lineTo(left - arrowHeight, center.dy);
    path.lineTo(left, center.dy - halfArrowWidth);
  }

  void _addArrowCornerAtBottomOfLeftSide(RRect bound, Path path, double arrowWidth, double arrowHeight) {
    final left = bound.left;
    final bottom = bound.bottom;

    path.lineTo(left - arrowHeight, bottom);
    path.lineTo(left, bottom - arrowWidth);
  }

  /// starting point
  void _addRoundCornerAtTopLeft(RRect bound, Path path, double radius) {
    final left = bound.left;
    final top = bound.top;

    path.moveTo(left, top + radius);

    path.arcTo(
      Rect.fromCircle(center: Offset(left + radius, top + radius), radius: radius),
      radians(180),
      radians(90),
      false,
    );
  }
}
