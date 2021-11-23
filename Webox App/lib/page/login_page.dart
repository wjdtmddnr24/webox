import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webox/services/record_service.dart';
import 'package:webox/utils/account.dart';
import 'package:webox/utils/webox_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idTextEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
          padding: EdgeInsets.all(30),
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
              child: Column(
            children: [
              SizedBox(height: 80),
              Image.asset('assets/images/symbol-v-k-v2.png', width: 220),
              SizedBox(height: 80),
              TextField(
                controller: _idTextEditController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '아이디',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '비밀번호',
                ),
              ),
              SizedBox(height: 20),
              Container(
                  child: SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_idTextEditController.text.isNotEmpty) {
                              await setUserId(_idTextEditController.text);
                              await resetRecordService();
                              Navigator.popAndPushNamed(
                                  context, WeboxRoutes.mainPage);
                            } else {
                              Fluttertoast.showToast(msg: '아이디를 입력해주세요.');
                            }
                          },
                          child: Text('로그인', style: TextStyle(fontSize: 15))))),
            ],
          ))),
    ));
  }
}
