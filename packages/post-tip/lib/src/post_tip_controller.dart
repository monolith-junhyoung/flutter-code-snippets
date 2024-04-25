import 'package:flutter/material.dart';

enum PostTipStatus { shown, hidden }

typedef ShowPostTipCallback = Future<void> Function();
typedef HidePostTipCallback = Future<void> Function();

class PostTipController extends ValueNotifier<PostTipStatus> {
  ShowPostTipCallback? showTip;
  HidePostTipCallback? hideTip;

  PostTipController({PostTipStatus? value}) : super(value ?? PostTipStatus.shown) {
    showTip = null;
    hideTip = null;
  }

  void attach({ShowPostTipCallback? showTip, HidePostTipCallback? hideTip}) {
    this.showTip = showTip;
    this.hideTip = hideTip;
  }

  bool get isShown => value == PostTipStatus.shown;

  Future<void> show() async {
    value = PostTipStatus.shown;
    await showTip?.call();
    notifyListeners();
  }

  Future<void> hide() async {
    value = PostTipStatus.hidden;
    await hideTip?.call();
    notifyListeners();
  }

  void notify(PostTipStatus status) {
    if (value != status) {
      value = status;
      notifyListeners();
    }
  }
}
