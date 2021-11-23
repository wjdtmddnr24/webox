import 'package:async_builder/async_builder.dart';
import 'package:async_builder/init_builder.dart';
import 'package:flutter/material.dart';
import 'package:webox/utils/account.dart';
import 'package:webox/utils/webox_routes.dart';

class MainSubPageThree extends StatefulWidget {
  const MainSubPageThree({Key? key}) : super(key: key);

  @override
  _MainSubPageThreeState createState() => _MainSubPageThreeState();
}

class _MainSubPageThreeState extends State<MainSubPageThree> {
  Future<String> initFuture() async {
    return (await getUserId())!;
  }

  @override
  Widget build(BuildContext context) {
    return InitBuilder<Future<String>>(
        getter: initFuture,
        builder: (context, future) => AsyncBuilder<String>(
            future: future,
            builder: (context, userId) => Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                    child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 4.0),
                          child: Text(
                            '환영합니다',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$userId',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30.0,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      0.0, 0.0, 0.0, 4.0),
                                  child: Text(' 님'),
                                )
                              ]),
                        ),
                        SizedBox(height: 20),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('작성한 커뮤니티 게시글 수: 0개'),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('영상 요청 수: 0개'),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('수신받은 쪽지: 0개'),
                        ),
                        Divider(),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            Spacer(),
                            ElevatedButton(
                                onPressed: () {
                                  clearUserId().then((value) =>
                                      Navigator.popAndPushNamed(
                                          context, WeboxRoutes.loginPage));
                                },
                                child: Text('로그아웃')),
                          ],
                        )
                      ],
                    ),
                  ),
                ))),
            waiting: (context) => Center(
                  child: CircularProgressIndicator(),
                )));
  }
}
