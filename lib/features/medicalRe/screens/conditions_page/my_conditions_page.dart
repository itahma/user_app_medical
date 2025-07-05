import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/api_service.dart';
import '../../utils/app_constants.dart';
class MyConditionsPage extends StatefulWidget {
  const MyConditionsPage({super.key});

  @override
  State<MyConditionsPage> createState() => _MyConditionsPageState();
}

class _MyConditionsPageState extends State<MyConditionsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<dynamic>> _chronicConditionsFuture;
  late Future<List<dynamic>> _diagnosedConditionsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _chronicConditionsFuture = _apiService.getMyChronicConditions();
    _diagnosedConditionsFuture = _apiService.getMyDiagnosedConditions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأمراض والتشخيصات', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.teal[200],
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(icon: Icon(Icons.healing), text: 'الأمراض المزمنة'),
            Tab(icon: Icon(Icons.sick_outlined), text: 'التشخيصات السابقة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConditionsList(_chronicConditionsFuture, 'لا توجد أمراض مزمنة مسجلة لك.'),
          _buildConditionsList(_diagnosedConditionsFuture, 'لا توجد تشخيصات سابقة مسجلة لك.'),
        ],
      ),
    );
  }

  Widget _buildConditionsList(Future<List<dynamic>> future, String emptyMessage) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.teal));
        }
        if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text(emptyMessage, style: const TextStyle(fontSize: 18, color: Colors.grey)));
        }

        final conditions = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: conditions.length,
          itemBuilder: (context, index) {
            final condition = conditions[index];
            final doctorInfo = condition['doc_id'] as Map<String, dynamic>?;
            final doctorName = 'د. ${doctorInfo?['name']?['first'] ?? ''} ${doctorInfo?['name']?['last'] ?? ''}';
            final date = DateTime.parse(condition['createdAt']).toLocal();
            final formattedDate = DateFormat('d MMMM, y', 'ar_SA').format(date);

            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(condition['conditionName'] ?? 'حالة غير محددة', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
                    const Divider(height: 20),
                    _InfoRow(icon: Icons.check_circle_outline, label: 'الحالة', value: getClinicalStatusDisplayText(condition['clinicalStatus'])),
                    _InfoRow(icon: Icons.person_outline, label: 'شُخصت بواسطة', value: doctorName),
                    _InfoRow(icon: Icons.calendar_today_outlined, label: 'تاريخ التشخيص', value: formattedDate),
                    if (condition['notes'] != null && condition['notes'].isNotEmpty)
                      _InfoRow(icon: Icons.comment_outlined, label: 'ملاحظات الطبيب', value: condition['notes'], isMultiLine: true),
                  ],
                ),
              ),
            );
          },
        );
      },
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