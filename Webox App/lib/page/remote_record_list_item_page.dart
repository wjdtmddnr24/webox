import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:webox/models/remote_record.dart';
import 'package:webox/services/record_service.dart';
import 'package:chewie/chewie.dart';

class RemoteRecordListItemPage extends StatefulWidget {
  const RemoteRecordListItemPage({Key? key}) : super(key: key);

  @override
  _RemoteRecordListItemPageState createState() =>
      _RemoteRecordListItemPageState();
}

class _RemoteRecordListItemPageState extends State<RemoteRecordListItemPage> {
  final RecordService recordService = getRecordService();

  late final RemoteRecord remoteRecord;
  bool _isGoogleMapLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: InitBuilder<Future<ChewieController>>(
                getter: getInitializedVideoPlayerController,
                disposer: (future) async {
                  final chewieController = await future;
                  chewieController.dispose();
                  chewieController.videoPlayerController.dispose();
                },
                builder: (context, future) => AsyncBuilder<ChewieController>(
                    future: future,
                    waiting: (context) =>
                        Center(child: CircularProgressIndicator()),
                    builder: (context, chewieController) {
                      final List<LatLng> points = remoteRecord.blocks
                          .where((element) =>
                              (element.metadata?.longitude != null &&
                                  element.metadata?.latitude != null))
                          .map((e) => LatLng(
                              e.metadata!.latitude!, e.metadata!.longitude!))
                          .toList();
                      final Set<Marker> markers = {};
                      final Set<Polyline> polylines = {};
                      polylines.add(Polyline(
                          color: Theme.of(context).colorScheme.primary,
                          polylineId: PolylineId(remoteRecord.id),
                          points: points));
                      if (points.length > 0) {
                        markers.add(Marker(
                            markerId: MarkerId('출발'), position: points.first));
                        markers.add(Marker(
                            markerId: MarkerId('도착'), position: points.last));
                      }

                      return Column(children: [
                        Container(
                            color: Colors.black,
                            height: 250,
                            child: Chewie(controller: chewieController!)),
                        Expanded(
                            flex: 6,
                            child: Container(
                                width: double.infinity,
                                child: Column(children: [
                                  Container(
                                      padding: EdgeInsets.all(10.0),
                                      alignment: Alignment.topLeft,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                DateFormat(
                                                        'yyyy-MM-dd HH:mm:ss')
                                                    .format(
                                                        remoteRecord.createdAt),
                                                style: TextStyle(fontSize: 16)),
                                            SizedBox(height: 4),
                                            Text('ID: ${remoteRecord.id}',
                                                style: TextStyle(fontSize: 12))
                                          ])),
                                  Divider(),
                                  Expanded(
                                      child: Container(
                                          padding: EdgeInsets.all(10.0),
                                          child: Stack(
                                            children: [
                                              GoogleMap(
                                                initialCameraPosition:
                                                    CameraPosition(
                                                        zoom: 16,
                                                        target:
                                                            points.length > 0
                                                                ? points[0]
                                                                : LatLng(
                                                                    126.873534,
                                                                    37.524782,
                                                                  )),
                                                polylines: polylines,
                                                markers: markers,
                                                onMapCreated: (_controller) =>
                                                    setState(() {
                                                  _isGoogleMapLoading = false;
                                                }),
                                              ),
                                              (_isGoogleMapLoading)
                                                  ? Container(
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    )
                                                  : Container()
                                            ],
                                          )))
                                ])))
                      ]);
                    }))));
  }

  Future<ChewieController> getInitializedVideoPlayerController() async {
    remoteRecord = ModalRoute.of(context)!.settings.arguments as RemoteRecord;
    final videoURL = await recordService.getRecordVideoURL(remoteRecord.id);

    final videoPlayerController = VideoPlayerController.network(videoURL);
    await videoPlayerController.initialize();
    final chewieController =
        ChewieController(videoPlayerController: videoPlayerController);

    return chewieController;
  }
}
