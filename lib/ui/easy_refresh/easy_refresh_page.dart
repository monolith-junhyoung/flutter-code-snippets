import 'package:easy_refresh/easy_refresh.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';

const refreshExpandedHeaderHeight = 262.0;

/// EasyRefresh를 이용한 리프레시 및 페이징 처리 예제,
///
/// dependencies:
///  - easy_refresh
///  - extended_nested_scroll_view
class EasyRefreshPage extends StatefulWidget {
  const EasyRefreshPage({super.key});

  @override
  State<EasyRefreshPage> createState() => _EasyRefreshPageState();
}

class _EasyRefreshPageState extends State<EasyRefreshPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;
  int _listCount = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      const offset = refreshExpandedHeaderHeight - kToolbarHeight;
      // print('header height: ${_scrollController.offset}, offset; $offset');
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
        children: <Widget>[
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
          ExtendedNestedScrollView(
            controller: _scrollController,
            onlyOneScrollInBody: true,
            pinnedHeaderSliverHeightBuilder: () => headerHeight,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  snap: false,
                  expandedHeight: refreshExpandedHeaderHeight,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    // title: Text(
                    //   'EasyRefreshPage',
                    //   style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
                    // ),
                    // titlePadding: EdgeInsets.zero,
                    // centerTitle: false,
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
                                fit: BoxFit.cover,
                              )),
                          // const DecoratedBox(
                          //   decoration: BoxDecoration(
                          //     gradient: LinearGradient(
                          //       begin: Alignment(0.0, 0.5),
                          //       end: Alignment.center,
                          //       colors: <Color>[
                          //         Color(0x60000000),
                          //         Color(0x00000000),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                )
              ];
            },
            body: Column(
              children: <Widget>[
                Expanded(
                  child: EasyRefresh(
                    header:
                        const ClassicHeader(dragText: 'Pull to refresh', readyText: 'Refreshing...', safeArea: false),
                    footer: const ClassicFooter(
                      position: IndicatorPosition.locator,
                      dragText: 'Pull to load',
                      processedText: 'Succeeded',
                    ),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(8),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return const ListItem();
                              },
                              childCount: _listCount,
                            ),
                          ),
                        ),
                        const FooterLocator.sliver(),
                      ],
                    ),
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) {
                          setState(() {
                            _listCount = 20;
                          });
                        }
                      });
                    },
                    onLoad: () async {
                      await Future.delayed(const Duration(seconds: 1), () {
                        if (mounted) {
                          setState(() {
                            _listCount += 10;
                          });
                        }
                      });
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  /// Scrollable direction.
  final Axis direction;

  const ListItem({
    Key? key,
    this.direction = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final backgroundColor = themeData.colorScheme.surfaceVariant;
    final foregroundColor = themeData.colorScheme.surface;
    if (direction == Axis.vertical) {
      return Card(
        elevation: 3,
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                height: 80,
                width: 80,
                color: foregroundColor,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, right: 24),
                      height: 12,
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 200),
                      color: foregroundColor,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      height: 12,
                      width: 80,
                      color: foregroundColor,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      height: 12,
                      width: 80,
                      color: foregroundColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      elevation: 0,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              height: 80,
              width: 80,
              color: foregroundColor,
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 8, bottom: 24),
                    width: 12,
                    height: double.infinity,
                    constraints: const BoxConstraints(
                      maxHeight: 200,
                    ),
                    color: foregroundColor,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 16),
                    width: 12,
                    height: 80,
                    color: foregroundColor,
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 12,
                    height: 80,
                    color: foregroundColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
