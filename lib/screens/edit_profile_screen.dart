import 'package:final_project/constants.dart';
import 'package:final_project/services/users_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;
  String? userDocId;
  final UsersServices _usersServices = UsersServices();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      try {
        final userData = await _usersServices.getUserData(user!.uid);
        if (userData != null) {
          userDocId = userData['docId'];
          _firstNameController.text = userData['data']['first_name'] ?? '';
          _lastNameController.text = userData['data']['last_name'] ?? '';
          _emailController.text = userData['data']['email'] ?? '';
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في جلب البيانات: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _confirmAndSave() async {
    if (!isValidEmail(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('البريد الإلكتروني غير صالح')),
      );
      return;
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Text('تأكيد الحفظ', style: TextStyle(fontFamily: mainFont)),
        ),
        content: const Text(
          'هل أنت متأكد من حفظ التغييرات؟',
          style: TextStyle(fontFamily: mainFont),
        ),
        actions: [
          TextButton(
            child: const Text('إلغاء', style: TextStyle(fontFamily: mainFont)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child:
                const Text('نعم، احفظ', style: TextStyle(fontFamily: mainFont)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (shouldSave == true) {
      await _saveChanges();
    }
  }

  Future<void> _saveChanges() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين')),
      );
      return;
    }

    try {
      if (userDocId != null) {
        await _usersServices.updateUserData(userDocId!, {
          'first_name': _firstNameController.text,
          'last_name': _lastNameController.text,
          'email': _emailController.text,
        });
      }

      await user?.updatePassword(_passwordController.text);
      await user?.updateEmail(_emailController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تحديث بياناتك بنجاح، ${_firstNameController.text} 🎉',
            style: const TextStyle(fontFamily: mainFont),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('حدث خطأ: $e', style: const TextStyle(fontFamily: mainFont)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              tooltip: 'رجوع',
              onPressed: () => Navigator.pop(context),
              color: primaryColor,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 35.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 198, 181, 181)
                                .withOpacity(0.3),
                            spreadRadius: 4,
                            blurRadius: 11,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          buildTextField(_firstNameController, 'الاسم الأول'),
                          const SizedBox(height: 16),
                          buildTextField(_lastNameController, 'الاسم الأخير'),
                          const SizedBox(height: 16),
                          buildTextField(_emailController, 'البريد الإلكتروني'),
                          const SizedBox(height: 16),
                          buildPasswordField(
                            _passwordController,
                            'كلمة المرور',
                            _obscurePassword1,
                            () => setState(
                                () => _obscurePassword1 = !_obscurePassword1),
                          ),
                          const SizedBox(height: 16),
                          buildPasswordField(
                            _confirmPasswordController,
                            'تأكيد كلمة المرور',
                            _obscurePassword2,
                            () => setState(
                                () => _obscurePassword2 = !_obscurePassword2),
                          ),
                          const SizedBox(height: 24),
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
                                  color: Color.fromARGB(128, 14, 13, 13),
                                ),
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

  Widget buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget buildPasswordField(TextEditingController controller, String label,
      bool obscure, VoidCallback toggleVisibility) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }
}
