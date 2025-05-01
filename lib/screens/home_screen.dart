import 'package:final_project/constants.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/gallery_card.dart';
import '../models/gallery_model.dart';
import '../models/category_model.dart';
import '../widgets/category_button.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategoryId = 'all';
  TextEditingController _searchController = TextEditingController();
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              padding:
                  EdgeInsets.fromLTRB(0, 5, 20, 15), // تقليل البادئة السفلية
              child: RichText(
                text: TextSpan(
                  children: const <TextSpan>[
                    TextSpan(
                      text: "مرحبا بك ",
                      style: TextStyle(
                          fontFamily: mainFont,
                          color: primaryColor,
                          fontSize: titleSize),
                    ),
                    TextSpan(
                      text: "في عالم المعارض",
                      style: TextStyle(
                          fontFamily: mainFont,
                          color: Colors.black,
                          fontSize: titleSize),
                    )
                  ],
                ),
              ),
            ),
          ),
          // حقل البحث المعدل بحجم أصغر
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SizedBox(
                height: 40, // ارتفاع أصغر
                width: 250, // عرض أصغر
                child: TextField(
                  cursorHeight: 14,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'بحث',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12, // حجم نص أصغر
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8), // تعديل موقع الأيقونة
                      child: Icon(
                        Icons.search,
                        color: Colors.grey[500],
                        size: 18, // حجم أيقونة أصغر
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(20), // زوايا أقل استدارة
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0, // تقليل المساحة العمودية
                      horizontal: 10,
                    ),
                    isDense: true,
                  ),
                  style: TextStyle(fontSize: 12), // حجم نص إدخال أصغر
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 25),
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
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<GalleryModel>>(
              stream: FirestoreService().getItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final items = snapshot.data!.where((item) {
                  return selectedCategoryId == 'all' ||
                      item.classificationId == selectedCategoryId;
                }).toList();

                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return GalleryCard(
                      imageUrl:
                          'https://drive.google.com/uc?id=${items[index].imageURL}',
                      name: items[index].title,
                      description: items[index].description,
                      location: items[index].location,
                      visitors: 2,
                      rating: 5.0,
                      endDate: items[index].endDate,
                      id: items[index].id.toString(),
                      isInitiallyFavorite:
                          false, // يمكنك تغيير هذه القيمة حسب الحاجة
                      galleryId: items[index].id.toString(),
                      showRemainingDays: false, startDate: '',
                      isActiveScreen: false,
                      // استخدام معرف المعرض كـ galleryId
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
///////////////////////////////////////////////////////////
