import 'package:final_project/constants.dart';
import 'package:final_project/models/suite_image_model.dart';
import 'package:final_project/models/suite_model.dart';
import 'package:final_project/services/suit_services.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SuiteScreen extends StatefulWidget {
  final SuiteModel suite;

  const SuiteScreen({
    super.key,
    required this.suite,
  });

  @override
  State<SuiteScreen> createState() => _SuiteScreenState();
}

class _SuiteScreenState extends State<SuiteScreen> {
  List<SuiteImageModel> suiteImages = []; // قائمة صور الأجنحة
  bool isLoading = true;
  bool isExpanded = false; // حالة وصف الجناح
  final SuiteServices _suiteServices = SuiteServices();

  @override
  void initState() {
    super.initState();
    fetchSuiteImages(); // جلب صور الأجنحة عند تحميل الشاشة
  }

  Future<void> fetchSuiteImages() async {
    try {
      List<SuiteImageModel> fetchedImages =
          await _suiteServices.getSuiteImages(widget.suite.id);
      setState(() {
        suiteImages = fetchedImages; // تحديث حالة الصور
        isLoading = false; // انتهاء التحميل
      });
    } catch (e) {
      print('Error fetching suite images: $e');
      setState(() {
        isLoading = false; // تعيين حالة التحميل إلى false إذا حدث خطأ
      });
    }
  }

  void _openImage(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoViewGalleryScreen(
          images: suiteImages,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  bool _isMoreTextVisible(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: 12, fontFamily: mainFont),
      ),
      maxLines: 3,
      textDirection: TextDirection.rtl,
    )..layout(
        maxWidth: MediaQuery.of(context).size.width - 40,
      );

    return textPainter
        .didExceedMaxLines; // تحقق مما إذا كان النص يتجاوز ثلاث أسطر
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: primaryColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("تفاصيل الجناح",
            style: TextStyle(
                fontFamily: mainFont, fontSize: 16, color: primaryColor)),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60.0),
                    child: Image.network(
                     widget.suite.imageUrl,
                      fit: BoxFit.cover,
                      height: 120,
                      width: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 130,
                          height: 130,
                          color: Colors.grey.shade200,
                          child: Icon(Icons.broken_image,
                              size: 40, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        widget.suite.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: TextStyle(
                          fontFamily: mainFont,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // وصف الجناح
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.suite.description,
                      textAlign: TextAlign.right,
                      overflow: isExpanded ? null : TextOverflow.ellipsis,
                      maxLines: isExpanded ? null : 3,
                      style: TextStyle(
                        fontFamily: mainFont,
                        fontSize: 12,
                      ),
                    ),
                    if (!isExpanded &&
                        _isMoreTextVisible(
                            widget.suite.description)) // شرط لإظهار "المزيد"
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = true; // توسيع الوصف عند الضغط
                          });
                        },
                        child: Text(
                          "المزيد",
                          style: TextStyle(
                            color: primaryColor,
                            fontFamily: mainFont,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (isExpanded) // زر "أقل" يظهر عند توسيع الوصف
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isExpanded = false; // تقليل الوصف عند الضغط
                          });
                        },
                        child: Text(
                          "أقل",
                          style: TextStyle(
                            color: primaryColor,
                            fontFamily: mainFont,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[400], thickness: 1),
              SizedBox(height: 10),
              // عرض الصور
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : suiteImages.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "لا توجد صور متاحة",
                            style: TextStyle(
                              fontFamily: mainFont,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: suiteImages.length,
                          itemBuilder: (context, index) {
                            final suiteImage = suiteImages[index];
                            return GestureDetector(
                              onTap: () => _openImage(
                                  context, index), // فتح الصورة عند النقر
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.network(
                                  suiteImage.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(Icons.broken_image,
                                          size: 40, color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

// صفحة عرض الصور باستخدام PhotoViewGallery
class PhotoViewGalleryScreen extends StatelessWidget {
  final List<SuiteImageModel> images;
  final int initialIndex;

  const PhotoViewGalleryScreen(
      {Key? key, required this.images, required this.initialIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PhotoViewGallery.builder(
        itemCount: images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index].imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        pageController: PageController(initialPage: initialIndex),
        backgroundDecoration: BoxDecoration(
          color: Colors.white, // تعيين خلفية بيضاء
        ),
      ),
    );
  }
}
