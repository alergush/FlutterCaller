import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientSearchNotifier extends Notifier<String> {
  @override
  String build() {
    return "";
  }

  void set(String content) {
    state = content;
  }
}

final clientSearchProvider = NotifierProvider<ClientSearchNotifier, String>(
  ClientSearchNotifier.new,
);
