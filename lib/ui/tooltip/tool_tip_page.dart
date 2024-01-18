import 'package:code_snippets/ui/tooltip/mono_tool_tip.dart';
import 'package:code_snippets/ui/tooltip/mono_tool_tip_bubble.dart';
import 'package:code_snippets/ui/tooltip/mono_tool_tip_controller.dart';
import 'package:flutter/material.dart';

const positions = <MonoToolTipPosition>[
  MonoToolTipPosition.leftStart,
  MonoToolTipPosition.leftCenter,
  MonoToolTipPosition.leftEnd,
  MonoToolTipPosition.topStart,
  MonoToolTipPosition.topCenter,
  MonoToolTipPosition.topEnd,
  MonoToolTipPosition.rightStart,
  MonoToolTipPosition.rightCenter,
  MonoToolTipPosition.rightEnd,
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
  MonoToolTipPosition _position = positions.first;

  int _index = 0;

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
                controller: _controller,
                position: _position,
                borderWidth: 4,
                borderColor: Colors.blueGrey,
                backgroundColor: Colors.pink,
                arrowHeight: 10,
                shadows: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 8),
                  ),
                ],
                keepContentInScreen: true,
                content: const SizedBox(
                  width: 320,
                  child: Text(
                    'ABCDEDGHIJKLMNOPQRSTUVWXYZ',
                    // 'ABC',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // target widget
                child: Container(
                  height: 60,
                  color: Colors.blue,
                  child: const Text('Target'),
                ),
              ),
            ),
            Row(
              children: [
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
                  child: const Text('Toggle'),
                ),
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      _index = (_index + 1) % positions.length;
                      _position = positions[_index];
                    });
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
