import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:final_project/models/gallery_model.dart';
import 'package:final_project/services/firestore_service.dart';
import 'package:final_project/widgets/gallery_card.dart';
import 'package:final_project/constants.dart';

class ActiveScreen extends StatelessWidget {
  const ActiveScreen({super.key});

  int calculateRemainingDays(String endDate) {
    try {
      final now = DateTime.now();
      final end = DateFormat('dd/MM/yyyy').parse(endDate);
      final difference = end.difference(now).inDays + 1;
      return difference >= 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 350;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'المعارض المنعقدة الآن',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontFamily: mainFont,
            fontWeight: FontWeight.bold,
            color: const Color.fromRGBO(166, 23, 28, 1),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 4, 20, screenHeight * 0.03), // مسافة سفلية نسبية
            child: Text(
              'سارع بزيارتنا قبل انتهاء المعرض، الفرصة لا تُفوّت!',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 13,
                fontFamily: mainFont,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<GalleryModel>>(
              stream: FirestoreService().getItems(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final activeGalleries = snapshot.data!.where((gallery) {
                  try {
                    final endDate =
                        DateFormat('dd/MM/yyyy').parse(gallery.endDate);
                    return endDate.isAfter(DateTime.now());
                  } catch (e) {
                    return false;
                  }
                }).toList();

                if (activeGalleries.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      child: Text(
                        'لا توجد معارض منعقدة حاليًا.',
                        style: TextStyle(
                          fontFamily: mainFont,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                  itemCount: activeGalleries.length,
                  itemBuilder: (context, index) {
                    final gallery = activeGalleries[index];
                    final remainingDays =
                        calculateRemainingDays(gallery.endDate);

                    return Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01,
                      ),
                      child: Stack(
                        children: [
                          GalleryCard(
                            imageUrl:
                                'https://drive.google.com/uc?id=${gallery.imageURL}',
                            name: gallery.title,
                            description: gallery.description,
                            location: gallery.location,
                            visitors: 2,
                            rating: 5.0,
                            endDate: gallery.endDate,
                            id: gallery.id,
                            isInitiallyFavorite: false,
                            showRemainingDays: false,
                            galleryId: gallery.id,
                            isActiveScreen: true,
                            startDate: '',
                          ),
                          Positioned(
                            top: screenHeight * 0.00,
                            right: screenWidth * 0.02,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.005,
                              ),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 241, 192, 69),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'متبقي $remainingDays من الايام',
                                style: TextStyle(
                                  color: const Color.fromARGB(255, 88, 20, 19),
                                  fontSize: isSmallScreen ? 10 : 12,
                                  fontFamily: mainFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
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
