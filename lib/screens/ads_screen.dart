import 'package:final_project/constants.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/ad_card.dart';
import '../models/ad_model.dart';

class AdsScreen extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  // دالة لتحويل تاريخ String إلى DateTime
  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return DateTime.now();
    final day = int.tryParse(parts[0]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final year = int.tryParse(parts[2]) ?? DateTime.now().year;
    return DateTime(year, month, day);
  }

  // دالة لترتيب وتصفية الإعلانات
  List<AdModel> _filterAndSortAds(List<AdModel> ads) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ads.where((ad) {
      try {
        final stopAd = _parseDate(ad.stopAd);
        return stopAd.isAfter(today) || stopAd.isAtSameMomentAs(today);
      } catch (e) {
        return false;
      }
    }).toList()
      ..sort(
          (a, b) => _parseDate(a.startDate).compareTo(_parseDate(b.startDate)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25.0, 0, 25.0, 25.0),
        child: FutureBuilder<List<AdModel>>(
          future: firestoreService.getAds(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('حدث خطأ أثناء تحميل البيانات');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('لا توجد بيانات حالياً');
            }

            // تصفية وترتيب الإعلانات
            final filteredAds = _filterAndSortAds(snapshot.data!);

            if (filteredAds.isEmpty) {
              return Center(child: Text('لا توجد إعلانات فعالة حالياً'));
            }

            return ListView(
              children: [
                // العنوان الجديد
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'الإعلانات',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontFamily: mainFont,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(166, 23, 28, 1),
                    ),
                  ),
                ),
                // Container مع الظل والأيقونة
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 40),
                      decoration: BoxDecoration(
                        border: Border.all(
                          // إضافة border
                          color:
                              Color.fromARGB(255, 239, 211, 211), // لون البورد
                          width: 1, // سماكة البورد
                        ),
                        color: Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                          bottomLeft: Radius.circular(0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 223, 209, 209)
                                .withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 7,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'كن جزءاً من الحدث ... حيث يلتقي الشغف بالابتكار!',
                        style: TextStyle(
                          fontSize: 13,
                          fontFamily: mainFont,
                          color: const Color.fromARGB(255, 62, 5, 7),
                          fontWeight: FontWeight.w100,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // أيقونة الجرس
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.notifications,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                ...filteredAds.map((ad) => AdCard(ad: ad)).toList(),
              ],
            );
          },
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.favorite), label: ''),
      //     BottomNavigationBarItem(icon: Icon(Icons.category), label: ''),
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
      //     BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: ''),
      //   ],
      //   selectedItemColor: Color(0xFFF4C94C),
      //   unselectedItemColor: Colors.grey,
      //   showSelectedLabels: false,
      //   showUnselectedLabels: false,
      // ),
    );
  }
}
