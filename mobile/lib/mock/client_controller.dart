import 'dart:async';
import 'package:flutter_caller/models/client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/mock/mock_database.dart';
import 'package:flutter_caller/mock/pending_deletions_provider.dart';

final mockStreamController = StreamController<List<Client>>.broadcast();

final clientsStreamProvider = StreamProvider<List<Client>>((ref) {
  Future.delayed(const Duration(seconds: 1), () {
    mockStreamController.add(List.from(mockDatabase));
  });

  // ref.onDispose(() {
  //   mockStreamController.close();
  // });

  return mockStreamController.stream;
});

class ClientController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  // Future<void> createClient(Client client) async {
  //   state = const AsyncValue.loading();

  //   state = await AsyncValue.guard(() async {
  //     await Future.delayed(const Duration(seconds: 1));

  //     mockDatabase.insert(0, client);

  //     mockStreamController.add(List.from(mockDatabase));
  //   });
  // }

  Future<void> deleteClient(Client client) async {
    ref
        .read(pendingDeletionsProvider.notifier)
        .update((s) => {...s, client.phone});

    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 1));
      mockDatabase.removeWhere((c) => c.phone == client.phone);
      mockStreamController.add(List.from(mockDatabase));
    });

    if (state.hasError) {
      _removePending(client.phone);
    } else {
      await Future.delayed(const Duration(seconds: 2));
      _removePending(client.phone);
    }
  }

  void _removePending(String phone) {
    ref.read(pendingDeletionsProvider.notifier).update((state) {
      final newState = Set<String>.from(state);
      newState.remove(phone);
      return newState;
    });
  }
}

final clientControllerProvider = AsyncNotifierProvider<ClientController, void>(
  ClientController.new,
);
