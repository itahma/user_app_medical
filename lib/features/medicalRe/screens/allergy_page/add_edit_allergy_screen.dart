import 'package:flutter/material.dart';

import '../../data/api_service.dart';
import '../../utils/app_constants.dart'; // تأكد من صحة المسار

class AddEditAllergyScreen extends StatefulWidget {
  final Map<String, dynamic>? allergy;
  const AddEditAllergyScreen({this.allergy, super.key});

  @override
  State<AddEditAllergyScreen> createState() => _AddEditAllergyScreenState();
}

class _AddEditAllergyScreenState extends State<AddEditAllergyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _substanceController = TextEditingController();
  final _reactionController = TextEditingController();
  String? _selectedType;

  final _apiService = ApiService();
  bool _isLoading = false;
  bool get _isEditMode => widget.allergy != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _selectedType = widget.allergy!['type'];
      _substanceController.text = widget.allergy!['substance'] ?? '';
      _reactionController.text = widget.allergy!['reaction'] ?? '';
    }
  }

  @override
  void dispose() {
    _substanceController.dispose();
    _reactionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final data = {
      'type': _selectedType,
      'substance': _substanceController.text,
      'reaction': _reactionController.text,
    };

    try {
      if (_isEditMode) {
        await _apiService.updateAllergy(widget.allergy!['_id'], data);
      } else {
        await _apiService.addAllergy(data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isEditMode ? 'تم تحديث الحساسية بنجاح' : 'تمت إضافة الحساسية بنجاح'), backgroundColor: Colors.green));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل العملية: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'تعديل حساسية' : 'إضافة حساسية جديدة', style: const TextStyle(color: Colors.white)),
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
              // حقول النموذج بالتصميم الاحترافي
              _buildDropdownField(label: 'نوع الحساسية*', value: _selectedType, hint: 'اختر نوع الحساسية',
                  items: allergyTypeOptions.entries.map((e) => DropdownMenuItem(value: e.value, child: Text(e.key))).toList(),
                  onChanged: (v) => setState(() => _selectedType = v)),
              const SizedBox(height: 20),
              _buildTextField(controller: _substanceController, label: 'المادة المسببة للحساسية*', hint: 'مثال: بنسلين، غبار الطلع...'),
              const SizedBox(height: 20),
              _buildTextField(controller: _reactionController, label: 'ردة الفعل التحسسية*', hint: 'مثال: طفح جلدي، صعوبة تنفس...', maxLines: 3),
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
                child: Text(_isEditMode ? 'حفظ التعديلات' : 'إضافة', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint, int maxLines = 1}) {
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
          ),
          validator: (v) => v!.isEmpty ? 'هذا الحقل مطلوب' : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({required String label, required String? value, required String hint, required List<DropdownMenuItem<String>> items, required void Function(String?)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: hint, filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          items: items,
          onChanged: onChanged,
          validator: (v) => v == null ? 'الرجاء الاختيار' : null,
        ),
      ],
    );
  }
}