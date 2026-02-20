import 'package:equatable/equatable.dart';

class CallScreenState extends Equatable {
  final bool isMinimized;
  final bool isSpeakerButtonPressed;
  final bool isMicrophoneButtonPressed;

  const CallScreenState({
    this.isMinimized = false,
    this.isSpeakerButtonPressed = false,
    this.isMicrophoneButtonPressed = false,
  });

  CallScreenState copyWith({
    bool? isMinimized,
    bool? isSpeakerButtonPressed,
    bool? isMicrophoneButtonPressed,
  }) {
    return CallScreenState(
      isMinimized: isMinimized ?? this.isMinimized,
      isSpeakerButtonPressed:
          isSpeakerButtonPressed ?? this.isSpeakerButtonPressed,
      isMicrophoneButtonPressed:
          isMicrophoneButtonPressed ?? this.isMicrophoneButtonPressed,
    );
  }

  @override
  List<Object?> get props => [
    isMinimized,
    isSpeakerButtonPressed,
    isMicrophoneButtonPressed,
  ];
}
