import 'package:flutter/material.dart';
import 'package:webox/page/base/page_container.dart';
import 'package:webox/page/login_page.dart';
import 'package:webox/page/main_page.dart';
import 'package:webox/page/record_list_item_page.dart';
import 'package:webox/page/record_list_page.dart';
import 'package:webox/page/record_page.dart';
import 'package:webox/page/remote_record_list_item_others_page.dart';
import 'package:webox/page/remote_record_list_item_page.dart';
import 'package:webox/page/remote_record_list_others_page.dart';
import 'package:webox/page/remote_record_list_page.dart';
import 'package:webox/utils/webox_routes.dart';

class WeboxApp extends StatefulWidget {
  bool isLoggined;

  WeboxApp({Key? key, required this.isLoggined}) : super(key: key);

  @override
  _WeboxAppState createState() => _WeboxAppState();
}

class _WeboxAppState extends State<WeboxApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.light(
              primary: Color(0xff437dff), secondary: Color(0xff9fc6ff))),
      initialRoute:
          widget.isLoggined ? WeboxRoutes.mainPage : WeboxRoutes.loginPage,
      routes: {
        WeboxRoutes.mainPage: (context) => MainPage(),
        WeboxRoutes.loginPage: (context) => LoginPage(),
        WeboxRoutes.recordPage: (context) => RecordPage(),
        WeboxRoutes.recordListPage: (context) => PageContainer(
            pageTitle: ('Record List Page'), body: RecordListPage()),
        WeboxRoutes.recordListItemPage: (context) => PageContainer(
            pageTitle: 'Record List Item Page', body: RecordListItemPage()),
        WeboxRoutes.remoteRecordListPage: (context) => RemoteRecordListPage(),
        WeboxRoutes.remoteRecordListOthersPage: (context) =>
            RemoteRecordListOthersPage(),
        WeboxRoutes.remoteRecordListItemPage: (context) =>
            RemoteRecordListItemPage(),
        WeboxRoutes.remoteRecordListItemOthersPage: (context) =>
            RemoteRecordListItemOthersPage()
      },
    );
  }
}
