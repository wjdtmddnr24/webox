part of 'record_bloc.dart';

abstract class RecordEvent extends Equatable {
  const RecordEvent();

  @override
  List<Object> get props => [];
}

class RecordStartRequested extends RecordEvent {}

class RecordStarted extends RecordEvent {}

class RecordFrameCaptured extends RecordEvent {
  const RecordFrameCaptured({required this.capturedAt, required this.image})
      : super();

  final DateTime capturedAt;
  final CameraImage image;

  @override
  List<Object> get props => [capturedAt, image];
}

class RecordFrameSaved extends RecordEvent {
  final Block block;
  final Frame frame;

  const RecordFrameSaved({required this.block, required this.frame});

  @override
  List<Object> get props => [block, frame];
}

class RecordBlockFrameGathered extends RecordEvent {
  final Block block;

  const RecordBlockFrameGathered(this.block);

  @override
  List<Object> get props => [block];
}

class RecordBlockVideoCreated extends RecordEvent {
  final Block block;

  const RecordBlockVideoCreated(this.block);

  @override
  List<Object> get props => [block];
}

class RecordBlockUploaded extends RecordEvent {
  final Block block;

  const RecordBlockUploaded(this.block);

  @override
  List<Object> get props => [block];
}

class RecordStopRequested extends RecordEvent {}

class RecordStopped extends RecordEvent {}
