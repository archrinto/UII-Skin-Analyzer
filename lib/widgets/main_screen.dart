import 'package:flutter/material.dart';

import './home_screen.dart';
import './profile/profile_screen.dart';
import './history/history_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  static const routeName = '/home';

  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var _selectedIndex = 0;

  static final List _pages = <Widget>[
    const HomeScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(
      () {
        _selectedIndex = index;
      },
    );
  }

  final List _bottomNavBarItem = const [
    {
      'index': 0,
      'text': 'Beranda',
      'icon': Icons.home,
    },
    {
      'index': 1,
      'text': 'Riwayat',
      'icon': Icons.bookmark,
    },
    {
      'index': 2,
      'text': 'Profil',
      'icon': Icons.person,
    },
  ];

  @override
  void initState() {
    _selectedIndex = widget.initialIndex;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF5FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset('assets/icons/logo-home.png'),
                Image.asset('assets/icons/logo-uii.png'),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: _pages[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFEFF5FF),
        elevation: 0,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        unselectedLabelStyle: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
        selectedLabelStyle: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
        items: _bottomNavBarItem.map(
          (item) {
            return BottomNavigationBarItem(
              label: item['text'],
              icon: Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: (_selectedIndex == item['index']) ? const Color(0xFF62BBE2) : Colors.transparent),
                child: Icon(item['icon'], color: (_selectedIndex == item['index']) ? Colors.white : const Color(0xFF62BBE2)),
              ),
            );
          },
        ).toList(),
      ),
    );
  }
}
