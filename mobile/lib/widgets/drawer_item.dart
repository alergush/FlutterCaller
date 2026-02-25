import 'package:flutter/material.dart';

class DrawerItemWidget extends StatelessWidget {
  const DrawerItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text("Clients"),
    );
  }
}
