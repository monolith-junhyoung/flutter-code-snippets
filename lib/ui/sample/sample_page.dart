import 'package:flutter/material.dart';

class SamplePage extends StatelessWidget {
  const SamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sample'),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            // height: 58,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/groc/bar_list_ranking_groc_bar_large.png'),
                fit: BoxFit.fill,
                centerSlice: Rect.fromLTRB(56, 4, 76, 54),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
