import 'package:final_project/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/constants.dart';

//طريقة ايجاد نسبة النجوم
//(عدد التقييمات ×5 \مجموع التقييمات)×5
class GalleryCard extends StatefulWidget {
  final String id;
  final String imageUrl;
  final String name;
  final String description;
  final String location;
  final int visitors;
  final double rating;
  final String endDate;

  const GalleryCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.location,
    required this.visitors,
    required this.rating,
    required this.endDate,
    required this.id,
  }) : super(key: key);

  @override
  _GalleryCardState createState() => _GalleryCardState();
}

class _GalleryCardState extends State<GalleryCard> {
  bool isFavorite = false;

  // دالة للتحقق مما إذا كان المعرض مغلقاً أم لا
  bool isClosed() {
    final endDate = DateFormat('DD/MM/yyyy').parse(widget.endDate);
    return DateTime.now().isAfter(endDate);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBackground,
      elevation: 3,
      margin: EdgeInsets.fromLTRB(25, 10, 25, 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? primaryColor : Colors.grey,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite; // عكس حالة القلب عند الضغط
                  });
                },
              ),
            ),
            // الصورة في المنتصف
            Center(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // اسم المعرض
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          widget.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: mainFont,
                              color: primaryColor),
                        ),
                      ),
                      // الوصف
                      Text(
                        widget.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontFamily: mainFont, fontSize: 9),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      // الموقع
                      Text(
                        "الموقع: ${widget.location}",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontFamily: mainFont,
                            fontSize: 9,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('عدد الزوار: ${widget.visitors}'),
                    // // حالة المعرض (مفتوح أو مغلق)
                    // const SizedBox(height: 4),
                    Text(
                      isClosed() ? ' مغلق' : ' مفتوح',
                      style: TextStyle(
                          color: isClosed() ? primaryColor : Colors.green,
                          fontFamily: mainFont,
                          fontSize: 12),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    // النجوم

                    FutureBuilder<double>(
                        future: FirestoreService().calculateRating(widget.id),
                        builder: (context, snapshot) {

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // عرض مؤشر التحميل
                          } else if (snapshot.hasError) {
                            return Text('??');
                          } else {
                            double stars = snapshot.data ?? 0.0;
                            return Row(children: [
                              Text(
                                stars.toStringAsFixed(1), // عرض عدد النجوم
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 11),
                              ),
                              SizedBox(width: 3),
                              Icon(
                                Icons.star,
                                color: secondaryColor,
                                size: 15,
                              )
                            ]);
                          }
                        }),

                    // Row(children: const [
                    //   Text(
                    //     '4.5',
                    //     style: TextStyle(color: Colors.grey, fontSize: 11),
                    //   ),
                    //   SizedBox(
                    //     width: 3,
                    //   ),
                    //   Icon(
                    //     Icons.star,
                    //     color: secondaryColor,
                    //     size: 15,
                    //   ),
                    // ]),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
