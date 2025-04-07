import 'package:flutter/material.dart';
import 'package:final_project/screens/home_screen.dart';
import 'package:final_project/constants.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryColor),
        ),
        drawer: buildDrawer(),
        body: getCurrentScreen(),
        bottomNavigationBar: buildCustomBottomAppBar(),
      ),
    );
  }

  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: primaryColor),
            child: Text('معرضي',
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(2);
            },
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text('Search'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(1);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(0);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(3);
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(4);
            },
          ),
        ],
      ),
    );
  }

  Widget buildCustomBottomAppBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: 25, right: 25),
      height: 45,
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildBottomIcon(Icons.trending_up_rounded, 4),
          buildBottomIcon(Icons.favorite_outline_rounded, 3),
          buildBottomIcon(Icons.home_outlined, 2),
          buildBottomIcon(Icons.notification_add_outlined, 1),
          buildBottomIcon(Icons.check_circle_outline_rounded, 0),
        ],
      ),
    );
  }

  Widget buildBottomIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _selectedIndex == index ? Colors.white : Colors.transparent,
        ),
        child: Icon(
          icon,
          color: _selectedIndex == index ? primaryColor : Colors.white,
          size: 30,
        ),
      ),
    );
  }

  Widget getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return Center(
            child: Text('تمت زيارتها', style: TextStyle(fontSize: 24)));
      case 1:
        return Center(child: Text('الإعلانات', style: TextStyle(fontSize: 24)));
      case 2:
        return HomeScreen();
      case 3:
        return Center(child: Text('المفضلة', style: TextStyle(fontSize: 24)));
      case 4:
        return Center(child: Text('الرائجة', style: TextStyle(fontSize: 24)));
      default:
        return Center(
            child: Text('شاشة غير معروفة', style: TextStyle(fontSize: 24)));
    }
  }
}
