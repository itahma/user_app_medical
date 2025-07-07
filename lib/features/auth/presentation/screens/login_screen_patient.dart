import 'package:flutter/material.dart';
import 'package:newappgradu/core/utils/commons.dart';
import 'package:newappgradu/features/auth/presentation/screens/register_screen_patient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../home/presentation/screen/home_screen.dart';
import '../../data/api_service_Auth.dart';
import 'forgot_password_screen.dart';


class LoginScreenPatient extends StatefulWidget {
  const LoginScreenPatient({super.key});
  @override
  State<LoginScreenPatient> createState() => _LoginScreenPatientState();
}

class _LoginScreenPatientState extends State<LoginScreenPatient> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final _apiService = ApiServiceAuth();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.login(email: _emailController.text.trim(), password: _passwordController.text);

      final token = result['token'];
      final user = result['user'];
      final userRole = user?['role']?.toString().toLowerCase();

      // التحقق من أن المستخدم هو مريض ('user')
      if (userRole == 'user') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('x-jwt', token); // استخدام مفتاح خاص بالمريض
        await prefs.setString('patient_user_role', userRole!);

        // حفظ FCM Token بعد تسجيل الدخول الناجح
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          await _apiService.saveFCMToken(fcmToken);
        }

        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()), // استبدلها بالشاشة الرئيسية لديك
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('بيانات الاعتماد هذه لا تخص حساب مريض.'), backgroundColor: Colors.orange));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الدخول: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل الدخول', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.person_pin_circle_outlined, size: 80, color: Colors.teal),
                const SizedBox(height: 20),
                Text('مرحباً بعودتك!', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                _buildTextField(label: 'البريد الإلكتروني*', hint: 'example@email.com', controller: _emailController, keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? 'الرجاء إدخال بريد صالح' : null),
                const SizedBox(height: 20),
                _buildTextField(label: 'كلمة المرور*', hint: '********', controller: _passwordController, isPassword: true, validator: (v) => (v == null || v.isEmpty) ? 'كلمة المرور مطلوبة' : null),
                Align(alignment: Alignment.centerLeft, child: TextButton(onPressed: () { Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                );}, child: const Text('هل نسيت كلمة المرور؟'))),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _submitLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('ليس لديك حساب؟'),
                  TextButton(onPressed: () {  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const RegisterScreenPatient()), // استبدلها بالشاشة الرئيسية لديك

                  );}, child: const Text('إنشاء حساب جديد', style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint, required TextEditingController controller, bool isPassword = false, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]), filled: true, fillColor: Colors.white,
            suffixIcon: isPassword ? IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          validator: validator,
        ),
      ],
    );
  }
}