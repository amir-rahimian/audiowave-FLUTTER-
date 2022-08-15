import 'dart:async';

import 'package:flutter/material.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'animation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _d = 0;
  bool _isRecording = false;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;

  //speech to text
  late stt.SpeechToText _speech;
  // bool _isListening = false;
  String _text = 'Speek';
  double _confidence = 1.0;

  final Map<String, HighlightedWord> _highlights = {
    'hi': HighlightedWord(
      textStyle: TextStyle(
          color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24.0),
    )
  };

  @override
  void initState() {
    super.initState();

    //stt :
    _speech = stt.SpeechToText();

    _noiseMeter = NoiseMeter(onError);
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _speech.cancel();
    super.dispose();
  }

  void onData(NoiseReading noiseReading) {
    setState(() {
      if (!_isRecording) {
        _isRecording = true;
      }
      double d = noiseReading.maxDecibel;
      if (!(d.isNegative || d.isInfinite || d.isNaN)) {
        _d = noiseReading.maxDecibel;
      }
    });
    print(noiseReading.toString());
  }

  void onError(Object error) {
    print(error.toString());
    _isRecording = false;
  }

  void start() async {
    // stt
    if (!_isRecording) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('$status'),
        onError: (errorNotification) => print('$errorNotification'),
      );
      if (available) {
        setState(() {
          _isRecording = true;
        });
        _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
              if (result.hasConfidenceRating && result.confidence > 0) {
                _confidence = result.confidence;
              }
            });
          },
        );
      } else {
        setState(() {
          _isRecording = false;
          _speech.stop();
        });
      }
    }

    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (err) {
      print(err);
    }
  }

  void stop() async {
    _speech.stop();
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription!.cancel();
        _noiseSubscription = null;
      }
      setState(() {
        _isRecording = false;
      });
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  Widget Lines(int count) {
    int c = count ~/ 2;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(c, (index) {
          return line((((_d * 2) / 10) - 3) * (index));
        }).toList(),
        line((((_d * 2) / 10) - 3) * (c)),
        ...List.generate(c, (index) {
          return line((((_d * 2) / 10) - 3) * (c - index - 1));
        }).toList()
      ],
    );
  }

  Widget line(double i) {
    return AnimatedContainer(
      margin: EdgeInsets.all(8.0),
      width: 8.0,
      height: 8.0 + (i.isNegative || i.isInfinite ? 0 : i),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            _isRecording
                ? "ON : ${(((_d) / 10) - 3).toStringAsFixed(0)} ::: c : $_confidence"
                : "OFF",
            style: const TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                child: Lines(10),
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: SingleChildScrollView(
                  reverse: true,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
                    child: TextHighlight(
                      words: _highlights,
                      text: _text,
                      textStyle: TextStyle(
                        fontSize: 24.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Stack(
          alignment: Alignment.center,
          children: [
            (_isRecording ? SoundRipple(_d) : Text("")),
            FloatingActionButton(
                elevation: 0.0,
                backgroundColor: _isRecording ? Colors.red : Colors.green,
                onPressed: _isRecording ? stop : start,
                child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic)),
          ],
        ),
      ),
    );
  }
}
