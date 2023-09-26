import 'dart:math';

import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'easy_refresh_page.dart';

class EasyRefreshWithListenerHeaderPage extends StatefulWidget {
  const EasyRefreshWithListenerHeaderPage({super.key});

  @override
  State<EasyRefreshWithListenerHeaderPage> createState() => _EasyRefreshWithListenerHeaderPageState();
}

class _EasyRefreshWithListenerHeaderPageState extends State<EasyRefreshWithListenerHeaderPage> {
  final _listenable = IndicatorStateListenable();
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
          EasyRefresh(
            controller: _controller,
            header: ListenerHeader(
              triggerOffset: 80,
              listenable: _listenable,
              safeArea: false,
            ),
            onRefresh: () async {
              print('onRefresh');
              await Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    _count = 20;
                  });
                  _controller.finishRefresh();
                  _controller.resetFooter();
                }
              });
            },
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
                  // floating: true,
                  pinned: true,
                  snap: false,
                  expandedHeight: refreshExpandedHeaderHeight,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    stretchModes: const <StretchMode>[],
                    background: Container(
                      color: Colors.yellow.withAlpha(125),
                      child: Column(
                        // fit: StackFit.expand,
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

          /// header loading indicator
          Positioned(
            top: headerHeight,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.topCenter,
              child: TopRefreshIndicatorContainer(
                listenable: _listenable,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopRefreshIndicatorContainer extends StatelessWidget {
  const TopRefreshIndicatorContainer({
    super.key,
    required this.listenable,
  });

  final ValueListenable<IndicatorState?> listenable;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<IndicatorState?>(
      valueListenable: listenable,
      builder: (BuildContext context, IndicatorState? state, _) {
        if (state == null) {
          return const SizedBox.shrink();
        }

        print('Refresh> indicator state: ${state.mode}');

        // build value
        final mode = state.mode;
        final offset = state.offset;
        final actualTriggerOffset = state.actualTriggerOffset;
        double? value;
        if (mode == IndicatorMode.inactive) {
          value = 0;
        } else if (mode == IndicatorMode.drag || mode == IndicatorMode.armed) {
          value = min(offset / actualTriggerOffset, 1) * 0.75;
        } else if (mode == IndicatorMode.ready || mode == IndicatorMode.processing) {
          value == null;
        } else {
          value = 1;
        }

        // build indicator
        Widget indicator;
        if (value != null && value < 0.1) {
          indicator = const SizedBox();
        } else if (value == 1) {
          indicator = Icon(
            Icons.done,
            color: Theme.of(context).colorScheme.primary,
          );
        } else {
          indicator = RefreshProgressIndicator(
            value: value,
          );
        }

        return SizedBox(
          width: 56,
          height: 56,
          child: Transform(
            transform: Matrix4.identity()..translate(0.0, min(offset, 40)),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              reverseDuration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: indicator,
            ),
          ),
        );
      },
    );
  }
}
