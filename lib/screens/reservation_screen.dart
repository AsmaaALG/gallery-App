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
  final _formKey = GlobalKey<FormState>(); // للتحقق من الصحة
  final _firestore =
      FirebaseFirestore.instance; // الاتصال بقاعدة بيانات Firestore

  // وحدات التحكم لحقول الإدخال
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _wingNameController = TextEditingController();
  final TextEditingController _wingImageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEADDDA),
        title: Text(
          'نموذج حجز مساحة',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontFamily: mainFont,
            color: const Color.fromARGB(255, 96, 3, 6),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            key: _formKey,
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

                // حقول النموذج
                _buildTextField('الاسم...', _nameController, isRequired: true),
                _buildTextField('الهاتف...', _phoneController,
                    isRequired: true, isPhone: true),
                _buildTextField('البريد الإلكتروني...', _emailController,
                    isRequired: true, isEmail: true),
                _buildTextField('العنوان ...', _addressController,
                    isRequired: true),
                _buildTextField('اسم الجناح...', _wingNameController,
                    isRequired: true),
                _buildTextField('صورة الجناح...', _wingImageController,
                    isRequired: true),
                _buildTextField(
                    'المؤسسة المسؤولة عن الجناح...', _organizationController,
                    isRequired: true),
                _buildTextField('وصف الجناح ...', _descriptionController,
                    isRequired: true),

                SizedBox(height: screenHeight * 0.04),

                // زر إرسال النموذج
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
                    ),
                    onPressed: _submitForm,
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
  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isRequired = false, bool isEmail = false, bool isPhone = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'هذا الحقل مطلوب';
          }
          if (isEmail && !_isValidEmail(value!)) {
            return 'البريد الإلكتروني غير صالح';
          }
          if (isPhone && !_isValidPhone(value!)) {
            return 'رقم الهاتف يجب أن يكون أرقام فقط';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: mainFont,
            color: Colors.grey,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
                color:
                    const Color.fromARGB(255, 198, 50, 39)), // لون الحواف أحمر
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide:
                BorderSide(color: const Color.fromARGB(255, 251, 207, 207)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide:
                BorderSide(color: const Color.fromARGB(255, 252, 159, 167)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide:
                BorderSide(color: const Color.fromARGB(255, 246, 177, 172)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide:
                BorderSide(color: const Color.fromARGB(255, 245, 159, 153)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: TextStyle(fontFamily: mainFont), // تعيين خط الحقول
      ),
    );
  }

  // دالة للتحقق من صحة البريد الإلكتروني
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // دالة للتحقق من صحة رقم الهاتف
  bool _isValidPhone(String phone) {
    return RegExp(r'^\d+$')
        .hasMatch(phone); // تحقق من أن الرقم يحتوي على أرقام فقط
  }

  // دالة لإرسال النموذج
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('space_form').add({
          'adId': widget.adId,
          'name': _nameController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'organization': _organizationController.text,
          'description': _descriptionController.text,
          'wingName': _wingNameController.text,
          'wingImage': _wingImageController.text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إرسال طلب الحجز بنجاح',
                style: TextStyle(fontFamily: mainFont)),
            backgroundColor: const Color.fromARGB(255, 171, 170, 170),
          ),
        );

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
    _descriptionController.dispose();
    _wingNameController.dispose();
    _wingImageController.dispose();
    super.dispose();
  }
}
