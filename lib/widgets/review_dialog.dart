import 'package:flutter/material.dart';
import 'package:final_project/models/reviews.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/constants.dart';

class ReviewDialog extends StatefulWidget {
  final String galleryId;
  final String userId;

  const ReviewDialog({
    super.key,
    required this.galleryId,
    required this.userId,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  double rating = 0;
  final TextEditingController commentController = TextEditingController();
  bool isSubmitting = false;
  String? existingReviewId;

  @override
  void initState() {
    super.initState();
    _loadExistingReview();
  }

  Future<void> _loadExistingReview() async {
    final query = await FirebaseFirestore.instance
        .collection('reviews')
        .where('gallery id', isEqualTo: widget.galleryId)
        .where('user id', isEqualTo: widget.userId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data();
      setState(() {
        existingReviewId = query.docs.first.id;
        rating =
            (data['number of stars'] ?? 0).toDouble(); // تحميل تقييم المستخدم
        commentController.text = data['comment'] ?? ''; // تحميل التعليق
      });
    }
  }

  Future<void> _submitReview() async {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار عدد النجوم')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final reviewData = Review(
      id: existingReviewId ?? '',
      galleryId: widget.galleryId,
      rating: rating,
      userId: widget.userId,
      date: DateTime.now(),
      comment: commentController.text.trim(),
      userName: '', // عادي تخليه فاضي أو تضيف اسم المستخدم حسب مشروعك
    ).toJson();

    if (existingReviewId != null) {
      // تحديث التقييم الحالي
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(existingReviewId)
          .update(reviewData);
    } else {
      // إضافة تقييم جديد
      await FirebaseFirestore.instance.collection('reviews').add(reviewData);
    }

    setState(() => isSubmitting = false);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال التقييم بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'يمكنك تقييم المعرض وترك تعليق صغير',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: mainFont,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C2C2C),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'عدد النجوم',
                style: TextStyle(
                  color: primaryColor,
                  fontFamily: mainFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  return Expanded(
                    child: IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: secondaryColor,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1.0; // تحديث عدد النجوم عند الضغط
                        });
                      },
                    ),
                  );
                }).reversed.toList(), // لعكس الترتيب من اليمين
              ),
              const SizedBox(height: 16),
              const Text(
                'التعليق',
                style: TextStyle(
                  color: primaryColor,
                  fontFamily: mainFont,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 2,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: '.... اترك تعليقك ',
                  hintStyle:
                      const TextStyle(fontFamily: mainFont, fontSize: 12),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 189, 155, 155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 189, 155, 155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    borderSide: const BorderSide(
                        color: Color.fromARGB(255, 189, 155, 155)),
                  ),
                ),
                style: TextStyle(fontFamily: mainFont, fontSize: 12),
              ),
              const SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _submitReview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'تم',
                            style: TextStyle(
                              color: primaryColor,
                              fontFamily: mainFont,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
