import 'package:equatable/equatable.dart';

import 'package:flutter_caller/models/caller.dart';
import 'package:flutter_caller/models/call_status.dart';
import 'package:flutter_caller/models/call_screen_state.dart';

class CallState extends Equatable {
  final CallStatus callStatus;
  final CallScreenState callScreenState;
  final Caller caller;
  final DateTime? connectedAt;

  const CallState({
    this.callStatus = CallStatus.idle,
    this.callScreenState = const CallScreenState(),
    this.caller = const Caller(),
    this.connectedAt,
  });

  CallState copyWith({
    CallStatus? callStatus,
    CallScreenState? callScreenState,
    Caller? caller,
    DateTime? connectedAt,
  }) {
    return CallState(
      callStatus: callStatus ?? this.callStatus,
      callScreenState: callScreenState ?? this.callScreenState,
      caller: caller ?? this.caller,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }

  @override
  List<Object?> get props => [
    callStatus,
    callScreenState,
    caller,
    connectedAt,
  ];
}
