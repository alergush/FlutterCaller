import 'package:flutter/material.dart';
import 'package:flutter_caller/models/client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_caller/widgets/clients_list_item.dart';
import 'package:flutter_caller/controllers/client_controller.dart';
import 'package:flutter_caller/mock/pending_deletions_provider.dart';
import 'package:flutter_caller/providers/client_search_provider.dart';
import 'package:flutter_caller/providers/clients_stream_provider.dart';

class ClientsList extends ConsumerWidget {
  const ClientsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<void>>(clientControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              showCloseIcon: true,
            ),
          );
        },
      );
    });

    final allClientsAsync = ref.watch<AsyncValue<List<Client>>>(
      clientsStreamProvider,
    );

    return allClientsAsync.when(
      data: (allClients) {
        final searchQuery = ref.watch(clientSearchProvider).toLowerCase();
        final pendingDeletions = ref.watch(pendingDeletionsProvider);

        final visibleClients = allClients
            .where(
              (c) => !pendingDeletions.contains(c.id),
            )
            .toList();

        final filteredClients = searchQuery.isEmpty
            ? visibleClients
            : visibleClients
                  .where(
                    (client) =>
                        client.name.toLowerCase().contains(searchQuery) ||
                        client.phone.contains(searchQuery),
                  )
                  .toList();

        if (filteredClients.isEmpty) {
          return Center(
            child: Text(
              "No clients found.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }

        return SlidableAutoCloseBehavior(
          child: ListView.builder(
            itemCount: filteredClients.length,

            itemBuilder: (context, index) => ClientsListItem(
              key: ValueKey(filteredClients[index].id),
              client: filteredClients[index],
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return const Center(
          child: Text("ERROR"),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }
}
