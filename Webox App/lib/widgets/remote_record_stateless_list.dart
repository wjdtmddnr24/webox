import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:webox/models/remote_record.dart';
import 'package:webox/services/record_service.dart';
import 'package:webox/utils/webox_routes.dart';

class RemoteRecordStatelessList extends StatelessWidget {
  final List<RemoteRecord> remoteRecordList;
  final int limit;
  final bool showNoneExists;
  final bool isOthers;

  const RemoteRecordStatelessList(
      {Key? key,
      required this.remoteRecordList,
      required this.limit,
      required this.showNoneExists,
      required this.isOthers})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredRemotedRecords =
        remoteRecordList.where((r) => r.updateStatus == "done").toList();
    if (filteredRemotedRecords.length == 0 && showNoneExists)
      return Container(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 40.0, 0.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('업로드된 영상이 없습니다.', style: TextStyle(fontSize: 16)),
                if (!isOthers) Text('주행 영상을 녹화해보세요.'),
                SizedBox(height: 40.0),
                Image.asset('assets/images/webox_img_2.png',
                    width: 160, height: 160),
              ],
            ),
          ));
    return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: limit < 0 || filteredRemotedRecords.length < limit
            ? filteredRemotedRecords.length
            : limit,
        itemBuilder: (context, index) => ListTile(
              isThreeLine: true,
              title: Text(DateFormat('yyyy-MM-dd HH:mm:ss')
                  .format(filteredRemotedRecords[index].createdAt)),
              subtitle: Text((isOthers
                      ? '영상 보유자: ${filteredRemotedRecords[index].userId}\n'
                      : '') +
                  '상태: ${filteredRemotedRecords[index].isVideoReady ? '업로드 완료' : '처리중'}' +
                  ' | 길이: 약 ${filteredRemotedRecords[index].blocks.length - 1}초'),
              leading: Container(
                width: 40,
                child: filteredRemotedRecords[index].thumbnailURL != null
                    ? CachedNetworkImage(
                        imageUrl: filteredRemotedRecords[index].thumbnailURL!,
                        fit: BoxFit.fitWidth,
                      )
                    : Icon(
                        Icons.video_library,
                        size: 50,
                      ),
              ),
              onTap: () {
                Navigator.pushNamed(
                    context,
                    isOthers
                        ? WeboxRoutes.remoteRecordListItemOthersPage
                        : WeboxRoutes.remoteRecordListItemPage,
                    arguments: filteredRemotedRecords[index]);
              },
            ));
  }
}
