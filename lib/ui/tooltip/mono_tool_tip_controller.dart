import 'package:flutter/material.dart';

enum ToolTipStatus { shown, hidden }

typedef ShowToolTip = Future<void> Function();
typedef HideToolTip = Future<void> Function();

class MonoToolTipController extends ValueNotifier<ToolTipStatus> {
  late ShowToolTip showToolTip;
  late HideToolTip hideToolTip;

  MonoToolTipController({ToolTipStatus? value}) : super(value ?? ToolTipStatus.hidden) {
    showToolTip = defaultShowToolTip;
    hideToolTip = defaultHideToolTip;
  }

  static Future<void> defaultShowToolTip() {
    throw StateError('This controller has not been attached to a tooltip yet.');
  }

  static Future<void> defaultHideToolTip() {
    throw StateError('This controller has not been attached to a tooltip yet.');
  }

  @mustCallSuper
  void attach({
    required ShowToolTip showToolTip,
    required HideToolTip hideToolTip,
  }) {
    this.showToolTip = showToolTip;
    this.hideToolTip = hideToolTip;
  }

  bool get isShown => value == ToolTipStatus.shown;

  Future<void> show() async {
    value = ToolTipStatus.shown;
    await showToolTip();
    notifyListeners();
  }

  Future<void> hide() async {
    value = ToolTipStatus.hidden;
    await hideToolTip();
    notifyListeners();
  }

  void notify(ToolTipStatus status) {
    if (value != status) {
      value = status;
      notifyListeners();
    }
  }
}
