import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/api_service.dart';

class PatientEncounterDetailsPage extends StatefulWidget {
  final String encounterId;
  final String patientId;

  const PatientEncounterDetailsPage({super.key, required this.encounterId, required this.patientId});

  @override
  State<PatientEncounterDetailsPage> createState() => _PatientEncounterDetailsPageState();
}

class _PatientEncounterDetailsPageState extends State<PatientEncounterDetailsPage> {
  late Future<Map<String, dynamic>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = ApiService().getEncounterDetails(
      userId: widget.patientId,
      encounterId: widget.encounterId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل اللقاء الطبي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('لا توجد تفاصيل لهذا اللقاء.'));
          }

          final details = snapshot.data!;
          final encounter = details['encounter'] as Map<String, dynamic>? ?? {};
          final condition = details['condition'] as Map<String, dynamic>?;
          final observations = details['observations'] as List<dynamic>? ?? [];
          final medications = details['medications'] as List<dynamic>? ?? [];

          final doctorInfo = encounter['doctorId'] as Map<String, dynamic>?;
          final doctorName = 'د. ${doctorInfo?['name']?['first'] ?? ''} ${doctorInfo?['name']?['last'] ?? ''}';

          final startDate = DateTime.parse(encounter['start'] ?? DateTime.now().toIso8601String()).toLocal();
          final formattedDate = DateFormat('EEEE, d MMMM, y', 'ar_SA').format(startDate);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionCard(title: 'معلومات اللقاء', children: [
                _InfoRow(icon: Icons.person_outline, label: 'الطبيب المعالج', value: doctorName),
                _InfoRow(icon: Icons.calendar_today, label: 'تاريخ اللقاء', value: formattedDate),
                _InfoRow(icon: Icons.notes_outlined, label: 'سبب الزيارة', value: encounter['reason'] ?? 'غير محدد', isMultiLine: true),
              ]),

              if (observations.isNotEmpty)
                _buildSectionCard(title: 'الفحوصات السريرية', children: observations.map((obs) =>
                    _InfoRow(icon: Icons.thermostat, label: obs['type'], value: '${obs['value']} ${obs['unit'] ?? ''}')).toList()),

              if (condition != null)
                _buildSectionCard(title: 'التشخيص', children: [
                  _InfoRow(icon: Icons.coronavirus_outlined, label: 'الحالة', value: condition['conditionName'] ?? 'غير محدد'),
                  if (condition['notes'] != null && condition['notes'].isNotEmpty)
                    _InfoRow(icon: Icons.comment_outlined, label: 'ملاحظات الطبيب', value: condition['notes'], isMultiLine: true),
                ]),

              if (medications.isNotEmpty)
                _buildSectionCard(title: 'الوصفة الطبية', children: medications.map((med) =>
                    _InfoRow(icon: Icons.medication, label: med['medicationName'], value: 'الجرعة: ${med['dosage']} - لمدة: ${med['duration']}', isMultiLine: true)).toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2, margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _InfoRow({required IconData icon, required String label, required String value, bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 16),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15, color: Colors.grey[800]))),
        ],
      ),
    );
  }
}