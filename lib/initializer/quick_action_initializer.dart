import 'dart:developer';

import 'package:code_snippets/main.dart';
import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

import '../ui/sample/sample_page.dart';

/// QuickAction: https://pub.dev/packages/quick_actions
///  ref) https://medium.flutterdevs.com/quick-action-in-flutter-cf5e516bd2fe
class QuickActionInitializer {

  void call() {
    const QuickActions quickActions = QuickActions();
    quickActions.initialize((String shortcutType) {
      if (shortcutType == "action_main") {
        log('press quick action for action_main');
        BuildContext? context = CodeSnippetApp.navigatorKey.currentContext;
        if (context != null) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const SamplePage()
          ));
        }
      }
    });

    quickActions.setShortcutItems(<ShortcutItem>[
      const ShortcutItem(
          type: 'action_main',
          localizedTitle: '메인 액션',
      )
    ]);
  }
}
