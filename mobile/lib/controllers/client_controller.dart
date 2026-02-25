import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_caller/models/client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/providers/auth_provider.dart';
import 'package:flutter_caller/providers/server_url_provider.dart';
import 'package:flutter_caller/mock/pending_deletions_provider.dart';

class ClientController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createClient(Client client) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final user = ref.read(firebaseAuthProvider).currentUser;

      if (user == null) {
        throw Exception('Auth Error');
      }

      final idToken = await user.getIdToken();

      if (idToken == null) {
        throw Exception('Token Error');
      }

      final serverBaseUrl = ref.read(serverUrlProvider);

      final response = await http.post(
        Uri.parse('$serverBaseUrl/clients'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode(client.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server Save Error');
      } else {
        debugPrint("HTTP: ${response.body}");
      }
    });
  }

  Future<void> deleteClient(Client client) async {
    if (client.id == null) return;

    ref
        .read(pendingDeletionsProvider.notifier)
        .update((s) => {...s, client.id!});

    state = await AsyncValue.guard(() async {
      final user = ref.read(firebaseAuthProvider).currentUser;

      if (user == null) {
        throw Exception('Auth Error');
      }

      final idToken = await user.getIdToken();

      if (idToken == null) {
        throw Exception('IdToken Error');
      }

      final serverBaseUrl = ref.read(serverUrlProvider);

      final response = await http.delete(
        Uri.parse('$serverBaseUrl/clients/${client.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Server Delete Client Error');
      } else {
        debugPrint("HTTP DELETE");
      }
    });

    if (state.hasError) {
      _removePendingClient(client.id!);
    } else {
      await Future.delayed(const Duration(seconds: 3));
      _removePendingClient(client.id!);
    }
  }

  void _removePendingClient(String id) {
    ref.read(pendingDeletionsProvider.notifier).update((state) {
      final newState = Set<String>.from(state);
      newState.remove(id);
      return newState;
    });
  }
}

final clientControllerProvider = AsyncNotifierProvider<ClientController, void>(
  ClientController.new,
);
