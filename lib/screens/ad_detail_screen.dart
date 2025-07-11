import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/screens/reservation_screen.dart';
import 'package:final_project/services/ads_services.dart';
import 'package:final_project/services/shared_sevices.dart';
import 'package:flutter/material.dart';
import 'package:final_project/models/ad_model.dart';
import 'package:final_project/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AdDetailScreen extends StatelessWidget {
  final AdModel ad;
    final AdsServices _adsServices = AdsServices();


  AdDetailScreen({super.key, required this.ad});
 

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBF3F3),
      appBar: AppBar(
        backgroundColor: Color(0xFFEADDDA),
        title: Text('تفاصيل المعرض',
            style: TextStyle(
              fontSize: 17,
              fontFamily: mainFont,
              color: const Color.fromARGB(255, 96, 3, 6),
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المعرض (دائرية وفي المنتصف)
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    // إضافة border للصورة
                    color: Color.fromARGB(255, 209, 180, 180), // لون البورد
                    width: 1, // سماكة البورد
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 235, 208, 208)
                          .withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    ad.imageUrl.isNotEmpty
                        ? ad.imageUrl // التعديل هنا
                        : 'https://via.placeholder.com/300x200.png?text=No+Image',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // عنوان المعرض (في المنتصف)
            Center(
              child: Text(
                ad.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: mainFont,
                  color: const Color.fromRGBO(166, 23, 28, 1),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            // مربع معلومات التاريخ والموقع
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 242, 197, 197)
                        .withOpacity(0.3),
                    spreadRadius: 4,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // صف التاريخ المعدل
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          ad.endDate,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: mainFont,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'إلى',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: mainFont,
                            color: primaryColor,
                            // نفس لون الأيقونات
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          ad.startDate,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: mainFont,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.calendar_today,
                            color: primaryColor, size: 17),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey[300], height: 10),
                  FutureBuilder<String>(
                    future:  SharedSevices().fetchCityName(ad.city),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildInfoRow(
                            Icons.location_on, 'جاري التحميل...');
                      } else if (snapshot.hasError) {
                        return _buildInfoRow(
                            Icons.location_on, 'خطأ في تحميل المدينة');
                      } else {
                        return _buildInfoRow(
                            Icons.location_on, snapshot.data ?? '');
                      }
                    },
                  ),
                  Divider(color: Colors.grey[300], height: 10),

                  FutureBuilder<String>(
                    future:  SharedSevices().fetchCompanyName(ad.company_id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildInfoRow(Icons.person, 'جاري التحميل...');
                      } else if (snapshot.hasError) {
                        return _buildInfoRow(
                            Icons.person, 'خطأ في تحميل المنظم');
                      } else {
                        return _buildInfoRow(Icons.business_outlined,
                            'المنظم : ${snapshot.data ?? ''}');
                      }
                    },
                  ),
                  Divider(color: Colors.grey[300], height: 10),
                  GestureDetector(
                    onTap: () => SharedSevices().launchMap(ad.location),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Text(
                          'اضغط للإنتقال للموقع',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: mainFont,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.map, color: primaryColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                width: double.infinity,
                child: Text(
                  ad.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: mainFont,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 55),

            // زر الحجز
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 241, 192, 69),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationScreen(ad: ad),
                    ),
                  );
                },
                child: Text(
                  'حجز مساحة',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 37, 36, 36),
                    fontSize: 16,
                    fontFamily: mainFont,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 55),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            // ✅ هذا يجعل النص يأخذ فقط ما يسمح به من المساحة
            child: Text(
              text,
              softWrap: true,
              maxLines: 3,
              overflow: TextOverflow
                  .ellipsis, // ✅ يمنع الخروج ويضع (...) إذا كان طويل
              style: TextStyle(
                fontSize: 13,
                fontFamily: mainFont,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 5),
          Icon(icon, color: primaryColor),
        ],
      ),
    );
  }
}
