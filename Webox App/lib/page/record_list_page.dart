import 'dart:io';

import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:webox/utils/camera.dart';
import 'package:webox/utils/webox_routes.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({Key? key}) : super(key: key);

  @override
  _RecordListPageState createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  Future<List<Directory>> getRecords() async {
    final documentDirectory =
        Directory('${await getDocumentDirectoryPath()}/records');
    if (!(await documentDirectory.exists())) return [];
    final files = await documentDirectory.list(recursive: false).toList();
    final List<Directory> recordDirectories = [];
    for (final file in files) {
      final d = Directory(file.path);
      if (await d.exists()) {
        recordDirectories.add(d);
      }
    }
    return recordDirectories;
  }

  @override
  Widget build(BuildContext context) {
    return InitBuilder<Future<List<Directory>>>(
      getter: getRecords,
      builder: (context, future) => AsyncBuilder<List<Directory>>(
          future: future,
          waiting: (context) => Center(
                child: CircularProgressIndicator(),
              ),
          builder: (context, value) => ListView.builder(
              shrinkWrap: true,
              itemCount: value!.length,
              itemBuilder: (context, index) {
                final name = p.basename(value[index].path);
                return ListTile(
                  title: Text(name),
                  onTap: () {
                    Navigator.pushNamed(context, WeboxRoutes.recordListItemPage,
                        arguments: name);
                  },
                );
              })),
    );
  }
}
