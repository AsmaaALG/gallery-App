import 'package:final_project/constants.dart';
import 'package:final_project/models/partner.dart';
import 'package:final_project/models/reviews.dart';
import 'package:final_project/models/suite.dart';
import 'package:final_project/screens/suite_screen.dart';
import 'package:final_project/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:firebase_auth/firebase_auth.dart';

class GalleryScreen extends StatefulWidget {
  final String id;
  final String imageUrl;
  final String name;
  final String description;
  final String location;
  final int visitors;
  final double rating;
  final String endDate;
  final String startDate;

  const GalleryScreen({
    super.key,
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.location,
    required this.visitors,
    required this.rating,
    required this.endDate,
    required this.startDate,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Suite> suites = [];
  List<Review> reviews = []; // قائمة التعليقات
  List<Partner> partners = []; // قائمة الشركاء
  bool isExpanded = false;
  bool isLoading = true;
  bool isFavorite = false; // حالة المفضلة
  final FirestoreService _firestoreService = FirestoreService();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchSuites(); // استدعاء دالة جلب الأجنحة عند تحميل الشاشة
    fetchReviews();
    fetchPartners(); // استدعاء دالة جلب الشركاء
    _checkFavoriteStatus(); // التحقق من حالة المفضلة
  }

  // دالة للتحقق من حالة المفضلة
  Future<void> _checkFavoriteStatus() async {
    if (_userId == null) return;
    try {
      bool favorite =
          await _firestoreService.isGalleryFavorite(_userId!, widget.id);
      if (mounted) {
        setState(() {
          isFavorite = favorite;
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
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
        maxWidth: MediaQuery.of(context).size.width -
            40); // الحساب بناءً على عرض الشاشة

    return textPainter
        .didExceedMaxLines; // تحقق مما إذا كان النص يتجاوز ثلاث أسطر
  }

  // دالة للتبديل بين حالة المفضلة
  Future<void> _toggleFavorite() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يجب تسجيل الدخول لإضافة إلى المفضلة')),
      );
      return;
    }

    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      if (isFavorite) {
        await _firestoreService.addToFavorite(_userId!, widget.id);
      } else {
        await _firestoreService.removeFromFavorite(_userId!, widget.id);
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

  Future<void> fetchReviews() async {
    try {
      List<Review> fetchedReviews =
          await FirestoreService().getReviews(widget.id);
      setState(() {
        reviews = fetchedReviews; // تحديث حالة التعليقات
        print("number of reviewsssss:::::: ${reviews.length}");
      });
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  Future<void> fetchPartners() async {
    try {
      List<Partner> fetchedPartners =
          await FirestoreService().getPartners(widget.id);
      setState(() {
        partners = fetchedPartners; // تحديث حالة الشركاء
      });
    } catch (e) {
      print('Error fetching partners: $e');
    }
  }

  bool isClosed() {
    try {
      final endDate = intl.DateFormat('dd/MM/yyyy').parse(widget.endDate);
      return DateTime.now().isAfter(endDate);
    } catch (e) {
      print('Error parsing date: $e');
      print('end date value: ${widget.endDate}');

      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.broken_image,
                                  size: 30,
                                  color:
                                      const Color.fromARGB(255, 207, 202, 174)),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFavorite
                                    ? const Color.fromARGB(255, 158, 17, 17)
                                    : primaryColor,
                                size: 28,
                              ),
                              onPressed: _toggleFavorite,
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward,
                                  color: primaryColor, size: 28),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: mainFont,
                                color: primaryColor),
                          ),
                          Text(
                            isClosed() ? ' مغلق' : ' مفتوح',
                            style: TextStyle(
                                color: isClosed() ? primaryColor : Colors.green,
                                fontFamily: mainFont,
                                fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.description,
                        textAlign: TextAlign.right,
                        overflow: isExpanded ? null : TextOverflow.ellipsis,
                        maxLines: isExpanded ? null : 3,
                        style: TextStyle(fontFamily: mainFont, fontSize: 10),
                      ),
                      if (!isExpanded &&
                          _isMoreTextVisible(
                              widget.description)) // شرط لإظهار "المزيد"
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isExpanded = true; // توسيع الوصف عند الضغط
                            });
                          },
                          child: Text(
                            "المزيد",
                            style: TextStyle(
                              fontSize: 10,
                              color: primaryColor,
                              fontFamily: mainFont,
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
                              fontSize: 10,
                              color: primaryColor,
                              fontFamily: mainFont,
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        margin: EdgeInsets.all(10),
                        height: 75,
                        decoration: BoxDecoration(
                          border: Border.all(color: primaryColor, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: const [
                                      Icon(
                                        Icons.groups_rounded,
                                        size: 20,
                                      ),
                                      Text(
                                        "111",
                                        style: TextStyle(
                                          fontFamily: mainFont, // تعيين الخط
                                          fontSize: 10, // تصغير حجم النص
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        size: 20,
                                      ),
                                      Text(
                                        "${widget.startDate}\n${widget.endDate}",
                                        style: TextStyle(
                                          fontFamily: mainFont, // تعيين الخط
                                          fontSize: 10, // تصغير حجم النص
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 20,
                                      ),
                                      Text(
                                        widget.location,
                                        style: TextStyle(
                                          fontFamily: mainFont,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Icon(
                                        Icons.star_border_rounded,
                                        size: 20,
                                      ),
                                      FutureBuilder<double>(
                                        future: FirestoreService()
                                            .calculateRating(widget.id),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            return Text(
                                              snapshot.data
                                                      ?.toStringAsFixed(1) ??
                                                  '0.0',
                                              style: TextStyle(
                                                fontFamily: mainFont,
                                                fontSize: 10,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                  child: Text(
                    "الأجنحة",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontFamily: mainFont,
                    ),
                  ),
                ),
                // قائمة الأجنحة
                if (isLoading)
                  CircularProgressIndicator(
                    color: primaryColor,
                  ) // عرض مؤشر التحميل
                else if (suites.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 18),
                    child: Text(
                      "لا توجد أجنحة في الوقت الحالي.",
                      style: TextStyle(
                        fontFamily: mainFont,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    height: suites.length * 120, // ارتفاع قسم الأجنحة
                    child: ListView.builder(
                      itemCount: suites.length,
                      itemBuilder: (context, index) {
                        final suite = suites[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Container(
                            height: 100, // ارتفاع كل جناح
                            margin: EdgeInsets.symmetric(
                                vertical: 5), // هامش بين الأجنحة
                            decoration: BoxDecoration(
                              color: cardBackground,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.grey.withOpacity(0.3), // لون الظل
                                  spreadRadius: 2, // مدى انتشار الظل
                                  blurRadius: 4, // مدى ضبابية الظل
                                  offset: Offset(1, 3), // اتجاه الظل (إزاحة)
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      15.0), // تحديد نصف القطر لجعل الحواف مدورة
                                  child: Image.network(
                                      'https://drive.google.com/uc?id=${suite.imageUrl}',
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100, errorBuilder:
                                          (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey.shade200,
                                      child: Icon(Icons.broken_image,
                                          size: 40, color: Colors.grey),
                                    );
                                  }),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(suite.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontFamily: mainFont,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12)),
                                        SizedBox(height: 5),
                                        Text(suite.description,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: TextStyle(
                                                fontFamily: mainFont,
                                                color: Colors.grey[800],
                                                fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 0, 10, 0),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SuiteScreen(
                                                name: suite.name,
                                                id: suite.id,
                                                mainImage: suite.imageUrl,
                                                description:
                                                    suite.description)),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: secondaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      ),
                                      side: BorderSide(
                                        color: secondaryColor, // لون الحواف
                                        width: 0.5, // عرض الحواف
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal:
                                              16.0), // تعديل المساحة الداخلية

                                      minimumSize:
                                          Size(40, 30), // تحديد الحجم الأدنى
                                    ),
                                    child: Text(
                                      "المزيد",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontFamily: mainFont, // لون النص
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 20),
/////////////////////////////////////////////////////////////////////////////
                // قسم التعليقات
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                  child: Text(
                    "التعليقات",
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: mainFont),
                  ),
                ),
                // قائمة التعليقات
                if (isLoading)
                  CircularProgressIndicator(
                    color: primaryColor,
                  ) // عرض مؤشر التحميل
                else if (reviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 18),
                    child: Text(
                      "لا توجد تعليقات متاحة.",
                      style: TextStyle(
                        fontFamily: mainFont,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  SizedBox(
                    height:
                        reviews.length >= 3 ? 400 : 200, // ارتفاع قسم التعليقات
                    child: ListView.builder(
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index]; // الحصول على التعليق
                        return Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 20), // هامش بين التعليقات
                          decoration: BoxDecoration(
                            color: Colors.white, // لون خلفية التعليق
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                  35), // حافة مدورة في الأعلى اليسار
                              topRight: Radius.circular(
                                  0), // حافة مدببة في الأعلى اليمين
                              bottomLeft: Radius.circular(
                                  35), // حافة مدورة في الأسفل اليسار
                              bottomRight: Radius.circular(
                                  35), // حافة مدورة في الأسفل اليمين
                            ),
                            border: Border.all(
                                color: const Color.fromARGB(131, 219, 185, 185),
                                width: 2), // تحديد لون الحافة
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(review.userName,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontFamily: mainFont,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.star_rate_rounded,
                                          color: secondaryColor,
                                          size: 15,
                                        ),
                                        SizedBox(
                                          width: 1,
                                        ),
                                        Text(
                                          review.rating.toStringAsFixed(0) ??
                                              '0.0',
                                          style: TextStyle(
                                            fontFamily: mainFont,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(review.comment,
                                      style: TextStyle(
                                          fontFamily: mainFont, fontSize: 12)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(height: 20),
                // قسم الشركاء
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
                  child: Text(
                    "الشركاء",
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontFamily: mainFont),
                  ),
                ),
                // قائمة الشركاء
                if (isLoading)
                  CircularProgressIndicator(
                    color: primaryColor,
                  ) // عرض مؤشر التحميل
                else if (partners.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 18),
                    child: Text(
                      "لا توجد معلومات عن الشركاء.",
                      style: TextStyle(
                        fontFamily: mainFont,
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  Container(
                    height: 200,
                    child: ListView.builder(
                      itemCount: partners.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final partner = partners[index];
                        return Container(
                          // color: primaryColor,
                          width: 150,
                          margin:
                              EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                          child: Column(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    50.0), // تحديد نصف القطر لجعل الحواف مدورة
                                child: Image.network(
                                    'https://drive.google.com/uc?id=${partner.image}',
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                    errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey.shade200,
                                    child: Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey),
                                  );
                                }),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                partner.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color.fromRGBO(33, 77, 109, 1),
                                    fontFamily: mainFont,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> fetchSuites() async {
    try {
      List<Suite> fetchedSuites = await FirestoreService().getSuites(widget.id);
      setState(() {
        suites = fetchedSuites; // تحديث حالة الأجنحة
        isLoading = false; // انتهاء التحميل
      });
    } catch (e) {
      print('Error fetching suites: $e');
      setState(() {
        isLoading = false; // تعيين حالة التحميل إلى false إذا حدث خطأ
      });
    }
  }
}
