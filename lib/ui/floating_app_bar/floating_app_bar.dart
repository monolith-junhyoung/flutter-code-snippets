import 'package:flutter/material.dart';

class FloatingActionBarPage extends StatelessWidget {
  const FloatingActionBarPage({super.key});

  Widget _buildAppBardBackground() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.network(
          'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg',
          fit: BoxFit.cover,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.0, 0.5),
              end: Alignment.center,
              colors: <Color>[
                Color(0x60000000),
                Color(0x00000000),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Floating App Bar';

    return MaterialApp(
      title: title,
      home: Scaffold(
        // No appbar provided to the Scaffold, only a body with a
        body: CustomScrollView(
          slivers: [
            // Add the app bar to the CustomScrollView.
            SliverAppBar(
              // Provide a standard title.
              title: Text(title),
              // Allows the user to reveal the app bar if they begin scrolling
              // back up the list of items.
              floating: true,
              pinned: true,
              snap: false,
              stretch: true,
              // Make the initial height of the SliverAppBar larger than normal.
              expandedHeight: 150,
              toolbarHeight: 60,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const <StretchMode>[
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                centerTitle: true,
                title: const Text('Flight Report'),
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.network('https://via.placeholder.com/350x150', fit: BoxFit.cover),
                  ],
                ),
              ),
            ),
            // Next, create a SliverList
            SliverList(
              // Use a delegate to build items as they're scrolled on screen.
              delegate: SliverChildBuilderDelegate(
                // The builder function returns a ListTile with a title that
                // displays the index of the current item.
                (context, index) => ListTile(title: Text('Item #$index')),
                // Builds 1000 ListTiles
                childCount: 1000,
              ),
            ),
          ],
        ),

        // body: CustomScrollView(
        //   slivers: [
        //     SliverAppBar(
        //       // Provide a standard title.
        //       title: Text(title),
        //       // Allows the user to reveal the app bar if they begin scrolling
        //       // back up the list of items.
        //       floating: true,
        //       pinned: true,
        //       snap: false,
        //       stretch: true,
        //       // Make the initial height of the SliverAppBar larger than normal.
        //       expandedHeight: 250,
        //       flexibleSpace: FlexibleSpaceBar(
        //         stretchModes: const <StretchMode>[
        //           StretchMode.zoomBackground,
        //           StretchMode.blurBackground,
        //           StretchMode.fadeTitle,
        //         ],
        //         centerTitle: true,
        //         title: const Text('Flight Report'),
        //         background: _buildAppBardBackground(),
        //       ),
        //     ),
        //     // Next, create a SliverList
        //     SliverList(
        //       // Use a delegate to build items as they're scrolled on screen.
        //       delegate: SliverChildBuilderDelegate(
        //         // The builder function returns a ListTile with a title that
        //         // displays the index of the current item.
        //         (context, index) => ListTile(title: Text('Item #$index')),
        //         // Builds 1000 ListTiles
        //         childCount: 1000,
        //       ),
        //     ),
        //   ],
        // ),

      ),
    );
  }
}
