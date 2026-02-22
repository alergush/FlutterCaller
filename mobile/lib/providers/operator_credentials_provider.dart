import 'package:flutter_caller/models/tokens.dart';
import 'package:flutter_caller/providers/auth_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OperatorCredentialsNotifier extends Notifier<OperatorCredentials?> {
  @override
  OperatorCredentials? build() {
    ref.listen(authStateProvider, (prev, next) {
      if (next.value == null) state = null;
    });

    return null;
  }

  void set(OperatorCredentials credentials) {
    state = credentials;
  }

  void clear() {
    state = null;
  }
}

final operatorCredentialsProvider =
    NotifierProvider<OperatorCredentialsNotifier, OperatorCredentials?>(
      OperatorCredentialsNotifier.new,
    );
