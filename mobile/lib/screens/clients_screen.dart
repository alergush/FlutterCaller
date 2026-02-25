import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_caller/widgets/main_drawer.dart';
import 'package:flutter_caller/widgets/clients_list.dart';
import 'package:flutter_caller/widgets/search_client_field.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clients"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pushNamed('add_client_screen');
            },
            icon: const Icon(Icons.add),
          ),
        ],
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            );
          },
        ),
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: const SearchClientField(),
          ),
          Expanded(
            child: const ClientsList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
