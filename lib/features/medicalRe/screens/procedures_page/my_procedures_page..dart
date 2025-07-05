import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/api_service.dart'; // تأكد من صحة المسار

class MyProceduresPage extends StatefulWidget {
  const MyProceduresPage({super.key});

  @override
  State<MyProceduresPage> createState() => _MyProceduresPageState();
}

class _MyProceduresPageState extends State<MyProceduresPage> {
  late Future<List<dynamic>> _proceduresFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _proceduresFuture = _apiService.getMyProcedures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل العمليات الجراحية', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _proceduresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد عمليات جراحية مسجلة.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final procedures = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: procedures.length,
            itemBuilder: (context, index) {
              final procedure = procedures[index];

              final performerInfo = procedure['performer'] as Map<String, dynamic>?;
              final doctorName = 'د. ${performerInfo?['name']?['first'] ?? ''} ${performerInfo?['name']?['last'] ?? 'غير معروف'}';

              final date = DateTime.parse(procedure['date']).toLocal();
              final formattedDate = DateFormat('d MMMM, y', 'ar_SA').format(date);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ExpansionTile(
                  leading: const Icon(Icons.healing_outlined, color: Colors.teal, size: 32),
                  title: Text(procedure['procedureName'] ?? 'عملية غير مسماة', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  subtitle: Text(formattedDate, style: TextStyle(color: Colors.grey[700])),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    _InfoRow(icon: Icons.person_outline, label: 'الطبيب', value: doctorName),
                    if (procedure['description'] != null)
                      _InfoRow(icon: Icons.notes_outlined, label: 'الوصف', value: procedure['description'], isMultiLine: true),
                    if (procedure['location'] != null)
                      _InfoRow(icon: Icons.local_hospital_outlined, label: 'المكان', value: procedure['location']),
                    if (procedure['outcome'] != null)
                      _InfoRow(icon: Icons.check_circle_outline, label: 'النتيجة', value: procedure['outcome']),
                    if (procedure['notes'] != null)
                      _InfoRow(icon: Icons.comment_outlined, label: 'ملاحظات', value: procedure['notes'], isMultiLine: true),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _InfoRow({required IconData icon, required String label, required String value, bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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