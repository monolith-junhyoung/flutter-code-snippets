## Getting Started

```dart
void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PostTip Demo',
      home: Scaffold(
        body: Center(
          child: PostTip(
            position: PostTipPosition.topStart,
            distance: 4,
            backgroundColor: Colors.lightBlue,
            content: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: Text('PostTip'),
            ),
            child: Container(
              color: Colors.yellow,
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.favorite,
                color: Colors.pink,
                size: 64.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```