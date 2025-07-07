import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newappgradu/features/auth/data/api_service_Auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../home/presentation/screen/home_screen.dart';
// استورد المسارات الخاصة بك هنا
// import 'package:newappgradu/core/routes/app_routes.dart';
// import 'package:newappgradu/core/utils/commons.dart';

class VerifyAndCompleteProfileScreen extends StatefulWidget {
  final String email;
  const VerifyAndCompleteProfileScreen({super.key, required this.email});

  @override
  State<VerifyAndCompleteProfileScreen> createState() => _VerifyAndCompleteProfileScreenState();
}

class _VerifyAndCompleteProfileScreenState extends State<VerifyAndCompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiServiceAuth();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regionController = TextEditingController();
  final _subRegionController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;

  @override
  void dispose() {
    _codeController.dispose(); _passwordController.dispose(); _confirmPasswordController.dispose();
    _firstNameController.dispose(); _lastNameController.dispose(); _phoneController.dispose();
    _regionController.dispose(); _subRegionController.dispose(); _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime(2000), firstDate: DateTime(1940), lastDate: DateTime.now());
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تعبئة كل الحقول المطلوبة')));
      return;
    }
    setState(() => _isLoading = true);

    final data = {
      'email': widget.email,
      'code': _codeController.text.trim(),
      'password': _passwordController.text,
      'First_Name': _firstNameController.text.trim(),
      'Last_Name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'gender': _selectedGender,
      'dateBirthday': _selectedDate!.toIso8601String(),
      'regionName': _regionController.text.trim(),
      'subRegion': _subRegionController.text.trim(),
      'address': _addressController.text.trim(),
    };

    try {
      final result = await _apiService.verifyAndCompleteProfile(data);
      final token = result['token'];
      final user = result['user'];

      if (token == null || user == null) throw Exception('استجابة الخادم غير صالحة.');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('x-jwt', token);
      await prefs.setString('patient_user_role', user['role']);

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await _apiService.saveFCMToken(fcmToken);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء حسابك بنجاح!'), backgroundColor: Colors.green));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()), // استبدلها بالشاشة الرئيسية لديك
            (route) => false,
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: ${e.toString().replaceFirst("Exception: ", "")}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استكمال الملف الشخصي', style: TextStyle(color: Colors.white)), backgroundColor: Colors.teal),
      backgroundColor: Colors.grey[50],
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle('التحقق وإنشاء كلمة المرور'),
            _buildTextField(controller: _codeController, label: 'كود التحقق*', hint: 'الكود الذي وصل إلى بريدك', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(controller: _passwordController, label: 'كلمة المرور*', hint: '********', isPassword: true, validator: (v) => v!.length < 6 ? 'قصيرة جدًا' : null),
            const SizedBox(height: 16),
            _buildTextField(controller: _confirmPasswordController, label: 'تأكيد كلمة المرور*', hint: '********', isPassword: true, validator: (v) => v != _passwordController.text ? 'كلمتا المرور غير متطابقتين' : null),

            const Divider(height: 40),
            _buildSectionTitle('المعلومات الشخصية'),
            _buildTextField(controller: _firstNameController, label: 'الاسم الأول*', hint: 'مثال: أحمد'),
            const SizedBox(height: 16),
            _buildTextField(controller: _lastNameController, label: 'الاسم الأخير*', hint: 'مثال: العلي'),
            const SizedBox(height: 16),
            _buildTextField(controller: _phoneController, label: 'رقم الهاتف*', hint: '+963...', keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField(controller: _regionController, label: 'المحافظة*', hint: 'مثال: دمشق'),
            const SizedBox(height: 16),
            _buildTextField(controller: _subRegionController, label: 'المنطقة*', hint: 'مثال: المزة'),
            const SizedBox(height: 16),
            _buildTextField(controller: _addressController, label: 'العنوان التفصيلي*', hint: 'مثال: شارع خالد بن الوليد'),
            const SizedBox(height: 16),
            _buildDateField(),
            const SizedBox(height: 16),
            _buildGenderDropdown(),

            const SizedBox(height: 40),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _submitProfile,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text('إنشاء الحساب وتسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 16, top: 8), child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800])));

  Widget _buildTextField({required TextEditingController controller, required String label, String? hint, int maxLines = 1, TextInputType? keyboardType, bool isPassword = false, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, maxLines: maxLines, keyboardType: keyboardType,
          obscureText: isPassword && !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]), filled: true, fillColor: Colors.white,
            suffixIcon: isPassword ? IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          validator: validator ?? (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
        ),
      ],
    );
  }

  Widget _buildDateField() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('تاريخ الميلاد*', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
    const SizedBox(height: 8),
    InkWell(
        borderRadius: BorderRadius.circular(12), onTap: _pickDate,
        child: InputDecorator(
            decoration: InputDecoration(filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(_selectedDate == null ? 'اختر تاريخ ميلادك' : DateFormat('d MMMM, y', 'ar_SA').format(_selectedDate!), style: TextStyle(fontSize: 16, color: _selectedDate == null ? Colors.grey[600] : Colors.black87)),
              Icon(Icons.calendar_today_outlined, color: Colors.teal[700]),
            ])
        )
    )
  ]);

  Widget _buildGenderDropdown() {
    final Map<String, String> genderOptions = {'ذكر': 'male', 'أنثى': 'female'};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الجنس*', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(hintText: 'اختر الجنس', filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
          items: genderOptions.entries.map((entry) => DropdownMenuItem<String>(value: entry.value, child: Text(entry.key))).toList(),
          onChanged: (newValue) => setState(() => _selectedGender = newValue),
          validator: (v) => v == null ? 'هذا الحقل مطلوب' : null,
        ),
      ],
    );
  }
}