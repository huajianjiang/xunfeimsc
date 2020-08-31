
import 'dart:async';

import 'package:flutter/services.dart';

import 'src/enums/speech_recognition.dart';
import 'src/models/speech_recognition.dart';

export 'src/enums/speech_recognition.dart';
export 'src/models/speech_recognition.dart';

class Xunfeimsc {
  static const MethodChannel _callChannel =
      const MethodChannel('com.huajianjiang.flutter.plugins/xunfeimsc');
  static const EventChannel _eventChannel = const EventChannel(
      'com.huajianjiang.flutter.plugins/speech_recognition_event');

  static const String cmd_speech_recognition_start = "startSpeechRecognition";
  static const String cmd_speech_recognition_stop = "stopSpeechRecognition";
  static const String cmd_speech_recognition_cancel = "cancelSpeechRecognition";

  Stream<SpeechRecognizeData> onSpeechRecognitionStateChanged() {
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => _parseSpeechRecognizeEvent(event));
  }

  Stream<SpeechRecognizeResult> onSpeechRecognitionResultAvailable() {
    return onSpeechRecognitionStateChanged()
        .where((event) => event.event == SpeechRecognitionEvent.onResult)
        .map((event) => event.data);
  }

  Future<void> startSpeechRecognition() async {
    return _callChannel.invokeMethod(cmd_speech_recognition_start);
  }

  Future<void> stopSpeechRecognition() async {
    return _callChannel.invokeMethod(cmd_speech_recognition_stop);
  }

  Future<void> cancelSpeechRecognition() async {
    return _callChannel.invokeMethod(cmd_speech_recognition_cancel);
  }

  SpeechRecognizeData _parseSpeechRecognizeEvent(Map<dynamic, dynamic> event) {
    String eventCode = event['eventCode'];
    Map<dynamic, dynamic> eventData = event['eventData'];
    SpeechRecognizeData data;
    switch(eventCode) {
      case 'onStartSpeech':
        data = SpeechRecognizeData(SpeechRecognitionEvent.onStart, null);
        break;
      case 'onFinishSpeech':
        data = SpeechRecognizeData(SpeechRecognitionEvent.onFinished, null);
        break;
      case 'onVolumeChanged':
        SpeechRecognizeVolume volume =
        SpeechRecognizeVolume(eventData['volume'], eventData['data']);
        data =
            SpeechRecognizeData(SpeechRecognitionEvent.onVolumeChanged, volume);
        break;
      case 'onResult':
        SpeechRecognizeResult result = SpeechRecognizeResult(
            eventData['result'], eventData['isLastResult']);
        data = SpeechRecognizeData(SpeechRecognitionEvent.onResult, result);
        break;
      default:
        throw ArgumentError('Unknown event code to handle: $eventCode');
    }
    return data;
  }

}
