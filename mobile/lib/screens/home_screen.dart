import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          mainAxisSize: .max,
          children: [
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                HapticFeedback.lightImpact();
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(12),
                backgroundColor: Colors.green,
                iconSize: 32,
                iconColor: Colors.white,
                elevation: 3,
              ),

              child: const Icon(Icons.phone),
            ),
            Spacer(),
            TextButton.icon(
              onPressed: () async {
                HapticFeedback.lightImpact();

                await ref.read(authProvider).signOut();
              },
              icon: const Icon(
                Icons.logout,
                size: 26,
                color: Colors.red,
              ),
              label: Text(
                "Log Out",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
