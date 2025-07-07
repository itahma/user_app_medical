import 'package:flutter/material.dart';
import 'package:newappgradu/features/auth/data/api_service_Auth.dart';
import 'package:newappgradu/features/auth/presentation/screens/verify_and_complete_profile_screen.dart';

class RegisterScreenPatient extends StatefulWidget {
  const RegisterScreenPatient({super.key});

  @override
  State<RegisterScreenPatient> createState() => _RegisterScreenPatientState();
}

class _RegisterScreenPatientState extends State<RegisterScreenPatient> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  final _apiService = ApiServiceAuth();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _apiService.registerPatient(_emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال كود التحقق إلى بريدك الإلكتروني.'), backgroundColor: Colors.green));
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => VerifyAndCompleteProfileScreen(email: _emailController.text.trim()),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
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
                Icon(Icons.person_add_alt_1, size: 80, color: Colors.teal[300]),
                const SizedBox(height: 20),
                Text('إنشاء حساب جديد', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                const SizedBox(height: 12),
                Text('أدخل بريدك الإلكتروني لنرسل لك كود التحقق', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني*',
                    hintText: 'example@email.com',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? 'الرجاء إدخال بريد إلكتروني صالح' : null,
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _submitEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('إرسال كود التحقق'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}