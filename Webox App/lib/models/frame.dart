import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

enum FrameStatus { ImageSaving, ImageSaved }

class Frame extends Equatable {
  final String path;
  final int offset;
  final DateTime capturedAt;
  Position? location;

  FrameStatus status = FrameStatus.ImageSaving;

  Frame(this.path, this.offset, this.capturedAt, {this.location});

  @override
  List<Object?> get props => [path, offset];
}
