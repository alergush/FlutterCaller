import 'package:flutter/material.dart';

class CallScreenIncomingCallButtonsWidget extends StatelessWidget {
  const CallScreenIncomingCallButtonsWidget({
    super.key,
    this.onAcceptButtonPressed,
    this.onDeclineButtonPressed,
  });

  static const double buttonIconSize = 36;
  static const double buttonPadding = 14;
  static const Color buttonIconColor = Colors.white;

  final VoidCallback? onAcceptButtonPressed;
  final VoidCallback? onDeclineButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 36,
        right: 36,
      ),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          // Accept
          ElevatedButton(
            onPressed: onAcceptButtonPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(buttonPadding),
              backgroundColor: Colors.green,
              iconSize: buttonIconSize,
              iconColor: Colors.white,
              elevation: 3,
            ),

            child: const Icon(Icons.call),
          ),
          // Decline
          ElevatedButton(
            onPressed: onDeclineButtonPressed,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(buttonPadding),
              backgroundColor: const Color.fromARGB(255, 201, 47, 36),
              iconSize: buttonIconSize,
              iconColor: buttonIconColor,
              elevation: 3,
            ),

            child: const Icon(Icons.call_end_rounded),
          ),
        ],
      ),
    );
  }
}
