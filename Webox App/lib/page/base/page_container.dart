import 'package:flutter/material.dart';

class PageContainer extends StatelessWidget {
  final String pageTitle;
  final Widget body;

  const PageContainer({Key? key, required this.pageTitle, required this.body})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pageTitle)),
      body: body,
    );
  }
}
