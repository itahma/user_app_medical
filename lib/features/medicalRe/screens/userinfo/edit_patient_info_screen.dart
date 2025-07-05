import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api_service.dart';




class EditPatientInfoScreen extends StatefulWidget {
  const EditPatientInfoScreen({super.key});

  @override
  State<EditPatientInfoScreen> createState() => _EditPatientInfoScreenState();
}

class _EditPatientInfoScreenState extends State<EditPatientInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  // استخدام late لتهيئة الـ Controllers داخل initState بعد تحميل البيانات
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String? _selectedMaritalStatus;
  String? _selectedBloodType;
  bool _isLoading = false;
  // متغير لتخزين البيانات الأصلية للمقارنة (اختياري)
  Map<String, dynamic>? _initialPatientData;

  final List<String> _maritalStatusOptions = [
    'أعزب/عزباء', 'متزوج/متزوجة', 'مطلق/مطلقة', 'أرمل/أرملة'
  ];
  final List<String> _bloodTypeOptions = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];
  final Map<String, String> _maritalStatusApiValues = {
    'أعزب/عزباء': 'single',
    'متزوج/متزوجة': 'married',
    'مطلق/مطلقة': 'divorced',
    'أرمل/أرملة': 'widowed'
  };

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // تهيئة الـ Controllers قبل استخدامها
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    // تحميل بيانات المريض المحفوظة عند بدء الشاشة
    _loadPatientInfo();
  }

  Future<void> _loadPatientInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final String? patientJsonString = prefs.getString('patient_medical_info');

    if (patientJsonString != null) {
      _initialPatientData = jsonDecode(patientJsonString);

      setState(() {
        _heightController.text = _initialPatientData?['height']?.toString() ?? '';
        _weightController.text = _initialPatientData?['weight']?.toString() ?? '';
        _selectedBloodType = _initialPatientData?['bloodType'];

        final String? savedApiStatus = _initialPatientData?['maritalStatus'];
        if (savedApiStatus != null) {
          _selectedMaritalStatus = _maritalStatusApiValues.entries
              .firstWhere((entry) => entry.value == savedApiStatus, orElse: () => const MapEntry('', ''))
              .key;
        }
      });
    } else {
      // التعامل مع حالة عدم وجود بيانات (مثلاً، عرض رسالة والعودة)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على بيانات مريض للتعديل.'), backgroundColor: Colors.orange),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedPatientData = {
      'height': double.tryParse(_heightController.text) ?? 0,
      'weight': double.tryParse(_weightController.text) ?? 0,
      'maritalStatus': _maritalStatusApiValues[_selectedMaritalStatus],
      'bloodType': _selectedBloodType,
    };

    try {
      final responseData = await _apiService.updatePatient(updatedPatientData);
      // تحديث البيانات المحفوظة محليًا بالبيانات الجديدة من الخادم
      await _savePatientInfoLocally(responseData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث المعلومات بنجاح! ✅'), backgroundColor: Colors.green),
      );
      // العودة إلى الشاشة السابقة بعد نجاح التحديث
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التحديث: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePatientInfoLocally(Map<String, dynamic> patientData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('patient_medical_info', jsonEncode(patientData));
    print('تم تحديث البيانات المحفوظة محليًا بالكامل: ${jsonEncode(patientData)}');
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الطبي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _initialPatientData == null
      // عرض مؤشر تحميل أثناء جلب البيانات الأولية
          ? Center(child: CircularProgressIndicator(color: Colors.teal[700]))
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                'يمكنك تعديل معلوماتك الطبية الأساسية هنا.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.teal[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'الطول (سم)',
                  prefixIcon: Icon(Icons.height, color: Colors.teal[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                validator: (value) { /* ... */ return null; },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'الوزن (كجم)',
                  prefixIcon: Icon(Icons.fitness_center, color: Colors.teal[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) { /* ... */ return null; },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'الحالة الاجتماعية',
                  prefixIcon: Icon(Icons.people_alt_outlined, color: Colors.teal[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                value: _selectedMaritalStatus,
                items: _maritalStatusOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                onChanged: (String? newValue) => setState(() => _selectedMaritalStatus = newValue),
                validator: (value) => value == null ? 'الرجاء الاختيار' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'فصيلة الدم',
                  prefixIcon: Icon(Icons.bloodtype_outlined, color: Colors.teal[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                value: _selectedBloodType,
                items: _bloodTypeOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                onChanged: (String? newValue) => setState(() => _selectedBloodType = newValue),
                validator: (value) => value == null ? 'الرجاء الاختيار' : null,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.teal[700]))
                  : ElevatedButton.icon(
                icon: const Icon(Icons.save_as_outlined),
                label: const Text('حفظ التعديلات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // لون مميز للتحديث
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                ),
                onPressed: _submitUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}