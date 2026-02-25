import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_caller/models/client.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_caller/screens/client_screen.dart';
import 'package:flutter_caller/controllers/client_controller.dart';

class ClientsListItem extends ConsumerWidget {
  const ClientsListItem({
    super.key,
    required this.client,
  });

  final Client client;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
        left: 12,
        right: 12,
      ),
      clipBehavior: .hardEdge,
      elevation: 1.25,
      child: Slidable(
        key: ValueKey(client.id),
        startActionPane: ActionPane(
          extentRatio: 0.25,
          motion: const DrawerMotion(),
          dismissible: DismissiblePane(
            dismissThreshold: 0.5,
            // closeOnCancel: true,
            onDismissed: () {},
            confirmDismiss: () async {
              HapticFeedback.lightImpact();

              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ClientScreen()));

              return false;
            },
          ),
          children: [
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.lightImpact();

                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ClientScreen()));
              },
              backgroundColor: Colors.blue,
              icon: Icons.edit,
              label: "Edit",
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          dismissible: DismissiblePane(
            dismissThreshold: 0.5,
            // closeOnCancel: true,
            onDismissed: () {
              ref.read(clientControllerProvider.notifier).deleteClient(client);
            },
            confirmDismiss: () async {
              HapticFeedback.lightImpact();
              return true;
            },
          ),
          children: [
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.mediumImpact();
                ref
                    .read(clientControllerProvider.notifier)
                    .deleteClient(client);
              },
              backgroundColor: Colors.red,
              icon: Icons.delete,
              label: "Delete",
            ),
          ],
        ),
        child: ListTile(
          title: Text(client.name.isEmpty ? "Unknown" : client.name),
          subtitle: Text(client.phone),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blueAccent.withAlpha(50),
            child: Text(
              _getInitials(client.name),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: .min,
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // _showMessagingOptions(context, client.phone);
                  _sendMessage(client.phone);
                },
                icon: const Icon(Icons.message),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _makePhoneCall(client.phone);
                },
                icon: const Icon(Icons.phone),
              ),
            ],
          ),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Could not launch $launchUri');
    }
  }

  Future<void> _sendMessage(String phoneNumber) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(
          smsUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint('SMS application launch error');
      }
    } catch (e) {
      debugPrint('SMS send error: $e');
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";

    List<String> nameParts = name.trim().split(RegExp(r'\s+'));

    if (nameParts.length > 1) {
      return (nameParts.first[0] + nameParts.last[0]).toUpperCase();
    }

    return nameParts[0][0].toUpperCase();
  }
}
