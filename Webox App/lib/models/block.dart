import 'package:equatable/equatable.dart';
import 'package:webox/models/frame.dart';

enum BlockStatus {
  GatheringFrames,
  GatheringComplete,
  VideoCreating,
  VideoCreated
}

enum UploadStatus { Pending, Uploading, UploadComplete }

class Block extends Equatable {
  final int offset;
  final List<Frame> frames = [];

  BlockStatus status = BlockStatus.GatheringFrames;
  UploadStatus uploadStatus = UploadStatus.Pending;
  String? path;

  Block({required this.offset});

  @override
  List<Object?> get props => [offset, frames];
}
