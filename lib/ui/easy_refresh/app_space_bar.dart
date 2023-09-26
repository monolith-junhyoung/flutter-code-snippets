import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// FlexibleSpaceBar와 비슷한 역활을 하지만 위로 스크롤할 때에 background를 transform 할 수 있다
/// Similar to FlexibleSpaceBar but this appbar additionally can transform the widget when it scrolls up.
/// FlexibleSpaceBar also does not support an animation effect when scrolling down to the bigger sized of the toolbar
/// while AppSpaceBar would zoom in
class AppSpaceBar extends StatefulWidget {
  const AppSpaceBar({
    super.key,
    this.title,
    this.titlePadding,
    this.centerTitle,
    this.background,
    this.appBarHeight,
    this.stretchModes = const <StretchMode>[StretchMode.zoomBackground],
    this.expandedTitleScale = 1.5,
  });

  /// The primary contents of the flexible space bar when expanded.
  ///
  /// Typically a [Text] widget.
  final Widget? title;

  /// Defines how far the [title] is inset from either the widget's
  /// bottom-left or its center.
  ///
  /// Typically this property is used to adjust how far the title is
  /// inset from the bottom-left and it is specified along with
  /// [centerTitle] false.
  ///
  /// By default the value of this property is
  /// `EdgeInsetsDirectional.only(start: 72, bottom: 16)` if the title is
  /// not centered, `EdgeInsetsDirectional.only(start: 0, bottom: 16)` otherwise.
  final EdgeInsetsGeometry? titlePadding;

  /// Whether the title should be centered.
  ///
  /// By default this property is true if the current target platform
  /// is [TargetPlatform.iOS] or [TargetPlatform.macOS], false otherwise.
  final bool? centerTitle;

  /// Shown behind the [title] when expanded.
  ///
  /// Typically an [Image] widget with [Image.fit] set to [BoxFit.cover].
  final Widget? background;

  final double? appBarHeight;

  final List<StretchMode> stretchModes;

  /// Defines how much the title is scaled when the FlexibleSpaceBar is expanded
  /// due to the user scrolling downwards. The title is scaled uniformly on the
  /// x and y axes while maintaining its bottom-left position (bottom-center if
  /// [centerTitle] is true).
  ///
  /// Defaults to 1.5 and must be greater than 1.
  final double expandedTitleScale;

  @override
  State<AppSpaceBar> createState() => _AppSpaceBarState();
}

class _AppSpaceBarState extends State<AppSpaceBar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      final FlexibleSpaceBarSettings settings = context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>()!;

      final List<Widget> children = <Widget>[];

      final double deltaExtent = settings.maxExtent - settings.minExtent;
      final currentSpaceExtent = constraints.maxHeight - settings.minExtent;

      // 0.0 -> Expanded
      // 1.0 -> Collapsed to toolbar
      final double t = clampDouble(1.0 - currentSpaceExtent / deltaExtent, 0.0, 1.0);

      // background
      if (widget.background != null) {
        final toolbarHeight = widget.appBarHeight ?? kToolbarHeight;
        final double fadeStart = max(0.0, 1.0 - toolbarHeight / deltaExtent);
        const double fadeEnd = 1.0;
        assert(fadeStart <= fadeEnd);
        // If the min and max extent are the same, the app bar cannot collapse
        // and the content should be visible, so opacity = 1.
        final double opacity =
            settings.maxExtent == settings.minExtent ? 1.0 : 1.0 - Interval(fadeStart, fadeEnd).transform(t);

        /// settings.maxExtent: fixed max height of app bar
        /// constraints.maxHeight: variable value of app bar's maximum height, this will be increased more than
        ///  settings.maxExtent when it's in stretch mode.
        print('AppSpaceBar> t: $t, settings.currentExtent: ${settings.currentExtent}, opacity: $opacity, '
            '\nconstraints.maxHeight : ${constraints.maxHeight},'
            '\nsettings.minExtent : ${settings.minExtent},'
            '\nsettings.maxExtent: ${settings.maxExtent}');

        double height = settings.maxExtent;
        if (constraints.maxHeight > height) {
          height = constraints.maxHeight;
        }

        // Zoom
        late double scaleFactor;
        late double dy;
        if (constraints.maxHeight < settings.maxExtent) {
          // when scaling down
          scaleFactor = currentSpaceExtent / deltaExtent;
          dy = 0;
        } else {
          // when scaling up
          scaleFactor = currentSpaceExtent / deltaExtent;
          dy = currentSpaceExtent;
        }

        final transform = Matrix4.identity()
          ..translate(0.0, -dy)
          ..scale(scaleFactor, scaleFactor, 1.0)
          ..translate(0.0, dy);

        children.add(
          Positioned(
            top: -(settings.maxExtent - settings.currentExtent),
            left: 0,
            right: 0,
            height: height,
            child: SpaceOpacityWidget(
              // IOS is relying on this semantics node to correctly traverse
              // through the app bar when it is collapsed.
              alwaysIncludeSemantics: true,
              opacity: opacity,
              child: Transform(alignment: Alignment.bottomCenter, transform: transform, child: widget.background),
            ),
          ),
        );

        // Blur
        if (widget.stretchModes.contains(StretchMode.blurBackground) && constraints.maxHeight > settings.maxExtent) {
          final double blurAmount = (constraints.maxHeight - settings.maxExtent) / 10;
          children.add(
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
                child: Container(color: Colors.transparent),
              ),
            ),
          );
        }
      }

      // title
      if (widget.title != null) {
        final ThemeData theme = Theme.of(context);

        Widget? title;
        switch (theme.platform) {
          case TargetPlatform.iOS:
          case TargetPlatform.macOS:
            title = widget.title;
          case TargetPlatform.android:
          case TargetPlatform.fuchsia:
          case TargetPlatform.linux:
          case TargetPlatform.windows:
            title = Semantics(
              namesRoute: true,
              child: widget.title,
            );
        }

        // StretchMode.fadeTitle
        if (widget.stretchModes.contains(StretchMode.fadeTitle) &&
            constraints.maxHeight > settings.maxExtent) {
          final double stretchOpacity = 1 -
              clampDouble(
                  (constraints.maxHeight - settings.maxExtent) / 100,
                  0.0,
                  1.0);
          title = Opacity(
            opacity: stretchOpacity,
            child: title,
          );
        }

        final double opacity = settings.toolbarOpacity;
        if (opacity > 0.0) {
          TextStyle titleStyle = theme.primaryTextTheme.titleLarge!;
          titleStyle = titleStyle.copyWith(
            color: titleStyle.color!.withOpacity(opacity),
          );
          final bool effectiveCenterTitle = _getEffectiveCenterTitle(theme);
          final EdgeInsetsGeometry padding = widget.titlePadding ??
              EdgeInsetsDirectional.only(
                start: effectiveCenterTitle ? 0.0 : 72.0,
                bottom: 16.0,
              );
          final double scaleValue = Tween<double>(begin: widget.expandedTitleScale, end: 1.0).transform(t);
          final Matrix4 scaleTransform = Matrix4.identity()
            ..scale(scaleValue, scaleValue, 1.0);
          final Alignment titleAlignment = _getTitleAlignment(effectiveCenterTitle);
          children.add(Container(
            padding: padding,
            child: Transform(
              alignment: titleAlignment,
              transform: scaleTransform,
              child: Align(
                alignment: titleAlignment,
                child: DefaultTextStyle(
                  style: titleStyle,
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return Container(
                        width: constraints.maxWidth / scaleValue,
                        alignment: titleAlignment,
                        child: title,
                      );
                    },
                  ),
                ),
              ),
            ),
          ));
        }
      }

      return ClipRect(child: Stack(children: children));
    });
  }

  bool _getEffectiveCenterTitle(ThemeData theme) {
    if (widget.centerTitle != null) {
      return widget.centerTitle!;
    }
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
    }
  }

  Alignment _getTitleAlignment(bool effectiveCenterTitle) {
    if (effectiveCenterTitle) {
      return Alignment.bottomCenter;
    }
    final TextDirection textDirection = Directionality.of(context);
    switch (textDirection) {
      case TextDirection.rtl:
        return Alignment.bottomRight;
      case TextDirection.ltr:
        return Alignment.bottomLeft;
    }
  }
}

class SpaceOpacityWidget extends SingleChildRenderObjectWidget {
  const SpaceOpacityWidget({
    super.key,
    required super.child,
    required this.opacity,
    required this.alwaysIncludeSemantics,
  });

  final double opacity;
  final bool alwaysIncludeSemantics;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSpaceOpacity(opacity: opacity, alwaysIncludeSemantics: alwaysIncludeSemantics);
  }

  @override
  void updateRenderObject(BuildContext context, covariant RenderSpaceOpacity renderObject) {
    renderObject
      ..alwaysIncludeSemantics = alwaysIncludeSemantics
      ..opacity = opacity;
  }
}

class RenderSpaceOpacity extends RenderOpacity {
  RenderSpaceOpacity({super.opacity, super.alwaysIncludeSemantics});

  @override
  bool get isRepaintBoundary => false;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) {
      return;
    }
    if (opacity == 0) {
      layer = null;
      return;
    }
    assert(needsCompositing);
    layer = context.pushOpacity(offset, (opacity * 255).round(), super.paint, oldLayer: layer as OpacityLayer?);
    assert(() {
      layer!.debugCreator = debugCreator;
      return true;
    }());
  }
}
