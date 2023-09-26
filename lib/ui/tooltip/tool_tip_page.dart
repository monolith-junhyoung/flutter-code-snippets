import 'dart:async';

import 'package:code_snippets/ui/tooltip/mono_tool_tip.dart';
import 'package:code_snippets/ui/tooltip/mono_tool_tip_controller.dart';
import 'package:code_snippets/ui/tooltip/mono_tool_tip_bubble.dart';
import 'package:flutter/material.dart';

const positions = <MonoToolTipPosition>[
  MonoToolTipPosition.rightStart,
  MonoToolTipPosition.rightCenter,
  MonoToolTipPosition.rightEnd,
  MonoToolTipPosition.leftStart,
  MonoToolTipPosition.leftCenter,
  MonoToolTipPosition.leftEnd,
  MonoToolTipPosition.topStart,
  MonoToolTipPosition.topCenter,
  MonoToolTipPosition.topEnd,
  MonoToolTipPosition.bottomStart,
  MonoToolTipPosition.bottomCenter,
  MonoToolTipPosition.bottomEnd,
];

class ToolTipPage extends StatefulWidget {
  const ToolTipPage({super.key});

  @override
  State<ToolTipPage> createState() => _ToolTipPageState();
}

class _ToolTipPageState extends State<ToolTipPage> {
  final _controller = MonoToolTipController(value: ToolTipStatus.shown);
  MonoToolTipPosition _position = MonoToolTipPosition.rightStart;

  // int _index = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   setState(() {
    //     _index = (_index+1) % positions.length;
    //     _position = positions[_index];
    //     print('timer is running with index: $_index');
    //   });
    // });

    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   if (_controller.value == ToolTipStatus.hidden) {
    //     _controller.show();
    //   } else {
    //     _controller.hide();
    //   }
    // });
  }

  @override
  void dispose() {
    // _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToolTip'),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: MonoToolTip(
                // position: ToolTipPosition.rightStart,
                // position: ToolTipPosition.rightCenter,
                // position: ToolTipPosition.rightEnd,
                // position: ToolTipPosition.leftStart,
                // position: ToolTipPosition.leftCenter,
                // position: ToolTipPosition.leftEnd,
                // position: ToolTipPosition.topStart,
                // position: ToolTipPosition.topCenter,
                // position: ToolTipPosition.topEnd,
                // position: ToolTipPosition.bottomStart,
                // position: ToolTipPosition.bottomCenter,
                controller: _controller,
                position: _position,
                borderWidth: 4,
                borderColor: Colors.blueGrey,
                backgroundColor: Colors.pink,
                arrowHeight: 10,
                // target widget
                child: Container(
                  width: 40,
                  height: 60,
                  color: Colors.blue,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () {
                setState(() {
                  if (_controller.value == ToolTipStatus.hidden) {
                    _controller.show();
                  } else {
                    _controller.hide();
                  }
                });
              },
              child: Text('Toggle'),
            ),
          ],
        ),
      ),
    );
  }
}
