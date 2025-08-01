import 'package:final_project/constants.dart';
import 'package:flutter/material.dart';
import '../services/ads_services.dart';
import '../widgets/ad_card.dart';
import '../models/ad_model.dart';

class AdsScreen extends StatelessWidget {
  final AdsServices adsServices = AdsServices();

  AdsScreen({super.key});

  DateTime _parseDate(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return DateTime.now();
    final day = int.tryParse(parts[0]) ?? 1;
    final month = int.tryParse(parts[1]) ?? 1;
    final year = int.tryParse(parts[2]) ?? DateTime.now().year;
    return DateTime(year, month, day);
  }

  // Future<List<AdModel>> _filterAndSortAds(List<AdModel> ads) async {
  //   final now = DateTime.now();
  //   final today = DateTime(now.year, now.month, now.day);

  //   // await adsServices.deleteExpiredAds();

  //   // نقل الإعلانات التي وصلت إلى تاريخ اليوم إلى مجموعة جديدة
  //   // for (final ad in ads) {
  //   //   final startAd = _parseDate(ad.startDate);
  //   //   if (startAd.isBefore(today) || startAd.isAtSameMomentAs(today)) {
  //   //     await adsServices.moveAdToCollection(ad, '2', ad.startDate);
  //   //   }
  //   // }

  //   final filteredAds = ads.where((ad) {
  //     try {
  //       final stopAd = _parseDate(ad.stopAd);
  //       return stopAd.isAfter(today) || stopAd.isAtSameMomentAs(today);
  //     } catch (e) {
  //       return false;
  //     }
  //   }).toList();

  //   filteredAds.sort(
  //       (a, b) => _parseDate(a.startDate).compareTo(_parseDate(b.startDate)));

  //   return filteredAds;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25.0, 0, 25.0, 25.0),
        child: FutureBuilder<List<AdModel>>(
          future: adsServices.getAds(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                'حدث خطأ أثناء تحميل البيانات',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: mainFont,
                  fontWeight: FontWeight.w100,
                ),
              ));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(
                'لا توجد إعلانات فعالة حالياً',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: mainFont,
                  fontWeight: FontWeight.w100,
                ),
              ));
            }

            final activeAds = snapshot.data!;

            return ListView(
              children: [
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
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 40),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 239, 211, 211),
                          width: 1,
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
                ...activeAds.map((ad) => AdCard(ad: ad)).toList(),
              ],
            );
          },
        ),
      ),
    );
  }
}
