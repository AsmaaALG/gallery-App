import 'package:final_project/constants.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/gallery_card.dart';
import '../models/gallery_model.dart';
import '../models/category_model.dart';
import '../widgets/category_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategoryId = 'all';
  TextEditingController _searchController = TextEditingController();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // عنوان الترحيب
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 20, 15),
              child: RichText(
                text: TextSpan(
                  children: const <TextSpan>[
                    TextSpan(
                      text: "مرحبا بك ",
                      style: TextStyle(
                        fontFamily: mainFont,
                        color: primaryColor,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: "في عالم المعارض",
                      style: TextStyle(
                        fontFamily: mainFont,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // حقل البحث
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: 40,
                width: 250,
                child: TextField(
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

          // أزرار التصنيفات
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: StreamBuilder<List<CategoryModel>>(
              stream: FirestoreService().getCategories(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final categories = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 15),
                      CategoryButton(
                        label: 'الكل',
                        isSelected: selectedCategoryId == 'all',
                        onPressed: () {
                          setState(() {
                            selectedCategoryId = 'all';
                          });
                        },
                      ),
                      ...categories.map((category) {
                        return CategoryButton(
                          label: category.name,
                          isSelected: selectedCategoryId == category.id,
                          onPressed: () {
                            setState(() {
                              selectedCategoryId = category.id;
                            });
                          },
                        );
                      }).toList(),
                      SizedBox(width: 15),
                    ],
                  ),
                );
              },
            ),
          ),

          // عرض قائمة المعارض
          Expanded(
            child: StreamBuilder<List<GalleryModel>>(
              stream: FirestoreService().getItems(),
              builder: (context, gallerySnapshot) {
                if (gallerySnapshot.hasError) {
                  return Center(child: Text('Error: ${gallerySnapshot.error}'));
                }
                if (!gallerySnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final allItems = gallerySnapshot.data!;
                final filteredItems = allItems.where((item) {
                  final matchesSearch =
                      item.title.toLowerCase().contains(_searchQuery);
                  final matchesCategory = selectedCategoryId == 'all' ||
                      item.classificationId == selectedCategoryId;
                  return matchesSearch && matchesCategory;
                }).toList();

                // إذا لم توجد نتائج للبحث
                if (filteredItems.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد نتائج بحث',
                      style: TextStyle(
                        fontFamily: mainFont,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                // إذا كان المستخدم مسجل دخول، جلب المفضلة
                return _userId != null
                    ? StreamBuilder<List<String>>(
                        stream: FirestoreService().getUserFavorites(_userId!),
                        builder: (context, favoriteSnapshot) {
                          if (favoriteSnapshot.hasError) {
                            return Center(
                                child:
                                    Text('Error: ${favoriteSnapshot.error}'));
                          }

                          final favoriteIds = favoriteSnapshot.data ?? [];

                          return ListView.builder(
                            // أضفنا padding في الأسفل لإعطاء مسافة بعد آخر معرض
                            padding: EdgeInsets.only(top: 10, bottom: 60),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final isFavorite =
                                  favoriteIds.contains(item.id.toString());
                              GalleryModel gallery = new GalleryModel(
                                  qrCode: item.qrCode,
                                  classificationId: item.classificationId,
                                  imageURL: item.imageURL,
                                  description: item.description,
                                  endDate: item.endDate,
                                  id: item.id,
                                  location: item.location,
                                  phone: item.phone,
                                  startDate: item.startDate,
                                  title: item.title,
                                  map: item.map);
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                child: GalleryCard(
                                  key: ValueKey(item.id),
                                  gallery: item,
                                  isInitiallyFavorite: isFavorite,
                                  showRemainingDays: false,
                                  isActiveScreen: false,
                                ),
                              );
                            },
                          );
                        },
                      )

                    // إذا لم يكن المستخدم مسجل دخول
                    : ListView.builder(
                        // أضفنا padding في الأسفل لإعطاء مسافة بعد آخر معرض
                        padding: EdgeInsets.only(top: 10, bottom: 20),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          GalleryModel gallery = new GalleryModel(
                              qrCode: item.qrCode,
                              classificationId: item.classificationId,
                              imageURL: item.imageURL,
                              description: item.description,
                              endDate: item.endDate,
                              id: item.id,
                              location: item.location,
                              phone: item.phone,
                              startDate: item.startDate,
                              title: item.title,
                              map: item.map);

                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            child: GalleryCard(
                              key: ValueKey(item.id),
                              gallery: gallery,
                              isInitiallyFavorite: false,
                              showRemainingDays: false,
                              isActiveScreen: false,
                            ),
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
