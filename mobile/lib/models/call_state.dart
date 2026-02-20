import 'package:equatable/equatable.dart';

import 'package:flutter_caller/models/caller.dart';
import 'package:flutter_caller/models/call_status.dart';
import 'package:flutter_caller/models/call_screen_state.dart';

class CallState extends Equatable {
  final CallStatus callStatus;
  final String? callError;
  final CallScreenState callScreenState;
  final Caller caller;
  final DateTime? connectedAt;
  final bool isFirstConnection;

  const CallState({
    this.callStatus = CallStatus.idle,
    this.callError,
    this.callScreenState = const CallScreenState(),
    this.caller = const Caller(),
    this.connectedAt,
    this.isFirstConnection = false,
  });

  CallState copyWith({
    CallStatus? callStatus,
    String? callError,
    CallScreenState? callScreenState,
    Caller? caller,
    DateTime? connectedAt,
    bool? isFirstConnection,
  }) {
    return CallState(
      callStatus: callStatus ?? this.callStatus,
      callError: callError ?? this.callError,
      callScreenState: callScreenState ?? this.callScreenState,
      caller: caller ?? this.caller,
      connectedAt: connectedAt ?? this.connectedAt,
      isFirstConnection: isFirstConnection ?? this.isFirstConnection,
    );
  }

  @override
  List<Object?> get props => [
    callStatus,
    callError,
    callScreenState,
    caller,
    connectedAt,
    isFirstConnection,
  ];
}
