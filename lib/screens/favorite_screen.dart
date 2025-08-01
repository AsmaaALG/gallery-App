import 'package:final_project/services/favorite_services.dart';
import 'package:final_project/services/gallery_services.dart';
import 'package:final_project/services/users_services.dart';
import 'package:flutter/material.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/models/gallery_model.dart';
import 'package:final_project/widgets/gallery_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final FavoriteServices _favoriteServices = FavoriteServices();

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

  Future<void> _showDeleteAllDialog() async {
    final favorites = await _favoriteServices.getUserFavorites(_userId!).first;

    if (favorites.isEmpty) {
      // إذا مافيش ولا معرض => نعرض رسالة تنبيه فقط
      if (mounted) {
        ScaffoldMessenger.of(_savedContext).showSnackBar(
          SnackBar(
            content: Text(
              'لا توجد معارض في المفضلة لحذفها',
              style: TextStyle(fontFamily: mainFont),
            ),
          ),
        );
      }
      return;
    }

    // إذا في معارض => نظهر مربع التأكيد
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
                  fontFamily: mainFont,
                ),
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
      await _favoriteServices.clearAllFavorites(_userId!);
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
          Expanded(
            child: StreamBuilder<List<String>>(
              stream: _favoriteServices.getUserFavorites(_userId!),
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
                  stream: GalleryServices().getItems(),
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
                      padding: EdgeInsets.only(top: 10, bottom: 60),
                      itemCount: favoriteGalleries.length,
                      itemBuilder: (context, index) {
                        final gallery = favoriteGalleries[index];
                        return FutureBuilder<double>(
                          future: UsersServices()
                              .calculateRating(gallery.id.toString()),
                          builder: (context, ratingSnapshot) {
                            // double rating = ratingSnapshot.data ?? 0.0;
                            GalleryModel galleryModel = GalleryModel(
                                qrCode: gallery.qrCode,
                                classificationId: gallery.classificationId,
                                imageURL: gallery.imageURL,
                                description: gallery.description,
                                endDate: gallery.endDate,
                                id: gallery.id,
                                location: gallery.location,
                                startDate: gallery.startDate,
                                title: gallery.title,
                                map: gallery.map,
                                company_id: gallery.company_id,
                                city: gallery.city);
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 20),
                              child: GalleryCard(
                                gallery: galleryModel,
                                isInitiallyFavorite: true,
                                showRemainingDays: false,
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
