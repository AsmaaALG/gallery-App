import 'package:final_project/screens/Active_screen.dart';
import 'package:final_project/screens/about_screen.dart';
import 'package:final_project/screens/ads_screen.dart';
import 'package:final_project/screens/favorite_screen.dart';
import 'package:final_project/screens/signIn_screen.dart';
import 'package:final_project/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/home_screen.dart';
import 'package:final_project/constants.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2;
  User? _user;

  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            decoration: BoxDecoration(color: primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 15,
                ),
                Text('معرضي',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: mainFont)),
                Text(
                  _user != null
                      ? _user!.email ?? ''
                      : 'البريد الإلكتروني غير متوفر',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      color: Colors.white, fontSize: 12, fontFamily: mainFont),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text(
              'الرئيسية',
              style: TextStyle(fontFamily: mainFont),
            ),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(2);
            },
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text(
              'الاشعارات',
              style: TextStyle(fontFamily: mainFont),
            ),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(1);
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'الحساب',
              style: TextStyle(fontFamily: mainFont),
            ),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(3);
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(
              'عن التطبيق',
              style: TextStyle(fontFamily: mainFont),
            ),
            onTap: () {
              Navigator.pop(context);
              _onItemTapped(0);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app_rounded,
              color: primaryColor,
            ),
            title: Text(
              'تسجيل الخروج',
              style: TextStyle(color: primaryColor, fontFamily: mainFont),
            ),
            onTap: () {
              Auth().signOut(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SignInScreen()), // تأكد من توجيه المستخدم إلى شاشة تسجيل الدخول
              );
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
        return AboutAppScreen();
      case 1:
        return AdsScreen();
      case 2:
        return HomeScreen();
      case 3:
        return FavoriteScreen();
      case 4:
        return ActiveScreen();
      default:
        return Center(
            child: Text('شاشة غير معروفة', style: TextStyle(fontSize: 24)));
    }
  }
}
