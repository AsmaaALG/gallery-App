import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/services/favorite_services.dart';
import 'package:final_project/services/gallery_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../widgets/gallery_card.dart';
import '../models/gallery_model.dart';
import '../models/category_model.dart';
import '../widgets/category_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FavoriteServices _favoriteServices = FavoriteServices();

class City {
  final String id;
  final String name;

  City({required this.id, required this.name});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategoryId = 'all';
  String? selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  String _searchQuery = '';
  bool _showLocationsList = false;
  List<City> _cities = [];
  Timer? _debounce;
  List<String> _favoriteIds = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchCities();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  Future<void> _fetchCities() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('city').get();
      final cities = snapshot.docs
          .map((doc) {
            return City(
              id: doc.id,
              name: doc['name'] ?? '',
            );
          })
          .where((c) => c.name.isNotEmpty)
          .toList();

      setState(() {
        _cities = cities;
      });
    } catch (e) {
      print('فشل في جلب المدن: $e');
    }
  }

  void _loadFavorites() {
    if (_userId != null) {
      _favoriteServices.getUserFavorites(_userId!).listen((ids) {
        setState(() {
          _favoriteIds = ids;
        });
      });
    }
  }

  void _toggleLocationsList() {
    setState(() {
      _showLocationsList = !_showLocationsList;
    });
  }

  void _selectLocation(String? locationId) {
    setState(() {
      selectedLocation = locationId;
      _showLocationsList = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
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
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _toggleLocationsList,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: SizedBox(
                    height: 40,
                    width: 200,
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
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: mainFont,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_showLocationsList)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'الكل',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: mainFont,
                        color: selectedLocation == null
                            ? primaryColor
                            : Colors.black,
                      ),
                    ),
                    onTap: () => _selectLocation(null),
                  ),
                  Divider(height: 1),
                  ..._cities.map((city) => Column(
                        children: [
                          ListTile(
                            title: Text(
                              city.name,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: mainFont,
                                color: selectedLocation == city.id
                                    ? primaryColor
                                    : Colors.black,
                              ),
                            ),
                            onTap: () => _selectLocation(city.id),
                          ),
                          Divider(height: 1),
                        ],
                      )),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: StreamBuilder<List<CategoryModel>>(
              stream: GalleryServices().getCategories(),
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
          Expanded(
            child: StreamBuilder<List<GalleryModel>>(
              stream: GalleryServices().getItems(),
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
                  final matchesLocation =
                      selectedLocation == null || item.city == selectedLocation;

                  return matchesSearch && matchesCategory && matchesLocation;
                }).toList();
                filteredItems.sort((a, b) {
                  final aDate = intl.DateFormat('dd-MM-yyyy').parse(a.endDate);
                  final bDate = intl.DateFormat('dd-MM-yyyy').parse(b.endDate);
                  return bDate.compareTo(aDate);
                });

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isNotEmpty || selectedLocation != null
                          ? 'لا توجد نتائج بحث'
                          : 'لا توجد معارض متاحة حالياً',
                      style: TextStyle(
                        fontFamily: mainFont,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(top: 10, bottom: 60),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final isFavorite =
                        _favoriteIds.contains(item.id.toString());
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            ),
          ),
        ],
      ),
    );
  }
}
