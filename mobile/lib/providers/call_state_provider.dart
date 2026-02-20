import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_caller/models/caller.dart';
import 'package:flutter_caller/models/call_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/models/call_status.dart';
import 'package:flutter_caller/models/call_methods.dart';

final _methodChannel = MethodChannel(
  'com.alergush.flutter_caller/call_methods',
);

final eventChannel = EventChannel('com.alergush.flutter_caller/call_events');

class CallNotifier extends Notifier<CallState> {
  @override
  CallState build() {
    return CallState();
  }

  bool syncWithMap(Map<dynamic, dynamic> data) {
    final String statusStr = data['callStatus'] ?? "idle";

    final status = CallStatus.values.firstWhere(
      (e) => e.name == statusStr.toLowerCase(),
      orElse: () => CallStatus.idle,
    );

    final int startTimeMs = data['callStartTime'] ?? 0;

    final bool isEnding =
        status == CallStatus.idle || status == CallStatus.disconnected;

    final newState = state.copyWith(
      callStatus: status,
      caller: isEnding
          ? state.caller
          : Caller(
              name: data['callerName'] ?? "Unknown",
              phone: data['callerPhone'] ?? "Unknown",
            ),
      connectedAt: startTimeMs > 0
          ? DateTime.fromMillisecondsSinceEpoch(startTimeMs)
          : null,
      callScreenState: state.callScreenState.copyWith(
        isMicrophoneButtonPressed: data['isMuted'] ?? false,
        isSpeakerButtonPressed: data['isSpeakerOn'] ?? false,
      ),
    );

    if (state == newState) {
      return false;
    }

    state = newState;

    return true;
  }

  void minimize() {
    state = state.copyWith(
      callScreenState: state.callScreenState.copyWith(isMinimized: true),
    );
  }

  void maximize() {
    state = state.copyWith(
      callScreenState: state.callScreenState.copyWith(isMinimized: false),
    );
  }

  Future<void> answer() async {
    try {
      await _methodChannel.invokeMethod(CallMethods.answer);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> hangup() async {
    try {
      _methodChannel.invokeMethod(CallMethods.hangup);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> toggleMicrophone() async {
    try {
      await _methodChannel.invokeMethod(CallMethods.toggleMute, {
        CallMethods.toggleMuteParamIsMute:
            !state.callScreenState.isMicrophoneButtonPressed,
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> toggleSpeaker() async {
    try {
      await _methodChannel.invokeMethod(CallMethods.toggleSpeaker, {
        CallMethods.toggleSpeakerParamIsSpeaker:
            !state.callScreenState.isSpeakerButtonPressed,
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }
}

final callStateProvider = NotifierProvider<CallNotifier, CallState>(
  CallNotifier.new,
);
