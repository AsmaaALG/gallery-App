import 'dart:math';

import 'package:final_project/constants.dart';
import 'package:final_project/models/gallery_model.dart';
import 'package:final_project/models/partner_model.dart';
import 'package:final_project/models/reviews_model.dart';
import 'package:final_project/models/suite_model.dart';
import 'package:final_project/screens/QR_code_screen.dart';
import 'package:final_project/screens/image_screen.dart';
import 'package:final_project/screens/suite_screen.dart';
import 'package:final_project/services/favorite_services.dart';
import 'package:final_project/services/shared_sevices.dart';
import 'package:final_project/services/suit_services.dart';
import 'package:final_project/services/users_services.dart';
import 'package:final_project/services/visit_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:firebase_auth/firebase_auth.dart';

class GalleryScreen extends StatefulWidget {
  final GalleryModel galleryModel;
  final int visitors;

  const GalleryScreen({
    super.key,
    required this.galleryModel,
    required this.visitors,
  });

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<SuiteModel> suites = [];
  List<ReviewsModel> reviews = [];
  List<PartnerModel> partners = [];
  bool isExpanded = false;
  bool isLoading = true;
  bool isFavorite = false;
  // String? _cirty;

  final FavoriteServices _favoriteServices = FavoriteServices();
  // final GalleryServices _galleryServices = GalleryServices();
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    fetchSuites();
    fetchReviews();
    fetchPartners();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    if (_userId == null) return;
    try {
      bool favorite = await _favoriteServices.isGalleryFavorite(
          _userId!, widget.galleryModel.id);
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
    )..layout(maxWidth: MediaQuery.of(context).size.width - 40);

    return textPainter.didExceedMaxLines;
  }

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
        await _favoriteServices.addToFavorite(_userId!, widget.galleryModel.id);
      } else {
        await _favoriteServices.removeFromFavorite(
            _userId!, widget.galleryModel.id);
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
      List<ReviewsModel> fetchedReviews =
          await SuiteServices().getReviews(widget.galleryModel.id);
      setState(() {
        reviews = fetchedReviews;
      });
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  Future<void> fetchSuites() async {
    try {
      List<SuiteModel> fetchedSuites =
          await SuiteServices().getSuites(widget.galleryModel.id);
      setState(() {
        suites = fetchedSuites;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching suites: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchPartners() async {
    try {
      List<PartnerModel> fetchedPartners =
          await SuiteServices().getPartners(widget.galleryModel.id);
      setState(() {
        partners = fetchedPartners;
      });
    } catch (e) {
      print('Error fetching partners: $e');
    }
  }

  bool isClosed() {
    try {
      final now = DateTime.now();
      final startDate =
          intl.DateFormat('dd-MM-yyyy').parse(widget.galleryModel.startDate);
      final endDate =
          intl.DateFormat('dd-MM-yyyy').parse(widget.galleryModel.endDate);
      final adjustedEndDate = endDate.add(const Duration(days: 1));

      // إذا لم يصل تاريخ البداية بعد، يعتبر مغلق
      if (now.isBefore(startDate)) {
        return true;
      }

      //  تجاوزنا تاريخ الانتهاء، يعتبر مغلق
      if (now.isAfter(adjustedEndDate)) {
        return true;
      }

      return false; // يعني المعرض مفتوح حاليًا
    } catch (e) {
      return false;
    }
  }

  Future<void> _registerVisitor() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يجب تسجيل الدخول لتسجيل الزيارة')),
      );
      return;
    }

    try {
      bool alreadyRegistered = await VisitServices()
          .isVisitorRegistered(_userId!, widget.galleryModel.id);

      if (alreadyRegistered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تسجيل زيارتك لهذا المعرض مسبقًا')),
        );
        return;
      }

      await VisitServices().registerVisitor(
        _userId!,
        widget.galleryModel.id,
        DateTime.now(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تسجيل زيارتك بنجاح!')),
      );
    } catch (e) {
      print('Error registering visitor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء تسجيل الزيارة')),
      );
    }
  }

  void _scanQRCode() async {
    final qrCodeData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerScreen(),
      ),
    );

    if (qrCodeData != null) {
      if (qrCodeData == widget.galleryModel.qrCode) {
        _registerVisitor();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الرمز غير صالح')),
        );
      }
    }
  }

  Widget _buildHeaderSection() {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          child: Image.network(
            widget.galleryModel.imageURL,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.broken_image,
                    size: 30, color: const Color.fromARGB(255, 207, 202, 174)),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                    icon: Icon(
                      Icons.qr_code_scanner,
                      color: isClosed() ? Colors.grey : primaryColor,
                    ),
                    onPressed: isClosed() ? null : _scanQRCode,
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward, color: primaryColor, size: 28),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 250,
                child: Text(
                  softWrap: true,
                  widget.galleryModel.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 5,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: mainFont,
                      color: primaryColor),
                ),
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
          SizedBox(height: 10),
          Text(
            widget.galleryModel.description,
            textAlign: TextAlign.right,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
            maxLines: isExpanded ? null : 3,
            style: TextStyle(fontFamily: mainFont, fontSize: 10),
          ),
          if (!isExpanded &&
              _isMoreTextVisible(widget.galleryModel.description))
            TextButton(
              onPressed: () {
                setState(() {
                  isExpanded = true;
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
          if (isExpanded)
            TextButton(
              onPressed: () {
                setState(() {
                  isExpanded = false;
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
          SizedBox(height: 15),
          GestureDetector(
            onTap: () =>
                SharedSevices().launchMap(widget.galleryModel.location),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: const [
                Icon(
                  Icons.map,
                  color: secondaryColor,
                  size: 20,
                ),
                SizedBox(width: 5),
                Text(
                  'اضغط لرؤيةالموقع على google maps',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: mainFont,
                    color: secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          Container(
            margin: EdgeInsets.all(10),
            height: 75,
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Icon(Icons.groups_rounded, size: 20),
                      Text(
                        widget.visitors.toString(),
                        style: const TextStyle(
                          fontFamily: mainFont,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.calendar_month_rounded, size: 20),
                      Text(
                        "${widget.galleryModel.startDate}\n${widget.galleryModel.endDate}",
                        style: TextStyle(
                          fontFamily: mainFont,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.location_on_outlined, size: 20),
                      FutureBuilder<String>(
                        future: SharedSevices()
                            .fetchCityName(widget.galleryModel.city),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text(
                              "تحميل...",
                              style: TextStyle(
                                fontFamily: mainFont,
                                fontSize: 9,
                                color: Colors.grey,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              "خطأ في تحميل المدينة",
                              style: TextStyle(
                                fontFamily: mainFont,
                                fontSize: 9,
                                color: Colors.red,
                              ),
                            );
                          } else {
                            return Text(
                              "${snapshot.data}",
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Icon(Icons.star_border_rounded, size: 20),
                      FutureBuilder<double>(
                        future: UsersServices()
                            .calculateRating(widget.galleryModel.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              snapshot.data?.toStringAsFixed(1) ?? '0.0',
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
            ),
          ),
          widget.galleryModel.map.isEmpty
              ? SizedBox()
              : GestureDetector(
                  child: Container(
                    width: double.infinity,
                    // height: 50,
                    color: cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('خارطة المعرض',
                              style: TextStyle(
                                fontFamily: mainFont,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.grey[800],
                              )),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.grey,
                            size: 17,
                          )
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    showImage(context, widget.galleryModel.map);
                  },
                )
        ],
      ),
    );
  }

  Widget _buildSuitesSection() {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    } else if (suites.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        child: Text(
          "لا توجد أجنحة في الوقت الحالي.",
          style: TextStyle(
            fontFamily: mainFont,
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
          child: Text(
            "الأجنحة",
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontFamily: mainFont,
            ),
          ),
        ),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: suites.length,
          itemBuilder: (context, index) {
            final suite = suites[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Container(
                height: 100,
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(1, 3)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        suite.main_image!,
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
                        },
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                      padding: const EdgeInsets.fromLTRB(15, 0, 10, 0),
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SuiteScreen(
                                      suite: suite,
                                    )),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: secondaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          side: BorderSide(
                            color: secondaryColor,
                            width: 0.5,
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          minimumSize: Size(40, 30),
                        ),
                        child: Text(
                          "المزيد",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: mainFont,
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
      ],
    );
  }

  Widget _buildReviewsSection() {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    } else if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        child: Text(
          "لا توجد تعليقات متاحة.",
          style: TextStyle(
            fontFamily: mainFont,
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // عدد التعليقات المعروضة
    int displayCount =
        isExpanded ? reviews.length : (reviews.length < 3 ? reviews.length : 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
          child: Text(
            "التعليقات",
            style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontFamily: mainFont),
          ),
        ),
        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: displayCount,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
                border: Border.all(
                    color: const Color.fromARGB(131, 219, 185, 185), width: 2),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
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
                        SizedBox(width: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star_rate_rounded,
                              color: secondaryColor,
                              size: 15,
                            ),
                            SizedBox(width: 1),
                            Text(
                              review.rating.toStringAsFixed(0) ?? '0.0',
                              style: TextStyle(
                                fontFamily: mainFont,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(review.comment,
                          style: TextStyle(fontFamily: mainFont, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        // عرض زر "المزيد" فقط إذا كان عدد التعليقات أكثر من 3
        if (reviews.length > 3)
          TextButton(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded; // عكس حالة التوسع
              });
            },
            child: Text(
              isExpanded ? "أقل" : "المزيد",
              style: TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontFamily: mainFont,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPartnersSection() {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    } else if (partners.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
        child: Text(
          "لا توجد معلومات عن الشركاء.",
          style: TextStyle(
            fontFamily: mainFont,
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 18),
          child: Text(
            "الشركاء",
            style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontFamily: mainFont),
          ),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: partners.length,
            itemBuilder: (context, index) {
              final partner = partners[index];
              return Container(
                width: 150,
                margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        partner.image,
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
                        },
                      ),
                    ),
                    SizedBox(height: 20),
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
      ],
    );
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
                _buildHeaderSection(),
                _buildGalleryInfoSection(),
                _buildSuitesSection(),
                SizedBox(height: 20),
                _buildReviewsSection(),
                SizedBox(height: 20),
                _buildPartnersSection(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageScreen(imageUrl: imageUrl),
      ),
    );
  }
}
