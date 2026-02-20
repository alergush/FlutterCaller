import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/models/call_status.dart';
import 'package:flutter_caller/screens/call_screen.dart';
import 'package:flutter_caller/providers/call_state_provider.dart';
import 'package:flutter_caller/widgets/call_screen/call_timer_widget.dart';

class CallBannerWidget extends ConsumerWidget {
  const CallBannerWidget({
    super.key,
  });

  static const double buttonIconSize = 20;
  static const Color buttonColor = Color.fromARGB(255, 50, 50, 50);
  static const Color backgroundColor = Color.fromARGB(255, 38, 38, 38);

  static const double bannerHeight = 125;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callStateProvider);
    final notifier = ref.watch(callStateProvider.notifier);

    final bool isBannerVisible =
        (callState.callStatus != CallStatus.idle) &&
        callState.callScreenState.isMinimized;

    final acceptMicroButtonWidget = ElevatedButton(
      onPressed: () async {
        HapticFeedback.lightImpact();

        if (callState.callStatus != CallStatus.idle &&
            callState.callStatus != CallStatus.ringing &&
            callState.callStatus != CallStatus.disconnected) {
          await notifier.toggleMicrophone();
        } else if (callState.callStatus == CallStatus.ringing) {
          await notifier.answer();
        }
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: callState.callStatus == CallStatus.ringing
            ? buttonColor
            : callState.callScreenState.isMicrophoneButtonPressed
            ? CallScreen.pressedButtonColor
            : buttonColor,
        iconSize: buttonIconSize,
        padding: const EdgeInsets.all(12),
      ),
      child: Icon(
        callState.callStatus == CallStatus.ringing
            ? Icons.phone
            : Icons.mic_off,
        color: callState.callStatus == CallStatus.ringing
            ? Colors.green
            : callState.callScreenState.isMicrophoneButtonPressed
            ? CallScreen.pressedButtonIconColor
            : CallScreen.buttonIconColor,
      ),
    );

    final incomingCallTextWidget = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Incoming Call",
            maxLines: 1,
            overflow: .ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w500,
              overflow: .ellipsis,
            ),
          ),
          Text(
            callState.caller.phone,
            maxLines: 1,
            overflow: .ellipsis,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    final callTimerWidget = CallTimerWidget(
      extraContent: "${callState.caller.name} - ",
      textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Colors.green,
        fontWeight: FontWeight.w500,
      ),
    );

    final rejectEndButtonWidget = ElevatedButton(
      onPressed: () async {
        HapticFeedback.lightImpact();

        if (callState.callStatus != CallStatus.idle &&
            callState.callStatus != CallStatus.disconnected) {
          await notifier.hangup();
        }
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        backgroundColor: buttonColor,
        iconSize: buttonIconSize,
        padding: const EdgeInsets.all(12),
      ),
      child: const Icon(
        Icons.call_end_rounded,
        color: Colors.red,
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      height: isBannerVisible ? bannerHeight : 0,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: backgroundColor,
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: SizedBox(
          height: bannerHeight,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: SafeArea(
              bottom: false,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();

                  notifier.maximize();

                  Navigator.of(context).pushNamedAndRemoveUntil(
                    'call_screen',
                    (route) => route.settings.name != 'call_screen',
                  );
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Row(
                  mainAxisSize: .max,
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    if (callState.callStatus == CallStatus.ringing) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: rejectEndButtonWidget,
                      ),
                      incomingCallTextWidget,
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: acceptMicroButtonWidget,
                      ),
                    ] else if (callState.callStatus != CallStatus.idle) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: acceptMicroButtonWidget,
                      ),
                      callTimerWidget,
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: rejectEndButtonWidget,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
