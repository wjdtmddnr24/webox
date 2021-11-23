import 'package:webox/models/remote_block_metadata.dart';

class RemoteBlock {
  final String id;
  final int offset;
  final RemoteBlockMetadata? metadata;

  const RemoteBlock(
      {required this.id, required this.offset, required this.metadata});

  factory RemoteBlock.fromJson(Map<String, dynamic> json) => RemoteBlock(
      id: json['id'] as String,
      offset: json['offset'] as int,
      metadata: json['metadata'] != null
          ? RemoteBlockMetadata.fromJson(json['metadata'])
          : null);
}
