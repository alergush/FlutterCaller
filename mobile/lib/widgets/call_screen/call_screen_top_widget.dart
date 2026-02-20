import 'package:flutter/material.dart';

import 'package:flutter_caller/models/call_status.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/providers/call_state_provider.dart';

class CallScreenTopWidget extends ConsumerWidget {
  const CallScreenTopWidget({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  final double height = 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(callStateProvider);

    final double safeAreaTop = MediaQuery.of(context).padding.top;

    Widget centerContent = const SizedBox.shrink();

    if (callState.callStatus == CallStatus.ringing) {
      centerContent = Text(
        "Incoming Call",
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: Colors.white,
        ),
      );
    } else if (callState.callStatus == CallStatus.connecting) {
      centerContent = Row(
        mainAxisSize: .min,
        children: [
          Text(
            "Connecting",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 20,
            width: 20,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    } else if (callState.callStatus == CallStatus.connected) {
      centerContent = Text(
        "Connected",
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: Colors.white,
        ),
      );
    } else if (callState.callStatus == CallStatus.reconnecting) {
      centerContent = Row(
        mainAxisSize: .min,
        children: [
          Text(
            "Reconnecting",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 20,
            width: 20,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    } else if (callState.callStatus == CallStatus.disconnected) {
      centerContent = Text(
        "Disconnected",
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: Colors.white,
        ),
      );
    }

    final content = Padding(
      padding: EdgeInsetsGeometry.only(top: safeAreaTop + 8),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            // Minimize Button
            Align(
              alignment: .centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 12),
                child: IconButton(
                  onPressed: onPressed,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Text
            Align(
              alignment: .center,
              child: centerContent,
            ),
          ],
        ),
      ),
    );

    Widget result;

    if (callState.callStatus != CallStatus.idle) {
      result = content;
    } else {
      result = SizedBox(height: height);
    }

    return result;
  }
}
