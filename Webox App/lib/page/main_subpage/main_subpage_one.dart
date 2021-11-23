import 'package:flutter/material.dart';
import 'package:webox/utils/webox_routes.dart';

class MainSubPageOne extends StatefulWidget {
  const MainSubPageOne({Key? key}) : super(key: key);

  @override
  _MainSubPageOneState createState() => _MainSubPageOneState();
}

class _MainSubPageOneState extends State<MainSubPageOne> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text('webox 앱을 종료하시겠습니까?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('취소')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('종료')),
                      ],
                    )) ??
            false;
      },
      child: Column(
        children: [
          Expanded(
              flex: 3,
              child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, WeboxRoutes.recordPage);
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 5.0),
                    child: Card(
                        child: Container(
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          SizedBox(width: 20),
                          Image.asset(
                            'assets/images/webox_img_5_1.png',
                            width: 100,
                            height: 100,
                          ),
                          Spacer(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '녹화하기',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '주행중 영상 녹화와 함께 실시간으로\n클라우드에 업로드를 합니다.',
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                          SizedBox(width: 20)
                        ],
                      ),
                    )),
                  ))),
          Expanded(
            flex: 3,
            child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, WeboxRoutes.remoteRecordListPage);
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                  child: Card(
                      child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 30),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '내 영상',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '클라우드에 업로드된\n나의 영상을 확인합니다.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                        Spacer(),
                        Image.asset(
                          'assets/images/webox_img_3.png',
                          width: 150,
                          height: 100,
                        ),
                        SizedBox(width: 20)
                      ],
                    ),
                  )),
                )),
          ),
          Expanded(
            flex: 3,
            child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, WeboxRoutes.remoteRecordListOthersPage);
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 10.0),
                  child: Card(
                      child: Container(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        SizedBox(width: 20),
                        Image.asset(
                          'assets/images/webox_img_4.png',
                          width: 125,
                          height: 100,
                        ),
                        SizedBox(width: 30),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '영상 검색',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '나에게 없는 다른사람의 영상을\n검색할 수 있습니다.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  )),
                )),
          ),
        ],
      ),
    );
  }
}
