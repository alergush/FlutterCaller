import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_caller/models/client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final clientsStreamProvider = StreamProvider<List<Client>>((ref) {
  return FirebaseFirestore.instance.collection('clients').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs.map((doc) {
      return Client.fromJson(doc.data(), doc.id);
    }).toList();
  });
});
