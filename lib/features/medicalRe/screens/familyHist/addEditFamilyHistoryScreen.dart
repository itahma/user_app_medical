import 'package:flutter/material.dart';
import 'package:newappgradu/features/medicalRe/utils/app_constants.dart';

import '../../data/api_service.dart';


class AddEditFamilyHistoryScreen extends StatefulWidget {
  final Map<String, dynamic>? historyRecord;
  const AddEditFamilyHistoryScreen({this.historyRecord, super.key});

  @override
  State<AddEditFamilyHistoryScreen> createState() =>
      _AddEditFamilyHistoryScreenState();
}

class _AddEditFamilyHistoryScreenState
    extends State<AddEditFamilyHistoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conditionController = TextEditingController();
  final _notesController = TextEditingController();

  final _apiService = ApiService();
  bool _isLoading = false;
  bool get _isEditMode => widget.historyRecord != null;
  String? _selectedRelationValue;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      // --- تعديل: قراءة مرنة من 'relationship' أو 'relation' ---
      _selectedRelationValue = widget.historyRecord!['relation'] ?? widget.historyRecord!['relationship'];
      _conditionController.text = widget.historyRecord!['condition'] ?? '';
      _notesController.text = widget.historyRecord!['notes'] ?? '';
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      // نرسل 'relation' لأن الـ backend يتوقعه في body الطلب
      'relation': _selectedRelationValue,
      'condition': _conditionController.text,
      'notes': _notesController.text,
    };
    print(">> FLUTTER: يتم إرسال هذه البيانات إلى الخادم: $data");

    try {
      if (_isEditMode) {
        await _apiService.updateFamilyHistory(widget.historyRecord!['_id'], data);
      } else {
        await _apiService.addFamilyHistory(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_isEditMode ? 'تم تحديث السجل بنجاح' : 'تمت إضافة السجل بنجاح'),
            backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل العملية: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _conditionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade400, width: 2)),
          ),
          validator: validator,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'تعديل سجل مرضي' : 'إضافة سجل مرضي جديد', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal, iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // حقل صلة القرابة (قائمة منسدلة) بالتصميم الجديد
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('صلة القرابة*', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedRelationValue,
                    decoration: InputDecoration(
                      hintText: 'اختر صلة القرابة', hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true, fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                    isExpanded: true,
                    items: familyRelationOptions.entries.map((entry) => DropdownMenuItem<String>(value: entry.value, child: Text(entry.key))).toList(),
                    onChanged: (value) => setState(() => _selectedRelationValue = value),
                    validator: (v) => v == null ? 'هذا الحقل مطلوب' : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'الحالة المرضية*',
                hint: 'مثال: السكري، ضغط الدم...',
                controller: _conditionController,
                validator: (v) => v == null || v.isEmpty ? 'هذا الحقل مطلوب' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'ملاحظات (اختياري)',
                hint: 'أي تفاصيل إضافية...',
                controller: _notesController,
                maxLines: 4,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditMode ? Colors.amber[800] : Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_isEditMode ? 'حفظ التعديلات' : 'إضافة السجل', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}