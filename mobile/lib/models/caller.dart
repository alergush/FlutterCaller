import 'package:equatable/equatable.dart';

class Caller extends Equatable {
  const Caller({
    this.name = "Unknown",
    this.phone = "Unknown",
    this.info,
  });

  final String name;
  final String phone;
  final String? info;

  @override
  List<Object?> get props => [
    name,
    phone,
    info,
  ];
}
