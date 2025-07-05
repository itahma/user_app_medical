import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // لاستخدام DateFormat

import '../../data/api_service.dart';

class AddEditImmunizationScreen extends StatefulWidget {
  final Map<String, dynamic>? immunizationRecord;
  const AddEditImmunizationScreen({this.immunizationRecord, super.key});

  @override
  State<AddEditImmunizationScreen> createState() => _AddEditImmunizationScreenState();
}

class _AddEditImmunizationScreenState extends State<AddEditImmunizationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineNameController = TextEditingController();
  final _doseNumberController = TextEditingController();
  final _lotNumberController = TextEditingController();

  DateTime? _selectedDate; // لتخزين التاريخ المختار

  final _apiService = ApiService();
  bool _isLoading = false;
  bool get _isEditMode => widget.immunizationRecord != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final record = widget.immunizationRecord!;
      _vaccineNameController.text = record['vaccineName'] ?? '';
      _doseNumberController.text = record['doseNumber']?.toString() ?? '';
      _lotNumberController.text = record['lotNumber'] ?? '';
      // قراءة التاريخ وتحويله من نص إلى كائن DateTime
      if (record['date'] != null) {
        _selectedDate = DateTime.tryParse(record['date']);
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء اختيار تاريخ اللقاح'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _isLoading = true);

    final data = {
      'vaccineName': _vaccineNameController.text,
      'doseNumber': int.tryParse(_doseNumberController.text) ?? 0,
      'lotNumber': _lotNumberController.text,
      // تحويل التاريخ إلى صيغة ISO 8601 String التي يتوقعها الـ backend
      'date': _selectedDate!.toIso8601String(),
    };

    try {
      if (_isEditMode) {
        await _apiService.updateImmunization(widget.immunizationRecord!['_id'], data);
      } else {
        await _apiService.addImmunization(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditMode ? 'تم تحديث اللقاح بنجاح' : 'تمت إضافة اللقاح بنجاح'), backgroundColor: Colors.green));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل العملية: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // دالة لاختيار التاريخ
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'تعديل اللقاح' : 'إضافة لقاح جديد', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.teal, iconTheme: const IconThemeData(color: Colors.white)),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _vaccineNameController, decoration: const InputDecoration(labelText: 'اسم اللقاح*'), validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
              const SizedBox(height: 20),
              // حقل التاريخ
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade400)),
                tileColor: Colors.white,
                leading: const Icon(Icons.calendar_today_outlined, color: Colors.teal),
                title: const Text('تاريخ أخذ اللقاح*'),
                subtitle: Text(
                  _selectedDate == null ? 'لم يتم الاختيار' : DateFormat('EEEE, d MMMM, y', 'ar_SA').format(_selectedDate!),
                  style: TextStyle(fontWeight: FontWeight.bold, color: _selectedDate == null ? Colors.grey : Colors.black87),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 20),
              TextFormField(controller: _doseNumberController, decoration: const InputDecoration(labelText: 'رقم الجرعة*'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
              const SizedBox(height: 20),
              TextFormField(controller: _lotNumberController, decoration: const InputDecoration(labelText: 'رقم التشغيلة (Lot)*'), validator: (v) => v!.isEmpty ? 'الحقل مطلوب' : null),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: _isEditMode ? Colors.amber[800] : Colors.teal, padding: const EdgeInsets.symmetric(vertical: 15)),
                child: Text(_isEditMode ? 'حفظ التعديلات' : 'إضافة اللقاح', style: const TextStyle(fontSize: 18, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}