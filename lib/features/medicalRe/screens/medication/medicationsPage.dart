import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/api_service.dart'; // تأكد من صحة المسار

class MyMedicationsPage extends StatefulWidget {
  const MyMedicationsPage({super.key});

  @override
  State<MyMedicationsPage> createState() => _MyMedicationsPageState();
}

class _MyMedicationsPageState extends State<MyMedicationsPage> {
  late Future<List<dynamic>> _medicationsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _medicationsFuture = _apiService.getMyMedications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أدويتي الموصوفة', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _medicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد أدوية موصوفة لك.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final medications = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final med = medications[index];
              final medName = med['medicationName'] ?? 'دواء غير معروف';

              // استخلاص اسم الطبيب من الكائن المتداخل
              final doctorInfo = med['encounterId']?['doctorId']?['name'] as Map<String, dynamic>?;
              final doctorFirstName = doctorInfo?['first'] ?? '';
              final doctorLastName = doctorInfo?['last'] ?? '';
              final doctorName = (doctorFirstName.isNotEmpty) ? 'د. $doctorFirstName $doctorLastName' : 'طبيب غير محدد';

              final date = med['createdAt'] != null ? DateTime.parse(med['createdAt']) : null;
              final formattedDate = date != null ? DateFormat('d MMM, y', 'ar_SA').format(date) : 'غير محدد';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(medName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                      const Divider(height: 20),
                      _InfoRow(icon: Icons.medication_liquid_outlined, label: 'الجرعة', value: med['dosage'] ?? 'غير محددة'),
                      _InfoRow(icon: Icons.timer_outlined, label: 'مدة الاستخدام', value: med['duration'] ?? 'غير محددة'),
                      _InfoRow(icon: Icons.person_outline, label: 'وُصفت بواسطة', value: doctorName),
                      _InfoRow(icon: Icons.calendar_today_outlined, label: 'تاريخ الوصفة', value: formattedDate),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _InfoRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15, color: Colors.grey[800]))),
        ],
      ),
    );
  }
}