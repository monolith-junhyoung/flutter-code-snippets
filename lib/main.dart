import 'package:code_snippets/data/data_repository.dart';
import 'package:code_snippets/ui/easy_refresh/easy_refresh_with_listener_header_page.dart';
import 'package:code_snippets/ui/nested_scroll_header/nested_scroll_header.dart';
import 'package:code_snippets/ui/sample/sample_page.dart';
import 'package:code_snippets/ui/speech_to_text/speech_to_text_page.dart';
import 'package:code_snippets/ui/tooltip/tool_tip_page.dart';
import 'package:flutter/material.dart';

import 'initializer/quick_action_initializer.dart';
import 'ui/easy_refresh/easy_refresh_page.dart';
import 'ui/easy_refresh/easy_refresh_with_app_space_bar_page.dart';
import 'ui/easy_refresh/easy_refresh_with_refresh_indicator_page.dart';
import 'ui/floating_app_bar/floating_app_bar.dart';
import 'ui/video/video_page.dart';

void main() {
  QuickActionInitializer();

  runApp(const CodeSnippetApp());
}

class CodeSnippetApp extends StatelessWidget {
  const CodeSnippetApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      navigatorKey: navigatorKey,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    final quickActionInitializer = QuickActionInitializer();
    quickActionInitializer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Snippets'),
      ),
      body: SafeArea(
          child: ListView.builder(
              itemCount: dataRepository.getPageList().length,
              itemBuilder: (BuildContext context, int index) {
                final PageType pageType = dataRepository.getPageAt(index);
                return ListTile(
                  title: Text(pageType.toString()),
                  onTap: () {
                    switch (pageType) {
                      case PageType.sample:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SamplePage()));
                        break;
                      case PageType.floatingAppBar:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FloatingActionBarPage()));
                        break;
                      case PageType.video:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VideoPage()));
                        break;
                      case PageType.toolTip:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ToolTipPage()));
                        break;
                      case PageType.speechToText:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SpeechToTextPage()));
                        break;
                      case PageType.nestedScrollHeader:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NestedScrollHeaderPage()));
                      case PageType.easyRefresh:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EasyRefreshPage()));
                      case PageType.easyRefreshWithListenerHeader:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EasyRefreshWithListenerHeaderPage()));
                      case PageType.easyRefreshWithRefreshIndicator:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EasyRefreshWithRefreshIndicatorPage()));
                      case PageType.easyRefreshWithAppSpaceBar:
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EasyRefreshWithAppSpaceBarPage()));
                    }

                  },
                );
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
