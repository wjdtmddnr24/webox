import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:webox/models/remote_record.dart';
import 'package:webox/services/record_service.dart';
import 'package:webox/utils/webox_routes.dart';

class RemoteRecordList extends StatelessWidget {
  final int? limit;
  final DateTime? startDatetime;
  final DateTime? endDatetime;
  final LatLng? location;
  final List<String>? matchObjects;

  const RemoteRecordList({
    Key? key,
    this.limit,
    this.startDatetime,
    this.endDatetime,
    this.location,
    this.matchObjects,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<List<RemoteRecord>>(
        future: getRecordService().getRemoteRecords(
            startDateTime: startDatetime,
            endDateTime: endDatetime,
            location: location,
            matchObjects: matchObjects),
        waiting: (context) => Center(child: CircularProgressIndicator()),
        builder: (context, remoteRecords) {
          final filteredRemotedRecords =
              remoteRecords?.where((r) => r.updateStatus == "done").toList();
          if (filteredRemotedRecords == null ||
              filteredRemotedRecords.length == 0) {
            return Container(
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('업로드된 영상이 없습니다.',
                        style: DefaultTextStyle.of(context)
                            .style
                            .apply(fontSizeFactor: 1.2)),
                    Text('주행 영상을 녹화해보세요.')
                  ],
                ));
          } else {
            return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount:
                    limit == null || filteredRemotedRecords.length < limit!
                        ? filteredRemotedRecords.length
                        : limit,
                itemBuilder: (context, index) => ListTile(
                      isThreeLine: true,
                      title: Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                          .format(filteredRemotedRecords[index].createdAt)),
                      subtitle: Text(filteredRemotedRecords[index].id +
                          '\n[${filteredRemotedRecords[index].isVideoReady ? '업로드 완료' : '처리중'}]'),
                      leading: Container(
                        width: 40,
                        child:
                            filteredRemotedRecords[index].thumbnailURL != null
                                ? Image.network(
                                    filteredRemotedRecords[index].thumbnailURL!,
                                    fit: BoxFit.fitWidth,
                                  )
                                : Icon(
                                    Icons.video_library,
                                    size: 50,
                                  ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                            context, WeboxRoutes.remoteRecordListItemPage,
                            arguments: filteredRemotedRecords[index]);
                      },
                    ));
          }
        });
  }
}
/*

class RemoteRecordList extends StatefulWidget {
  final int? limit;
  final DateTime? startDatetime;
  final DateTime? endDatetime;
  final LatLng? location;
  final List<String>? matchObjects;

  const RemoteRecordList(
      {Key? key,
      this.limit,
      this.startDatetime,
      this.endDatetime,
      this.location,
      this.matchObjects})
      : super(key: key);

  @override
  _RemoteRecordListState createState() => _RemoteRecordListState();
}

class _RemoteRecordListState extends State<RemoteRecordList> {
  final RecordService recordService = RecordService();

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder<List<RemoteRecord>>(
        future: recordService.getRemoteRecords(
            startDateTime: widget.startDatetime,
            endDateTime: widget.endDatetime,
            location: widget.location,
            matchObjects: widget.matchObjects),
        waiting: (context) => Center(child: CircularProgressIndicator()),
        builder: (context, remoteRecords) {
          final filteredRemotedRecords =
              remoteRecords?.where((r) => r.isVideoReady).toList();
          if (filteredRemotedRecords == null ||
              filteredRemotedRecords.length == 0) {
            return Expanded(
                child: Container(
                    child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('업로드된 영상이 없습니다.',
                    style: DefaultTextStyle.of(context)
                        .style
                        .apply(fontSizeFactor: 1.2)),
                Text('주행 영상을 녹화해보세요.')
              ],
            )));
          } else {
            return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: widget.limit == null ||
                        filteredRemotedRecords.length < widget.limit!
                    ? filteredRemotedRecords.length
                    : widget.limit,
                itemBuilder: (context, index) => ListTile(
                      isThreeLine: true,
                      title: Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                          .format(filteredRemotedRecords[index].createdAt)),
                      subtitle: Text(filteredRemotedRecords[index].id),
                      leading: Container(
                        width: 40,
                        child:
                            filteredRemotedRecords[index].thumbnailURL != null
                                ? Image.network(
                                    filteredRemotedRecords[index].thumbnailURL!,
                                    fit: BoxFit.fitWidth,
                                  )
                                : Icon(
                                    Icons.video_library,
                                    size: 50,
                                  ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                            context, WeboxRoutes.remoteRecordListItemPage,
                            arguments: filteredRemotedRecords[index].id);
                      },
                    ));
          }
        });
  }
}
*/
