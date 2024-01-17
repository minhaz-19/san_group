import 'package:flutter/material.dart';
import 'package:san_group/pages/leave_approval.dart';
import 'package:san_group/outside_office_approval.dart';
import 'package:san_group/pages/tour_approval.dart';

class my_team extends StatefulWidget {
  const my_team({super.key});

  @override
  State<my_team> createState() => _my_teamState();
}

class _my_teamState extends State<my_team> {
  Future<bool> _onWillPop() async {
    return (_selectedIndex == 0 ? true : set_index_to_zero());
  }

  bool set_index_to_zero() {
    setState(() {
      _selectedIndex = 0;
    });
    return false;
  }

  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    outside_office_entry_approval(),
    tour_approval(),
    leave_approval(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          unselectedIconTheme: IconThemeData(
            color: Colors.blueGrey,
          ),
          selectedIconTheme: IconThemeData(
            color: Colors.redAccent,
          ),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('images/outside.png'),
              ),
              label: 'Outside Approval',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('images/tour.png'),
              ),
              label: 'Tour Approval',
            ),
            BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage('images/leave.png'),
              ),
              label: 'Leave Approval',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
