import 'package:final_project/constants.dart';
import 'package:flutter/material.dart';
import '../models/ad_model.dart';
import '../screens/ad_detail_screen.dart';

class AdCard extends StatelessWidget {
  final AdModel ad;

  const AdCard({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String imageUrl = ad.imageUrl.isNotEmpty
        ? 'https://drive.google.com/uc?id=${ad.imageUrl}' // التعديل هنا لاستخدام Google Drive
        : 'https://via.placeholder.com/300x200.png?text=No+Image';

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(maxHeight: 150),
      decoration: BoxDecoration(
        color: Color(0xFFFBF3F3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 241, 229, 229),
            blurRadius: 4,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصورة
          Container(
            width: 120,
            height: double.infinity,
            margin: const EdgeInsets.only(right: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(Icons.broken_image,
                        size: 30,
                        color: const Color.fromARGB(255, 207, 202, 174)),
                  );
                },
              ),
            ),
          ),

          // الجزء النصي
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ad.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(166, 23, 28, 1),
                      fontFamily: mainFont,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ad.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontFamily: mainFont,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 241, 192, 69),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        minimumSize: Size(75, 35),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdDetailScreen(ad: ad),
                          ),
                        );
                      },
                      child: Text(
                        'المزيد',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: mainFont,
                          color: const Color.fromARGB(255, 50, 49, 49),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
