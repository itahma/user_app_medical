import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'doctor_results_page.dart';
class DoctorSearchPage extends StatefulWidget {
  const DoctorSearchPage({super.key});

  @override
  State<DoctorSearchPage> createState() => _DoctorSearchPageState();
}

class _DoctorSearchPageState extends State<DoctorSearchPage> {
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  RangeValues _priceRange = const RangeValues(0, 100000);
  double _minRating = 0.0;

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _navigateToResults() {
    // تجميع كل الفلاتر في خريطة (Map) واحدة
    final filters = {
      'name': _nameController.text,
      'specialization': _specializationController.text,
      'city': _cityController.text,
      'country': _countryController.text,
      'minPrice': _priceRange.start.round().toString(),
      // لا نرسل maxPrice إذا كان في حده الأقصى لتجنب تصفية غير ضرورية
      'maxPrice': _priceRange.end.round() >= 100000 ? '' : _priceRange.end.round().toString(),
      'minRating': _minRating.toString(),
    };

    // الانتقال إلى شاشة النتائج وتمرير الفلاتر معها
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorResultsPage(searchFilters: filters),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ابحث عن طبيب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ابحث عن الطبيب المناسب لك', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.teal[900])),
            const SizedBox(height: 8),
            Text('استخدم الفلاتر أدناه لتضييق نطاق البحث والعثور على أفضل رعاية.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 24),
            _buildTextField(controller: _nameController, label: 'اسم الطبيب', hint: 'ابحث بالاسم...'),
            const SizedBox(height: 16),
            _buildTextField(controller: _specializationController, label: 'التخصص', hint: 'ابحث بالتخصص...'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(controller: _countryController, label: 'المحافظة', hint: 'مثال: دمشق')),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(controller: _cityController, label: 'المدينة/المنطقة', hint: 'مثال: المزة')),
              ],
            ),
            const SizedBox(height: 24),
            Text('نطاق سعر المعاينة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
            RangeSlider(
              values: _priceRange, min: 0, max: 100000,
              divisions: 20,
              labels: RangeLabels('ل.س ${_priceRange.start.round()}', _priceRange.end.round() >= 100000 ? '+100 ألف' : 'ل.س ${_priceRange.end.round()}'),
              onChanged: (RangeValues values) => setState(() => _priceRange = values),
              activeColor: Colors.teal,
            ),
            const SizedBox(height: 16),
            Text('الحد الأدنى للتقييم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: _minRating, minRating: 0,
              direction: Axis.horizontal, allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) => setState(() => _minRating = rating),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text('بـحـث'),
              onPressed: _navigateToResults,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal[800])),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true, fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.teal.shade400, width: 2)),
          ),
        ),
      ],
    );
  }
}