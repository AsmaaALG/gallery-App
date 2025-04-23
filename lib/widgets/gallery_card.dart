import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GalleryCard extends StatefulWidget {
  final String id;
  final String imageUrl;
  final String name;
  final String description;
  final String location;
  final int visitors;
  final double rating;
  final String endDate;
  final bool isInitiallyFavorite;
  final String galleryId;

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
    required this.isInitiallyFavorite,
    required this.galleryId,
  }) : super(key: key);

  @override
  _GalleryCardState createState() => _GalleryCardState();
}

class _GalleryCardState extends State<GalleryCard> {
  late bool isFavorite;
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isInitiallyFavorite;
    if (_userId != null && widget.galleryId != null) {
      _firestoreService
          .isFavorite(_userId!, widget.galleryId)
          .listen((favorite) {
        if (mounted) {
          setState(() {
            isFavorite = favorite;
          });
        }
      });
    }
  }

  bool isClosed() {
    try {
      final endDate = DateFormat('dd/MM/yyyy').parse(widget.endDate);
      return DateTime.now().isAfter(endDate);
    } catch (e) {
      return false;
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null || widget.galleryId.isEmpty) return;

    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      if (isFavorite) {
        await _firestoreService.addToFavorite(_userId!, widget.galleryId);
      } else {
        await _firestoreService.removeFromFavorite(_userId!, widget.galleryId);
      }
    } catch (e) {
      setState(() {
        isFavorite = !isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تحديث المفضلة')),
      );
    }
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
                onPressed: _toggleFavorite,
              ),
            ),
            Center(
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                height: 120,
                width: double.infinity,
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
                      Text(
                        widget.description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontFamily: mainFont, fontSize: 9),
                      ),
                      SizedBox(height: 5),
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
                    Text(
                      isClosed() ? ' مغلق' : ' مفتوح',
                      style: TextStyle(
                          color: isClosed() ? primaryColor : Colors.green,
                          fontFamily: mainFont,
                          fontSize: 12),
                    ),
                    SizedBox(height: 5),
                    FutureBuilder<double>(
                      future: _firestoreService.calculateRating(widget.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('??');
                        } else {
                          double stars = snapshot.data ?? 0.0;
                          return Row(children: [
                            Text(
                              stars.toStringAsFixed(1),
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
                      },
                    ),
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
