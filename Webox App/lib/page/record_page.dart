import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webox/blocs/record/record_bloc.dart';
import 'package:webox/utils/camera.dart';
import 'package:webox/utils/location.dart';
import 'package:webox/widgets/record.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({Key? key}) : super(key: key);

  @override
  _RecordPageState createState() => _RecordPageState();
}

Future<CameraController> initRecordPage(BuildContext context) async {
  try {
    await Permission.storage.request();
    await checkLocationPermission();
  } catch (e) {
    Navigator.pop(context);
  }
  return getCameraController();
}

class _RecordPageState extends State<RecordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
            alignment: Alignment.center,
            child: InitBuilder<Future<CameraController>>(
              getter: () => initRecordPage(context),
              disposer: (f) => f.then((controller) => controller.dispose()),
              builder: (context, future) => AsyncBuilder<CameraController>(
                  future: future,
                  waiting: (context) => Center(
                        child: CircularProgressIndicator(),
                      ),
                  builder: (context, cameraController) => BlocProvider(
                      create: (context) =>
                          RecordBloc(controller: cameraController!),
                      child: SafeArea(
                          child: RecordWidget(
                              cameraController: cameraController!)))),
            )));
  }
}
