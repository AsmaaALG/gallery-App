import 'package:flutter/material.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/services/firestore_service.dart';
import 'package:final_project/models/gallery_model.dart';
import 'package:final_project/widgets/gallery_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  late TextEditingController _searchController;
  late BuildContext _savedContext;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _savedContext = context;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showDeleteAllDialog() async {
    final confirmed = await showDialog<bool>(
      context: _savedContext,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          title: Text(
            'حذف الكل',
            style: TextStyle(fontFamily: mainFont),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'هل أنت متأكد من حذف جميع المعارض من المفضلة؟',
            style: TextStyle(fontFamily: mainFont),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text(
                'إلغاء',
                style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontFamily: mainFont),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                'حذف',
                style: TextStyle(color: Colors.red, fontFamily: mainFont),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _firestoreService.clearAllFavorites(_userId!);
      if (mounted) {
        ScaffoldMessenger.of(_savedContext).showSnackBar(
          SnackBar(
            content: Text(
              'تم حذف جميع المعارض من المفضلة',
              style: TextStyle(fontFamily: mainFont),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return Center(
        child: Text(
          'يجب تسجيل الدخول لعرض المفضلة',
          style: TextStyle(fontFamily: mainFont),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'المفضلة',
          style: TextStyle(fontFamily: mainFont),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _showDeleteAllDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: 40,
                width: 250,
                child: TextField(
                  cursorHeight: 14,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                      fontFamily: mainFont,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.search,
                        color: Colors.grey[500],
                        size: 18,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                    isDense: true,
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: mainFont,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: _firestoreService.getUserFavorites(_userId!),
              builder: (context, favoriteSnapshot) {
                if (favoriteSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'حدث خطأ: ${favoriteSnapshot.error}',
                      style: TextStyle(fontFamily: mainFont),
                    ),
                  );
                }
                if (!favoriteSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final favoriteIds = favoriteSnapshot.data!;
                if (favoriteIds.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد معارض في المفضلة',
                      style: TextStyle(fontFamily: mainFont),
                    ),
                  );
                }

                return StreamBuilder<List<GalleryModel>>(
                  stream: _firestoreService.getItems(),
                  builder: (context, gallerySnapshot) {
                    if (gallerySnapshot.hasError) {
                      return Center(
                        child: Text(
                          'حدث خطأ: ${gallerySnapshot.error}',
                          style: TextStyle(fontFamily: mainFont),
                        ),
                      );
                    }
                    if (!gallerySnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var favoriteGalleries = gallerySnapshot.data!
                        .where((gallery) =>
                            favoriteIds.contains(gallery.id.toString()))
                        .where(
                            (gallery) => gallery.title.toLowerCase().contains(
                                  _searchController.text.toLowerCase(),
                                ))
                        .toList();

                    return ListView.builder(
                      itemCount: favoriteGalleries.length, //حسب حجم المفضلة
                      itemBuilder: (context, index) {
                        final gallery = favoriteGalleries[index];
                        return FutureBuilder<double>(
                          future: _firestoreService
                              .calculateRating(gallery.id.toString()),
                          builder: (context, ratingSnapshot) {
                            double rating = ratingSnapshot.data ?? 0.0;
                            return GalleryCard(
                              imageUrl:
                                  'https://drive.google.com/uc?id=${gallery.imageURL}',
                              name: gallery.title,
                              description: gallery.description,
                              location: gallery.location,
                              visitors: 2,
                              rating: rating,
                              endDate: gallery.endDate,
                              isInitiallyFavorite: true,
                              galleryId: gallery.id.toString(),
                              id: gallery.id.toString(),
                              showRemainingDays: false,
                              startDate: '',
                              isActiveScreen: false,
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
