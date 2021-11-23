import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webox/utils/webox_routes.dart';

class MainSubPageTwo extends StatefulWidget {
  const MainSubPageTwo({Key? key}) : super(key: key);

  @override
  _MainSubPageTwoState createState() => _MainSubPageTwoState();
}

class _MainSubPageTwoState extends State<MainSubPageTwo> {
  final List<CommunityListItemData> items = [
    CommunityListItemData(
        'user123',
        '울산에서 사고 블랙박스 영상 급구합니다 사례금 지급합니다ㅠ',
        '21년 10월 30일(토) 오후 2시 55분경 울산 남구 선암동 체육공원 앞 산업로(용연공단, 석유화학공단 방면)에 선암동 버스정류장 앞 부근에서 사고가 있었습니다....',
        DateTime.now()),
    CommunityListItemData(
        'otheruser123',
        '공사용 도로에서 사고가 났습니다. 도와주세요',
        '신형 투싼 차주입니다.\n아침에 비포장 도로 출근길 삼거리에서 자재 화물차량이 삼거리 가운데 서있었고...',
        DateTime.now()),
    CommunityListItemData(
        'auser123',
        '사고가 났는데 블랙박스 영상이 녹화가 안되어있습니다.',
        '차는 주차해놓은 정차차량 상태입니다.\n조수석 뒷 자리 문을 박아서 후방 카메라를 확인해야 할 거 같더라구요.\n블랙박스 업체 뷰어프로그램을 다운로드 해서 후방 영상을 켜보니까...',
        DateTime.now()),
    CommunityListItemData(
        'user123',
        '블랙박스 영상 구합니다 사례금 지급합니다',
        '21년 10월 20일(수) 서해안도로 화성휴게소(서울방향), 한국도로공사 화성지사 부근에서 16:58경 사고가 있었습니다.\n147로 시작하는 제네시스 차량이 갑자기 가속이 붙으면서 차체가 심하게 흔들리는 장면 목격하신 분 연락 부탁드립니다....',
        DateTime.now()),
    CommunityListItemData(
        'myuser123',
        '제가 잘못한게 무엇일까요?Feat. 분심위 1차결과 9:1',
        '21년 10월 20일(수) 서해안도로 화성휴게소(서울방향), 한국도로공사 화성지사 부근에서 16:58경 사고가 있었습니다.\n147로 시작하는 제네시스 차량이 갑자기 가속이 붙으면서 차체가 심하게 흔들리는 장면 목격하신 분 연락 부탁드립니다....',
        DateTime.now()),
    CommunityListItemData(
        'myuser123',
        '저와 상대방 중 보복신고 대상이 될 수 있는 상황인가요?',
        '21년 10월 20일(수) 서해안도로 화성휴게소(서울방향), 한국도로공사 화성지사 부근에서 16:58경 사고가 있었습니다.\n147로 시작하는 제네시스 차량이 갑자기 가속이 붙으면서 차체가 심하게 흔들리는 장면 목격하신 분 연락 부탁드립니다....',
        DateTime.now()),
    CommunityListItemData(
        'myuser123',
        '대구 월성동 조암초등학교앞 뺑소니 물피도주 찾습니다.',
        '21년 10월 20일(수) 서해안도로 화성휴게소(서울방향), 한국도로공사 화성지사 부근에서 16:58경 사고가 있었습니다.\n147로 시작하는 제네시스 차량이 갑자기 가속이 붙으면서 차체가 심하게 흔들리는 장면 목격하신 분 연락 부탁드립니다....',
        DateTime.now()),
    CommunityListItemData(
        'myuser123',
        '13일 오전 불암산터널 사고 목격자 블박 도움 부탁드립니다',
        '21년 10월 20일(수) 서해안도로 화성휴게소(서울방향), 한국도로공사 화성지사 부근에서 16:58경 사고가 있었습니다.\n147로 시작하는 제네시스 차량이 갑자기 가속이 붙으면서 차체가 심하게 흔들리는 장면 목격하신 분 연락 부탁드립니다....',
        DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.separated(
          itemCount: items.length,
          shrinkWrap: true,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) => ListTile(
                title: Text(items[index].title),
                subtitle: Text(items[index].userId +
                    ' - ' +
                    DateFormat('yyyy-MM-dd HH:mm aa')
                        .format(items[index].createdAt)),
              )),
    );
  }
}

class CommunityListItemData {
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;

  const CommunityListItemData(
      this.userId, this.title, this.content, this.createdAt);
}
