import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api_service.dart';



class AddPatientInfoScreen extends StatefulWidget {
  const AddPatientInfoScreen({super.key});

  @override
  State<AddPatientInfoScreen> createState() => _AddPatientInfoScreenState();
}

class _AddPatientInfoScreenState extends State<AddPatientInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String? _selectedMaritalStatus;
  String? _selectedBloodType;
  bool _isLoading = false;

  // --- بداية التعديل: متغير الحالة لتحديد وضع الواجهة ---
  bool _isDataSaved = false;
  // --- نهاية التعديل ---

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
    // عند بدء الشاشة، حاول تحميل البيانات المحفوظة لتحديد الوضع
    _loadAndDisplayPatientInfo();
  }

  // دالة لتحميل البيانات وعرضها وتحديد وضع الواجهة
  Future<void> _loadAndDisplayPatientInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final String? patientJsonString = prefs.getString('patient_medical_info');

    if (patientJsonString != null) {
      final Map<String, dynamic> patientData = jsonDecode(patientJsonString);

      setState(() {
        _heightController.text = patientData['height']?.toString() ?? '';
        _weightController.text = patientData['weight']?.toString() ?? '';
        _selectedBloodType = patientData['bloodType'];

        final String? savedApiStatus = patientData['maritalStatus'];
        if (savedApiStatus != null) {
          _selectedMaritalStatus = _maritalStatusApiValues.entries
              .firstWhere((entry) => entry.value == savedApiStatus, orElse: () => const MapEntry('', ''))
              .key;
        }

        // --- تعديل: تفعيل وضع القراءة فقط لأن البيانات موجودة ---
        _isDataSaved = true;
      });
    }
  }

  Future<void> _submitPatientInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final patientData = {
      'height': double.tryParse(_heightController.text) ?? 0,
      'weight': double.tryParse(_weightController.text) ?? 0,
      'maritalStatus': _maritalStatusApiValues[_selectedMaritalStatus],
      'bloodType': _selectedBloodType,
    };

    try {
      final responseData = await _apiService.addPatient(patientData);
      await _savePatientInfoLocally(responseData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ المعلومات بنجاح! ✅'), backgroundColor: Colors.green),
      );

      // --- بداية التعديل: تفعيل وضع القراءة فقط بعد الحفظ الناجح ---
      setState(() {
        _isDataSaved = true;
        _isLoading = false;
      });
      // --- نهاية التعديل ---

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحفظ: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePatientInfoLocally(Map<String, dynamic> patientData) async {
    final prefs = await SharedPreferences.getInstance();
    String patientJsonString = jsonEncode(patientData);
    await prefs.setString('patient_medical_info', patientJsonString);
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
        title: Text(
          // تغيير العنوان بناءً على حالة الحفظ
            _isDataSaved ? 'ملفك الطبي الأساسي' : 'استكمال الملف الطبي',
            style: const TextStyle(color: Colors.white)
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 20),
              // عرض رسالة مختلفة بناءً على حالة الحفظ
              Text(
                _isDataSaved
                    ? 'تم حفظ معلوماتك الطبية الأساسية بنجاح.'
                    : 'الرجاء إدخال معلوماتك الطبية الأساسية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.teal[700]),
                textAlign: TextAlign.center,
              ),
              if(_isDataSaved)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'للتعديل، يرجى استخدام شاشة تعديل الملف الشخصي.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 30),

              // --- بداية التعديل: إضافة خاصية readOnly ---
              TextFormField(
                controller: _heightController,
                readOnly: _isDataSaved, // <-- جعل الحقل للقراءة فقط إذا تم الحفظ
                decoration: InputDecoration(
                  labelText: 'الطول (سم)',
                  prefixIcon: Icon(Icons.height, color: Colors.teal[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: _isDataSaved ? Colors.grey[200] : Colors.white, // تغيير لون الخلفية
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) { /* ... */ return null; },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                readOnly: _isDataSaved, // <-- جعل الحقل للقراءة فقط
                decoration: InputDecoration(
                  labelText: 'الوزن (كجم)',
                  prefixIcon: Icon(Icons.fitness_center, color: Colors.teal[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: _isDataSaved ? Colors.grey[200] : Colors.white,
                  filled: true,
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
                  fillColor: _isDataSaved ? Colors.grey[200] : Colors.white,
                  filled: true,
                ),
                value: _selectedMaritalStatus,
                hint: const Text('اختر الحالة الاجتماعية'),
                items: _maritalStatusOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                // --- تعطيل القائمة المنسدلة إذا تم الحفظ ---
                onChanged: _isDataSaved ? null : (newValue) => setState(() => _selectedMaritalStatus = newValue),
                validator: (value) => value == null ? 'الرجاء الاختيار' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'فصيلة الدم',
                  prefixIcon: Icon(Icons.bloodtype_outlined, color: Colors.teal[600]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  fillColor: _isDataSaved ? Colors.grey[200] : Colors.white,
                  filled: true,
                ),
                value: _selectedBloodType,
                hint: const Text('اختر فصيلة الدم'),
                items: _bloodTypeOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                // --- تعطيل القائمة المنسدلة إذا تم الحفظ ---
                onChanged: _isDataSaved ? null : (newValue) => setState(() => _selectedBloodType = newValue),
                validator: (value) => value == null ? 'الرجاء الاختيار' : null,
              ),
              // --- نهاية التعديل ---
              const SizedBox(height: 40),

              // --- بداية التعديل: إظهار الزر فقط إذا لم يتم الحفظ بعد ---
              if (!_isDataSaved)
                _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.teal[700]))
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_outlined),
                  label: const Text('حفظ المعلومات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  ),
                  onPressed: _submitPatientInfo,
                ),
              // --- نهاية التعديل ---
            ],
          ),
        ),
      ),
    );
  }
}