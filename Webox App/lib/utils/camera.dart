import 'dart:io';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:webox/models/frame.dart';
import 'package:webox/models/record.dart';

Directory? documentDirectory;

Future<String> getDocumentDirectoryPath() async {
  if (documentDirectory == null)
    documentDirectory = await getApplicationDocumentsDirectory();
  return documentDirectory!.path;
}

Future<String> getRecordPath(Record record) async {
  return '${await getDocumentDirectoryPath()}/records/${record.name}';
}

Future<CameraController> getCameraController() async {
  final cameras = await availableCameras();
  final controller = CameraController(cameras[0], ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg);
  await controller.initialize();
  return controller;
}

Future<Frame> saveCameraImage(Frame frame, CameraImage image) async {
  await File(frame.path).writeAsBytes(image.planes[0].bytes);
  frame.status = FrameStatus.ImageSaved;
  // print('frame ${frame.offset} saved in ${frame.path}');
  return frame;
}
