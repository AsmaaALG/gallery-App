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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _savedContext = context;
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // نافذة تأكيد لحذف جميع المعارض من المفضلة
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
    // في حال عدم تسجيل الدخول
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
          style: TextStyle(
            fontFamily: mainFont,
            color: const Color.fromRGBO(166, 23, 28, 1),
            fontWeight: FontWeight.bold,
            fontSize: titleSize,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _showDeleteAllDialog, // زر لحذف الكل
          ),
        ],
      ),
      body: Column(
        children: [
          // حقل البحث
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: 40,
                width: 250,
                child: TextField(
                  cursorHeight: 14,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'ابحث باسم المعرض',
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
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          // عرض قائمة المعارض المفضلة
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

                    // فلترة المعارض حسب المفضلة والبحث
                    var favoriteGalleries = gallerySnapshot.data!
                        .where((gallery) =>
                            favoriteIds.contains(gallery.id.toString()))
                        .where((gallery) =>
                            gallery.title.toLowerCase().contains(_searchQuery))
                        .toList();

                    if (favoriteGalleries.isEmpty && _searchQuery.isNotEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد نتائج بحث',
                          style: TextStyle(fontFamily: mainFont),
                        ),
                      );
                    }

                    return ListView.builder(
                      // أضفنا هنا مسافة إضافية في الأسفل بعد آخر معرض
                      padding: EdgeInsets.only(top: 10, bottom: 60),
                      itemCount: favoriteGalleries.length,
                      itemBuilder: (context, index) {
                        final gallery = favoriteGalleries[index];
                        return FutureBuilder<double>(
                          future: _firestoreService
                              .calculateRating(gallery.id.toString()),
                          builder: (context, ratingSnapshot) {
                            double rating = ratingSnapshot.data ?? 0.0;
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 20),
                              child: GalleryCard(
                                imageUrl:
                                    'https://drive.google.com/uc?id=${gallery.imageURL}',
                                name: gallery.title,
                                description: gallery.description,
                                location: gallery.location,
                                rating: rating,
                                endDate: gallery.endDate,
                                isInitiallyFavorite: true,
                                galleryId: gallery.id.toString(),
                                id: gallery.id.toString(),
                                showRemainingDays: false,
                                startDate: gallery.startDate,
                                isActiveScreen: false,
                              ),
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
