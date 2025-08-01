import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/screens/Active_screen.dart';
import 'package:final_project/screens/about_screen.dart';
import 'package:final_project/screens/ads_screen.dart';
import 'package:final_project/screens/edit_profile_screen.dart';
import 'package:final_project/screens/favorite_screen.dart';
import 'package:final_project/screens/signIn_screen.dart';
import 'package:final_project/screens/visited_screen.dart';
import 'package:final_project/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/home_screen.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/screens/notifications_screen.dart';

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

  Stream<int> getUnreadCount(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final seenBy = List<String>.from(doc['seenBy'] ?? []);
        return !seenBy.contains(userId);
      }).length;
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
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Builder(
              builder: (context) {
                return StreamBuilder<int>(
                  stream: getUnreadCount(_user!.uid),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;

                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: primaryColor,
                            size: 30,
                          ),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),
                        if (count > 0)
                          Positioned(
                            right: 3,
                            top: 12,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Image.asset(
                "images/logo.png",
                height: 40,
                width: 40,
              ),
            ),
          ],
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
          StreamBuilder<int>(
            stream: getUnreadCount(_user!.uid),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;

              return ListTile(
                leading: SizedBox(
                  width: 30,
                  height: 30,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications, size: 26),
                      if (count > 0)
                        Positioned(
                          right: -2, 
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 18, minHeight: 18),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                title: const Text(
                  'الإشعارات',
                  style: TextStyle(fontFamily: mainFont),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NotificationsScreen()),
                  );
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'الحساب',
              style: TextStyle(fontFamily: mainFont),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(
              'عن التطبيق',
              style: TextStyle(fontFamily: mainFont),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AboutAppScreen()));
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
                (Route<dynamic> route) => false,
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
        return VisitedScreen(currentUserId: _user!.uid);
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
