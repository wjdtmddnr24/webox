import 'dart:ui';

import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:webox/models/remote_record.dart';
import 'package:webox/services/record_service.dart';
import 'package:chewie/chewie.dart';

class RemoteRecordListItemOthersPage extends StatefulWidget {
  const RemoteRecordListItemOthersPage({Key? key}) : super(key: key);

  @override
  _RemoteRecordListItemOthersPageState createState() =>
      _RemoteRecordListItemOthersPageState();
}

class _RemoteRecordListItemOthersPageState
    extends State<RemoteRecordListItemOthersPage> {
  RemoteRecord? remoteRecord;

  bool _isGoogleMapLoading = true;

  @override
  Widget build(BuildContext context) {
    if (remoteRecord == null)
      remoteRecord = ModalRoute.of(context)!.settings.arguments as RemoteRecord;

    final List<LatLng> points = remoteRecord!.blocks
        .where((element) => (element.metadata?.longitude != null &&
            element.metadata?.latitude != null))
        .map((e) => LatLng(e.metadata!.latitude!, e.metadata!.longitude!))
        .toList();
    final Set<Marker> markers = {};
    final Set<Polyline> polylines = {};
    polylines.add(Polyline(
        color: Theme.of(context).colorScheme.primary,
        polylineId: PolylineId(remoteRecord!.id),
        points: points));
    if (points.length > 0) {
      markers.add(Marker(markerId: MarkerId('출발'), position: points.first));
      markers.add(Marker(markerId: MarkerId('도착'), position: points.last));
    }
    return Scaffold(
        body: SafeArea(
            child: Column(children: [
      SizedBox(
          height: 250,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                  imageUrl: remoteRecord!.thumbnailURL!, fit: BoxFit.cover),
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '이 영상은 다른 유저의 영상입니다.\n해당 유저에게 영상을 요청해보세요.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text('영상 요청'),
                                        content: Text(
                                            '${remoteRecord!.userId}님에게 해당 영상을 요청하시겠습니까?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        '${remoteRecord!.userId}님에게 영상을 요청했습니다.');
                                                Navigator.pop(context);
                                              },
                                              child: Text('예')),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('아니오')),
                                        ],
                                      ));
                            },
                            child: Text('요청하기'))
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
      Expanded(
          flex: 6,
          child: Container(
              width: double.infinity,
              child: Column(children: [
                Container(
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.topLeft,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              DateFormat('yyyy-MM-dd HH:mm:ss')
                                  .format(remoteRecord!.createdAt),
                              style: TextStyle(fontSize: 16)),
                          SizedBox(height: 4),
                          Text('ID: ${remoteRecord!.id}',
                              style: TextStyle(fontSize: 12))
                        ])),
                Divider(),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: CameraPosition(
                                  zoom: 16,
                                  target: points.length > 0
                                      ? points[0]
                                      : LatLng(
                                          126.873534,
                                          37.524782,
                                        )),
                              polylines: polylines,
                              markers: markers,
                              onMapCreated: (_controller) => setState(() {
                                _isGoogleMapLoading = false;
                              }),
                            ),
                            (_isGoogleMapLoading)
                                ? Container(
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                : Container()
                          ],
                        )))
              ])))
    ])));
  }
}
