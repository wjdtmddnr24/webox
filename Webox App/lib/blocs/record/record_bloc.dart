import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:queue/queue.dart';
import 'package:sprintf/sprintf.dart';
import 'package:webox/models/block.dart';
import 'package:webox/models/frame.dart';
import 'package:webox/models/record.dart';
import 'package:webox/services/record_service.dart';
import 'package:webox/utils/camera.dart';
import 'package:webox/utils/ffmpeg.dart';

part 'record_event.dart';

part 'record_state.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  Record? record;
  final CameraController controller;
  final blockQueue = Queue(parallel: 1);
  final frameQueue = Queue(parallel: 1);
  final uploadQueue = Queue(parallel: 4);
  final RecordService recordService = getRecordService();
  bool recordStarted = false;

  Position? currentPosition;
  StreamSubscription<Position>? currentPositionStream;

  int createdBlockCount = 0;
  int uploadedBlockCount = 0;

  RecordBloc({required this.controller}) : super(RecordInitial()) {
    on<RecordStartRequested>(_onRecordStartRequested);
    on<RecordStarted>(_onRecordStarted);
    on<RecordFrameCaptured>(_onRecordFrameCaptured);
    on<RecordFrameSaved>(_onRecordFrameSaved);
    on<RecordBlockFrameGathered>(_onRecordBlockFrameGathered);
    on<RecordBlockVideoCreated>(_onRecordBlockVideoCreated);
    on<RecordBlockUploaded>(_onRecordBlockUploaded);
    on<RecordStopRequested>(_onRecordStopRequested);
    on<RecordStopped>(_onRecordStopped);
  }

  void _onRecordStartRequested(
      RecordStartRequested event, Emitter<RecordState> emit) async {
    final name = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    record = Record(name: name);

    await Directory(await getRecordPath(record!)).create(recursive: true);

    createdBlockCount = 0;
    uploadedBlockCount = 0;

    String remoteId = await recordService.createRecord();
    record!.remoteId = remoteId;
    print(remoteId);

    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    currentPositionStream = Geolocator.getPositionStream(
            desiredAccuracy: LocationAccuracy.bestForNavigation)
        .listen((Position? position) {
      print(position == null
          ? 'Unknown'
          : position.latitude.toString() +
              ', ' +
              position.longitude.toString());
      currentPosition = position;
    });

    emit(RecordStartRequestSuccess());
    add(RecordStarted());
  }

  void _onRecordStarted(RecordStarted event, Emitter<RecordState> emit) async {
    recordStarted = true;
    controller.startImageStream((image) =>
        add(RecordFrameCaptured(capturedAt: DateTime.now(), image: image)));

    emit(RecordStartSuccess());
  }

  void _onRecordFrameCaptured(
      RecordFrameCaptured event, Emitter<RecordState> emit) async {
    if (record!.recordStartedAt == null) {
      record!.recordStartedAt = event.capturedAt;
      record!.blocks.add(Block(offset: 0));
    }

    final elapsedMilliSecond =
        event.capturedAt.difference(record!.recordStartedAt!).inMilliseconds;

    // print('frame $elapsedMilliSecond received');

    final latestBlock = record!.blocks.last;
    if ((elapsedMilliSecond ~/ 1000) != (latestBlock.offset ~/ 1000)) {
      // if (((elapsedMilliSecond - latestBlock.offset) ~/ 1000 >= 3)) {
      latestBlock.status = BlockStatus.GatheringComplete;
      add(RecordBlockFrameGathered(latestBlock));
      record!.blocks.add(Block(offset: elapsedMilliSecond));
      // blockQueue.add(() => createVideoFromBlock(record!, latestBlock));
    }

    final targetBlock = record!.blocks.last;

    final path = '${await getRecordPath(record!)}/frame_${sprintf('%04d', [
          targetBlock.offset ~/ 1000
        ])}_${sprintf('%04d', [targetBlock.frames.length])}.jpg';
    final frame = Frame(path, elapsedMilliSecond, event.capturedAt,
        location: currentPosition);
    targetBlock.frames.add(frame);

    frameQueue.add(() => saveCameraImage(frame, event.image)).then(
        (frame) => add(RecordFrameSaved(block: targetBlock, frame: frame)));

    emit(RecordFrameCaptureSuccess(elapsedMilliSecond));
  }

  void _onRecordFrameSaved(
      RecordFrameSaved event, Emitter<RecordState> emit) async {
    final block = event.block;
    final frame = event.frame;
    // print('frame ${frame.offset} saved in block ${block.offset}');

    if (block.status == BlockStatus.GatheringComplete &&
        block.frames.every((f) => f.status == FrameStatus.ImageSaved)) {
      block.status = BlockStatus.VideoCreating;
      blockQueue
          .add(() => createVideoFromBlock(record!, block))
          .then((value) => add(RecordBlockVideoCreated(block)));
    }

    emit(RecordFrameSaveSuccess(frame));
  }

  void _onRecordBlockFrameGathered(
      RecordBlockFrameGathered event, Emitter<RecordState> emit) async {
    final block = event.block;
    print('block ${block.offset} gathered with ${block.frames.length} frames');
    if (block.status == BlockStatus.GatheringComplete &&
        block.frames.every((f) => f.status == FrameStatus.ImageSaved)) {
      block.status = BlockStatus.VideoCreating;
      blockQueue
          .add(() => createVideoFromBlock(record!, block))
          .then((value) => add(RecordBlockVideoCreated(block)));
    }
    emit(RecordBlockFrameGatherSuccess(block));
  }

  void _onRecordBlockVideoCreated(
      RecordBlockVideoCreated event, Emitter<RecordState> emit) async {
    createdBlockCount++;
    emit(RecordBlockVideoCreatedSuccess(createdBlockCount));

    final block = event.block;
    print('block ${block.offset} video created');

    await uploadQueue.add(() => recordService.sendBlockVideo(record!, block));
    add(RecordBlockUploaded(block));
  }

  void _onRecordBlockUploaded(
      RecordBlockUploaded event, Emitter<RecordState> emit) {
    uploadedBlockCount++;
    emit(RecordBlockUploadSuccess(uploadedBlockCount));

    final block = event.block;
    print('block ${block.offset} video uploaded');
  }

  void _onRecordStopRequested(
      RecordStopRequested event, Emitter<RecordState> emit) async {
    print('----------!!! record stop requested');
    recordStarted = false;
    controller.stopImageStream();
    currentPositionStream?.cancel();

    // blockQueue.add(() => concatVideos(record!));
    while (!record!.blocks.every((b) =>
        b.uploadStatus == UploadStatus.UploadComplete ||
        b.offset == record!.blocks.last.offset)) {
      await Future.delayed(Duration(milliseconds: 300));
    }
    await recordService.finishUploadBlock(record!);
    print('----------!!! record stop request done');

    emit(RecordStopRequestSuccess());
    add(RecordStopped());
  }

  void _onRecordStopped(RecordStopped event, Emitter<RecordState> emit) {
    emit(RecordStopSuccess());
  }
}
