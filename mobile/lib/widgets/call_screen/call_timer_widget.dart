import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_caller/models/call_status.dart';
import 'package:flutter_caller/utils/format_duration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/providers/call_state_provider.dart';

class CallTimerWidget extends ConsumerStatefulWidget {
  const CallTimerWidget({
    super.key,
    this.textStyle,
    this.extraContent,
  });

  final TextStyle? textStyle;
  final String? extraContent;

  @override
  ConsumerState<CallTimerWidget> createState() => _CallTimerState();
}

class _CallTimerState extends ConsumerState<CallTimerWidget> {
  Timer? _timer;
  String _formattedTime = "00:00";

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final callState = ref.read(callStateProvider);

    if (callState.callStatus != CallStatus.connected ||
        callState.connectedAt == null) {
      if (_formattedTime != "00:00") {
        setState(() {
          _formattedTime = "00:00";
        });
      }
      return;
    }

    final duration = DateTime.now().difference(callState.connectedAt!);
    final newTime = formatDuration(duration);

    if (_formattedTime != newTime) {
      if (mounted) {
        setState(() {
          _formattedTime = newTime;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(callStateProvider.select((s) => s.connectedAt), (prev, next) {
      _updateTime();
    });

    return Text(
      widget.extraContent != null
          ? "${widget.extraContent}$_formattedTime"
          : _formattedTime,
      style: widget.textStyle,
    );
  }
}
