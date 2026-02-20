import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/models/call_status.dart';
import 'package:flutter_caller/providers/call_state_provider.dart';
import 'package:flutter_caller/widgets/call_screen/call_timer_widget.dart';
import 'package:flutter_caller/widgets/call_screen/call_screen_top_widget.dart';
import 'package:flutter_caller/widgets/call_screen/call_screen_buttons_widget.dart';
import 'package:flutter_caller/widgets/call_screen/call_screen_incoming_call_buttons_widget.dart';

class CallScreen extends ConsumerWidget {
  const CallScreen({super.key});

  static const Color buttonBarColor = Color.fromARGB(255, 38, 38, 38);
  static const Color buttonColor = Color.fromARGB(255, 75, 75, 75);
  static const Color pressedButtonColor = Colors.white;
  static const Color buttonIconColor = Colors.white;
  static const Color pressedButtonIconColor = Colors.black;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callStateProvider);
    final notifier = ref.watch(callStateProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;

          if (callState.callStatus != CallStatus.disconnected) {
            notifier.minimize();
            ScaffoldMessenger.of(context).clearSnackBars();
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: callState.callError == null
                    ? const [
                        Color.fromARGB(255, 55, 128, 57),
                        Color.fromARGB(255, 20, 65, 102),
                      ]
                    : const [
                        Color.fromARGB(255, 215, 65, 55),
                        Color.fromARGB(255, 20, 65, 102),
                      ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CallScreenTopWidget(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).clearSnackBars();
                    notifier.minimize();
                    Navigator.of(context).pop();
                  },
                ),

                const SizedBox(height: 32),

                if (callState.callStatus != CallStatus.idle &&
                    callState.callStatus != CallStatus.ringing)
                  CallTimerWidget(
                    textStyle: Theme.of(context).textTheme.titleMedium!
                        .copyWith(
                          color: Colors.white,
                        ),
                  ),

                if (callState.callStatus == CallStatus.idle)
                  const SizedBox(height: 60),

                const SizedBox(height: 32),

                GestureDetector(
                  onLongPress: () async {
                    HapticFeedback.lightImpact();

                    await Clipboard.setData(
                      ClipboardData(text: callState.caller.name),
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('The name has been copied.'),
                          duration: Duration(seconds: 2),
                          showCloseIcon: true,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Text(
                    callState.caller.name,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                GestureDetector(
                  onLongPress: () async {
                    HapticFeedback.lightImpact();

                    await Clipboard.setData(
                      ClipboardData(text: callState.caller.phone),
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('The phone number has been copied.'),
                          duration: Duration(seconds: 2),
                          showCloseIcon: true,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Text(
                    callState.caller.phone,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 42),

                CircleAvatar(
                  radius: 86,
                  backgroundColor: Colors.grey[350],
                  foregroundColor: Color.fromARGB(255, 20, 65, 102),
                  child: const Icon(
                    Icons.person,
                    size: 120,
                  ),
                ),

                Spacer(),

                if (callState.callStatus == CallStatus.ringing)
                  CallScreenIncomingCallButtonsWidget(
                    onAcceptButtonPressed: () async {
                      HapticFeedback.lightImpact();
                      await notifier.answer();
                    },
                    onDeclineButtonPressed: () async {
                      HapticFeedback.lightImpact();
                      // notifier.minimize();
                      Navigator.of(context).pop();
                      await notifier.hangup();
                    },
                  )
                else if (callState.callStatus == CallStatus.connecting ||
                    callState.callStatus == CallStatus.connected ||
                    callState.callStatus == CallStatus.reconnecting)
                  CallScreenButtonsWidget(
                    onMicrophoneButtonPressed: () async {
                      HapticFeedback.lightImpact();

                      if (callState.callStatus != CallStatus.idle &&
                          callState.callStatus != CallStatus.ringing &&
                          callState.callStatus != CallStatus.disconnected) {
                        await notifier.toggleMicrophone();
                      }
                    },
                    onSpeakerButtonPressed: () async {
                      HapticFeedback.lightImpact();

                      if (callState.callStatus != CallStatus.idle &&
                          callState.callStatus != CallStatus.ringing &&
                          callState.callStatus != CallStatus.ringing) {
                        await notifier.toggleSpeaker();
                      }
                    },
                    onCallEndButtonPressed: () async {
                      HapticFeedback.lightImpact();

                      if (callState.callStatus != CallStatus.disconnected) {
                        // notifier.minimize();
                        Navigator.of(context).pop();
                        await notifier.hangup();
                      }
                    },
                  ),

                if (callState.callStatus == CallStatus.ringing)
                  const SizedBox(height: 60),
                if (callState.callStatus == CallStatus.connecting ||
                    callState.callStatus == CallStatus.connected ||
                    callState.callStatus == CallStatus.reconnecting)
                  const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
