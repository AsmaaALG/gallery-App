import 'package:final_project/models/ad_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/constants.dart';
import 'package:flutter/services.dart';

class ReservationScreen extends StatefulWidget {
  final AdModel ad;

  const ReservationScreen({super.key, required this.ad});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _organizationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _wingNameController = TextEditingController();
  final TextEditingController _commercialNumberController =
      TextEditingController();

  String? _selectedOrganizationType;
  Map<String, dynamic>? _selectedSuite;
  List<Map<String, dynamic>> _suites = [];

  @override
  void initState() {
    super.initState();
    _fetchSuites();
  }

  Future<void> _fetchSuites() async {
    final doc = await _firestore.collection('ads').doc(widget.ad.id).get();
    final data = doc.data();

    if (data != null && data['suites'] != null) {
      List<Map<String, dynamic>> suitesList =
          List<Map<String, dynamic>>.from(data['suites']);

      // تصفية الأجنحة التي status == 1
      suitesList = suitesList.where((suite) => suite['status'] == 0).toList();

      // ترتيب الأجنحة حسب الاسم
      suitesList.sort((a, b) {
        final nameA = a['name']?.toString() ?? '';
        final nameB = b['name']?.toString() ?? '';
        return nameA.compareTo(nameB);
      });

      setState(() {
        _suites = suitesList;
      });
    }
  }

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
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'يمكنك تعبئة النموذج للاشتراك وحجز مساحة لك داخل المعرض',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontFamily: mainFont,
                    color: const Color.fromARGB(255, 60, 59, 59),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                _buildTextField('الاسم...', _nameController, isRequired: true),
                _buildTextField('الهاتف...', _phoneController,
                    isRequired: true, isPhone: true),
                _buildTextField('البريد الإلكتروني...', _emailController,
                    isRequired: true, isEmail: true),
                _buildTextField('العنوان...', _addressController,
                    isRequired: true),
                _buildTextField('المؤسسة المسؤولة...', _organizationController,
                    isRequired: true),
                _buildTextField('الرقم التجاري...', _commercialNumberController,
                    isRequired: true, isNumber: true),

                _buildTextField('اسم الجناح...', _wingNameController,
                    isRequired: true),
                _buildTextField('وصف الجناح...', _descriptionController,
                    isRequired: true, maxLines: 3),

                // نوع المؤسسة
                DropdownButtonFormField<String>(
                  value: _selectedOrganizationType,
                  decoration: _dropdownDecoration('نوع المؤسسة (محلي / أجنبي)'),
                  items: ['محلي', 'أجنبي'].map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Align(
                          alignment: Alignment.topRight,
                          child: Text(type,
                              style: TextStyle(
                                  fontFamily: mainFont, fontSize: 13))),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => _selectedOrganizationType = val),
                  validator: (val) => val == null ? 'اختر نوع المؤسسة' : null,
                ),
                const SizedBox(height: 15),

                // قائمة الأجنحة
                DropdownButtonFormField<Map<String, dynamic>>(
                  menuMaxHeight: 300,
                  value: _selectedSuite,
                  alignment: AlignmentDirectional.centerStart,
                  decoration: _suites.isEmpty
                      ? _dropdownDecoration('لاتوجد أجنحة متاحة')
                      : _dropdownDecoration('اختر الجناح'),
                  items: _suites.map((suite) {
                    final name = suite['name'] ?? 'جناح';
                    final area = suite['area'] ?? 'غير محدد';
                    final price = suite['price'] ?? 'غير محدد';
                    return DropdownMenuItem(
                      alignment: AlignmentDirectional.centerEnd,
                      value: suite,
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          textAlign: TextAlign.right,
                          // 'جناح :$name / المساحة:$area / السعر:$price',
                          ' المساحة : $area (م²)   |  السعر : $price د   | $name',
                          style: TextStyle(fontFamily: mainFont, fontSize: 11),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedSuite = val),
                  validator: (val) => val == null ? 'اختر جناحًا' : null,
                ),

                const SizedBox(height: 15),

                // زر خارطة المعرض
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          MapViewerScreen(imageUrl: widget.ad.imageUrl),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(
                        color: Color.fromARGB(255, 251, 207, 207)),
                    backgroundColor: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'خارطة المعرض',
                        textAlign: TextAlign.center,
                        style:
                            const TextStyle(fontFamily: mainFont, fontSize: 12),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.04),

                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 241, 192, 69),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.2,
                        vertical: screenHeight * 0.02,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
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

  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(fontFamily: mainFont, color: Colors.grey),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isRequired = false,
      bool isEmail = false,
      bool isPhone = false,
      bool isNumber = false,
      int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters:
            isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'هذا الحقل مطلوب';
          }
          if (isEmail && !_isValidEmail(value!)) {
            return 'ادخال بريد إلكتروني صالح مثل ex@gmail.com';
          }
          if (isPhone && !RegExp(r'^\d{10}$').hasMatch(value!)) {
            return 'رقم الهاتف يجب أن يكون مكونًا من 10 أرقام';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontFamily: mainFont, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        style: const TextStyle(fontFamily: mainFont),
      ),
    );
  }

  bool _isValidEmail(String email) {
    final RegExp regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$");
    final allowedDomains = [
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
      'icloud.com'
    ];
    if (!regex.hasMatch(email)) return false;
    final domain = email.split('@').last.toLowerCase();
    return allowedDomains.contains(domain);
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestore.collection('space_form').add({
          'adId': widget.ad.id,
          'name': _nameController.text,
          'address': _addressController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'organization': _organizationController.text,
          'description': _descriptionController.text,
          'wingName': _wingNameController.text,
          'commercialNumber': _commercialNumberController.text,
          'organizationType': _selectedOrganizationType,
          'selectedSuite': _selectedSuite,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              textAlign: TextAlign.right,
              'تم إرسال طلبك سيتم ارسال بريد لك في حالة القبول',
              style: TextStyle(fontFamily: mainFont, fontSize: 13)),
          backgroundColor: Color.fromARGB(255, 171, 170, 170),
        ));

        Future.delayed(
            const Duration(seconds: 1), () => Navigator.pop(context));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              textAlign: TextAlign.right,
              'خطأ أثناء الحفظ: $e',
              style: const TextStyle(fontFamily: mainFont)),
          backgroundColor: Colors.red,
        ));
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
    _commercialNumberController.dispose();
    super.dispose();
  }
}

class MapViewerScreen extends StatelessWidget {
  final String imageUrl;
  const MapViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          foregroundColor: primaryColor,
          title: const Text(
            'خارطة المعرض',
            style: TextStyle(color: primaryColor),
          )),
      body: InteractiveViewer(
        child: Center(
          child: Image.network(
            imageUrl, // غيّر المسار إذا لزم
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.broken_image,
                    size: 50, color: const Color.fromARGB(255, 207, 202, 174)),
              );
            },
          ),
        ),
      ),
    );
  }
}
