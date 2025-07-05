import 'package:flutter/material.dart';

import '../../data/api_service.dart';
import '../../utils/app_constants.dart';
import 'add_edit_allergy_screen.dart';

class MyAllergiesPage extends StatefulWidget {
  const MyAllergiesPage({super.key});

  @override
  State<MyAllergiesPage> createState() => _MyAllergiesPageState();
}

class _MyAllergiesPageState extends State<MyAllergiesPage> {
  late Future<List<dynamic>> _allergiesFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _refreshAllergies();
  }

  void _refreshAllergies() {
    setState(() {
      _allergiesFuture = _apiService.getMyAllergies();
    });
  }

  void _navigateToAddEditScreen([Map<String, dynamic>? allergy]) {
    Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => AddEditAllergyScreen(allergy: allergy)))
        .then((result) {
      if (result == true) _refreshAllergies();
    });
  }

  Future<void> _deleteAllergy(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا السجل؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await _apiService.deleteAllergy(id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف بنجاح'), backgroundColor: Colors.green));
      _refreshAllergies();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الحذف: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحساسيات', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _allergiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لم تقم بإضافة أي حساسيات بعد.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final allergies = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _refreshAllergies(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: allergies.length,
              itemBuilder: (context, index) {
                final allergy = allergies[index];
                return Card(
                  elevation: 3, margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    leading: const CircleAvatar(child: Icon(Icons.shield_outlined)),
                    title: Text(allergy['substance'] ?? 'مادة غير معروفة', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('النوع: ${getAllergyTypeDisplayText(allergy['type'])}\nردة الفعل: ${allergy['reaction'] ?? ''}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: Icon(Icons.edit_outlined, color: Colors.amber[800]), onPressed: () => _navigateToAddEditScreen(allergy)),
                        IconButton(icon: Icon(Icons.delete_outline, color: Colors.red[700]), onPressed: () => _deleteAllergy(allergy['_id'])),
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
        tooltip: 'إضافة حساسية جديدة',
      ),
    );
  }
}