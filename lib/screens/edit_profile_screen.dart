// ملف شاشة تعديل الملف الشخصي
import 'package:final_project/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // متحكمات حقول النص لإدخال البيانات
  final _firstNameController = TextEditingController(); // للاسم الأول
  final _lastNameController = TextEditingController(); // للاسم الأخير
  final _passwordController = TextEditingController(); // لكلمة المرور
  final _confirmPasswordController =
      TextEditingController(); // لتأكيد كلمة المرور

  // متغيرات اتصال بفيربيس وحالة التطبيق
  final user = FirebaseAuth.instance.currentUser; // المستخدم الحالي
  bool _isLoading = true; // حالة التحميل
  bool _obscurePassword = true; // إخفاء/إظهار كلمة المرور
  String? userDocId; // معرّف مستند المستخدم
  final FirestoreService _firestoreService =
      FirestoreService(); // خدمة فايرستور

  @override
  void initState() {
    super.initState();
    _loadUserData(); // تحميل بيانات المستخدم عند بدء الشاشة
  }

  // دالة لتحميل بيانات المستخدم من فايرستور
  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        final userData = await _firestoreService.getUserData(user!.uid);

        if (userData != null) {
          userDocId = userData['docId']; // حفظ معرّف المستند
          // تعبئة الحقول بالبيانات الموجودة
          _firstNameController.text = userData['data']['first_name'] ?? '';
          _lastNameController.text = userData['data']['last_name'] ?? '';
          _passwordController.text = userData['data']['password'] ?? '';
          _confirmPasswordController.text = userData['data']['password'] ?? '';
        }
      } catch (e) {
        // عرض رسالة خطأ في حالة الفشل
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في جلب البيانات: $e')),
        );
      } finally {
        setState(() => _isLoading = false); // إنهاء التحميل
      }
    }
  }

  // دالة لعرض نافذة تأكيد قبل الحفظ
  Future<void> _confirmAndSave() async {
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text(
            'تأكيد الحفظ',
            style: TextStyle(fontFamily: mainFont),
          ),
        ),
        content: const Text(
          'هل أنت متأكد من حفظ التغييرات؟',
          style: TextStyle(fontFamily: mainFont),
        ),
        actions: [
          // زر الإلغاء
          TextButton(
            child: const Text(
              'إلغاء',
              style: TextStyle(fontFamily: mainFont),
            ),
            onPressed: () => Navigator.pop(context, false),
          ),
          // زر الحفظ
          ElevatedButton(
            child: const Text(
              'نعم، احفظ',
              style: TextStyle(fontFamily: mainFont),
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _saveChanges(); // حفظ التغييرات إذا وافق المستخدم
    }
  }

  // دالة لحفظ التغييرات في فايرستور وفيربيس أوث
  Future<void> _saveChanges() async {
    // التحقق من تطابق كلمتي المرور
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'كلمتا المرور غير متطابقتين',
            style: TextStyle(fontFamily: mainFont),
          ),
        ),
      );
      return;
    }

    try {
      if (userDocId != null) {
        // تحديث بيانات المستخدم في فايرستور
        await _firestoreService.updateUserData(userDocId!, {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'password': _passwordController.text,
        });
      }

      // تحديث كلمة المرور في فيربيس أوث
      await user?.updatePassword(_passwordController.text);

      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تحديث بياناتك بنجاح، ${_firstNameController.text} 🎉',
            style: TextStyle(fontFamily: mainFont),
          ),
        ),
      );
    } catch (e) {
      // عرض رسالة خطأ في حالة الفشل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ: $e',
            style: TextStyle(fontFamily: mainFont),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // اتجاه النص من اليمين لليسار
      child: Scaffold(
        backgroundColor: Colors.white, // خلفية بيضاء للشاشة
        appBar: AppBar(
          backgroundColor: Colors.white, // خلفية بيضاء لشريط التطبيق
          elevation: 0, // إزالة الظل
          leading: IconButton(
            icon: const Icon(Icons.arrow_back), // زر الرجوع
            onPressed: () => Navigator.pop(context),
            color: Colors.black, // لون أسود لزر الرجوع
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator()) // عرض مؤشر تحميل
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 35.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // قسم العنوان والوصف
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "الحساب",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: mainFont,
                              color: Color.fromRGBO(166, 23, 28, 1),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "هنا يمكنك إدارة معلوماتك الشخصية وتحديث بياناتك.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(255, 47, 46, 46),
                              fontFamily: mainFont,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // حاوية النموذج
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // لون الحدود
                          width: 1.5, // سمك الحدود
                        ),
                        borderRadius: BorderRadius.circular(20), // زوايا دائرية
                        color: Colors.white, // خلفية بيضاء
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 198, 181, 181)
                                .withOpacity(0.3), // لون الظل
                            spreadRadius: 4, // مدى انتشار الظل
                            blurRadius: 11, // درجة ضبابية الظل
                            offset: Offset(0, 2), // اتجاه الظل
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // حقل الاسم الأول
                          TextField(
                            controller: _firstNameController,
                            decoration: InputDecoration(
                              labelText: 'الاسم الأول',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),

                          // حقل الاسم الأخير
                          TextField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                              labelText: 'الاسم الأخير',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 16),

                          // حقل كلمة المرور
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() =>
                                      _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // حقل تأكيد كلمة المرور
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'تأكيد كلمة المرور',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // زر الحفظ
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _confirmAndSave,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 241, 192, 69),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'حفظ الإعدادات',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: mainFont,
                                    color: Color.fromARGB(128, 14, 13, 13)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
