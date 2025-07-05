import 'package:flutter/material.dart';
import 'package:newappgradu/features/medicalRe/utils/app_constants.dart';

import '../../data/api_service.dart';
import 'addEditFamilyHistoryScreen.dart';


class FamilyHistoryPage extends StatefulWidget {
  const FamilyHistoryPage({super.key});

  @override
  State<FamilyHistoryPage> createState() => _FamilyHistoryPageState();
}

class _FamilyHistoryPageState extends State<FamilyHistoryPage> {
  late Future<List<dynamic>> _historyFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _historyFuture = _apiService.getFamilyHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = _apiService.getFamilyHistory();
    });
  }

  Future<void> _deleteRecord(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا السجل؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.deleteFamilyHistory(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف بنجاح'), backgroundColor: Colors.green));
      _refreshHistory();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحذف: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red));
    }
  }

  void _navigateToAddEditScreen([Map<String, dynamic>? historyRecord]) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => AddEditFamilyHistoryScreen(historyRecord: historyRecord)),
    ).then((result) {
      if (result == true) {
        _refreshHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تاريخ العائلة المرضي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ في جلب البيانات: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (snapshot.hasData) {
            print(">> FLUTTER: تم استلام هذه البيانات من الخادم: ${snapshot.data}");
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد سجلات. انقر على (+) للإضافة.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final historyList = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _refreshHistory(),
            color: Colors.teal,
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final record = historyList[index] as Map<String, dynamic>;

                // --- تعديل: قراءة مرنة من 'relationship' أو 'relation' ---
                final relationApiValue = record['relationship'] ?? record['relation'];
                final relationDisplayText = getRelationDisplayText(relationApiValue);
                // --- نهاية التعديل ---

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.withOpacity(0.1),
                      child: Icon(Icons.family_restroom_outlined, color: Colors.teal[700]),
                    ),
                    title: Text(relationDisplayText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    subtitle: Text(record['condition'] ?? 'لا توجد حالة مسجلة', style: TextStyle(color: Colors.grey[600])),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit_outlined, color: Colors.amber[800]), tooltip: 'تعديل', onPressed: () => _navigateToAddEditScreen(record)),
                        IconButton(icon: Icon(Icons.delete_outline, color: Colors.red[700]), tooltip: 'حذف', onPressed: () => _deleteRecord(record['_id'])),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'إضافة سجل جديد',
      ),
    );
  }
}