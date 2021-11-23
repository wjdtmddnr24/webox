import 'package:flutter/material.dart';
import 'package:webox/page/main_subpage/main_subpage_one.dart';
import 'package:webox/page/main_subpage/main_subpage_three.dart';
import 'package:webox/page/main_subpage/main_subpage_two.dart';
import 'package:webox/utils/webox_routes.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedPageIndex = 0;

  static const List<Widget> _mainSubPages = <Widget>[
    MainSubPageOne(),
    MainSubPageTwo(),
    MainSubPageThree()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Webox'),),
      body: _mainSubPages.elementAt(_selectedPageIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Colors.white,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection_rounded),
            label: '녹화/영상',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '커뮤니티',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
        currentIndex: _selectedPageIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
