import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';

import 'app_space_bar.dart';
import 'easy_refresh_page.dart';

class EasyRefreshWithRefreshIndicatorPage extends StatefulWidget {
  const EasyRefreshWithRefreshIndicatorPage({super.key});

  @override
  State<EasyRefreshWithRefreshIndicatorPage> createState() => _EasyRefreshWithRefreshIndicatorPageState();
}

class _EasyRefreshWithRefreshIndicatorPageState extends State<EasyRefreshWithRefreshIndicatorPage> {
  late EasyRefreshController _controller;
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  int _count = 20;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    _scrollController.addListener(() {
      const offset = refreshExpandedHeaderHeight - kToolbarHeight;
      // print('header height: ${_scrollController.offset}, offset(fixed); $offset');
      if (_scrollController.offset >= offset && !_isCollapsed) {
        setState(() {
          _isCollapsed = true;
        });
      } else if (_scrollController.offset < offset && _isCollapsed) {
        setState(() {
          _isCollapsed = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = topPadding + kToolbarHeight;
    print('building: topPadding: $topPadding, kToolbarHeight: $kToolbarHeight, _isCollapsed: $_isCollapsed');

    return Scaffold(
      body: Stack(
        children: [
          /// container that places under the app bar
          Container(
            width: double.infinity,
            height: kToolbarHeight,
            margin: EdgeInsets.only(top: topPadding),
            color: Colors.pink,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Container at Top-Left Corner',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// Refresh widget
          RefreshIndicator(
            edgeOffset: headerHeight,
            displacement: 40,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              if (mounted) {
                setState(() {
                  _count = 20;
                });
                _controller.finishRefresh();
                _controller.resetFooter();
              }
            },
            child: EasyRefresh(
              controller: _controller,
              onLoad: () async {
                print('onLoad');
                await Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _count += 10;
                    });
                    _controller.finishLoad(_count > 40 ? IndicatorResult.noMore : IndicatorResult.success);
                  }
                });
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[
                  // AppBar
                  SliverAppBar(
                    pinned: true,
                    // snap: true,
                    // floating: true,
                    stretch: true,
                    expandedHeight: refreshExpandedHeaderHeight,
                    backgroundColor: Colors.transparent,
                    // shadowColor: Colors.transparent,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      stretchModes: const <StretchMode>[
                        StretchMode.zoomBackground,
                        StretchMode.blurBackground,
                      ],
                      background: Container(
                        color: Colors.yellow.withAlpha(125),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: headerHeight),
                            Container(
                              color: Colors.blue.withAlpha(125),
                              width: double.infinity,
                              child: Image.network(
                                'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
                                height: refreshExpandedHeaderHeight - kToolbarHeight,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // List
                  SliverPadding(
                    padding: const EdgeInsets.all(8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return const ListItem();
                        },
                        childCount: _count,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
