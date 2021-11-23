part of 'record_bloc.dart';

abstract class RecordState extends Equatable {
  const RecordState();

  @override
  List<Object> get props => [];
}

class RecordInitial extends RecordState {
  const RecordInitial();
}

class RecordStartRequestSuccess extends RecordState {
  const RecordStartRequestSuccess();
}

class RecordStartSuccess extends RecordState {
  const RecordStartSuccess();
}

class RecordStartFailure extends RecordState {
  const RecordStartFailure();
}

class RecordBlockVideoCreatedSuccess extends RecordState {
  final int createdBlockCount;

  const RecordBlockVideoCreatedSuccess(this.createdBlockCount);
}

class RecordBlockUploadSuccess extends RecordState {
  final int uploadedBlockCount;

  const RecordBlockUploadSuccess(this.uploadedBlockCount);
}

class RecordStopRequestSuccess extends RecordState {
  const RecordStopRequestSuccess();
}

class RecordStopSuccess extends RecordState {
  const RecordStopSuccess();
}

class RecordStopFailure extends RecordState {
  const RecordStopFailure();
}

class RecordFrameCaptureSuccess extends RecordState {
  final elapsedMillisecond;

  const RecordFrameCaptureSuccess(this.elapsedMillisecond);

  @override
  List<Object> get props => [elapsedMillisecond];
}

class RecordFrameCaptureFailure extends RecordState {
  const RecordFrameCaptureFailure();
}

class RecordFrameSaveSuccess extends RecordState {
  final Frame frame;

  const RecordFrameSaveSuccess(this.frame);

  @override
  List<Object> get props => [frame];
}

class RecordBlockFrameGatherSuccess extends RecordState {
  final Block block;

  const RecordBlockFrameGatherSuccess(this.block);
}
