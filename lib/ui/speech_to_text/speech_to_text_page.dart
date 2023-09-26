import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:livespeechtotext/livespeechtotext.dart';
import 'package:permission_handler/permission_handler.dart';

///
/// LiveSpeechToText example
class SpeechToTextPage extends StatefulWidget {
  const SpeechToTextPage({super.key});

  @override
  State<SpeechToTextPage> createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  late Livespeechtotext _speech;
  late String _recognisedText;
  String? _localeName = '';
  StreamSubscription<dynamic>? onSuccessEvent;

  bool microphoneGranted = false;

  @override
  void initState() {
    _speech = Livespeechtotext();

    _speech.setLocale('ko-KR').then((value) async {
      _localeName = await _speech.getLocaleDisplayName();

      setState(() {});
    });

    _speech.getLocaleDisplayName().then((value) => setState(
          () => _localeName = value,
        ));

    // onSuccessEvent = _livespeechtotextPlugin.addEventListener('success', (text) {
    //   setState(() {
    //     _recognisedText = text ?? '';
    //   });
    // });

    binding().whenComplete(() => null);

    // _livespeechtotextPlugin
    //     .getSupportedLocales()
    //     .then((value) => value?.entries.forEach((element) {
    //           print(element);
    //         }));

    _recognisedText = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Live Speech To Text'),
        ),
        body: Center(
          child: Column(
            children: [
              Text(_recognisedText),
              if (!microphoneGranted)
                ElevatedButton(
                  onPressed: () {
                    binding();
                  },
                  child: const Text("Check Permissions"),
                ),
              ElevatedButton(
                  onPressed: microphoneGranted
                      ? () {
                          print("start button pressed");
                          try {
                            _speech.start();
                          } on PlatformException {
                            print('error');
                          }
                        }
                      : null,
                  child: const Text('Start')),
              ElevatedButton(
                  onPressed: microphoneGranted
                      ? () {
                          print("stop button pressed");
                          try {
                            _speech.stop();
                          } on PlatformException {
                            print('error');
                          }
                        }
                      : null,
                  child: const Text('Stop')),
              Text("Locale: $_localeName"),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> binding() async {
    onSuccessEvent?.cancel();

    return Future.wait([]).then((_) async {
      // Check if the user has already granted microphone permission.
      var permissionStatus = await Permission.microphone.status;

      // If the user has not granted permission, prompt them for it.
      if (!microphoneGranted) {
        await Permission.microphone.request();

        // Check if the user has already granted the permission.
        permissionStatus = await Permission.microphone.status;

        if (!permissionStatus.isGranted) {
          return Future.error('Microphone access denied');
        }
      }

      // Check if the user has already granted speech permission.
      if (Platform.isIOS) {
        var speechStatus = await Permission.speech.status;

        // If the user has not granted permission, prompt them for it.
        if (!microphoneGranted) {
          await Permission.speech.request();

          // Check if the user has already granted the permission.
          speechStatus = await Permission.speech.status;

          if (!speechStatus.isGranted) {
            return Future.error('Speech access denied');
          }
        }
      }

      return Future.value(true);
    }).then((value) {
      microphoneGranted = true;

      // listen to event "success"
      onSuccessEvent = _speech.addEventListener("success", (value) {
        if (value.runtimeType != String) return;
        if ((value as String).isEmpty) return;

        print('value: $value');

        setState(() {
          _recognisedText += value;
        });
      });

      setState(() {});
    }).onError((error, stackTrace) {
      // toast
      print(error.toString());
      // open app setting
    });
  }
}
