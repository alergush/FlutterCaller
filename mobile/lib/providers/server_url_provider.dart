import 'package:flutter_riverpod/flutter_riverpod.dart';

final serverUrlProvider = Provider((ref) {
  return "http://192.168.0.150:3000/api";
});
