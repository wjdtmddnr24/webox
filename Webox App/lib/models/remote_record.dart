import 'package:webox/models/remote_block.dart';

class RemoteRecord {
  final String id;
  final String? thumbnailURL;
  final String userId;
  final bool isVideoReady;
  final String updateStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RemoteBlock> blocks;

  const RemoteRecord(
      {required this.id,
      required this.thumbnailURL,
      required this.userId,
      required this.isVideoReady,
      required this.updateStatus,
      required this.createdAt,
      required this.updatedAt,
      required this.blocks});

  factory RemoteRecord.fromJson(Map<String, dynamic> json) => RemoteRecord(
      id: json['id'] as String,
      thumbnailURL: json['thumbnailURL'],
      userId: json['userId'] as String,
      isVideoReady: json['isVideoReady'] as bool,
      updateStatus: json['updateStatus'] as String,
      blocks:
          (json['blocks'] as List).map((e) => RemoteBlock.fromJson(e)).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updatedAt'] as String).toLocal());
}
