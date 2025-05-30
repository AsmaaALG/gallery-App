import 'package:final_project/models/gallery_model.dart';
import 'package:final_project/screens/gallery_screen.dart';
import 'package:final_project/services/favorite_services.dart';
import 'package:final_project/services/users_services.dart';
import 'package:final_project/services/visit_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GalleryCard extends StatefulWidget {
  final GalleryModel gallery;
  final bool isInitiallyFavorite;
  final bool showRemainingDays;
  final bool isActiveScreen;

  const GalleryCard({
    Key? key,
    required this.gallery,
    required this.isInitiallyFavorite,
    required this.showRemainingDays,
    required this.isActiveScreen,
  }) : super(key: key);

  @override
  _GalleryCardState createState() => _GalleryCardState();
}

final FavoriteServices _favoriteServices = FavoriteServices();

FutureBuilder<double> numberOfStars(String id) {
  return FutureBuilder<double>(
    future: UsersServices().calculateRating(id),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('');
      } else {
        double stars = snapshot.data ?? 0.0;
        return Row(children: [
          Text(
            stars.toStringAsFixed(1),
            style: TextStyle(color: Colors.grey, fontSize: 11),
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
  );
}

class _GalleryCardState extends State<GalleryCard> {
  late bool isFavorite;
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isInitiallyFavorite;
    if (_userId != null && widget.gallery.id.isNotEmpty) {
      _favoriteServices
          .isFavorite(_userId!, widget.gallery.id)
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
      final endDate = DateFormat('dd-MM-yyyy').parse(widget.gallery.endDate);
      final adjustedEndDate =
          endDate.add(const Duration(days: 1)); // نحسب اليوم الحالي
      return DateTime.now().isAfter(adjustedEndDate);
    } catch (e) {
      return false;
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null || widget.gallery.id.isEmpty) return;

    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      if (isFavorite) {
        await _favoriteServices.addToFavorite(_userId!, widget.gallery.id);
      } else {
        await _favoriteServices.removeFromFavorite(_userId!, widget.gallery.id);
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

  Future<int> getVisitorCount() async {
    try {
      return await VisitServices().getVisitorCount(widget.gallery.id);
    } catch (e) {
      print('Error fetching visitor count: $e');
      return 0; // ارجع صفر في حالة حدوث خطأ
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => FutureBuilder<int>(
                    future: getVisitorCount(),
                    builder: (context, snapshot) {
                      int visitors = snapshot.data ?? 0;
                      return GalleryScreen(
                        galleryModel: widget.gallery,
                        visitors: visitors, // تمرير عدد الزوار
                      );
                    },
                  )),
        );
      },
      child: Card(
        color: cardBackground,
        elevation: 6,
        shadowColor: const Color.fromARGB(255, 255, 255, 255), // <-- لون الظل
        margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
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
                  'https://drive.google.com/uc?id=${widget.gallery.imageURL}',
                  fit: BoxFit.cover,
                  height: 120,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color.fromARGB(255, 253, 242, 242),
                      child: Icon(Icons.broken_image,
                          size: 50,
                          color: const Color.fromARGB(255, 193, 192, 184)),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            widget.gallery.title,
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
                          widget.gallery.description,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontFamily: mainFont, fontSize: 9),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "الموقع: ${widget.gallery.location}",
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
                      numberOfStars(widget.gallery.id),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
