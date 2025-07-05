import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/database/api/end_points.dart';

// تم دمج كل شيء في ملف واحد كما طلبت

class EditProfilePage extends StatefulWidget {
  // هذه الشاشة الآن تستقبل بيانات المستخدم الحالية من الشاشة السابقة
  final Map<String, dynamic> currentUserProfile;

  const EditProfilePage({
    super.key,
    required this.currentUserProfile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers للحقول النصية
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;

  // متغيرات للحقول الأخرى
  DateTime? _selectedDate;
  String? _selectedGender;

  // متغيرات الحالة
  bool _isLoading = false;

  // Map لترجمة وعرض قيم الجنس
  final Map<String, String> _genderOptions = {
    'ذكر': 'male',
    'أنثى': 'female',
  };

  @override
  void initState() {
    super.initState();
    // تهيئة الـ Controllers بالبيانات القادمة من الشاشة السابقة
    _firstNameController = TextEditingController(text: widget.currentUserProfile['First_Name'] ?? '');
    _lastNameController = TextEditingController(text: widget.currentUserProfile['Last_Name'] ?? '');
    _phoneController = TextEditingController(text: widget.currentUserProfile['phone'] ?? '');

    _selectedGender = widget.currentUserProfile['gender'];

    if (widget.currentUserProfile['dateBirthday'] != null) {
      _selectedDate = DateTime.tryParse(widget.currentUserProfile['dateBirthday']);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- بداية: منطق الـ API (باستخدام Dio) ---

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-jwt');
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final Map<String, dynamic> dataToUpdate = {
      'First_Name': _firstNameController.text,
      'Last_Name': _lastNameController.text,
      'phone': _phoneController.text,
      'gender': _selectedGender,
      // تنسيق التاريخ بالشكل DD/MM/YYYY الذي يتوقعه الـ backend
      if (_selectedDate != null)
        'dateBirthday': _selectedDate!.toIso8601String(),
    };

    print(">> FLUTTER: يتم إرسال بيانات التحديث: $dataToUpdate");

    try {
      final token = await _getAuthToken();
      if (token == null) throw Exception('المستخدم غير مسجل دخوله');

      final dio = Dio(BaseOptions(
        baseUrl: '${EndPoint.host}', // ضع هنا عنوان الخادم الأساسي
        headers: {'Content-Type': 'application/json', 'x-jwt': token},
      ));

      final response = await dio.put('/api/user/updateUserProfile', data: dataToUpdate);

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح! ✅'), backgroundColor: Colors.green),
        );
        // العودة إلى الشاشة السابقة مع إرسال إشارة للنجاح لتحديث البيانات هناك
        Navigator.of(context).pop(true);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التحديث: ${e.response?.data['message'] ?? 'حدث خطأ'}'), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التحديث: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // --- نهاية: منطق الـ API ---


  // --- بداية: الدوال المساعدة للواجهة ---

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade400, width: 2)),
          ),
          validator: (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
        ),
      ],
    );
  }
  // --- نهاية: الدوال المساعدة للواجهة ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(label: 'الاسم الأول*', controller: _firstNameController),
              const SizedBox(height: 20),
              _buildTextField(label: 'الاسم الأخير*', controller: _lastNameController),
              const SizedBox(height: 20),
              _buildTextField(label: 'رقم الهاتف*', controller: _phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 20),

              // حقل اختيار تاريخ الميلاد
              Text('تاريخ الميلاد*', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null ? 'اختر تاريخ ميلادك' : DateFormat('dd / MM / yyyy').format(_selectedDate!),
                        style: TextStyle(color: _selectedDate == null ? Colors.grey[600] : Colors.black87, fontSize: 16),
                      ),
                      Icon(Icons.calendar_today_outlined, color: Colors.teal[700]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // حقل اختيار الجنس
              Text('الجنس*', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  hintText: 'اختر الجنس',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                items: _genderOptions.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
                validator: (value) => value == null ? 'الرجاء اختيار الجنس' : null,
              ),
              const SizedBox(height: 40),

              // زر الحفظ
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : ElevatedButton(
                onPressed: _submitUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('حفظ التعديلات', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}