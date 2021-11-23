import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:webox/models/remote_record.dart';
import 'package:webox/services/record_service.dart';
import 'package:webox/utils/webox_routes.dart';
import 'package:webox/widgets/remote_record_list.dart';
import 'package:webox/widgets/remote_record_search_form.dart';
import 'package:webox/widgets/remote_record_stateless_list.dart';

class RemoteRecordListPage extends StatefulWidget {
  const RemoteRecordListPage({Key? key}) : super(key: key);

  @override
  _RemoteRecordListPageState createState() => _RemoteRecordListPageState();
}

class _RemoteRecordListPageState extends State<RemoteRecordListPage> {
  DateTime? _startDatetime;
  DateTime? _endDatetime;
  LatLng? _location;
  List<String>? _matchObjects;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: SingleChildScrollView(
                    child: Container(
                        child: Column(
                  children: [
                    RemoteRecordSearchForm(
                      onSearch: () async {
                        setState(() {});
                      },
                      onChange: (
                          {DateTime? startDateTime,
                          DateTime? endDateTime,
                          LatLng? location,
                          List<String>? matchObjects}) async {
                        _startDatetime = startDateTime;
                        _endDatetime = endDateTime;
                        _location = location;
                        _matchObjects = matchObjects;
                      },
                    ),
                    AsyncBuilder<List<RemoteRecord>>(
                        future: getRecordService().getRemoteRecords(
                            startDateTime: _startDatetime,
                            endDateTime: _endDatetime,
                            location: _location,
                            matchObjects: _matchObjects),
                        waiting: (context) =>
                            Container(child: CircularProgressIndicator()),
                        builder: (context, remoteRecordList) =>
                            RemoteRecordStatelessList(
                              remoteRecordList: remoteRecordList!,
                              limit: -1,
                              showNoneExists: true,
                              isOthers: false,
                            )),
                  ],
                ))))));
  }
}
