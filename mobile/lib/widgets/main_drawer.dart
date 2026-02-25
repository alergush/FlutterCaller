import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/providers/auth_provider.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: Column(
        children: [
          const SizedBox(height: 300),
          // InkWell(
          //   onTap: () {},
          //   child: const DrawerItemWidget(),
          // ),
          Spacer(),
          TextButton.icon(
            onPressed: () async {
              HapticFeedback.lightImpact();
              await ref.read(authServiceProvider).signOut();
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
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
