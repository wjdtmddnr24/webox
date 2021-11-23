import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:webox/models/block.dart';
import 'package:webox/models/record.dart';
import 'package:webox/models/remote_record.dart';
import 'package:webox/utils/account.dart';
import 'package:webox/widgets/remote_record_search_form.dart';

RecordService? _recordService;

Future<void> resetRecordService() async {
  final _userId = await getUserId();
  _recordService = RecordService(_userId!);
}

RecordService getRecordService() {
  return _recordService!;
}

class RecordService {
  static final String apiURL = 'https://api.we-box.io';
  late final Dio _dio;
  final String userId;

  RecordService(this.userId) {
    _dio = Dio(BaseOptions(baseUrl: apiURL, headers: {'userId': userId}));
  }

  Future<String> createRecord() async {
    final response = await _dio.post('/backup/record');
    return response.data!['id'];
  }

  Future<List<RemoteRecord>> getRemoteRecords(
      {DateTime? startDateTime,
      DateTime? endDateTime,
      LatLng? location,
      List<String>? matchObjects}) async {
    final dataParams = jsonEncode({
      'capturedAt': startDateTime != null && endDateTime != null
          ? {
              'start': startDateTime.toUtc().toString(),
              'end': endDateTime.toUtc().toString()
            }
          : null,
      'location': location != null
          ? {
              'longitude': location.longitude,
              'latitude': location.latitude,
              'distance': 50
            }
          : null,
      'match_objects': matchObjects
    });
    print(dataParams);
    final response = await _dio.post<List>('/search/record', data: dataParams);
    return response.data?.map((e) => RemoteRecord.fromJson(e)).toList() ?? [];
  }

  Future<List<RemoteRecord>> getOthersRemoteRecords(
      {DateTime? startDateTime,
        DateTime? endDateTime,
        LatLng? location,
        List<String>? matchObjects}) async {
    final dataParams = jsonEncode({
      'capturedAt': startDateTime != null && endDateTime != null
          ? {
        'start': startDateTime.toUtc().toString(),
        'end': endDateTime.toUtc().toString()
      }
          : null,
      'location': location != null
          ? {
        'longitude': location.longitude,
        'latitude': location.latitude,
        'distance': 50
      }
          : null,
      'match_objects': matchObjects
    });
    print(dataParams);
    final response = await _dio.post<List>('/search/record/others', data: dataParams);
    return response.data?.map((e) => RemoteRecord.fromJson(e)).toList() ?? [];
  }

  Future<String> sendBlockVideo(Record record, Block block) async {
    block.uploadStatus = UploadStatus.Uploading;
    final formData = FormData.fromMap({
      'offset': block.offset,
      'file': await MultipartFile.fromFile(block.path!),
      'metadata': {
        'createdAt': block.frames[0].capturedAt.toUtc().toString(),
        'location': block.frames[0].location?.toJson()
      }
    });
    final response = await _dio.post('/backup/record/${record.remoteId!}/block',
        data: formData);
    print('${response.data}');
    block.uploadStatus = UploadStatus.UploadComplete;
    return response.data!['id'];
  }

  Future<String> getRecordVideoURL(String recordId) async {
    final response = await _dio.get('/playback/record/$recordId');
    print(response.data!);
    return response.data!;
  }

  Future<void> finishUploadBlock(Record record) async {
    final response =
        await _dio.post('/backup/record/${record.remoteId!}/finish');
    print('/backup/record/${record.remoteId!}/finish');
    print(response);
    print(response.data!);
    print('all upload finished!!');
  }
}
