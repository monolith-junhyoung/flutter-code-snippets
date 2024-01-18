import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// 다각형을 다루기
class PolygonPage extends StatefulWidget {
  const PolygonPage({super.key});

  @override
  State<PolygonPage> createState() => _PolygonPageState();
}

class _PolygonPageState extends State<PolygonPage> {
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final clipper = RightClipper();
    Path path = Path();
    // final size = MediaQuery.of(context).size;
    final size = Size(
      MediaQuery.of(context).size.width,
      MediaQuery.of(context).size.height - bottomPadding,
    );
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    // final vertices = path.getVertices();

    List<Offset> vert = [
      Offset(0, 0),
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ];
    for (var element in vert) {
      print('Vert> $element, size: $size, length: ${path.computeMetrics().length}');
    }
    final center = calculateCenter(vert);
    print('Vert> center : $center');

    final test = calculateCenter([
      Offset(1, 1),
      Offset(2, 4),
      Offset(5, 4),
      Offset(11, 1),
    ]);
    print('Vert> center of test : $test');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polygon'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  // width: screenWidth * 0.81,
                  // height: screenHeight * 0.97,
                  width: screenWidth,
                  height: screenHeight,
                  child: ClipPath(
                    clipper: RightClipper(),
                    child: Container(
                      color: Colors.lightGreen,
                      width: double.infinity,
                      height: double.infinity,
                      child: Column(
                        children: [
                          Container(
                            color: Colors.yellow,
                            width: 150,
                            height: 120,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // top layer
            CustomPaint(
              painter: DotPainter(offset: center),
            ),
          ],
        ),
      ),
    );
  }

  Offset calculateCenter(List<Offset> xy) {
    double area = calculatePolygonArea(xy);
    final n = xy.length;
    double cx = 0.0;
    double cy = 0.0;

    for (var i = 0; i < n - 1; i++) {
      final value = xy[i].dx * xy[i + 1].dy - xy[i + 1].dx * xy[i].dy;
      cx += (xy[i].dx + xy[i + 1].dx) * value;
      cy += (xy[i].dy + xy[i + 1].dy) * value;
    }
    final lastValue = xy[n - 1].dx * xy[0].dy - xy[0].dx * xy[n - 1].dy;
    cx += (xy[n - 1].dx + xy[0].dx) * lastValue;
    cy += (xy[n - 1].dy + xy[0].dy) * lastValue;

    cx = cx / (6 * area);
    cy = cy / (6 * area);
    return Offset(cx, cy);
  }

  /// n개의 정점을 가진 다각형의 영역을 나타낸다.
  double calculatePolygonArea(List<Offset> xy) {
    if (xy.isEmpty) {
      return 0.0;
    }

    double area = 0.0;
    final n = xy.length;

    for (var i = 0; i < n - 1; i++) {
      area += (xy[i].dx * xy[i + 1].dy - xy[i + 1].dx * xy[i].dy);
    }
    area = 0.5 * area.abs();
    return area;
  }
}

class RightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

extension PathEx on Path {
  List<Offset> getVertices() {
    final List<Offset> vertices = [];
    computeMetrics().forEachIndexed((i, e) {
      final tangent = e.getTangentForOffset(i.toDouble());
      if (tangent != null) {
        vertices.add(tangent.position);
      }
    });
    return vertices;
  }
}

class DotPainter extends CustomPainter {
  final Offset offset;

  DotPainter({super.repaint, required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.redAccent // 색은 보라색
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.clear
      ..strokeWidth = 2.0;

    canvas.drawCircle(offset, 2.0, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
