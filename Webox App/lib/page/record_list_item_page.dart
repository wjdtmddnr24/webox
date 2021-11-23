import 'dart:io';

import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:webox/utils/camera.dart';

class RecordListItemPage extends StatefulWidget {
  const RecordListItemPage({Key? key}) : super(key: key);

  @override
  _RecordListItemPageState createState() => _RecordListItemPageState();
}

class _RecordListItemPageState extends State<RecordListItemPage> {
  VideoPlayerController? _controller;
  File? imageFile;

  Future<List<File>> getFiles() async {
    final String name = ModalRoute.of(context)!.settings.arguments as String;
    print('AAAA$name');
    final documentDirectory =
        Directory('${await getDocumentDirectoryPath()}/records/$name');
    final files = await documentDirectory.list(recursive: false).toList();
    return files.where((f) => f is File).map((e) => e as File).toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InitBuilder<Future<List<File>>>(
        getter: getFiles,
        builder: (context, future) => AsyncBuilder<List<File>>(
            future: future,
            waiting: (context) => Center(
                  child: CircularProgressIndicator(),
                ),
            builder: (context, value) => Column(
                  children: [
                    Expanded(
                        flex: 4,
                        child: Container(
                          child: _controller != null &&
                                  _controller!.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio: _controller!.value.aspectRatio,
                                  child: VideoPlayer(_controller!))
                              : (imageFile != null
                                  ? PhotoView(
                                      imageProvider: FileImage(imageFile!))
                                  : null),
                        )),
                    Expanded(
                        flex: 1,
                        child: Center(
                            child: ElevatedButton(
                          child: Text('Start'),
                          onPressed: () {
                            if (_controller != null &&
                                _controller!.value.isInitialized)
                              _controller!.play();
                          },
                        ))),
                    Expanded(
                        flex: 5,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: value!.length,
                            itemBuilder: (context, index) {
                              final name = p.basename(value[index].path);
                              return ListTile(
                                title: Text(name),
                                subtitle:
                                    Text(value[index].lengthSync().toString()),
                                onTap: () {
                                  _controller?.dispose();
                                  imageFile = null;
                                  if (name.endsWith('.mp4')) {
                                    _controller =
                                        VideoPlayerController.file(value[index])
                                          ..initialize()
                                              .then((value) => setState(() {}));
                                  } else {
                                    imageFile = value[index];
                                    setState(() {});
                                  }
                                },
                              );
                            }))
                  ],
                )));
  }
}
