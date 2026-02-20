import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/models/call_status.dart';
import 'package:flutter_caller/widgets/call_banner_widget.dart';
import 'package:flutter_caller/providers/call_state_provider.dart';

class CallOverlayManager extends ConsumerWidget {
  final Widget child;

  const CallOverlayManager({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBannerVisible = ref.watch(
      callStateProvider.select(
        (s) => s.callStatus != CallStatus.idle && s.callScreenState.isMinimized,
      ),
    );

    return Column(
      children: [
        const CallBannerWidget(),
        // Other Screen
        Expanded(
          child: isBannerVisible
              ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: child,
                )
              : child,
        ),
      ],
    );
  }
}
