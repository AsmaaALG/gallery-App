import 'package:final_project/screens/gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_project/models/gallery_model.dart';
import 'package:final_project/services/visit_services.dart';
import 'package:final_project/constants.dart';
import 'package:final_project/widgets/review_dialog.dart';

class VisitedScreen extends StatefulWidget {
  final String currentUserId;
  const VisitedScreen({super.key, required this.currentUserId});

  @override
  State<VisitedScreen> createState() => _VisitedScreenState();
}

class _VisitedScreenState extends State<VisitedScreen> {
  late Future<List<GalleryModel>> _visitedGalleriesFuture;

  @override
  void initState() {
    super.initState();
    _visitedGalleriesFuture = _loadVisitedGalleries();
  }

  Future<List<GalleryModel>> _loadVisitedGalleries() async {
    final visitSnapshots =
        await VisitServices().getUserVisit(widget.currentUserId).first;

    if (visitSnapshots.isEmpty) return [];

    List<GalleryModel> galleries = [];
    for (var visit in visitSnapshots) {
      final gallery = await VisitServices().getGalleryById(visit.galleryId);
      if (gallery != null) galleries.add(gallery);
    }
    return galleries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'المعارض  المُزارة',
          style: TextStyle(
            fontFamily: mainFont,
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: titleSize,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<GalleryModel>>(
        future: _visitedGalleriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'لم تقم بزيارة أي معرض بعد.',
                style: TextStyle(fontFamily: mainFont),
              ),
            );
          }

          final galleries = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'كن جزءًا من الحدث ... حيث يلتقي الشغف بالابتكار! قيّم المعارض!',
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: mainFont,
                    color: Colors.black87,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(17.0),
                  child: GridView.builder(
                    itemCount: galleries.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.68,
                    ),
                    itemBuilder: (context, index) {
                      final gallery = galleries[index];
                      Future<int> getVisitorCount() async {
                        try {
                          return await VisitServices()
                              .getVisitorCount(gallery.id);
                        } catch (e) {
                          print('Error fetching visitor count: $e');
                          return 0; // ارجع صفر في حالة حدوث خطأ
                        }
                      }

                      return SizedBox(
                        height: 260,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 253, 245, 245),
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 13, 3, 3)
                                    .withOpacity(0.15),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 17),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FutureBuilder<int>(
                                                future: getVisitorCount(),
                                                builder: (context, snapshot) {
                                                  int visitors =
                                                      snapshot.data ?? 0;
                                                  return GalleryScreen(
                                                    galleryModel: gallery,
                                                    visitors:
                                                        visitors, // تمرير عدد الزوار
                                                  );
                                                },
                                              )),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 35,
                                        backgroundImage: NetworkImage(
                                          gallery.imageURL,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        gallery.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                          fontFamily: mainFont,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        gallery.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black87,
                                          fontFamily: mainFont,
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => ReviewDialog(
                                          galleryId: gallery.id,
                                          userId: widget.currentUserId,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: secondaryColor,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 11, vertical: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(17.5),
                                      ),
                                    ),
                                    child: const Text(
                                      'قيم المعرض',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontFamily: mainFont,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
