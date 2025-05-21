import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/constants.dart';

class ReservationScreen extends StatefulWidget {
  final String adId; // معرف الإعلان

  const ReservationScreen({Key? key, required this.adId}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>(); //   للتحقق من الصحة
  final _firestore =
      FirebaseFirestore.instance; // الاتصال بقاعدة بيانات Firestore

  // وحدات التحكم لحقول الإدخال
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _productTypeController = TextEditingController();
  final TextEditingController _wingNameController =
      TextEditingController(); // حقل اسم الجناح
  final TextEditingController _wingImageController =
      TextEditingController(); // حقل صورة الجناح

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400; // التحقق من حجم الشاشة

    return Scaffold(
      backgroundColor: const Color(0xFFFBF3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEADDDA),
        title: Text(
          'نموذج حجز مساحة',
          style: TextStyle(
            fontSize:
                isSmallScreen ? 14 : 16, // حجم الخط يكون بناءً على حجم الشاشة
            fontFamily: mainFont,
            color: const Color.fromARGB(255, 96, 3, 6),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            key: _formKey, //    للتحقق من صحة الإدخال
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.03),
                  child: Text(
                    'يمكنك تعبئة النموذج للاشتراك وحجز مساحة لك داخل المعرض',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 16,
                      fontFamily: mainFont,
                      color: const Color.fromARGB(255, 60, 59, 59),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),

                //////////حقول الفورم

                _buildTextField('الاسم...', _nameController,
                    isRequired: true, context: context),

                _buildTextField('الهاتف...', _phoneController,
                    isRequired: true, context: context),

                _buildTextField('البريد الإلكتروني...', _emailController,
                    isRequired: true, isEmail: true, context: context),

                _buildTextField('العنوان ...', _addressController,
                    isRequired: true, context: context),

                _buildTextField('اسم الجناح...', _wingNameController,
                    isRequired: true, context: context), // حقل اسم الجناح

                _buildTextField('صورة الجناح...', _wingImageController,
                    isRequired: true, context: context), // حقل صورة الجناح

                _buildTextField(
                    'المؤسسة المسؤولة عن الجناح...', _organizationController,
                    isRequired: true, context: context),

                _buildTextField('وصف الجناح ...', _productTypeController,
                    isRequired: true, context: context),

                SizedBox(height: screenHeight * 0.04),

                ////////////تنسيييق الفورم

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 241, 192, 69),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.2,
                        vertical: screenHeight * 0.02,
                      ),
                      minimumSize: Size(screenWidth * 0.5, screenHeight * 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 5,
                      shadowColor: const Color.fromARGB(255, 247, 205, 205)
                          .withOpacity(0.6),
                    ),
                    onPressed: _submitForm, // استدعاء لدالة إرسال النموذج
                    child: Text(
                      'إرسال',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 49, 45, 45),
                        fontSize: isSmallScreen ? 16 : 18,
                        fontFamily: mainFont,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لإنشاء حقل نصي
  Widget _buildTextField(
    String hint,
    TextEditingController controller, {
    bool isRequired = false,
    bool isEmail = false, // هل الحقل لبريد إلكتروني
    required BuildContext context,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.04),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 237, 164, 164).withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(50),
        ),
        child: TextFormField(
          controller: controller,
          validator: (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'هذا الحقل مطلوب';
            }
            if (isEmail && !_isValidEmail(value!)) {
              return 'البريد الإلكتروني غير صالح';
            }
            return null;
          },
          //تنسيق شكل الفورم و الحقول

          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: mainFont,
              color: Colors.grey,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(color: Colors.white),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide:
                  BorderSide(color: const Color.fromARGB(255, 251, 207, 207)),
            ),

            //  الحدود عند التركيز
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide:
                  BorderSide(color: const Color.fromARGB(255, 252, 159, 167)),
            ),

            //  الحدود عند وجود خطأ
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide:
                  BorderSide(color: const Color.fromARGB(255, 246, 177, 172)),
            ),

            //  الحدود عند وجود خطأ والتركيز
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide:
                  BorderSide(color: const Color.fromARGB(255, 245, 159, 153)),
            ),

            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: screenWidth * 0.04),
          ),
        ),
      ),
    );
  }

  // دالة للتحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // دالة لإرسال النموذج
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // التحقق من صحة النموذج
      try {
        await _firestore.collection('space_form').add({
          // إضافة البيانات إلى Firestore
          'adId': widget.adId,
          'name': _nameController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'organization': _organizationController.text,
          'productType': _productTypeController.text,
          'wingName': _wingNameController.text, // إضافة اسم الجناح
          'wingImage': _wingImageController.text, // إضافة صورة الجناح
          'timestamp': FieldValue.serverTimestamp(),
        });

        //  رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال طلب الحجز بنجاح',
                style: TextStyle(fontFamily: mainFont)),
            backgroundColor: const Color.fromARGB(255, 171, 170, 170),
          ),
        );

        // العودة إلى الشاشة السابقة بعد فترة
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ البيانات: ${e.toString()}',
                style: TextStyle(fontFamily: mainFont)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _organizationController.dispose();
    _productTypeController.dispose();
    _wingNameController.dispose(); // تحرير حقل اسم الجناح
    _wingImageController.dispose(); // تحرير حقل صورة الجناح
    super.dispose();
  }
}
