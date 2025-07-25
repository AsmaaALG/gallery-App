import 'package:final_project/constants.dart';
import 'package:flutter/material.dart';
import '../models/ad_model.dart';
import '../screens/ad_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AdCard extends StatelessWidget {
  final AdModel ad;

  const AdCard({Key? key, required this.ad}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String imageUrl = ad.imageUrl.isNotEmpty
        ? ad.imageUrl
        : 'https://via.placeholder.com/300x200.png?text=No+Image';

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(maxHeight: 170),
      decoration: BoxDecoration(
        color: Color(0xFFFBF3F3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 241, 229, 229),
            blurRadius: 4,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // الصورة
          Container(
            width: 130,
            height: double.infinity,
            // margin: const EdgeInsets.only(right: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.broken_image),
              ),
            ),
          ),

          // الجزء النصي
          Container(
            width: 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ad.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromRGBO(166, 23, 28, 1),
                    fontFamily: mainFont,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  ad.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[700],
                    fontFamily: mainFont,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 241, 192, 69),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 3),
                      minimumSize: Size(45, 35),
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
          // ),
        ],
      ),
    );
  }
}
