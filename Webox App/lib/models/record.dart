import 'package:equatable/equatable.dart';
import 'package:webox/models/block.dart';

class Record extends Equatable {
  final String name;
  final List<Block> blocks = [];
  DateTime? recordStartedAt;
  String? remoteId;

  Record({required this.name});

  @override
  List<Object?> get props => [recordStartedAt, blocks];
}
