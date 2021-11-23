import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webox/app.dart';
import 'package:webox/services/record_service.dart';
import 'package:webox/utils/account.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xff325EBF),
  ));
  final _userId = await getUserId();

  if (_userId != null)
    resetRecordService();

  runApp(WeboxApp(
    isLoggined: await isLogined(),
  ));
}
