import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/providers/call_state_provider.dart';

class CallScreenButtonsWidget extends ConsumerWidget {
  const CallScreenButtonsWidget({
    super.key,
    this.onCallEndButtonPressed,
    this.onMicrophoneButtonPressed,
    this.onSpeakerButtonPressed,
  });

  final VoidCallback? onSpeakerButtonPressed;
  final VoidCallback? onMicrophoneButtonPressed;
  final VoidCallback? onCallEndButtonPressed;

  static const double buttonIconSize = 26;
  static const double buttonPadding = 14;

  static const Color buttonColor = Color.fromARGB(255, 75, 75, 75);
  static const Color buttonBarColor = Color.fromARGB(255, 38, 38, 38);
  static const Color pressedButtonColor = Colors.white;
  static const Color buttonIconColor = Colors.white;
  static const Color pressedButtonIconColor = Colors.black;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callStateProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      height: 76,
      width: double.infinity,
      decoration: BoxDecoration(
        color: buttonBarColor,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Speaker Button
          ElevatedButton(
            onPressed: onSpeakerButtonPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(buttonPadding),
              backgroundColor: callState.callScreenState.isSpeakerButtonPressed
                  ? pressedButtonColor
                  : buttonColor,
              iconSize: buttonIconSize,
              iconColor: callState.callScreenState.isSpeakerButtonPressed
                  ? pressedButtonIconColor
                  : buttonIconColor,
            ),

            child: const Icon(Icons.volume_up_rounded),
          ),
          // Microphone Button
          ElevatedButton(
            onPressed: onMicrophoneButtonPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(buttonPadding),
              backgroundColor:
                  callState.callScreenState.isMicrophoneButtonPressed
                  ? pressedButtonColor
                  : buttonColor,
              iconSize: buttonIconSize,
              iconColor: callState.callScreenState.isMicrophoneButtonPressed
                  ? pressedButtonIconColor
                  : buttonIconColor,
            ),

            child: const Icon(Icons.mic_off),
          ),
          // Call End Button
          ElevatedButton(
            onPressed: onCallEndButtonPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(buttonPadding),
              backgroundColor: const Color.fromARGB(255, 201, 47, 36),
              iconSize: buttonIconSize,
              iconColor: buttonIconColor,
            ),

            child: const Icon(Icons.call_end_rounded),
          ),
        ],
      ),
    );
  }
}
