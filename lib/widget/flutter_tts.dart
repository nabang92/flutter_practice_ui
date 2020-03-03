import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class FlutterTtsPage extends StatefulWidget {
  @override
  _FlutterTtsPageState createState() => _FlutterTtsPageState();
}

enum TtsState { playing, stopped }

class _FlutterTtsPageState extends State<FlutterTtsPage> {
  String text =
      "The first version of Flutter was known as codename 'Sky' and ran on the Android operating system. It was unveiled at the 2015 Dart developer summit, with the stated intent of being able to render consistently at 120 frames per second.[6] During the keynote of Google Developer Days in Shanghai, Google announced Flutter Release Preview 2 which is the last big release before Flutter 1.0. On December 4, 2018, Flutter 1.0 was released at the Flutter Live event, denoting the first 'stable' version of the Framework.[7] On December 11, 2019, Flutter 1.12 was released at the Flutter Interactive event, it was announced that Flutter was the first UI platform designed for ambient computing";
  bool isPlaying = false;
  FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    initializeTts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("flutter_tts"),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              InkWell(
                child: Icon(
                  (isPlaying)
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.pink,
                  size: 48,
                ),
                onTap: () {
                  if (isPlaying) {
                    _stop();
                  } else {
                    _speak(text);
                  }
                },
              ),
              Text(
                text,
                style: TextStyle(color: Colors.pink, fontSize: 20),
              ),
            ]),
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  initializeTts() {
    _flutterTts = FlutterTts();

    _flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        isPlaying = false;
      });
    });
  }

  Future _speak(String text) async {
    if (text != null && text.isNotEmpty) {
      setTtsLanguage();
      var result = await _flutterTts.speak(text);
      if (result == 1)
        setState(() {
          isPlaying = true;
        });
    }
  }

  Future _stop() async {
    var result = await _flutterTts.stop();
    if (result == 1)
      setState(() {
        isPlaying = false;
      });
  }

  void setTtsLanguage() async {
    await _flutterTts.setLanguage("en-US");
  }

  @override
  void dispose() {
    super.dispose();
    _flutterTts.stop();
  }
}
