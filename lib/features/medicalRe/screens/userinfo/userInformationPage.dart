import 'package:flutter/material.dart';

import 'package:newappgradu/features/medicalRe/screens/userinfo/addPatient.dart';
import 'package:newappgradu/features/medicalRe/screens/userinfo/edit_patient_info_screen.dart';

import '../../data/api_service.dart';



class UserInformationPage extends StatefulWidget {
  const UserInformationPage({super.key});

  @override
  State<UserInformationPage> createState() => _UserInformationPageState();
}

class _UserInformationPageState extends State<UserInformationPage> {
  // متغيرات الحالة
  bool _isLoading = true;
  Map<String, dynamic>? _patientData;
  String? _errorMessage;

  // Map لترجمة القيم الإنجليزية إلى العربية للعرض
  final Map<String, String> _maritalStatusDisplayValues = {
    'single': 'أعزب/عزباء',
    'married': 'متزوج/متزوجة',
    'divorced': 'مطلق/مطلقة',
    'widowed': 'أرمل/أرملة'
  };

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  // دالة لجلب البيانات من الـ API
  Future<void> _fetchPatientData() async {
    // إعادة تعيين الحالة قبل كل طلب جديد
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService().getMyPatientInfo();
      setState(() {
        _patientData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات المستخدم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // عرض الأزرار بناءً على حالة البيانات
          if (!_isLoading && _errorMessage == null)
            _patientData == null
            // إذا لم تكن هناك بيانات، أظهر زر الإضافة
                ? IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'إضافة معلوماتك',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPatientInfoScreen()),
                ).then((_) => _fetchPatientData()); // تحديث البيانات عند العودة
              },
            )
            // إذا كانت هناك بيانات، أظهر زر التعديل
                : IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'تعديل معلوماتك',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditPatientInfoScreen()),
                ).then((_) => _fetchPatientData()); // تحديث البيانات عند العودة
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(), // استدعاء دالة لبناء محتوى الصفحة
    );
  }

  // دالة لبناء محتوى الصفحة بناءً على الحالة (تحميل، خطأ، عرض البيانات)
  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.teal[700]));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red[600], size: 60),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ في جلب البيانات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(_errorMessage!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                onPressed: _fetchPatientData,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              )
            ],
          ),
        ),
      );
    }
    if (_patientData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.blue[600], size: 60),
            const SizedBox(height: 16),
            const Text(
              'لا توجد بيانات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('لم تقم بإضافة معلوماتك الطبية الأساسية بعد.', style: TextStyle(color: Colors.grey),),
            const Text('انقر على علامة (+) في الأعلى للإضافة.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    // إذا كانت هناك بيانات، قم بعرضها
    return RefreshIndicator(
      onRefresh: _fetchPatientData, // تفعيل السحب للتحديث
      color: Colors.teal,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _InfoCard(
            icon: Icons.height,
            label: 'الطول',
            value: '${_patientData!['height'] ?? 'N/A'} سم',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.fitness_center,
            label: 'الوزن',
            value: '${_patientData!['weight'] ?? 'N/A'} كجم',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.bloodtype_outlined,
            label: 'فصيلة الدم',
            value: _patientData!['bloodType'] ?? 'N/A',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.people_alt_outlined,
            label: 'الحالة الاجتماعية',
            // ترجمة القيمة من الإنجليزية إلى العربية للعرض
            value: _maritalStatusDisplayValues[_patientData!['maritalStatus']] ?? _patientData!['maritalStatus'] ?? 'N/A',
          ),
        ],
      ),
    );
  }
}

// ويدجت إضافي لتصميم بطاقة عرض المعلومات بشكل أنيق
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.teal.withOpacity(0.15),
              child: Icon(icon, size: 26, color: Colors.teal[800]),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 15, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}