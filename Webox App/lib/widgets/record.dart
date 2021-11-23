import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:webox/blocs/record/record_bloc.dart';

class RecordWidget extends StatefulWidget {
  final CameraController cameraController;

  const RecordWidget({Key? key, required this.cameraController})
      : super(key: key);

  @override
  _RecordWidgetState createState() => _RecordWidgetState();
}

class _RecordWidgetState extends State<RecordWidget> {
  bool _recordStarted = false;
  bool _alertDialogOpened = false;

  DateTime? _recordStartTime;
  DateTime? _recordStopRequestTime;
  Timer? _recordTimer;

  int _createdBlockCount = 0;
  int _uploadedBlockCount = 0;

  void _startOrStopRecord() {
    if (!_recordStarted) {
      _showProgressDialog('녹화 시작 준비중입니다...');
      context.read<RecordBloc>().add(RecordStartRequested());
    } else {
      setState(() {
        _recordTimer?.cancel();
        _recordTimer = null;
      });

      _showProgressDialog('녹화 종료중입니다...');
      context.read<RecordBloc>().add(RecordStopRequested());
    }
  }

  void _showProgressDialog(String message) {
    setState(() {
      _alertDialogOpened = true;
    });
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            content: SizedBox(
                height: 48,
                child: Row(children: [
                  CircularProgressIndicator(),
                  Text('      $message')
                ]))));
  }

  @override
  Widget build(BuildContext context) {
    print('$_uploadedBlockCount/$_createdBlockCount');
    return BlocConsumer<RecordBloc, RecordState>(
      builder: (context, state) {
        return OrientationBuilder(builder: (context, orientation) {
          return WillPopScope(
            onWillPop: () async {
              if (_recordStarted) {
                Fluttertoast.showToast(msg: '녹화 중에는 뒤로갈 수 없습니다.');
              }
              return !_recordStarted;
            },
            child: AspectRatio(
                aspectRatio: 9 / 16,
                child: CameraPreview(widget.cameraController,
                    child: Stack(children: [
                      Container(
                          padding: EdgeInsets.all(10.0),
                          alignment: Alignment.topRight,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  child: Text(
                                      'Created Blocks: $_createdBlockCount\nUploaded Blocks: $_uploadedBlockCount',
                                      style: TextStyle(color: Colors.white54)),
                                  padding: EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                      color: Colors.grey.withAlpha(150)),
                                )
                              ])),
                      Container(
                          alignment: Alignment.bottomCenter,
                          padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 110),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                  _recordStartTime != null &&
                                          _recordStopRequestTime != null
                                      ? _recordStopRequestTime!
                                          .difference(_recordStartTime!)
                                          .toString()
                                          .split('.')
                                          .first
                                          .padLeft(8, "0")
                                      : '00:00:00',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)))),
                      Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: _startOrStopRecord,
                            child: (!_recordStarted)
                                ? Stack(alignment: Alignment.center, children: [
                                    Icon(
                                      Icons.circle,
                                      size: 40,
                                      color: Colors.red,
                                    ),
                                    Icon(
                                      Icons.circle_outlined,
                                      size: 80,
                                      color: Colors.white,
                                    )
                                  ])
                                : Stack(alignment: Alignment.center, children: [
                                    Icon(
                                      Icons.stop,
                                      size: 50,
                                      color: Colors.white,
                                    ),
                                    Icon(
                                      Icons.circle_outlined,
                                      size: 80,
                                      color: Colors.white,
                                    )
                                  ]),
                          ))
                    ]))),
          );
        });
      },
      listener: (context, state) {
        if (state is RecordStartRequestSuccess) {
          if (_alertDialogOpened) {
            setState(() {
              _alertDialogOpened = false;
            });
            Navigator.of(context).pop();
          }
        }
        if (state is RecordStartSuccess) {
          setState(() {
            _recordStarted = true;
            _recordStartTime = DateTime.now();
            _recordTimer = Timer.periodic(Duration(seconds: 1), (timer) {
              setState(() {
                _recordStopRequestTime = DateTime.now();
              });
            });
          });
        }
        if (state is RecordStopRequestSuccess) {
          if (_alertDialogOpened) {
            setState(() {
              _alertDialogOpened = false;
            });
            Navigator.of(context).pop();
          }
        }
        if (state is RecordStopSuccess) {
          setState(() {
            _recordStarted = false;
            _recordStartTime = null;
            _createdBlockCount = 0;
            _uploadedBlockCount = 0;
          });
        }
        if (state is RecordBlockVideoCreatedSuccess) {
          if (_recordStarted)
            setState(() {
              _createdBlockCount = state.createdBlockCount;
            });
          print('$_uploadedBlockCount/$_createdBlockCount');
        }
        if (state is RecordBlockUploadSuccess) {
          if (_recordStarted)
            setState(() {
              _uploadedBlockCount = state.uploadedBlockCount;
            });
          print('$_uploadedBlockCount/$_createdBlockCount');
        }
      },
    );
  }
}
