import 'package:equatable/equatable.dart';

class Client extends Equatable {
  final String? id;
  final String name;
  final String phone;
  final String? extra;

  const Client({
    this.id,
    required this.name,
    required this.phone,
    this.extra,
  });

  factory Client.fromJson(Map<String, dynamic> data, String id) {
    return Client(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      extra: data['extra'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'extra': extra,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    extra,
  ];
}
