import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // لاستخدام DateFormat
import '../../data/api_service.dart';
import 'add_edit_immunization_screen.dart';

class ImmunizationsPage extends StatefulWidget {
  const ImmunizationsPage({super.key});

  @override
  State<ImmunizationsPage> createState() => _ImmunizationsPageState();
}

class _ImmunizationsPageState extends State<ImmunizationsPage> {
  late Future<List<dynamic>> _immunizationsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _immunizationsFuture = _apiService.getImmunizations();
  }

  void _refreshList() {
    setState(() {
      _immunizationsFuture = _apiService.getImmunizations();
    });
  }

  // --- بداية الإضافة: دالة لحذف سجل اللقاح ---
  Future<void> _deleteImmunization(String id) async {
    // إظهار مربع حوار للتأكيد قبل الحذف
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا السجل بشكل نهائي؟'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    // إذا لم يؤكد المستخدم الحذف، لا تفعل شيئًا
    if (confirmDelete != true) return;

    try {
      await _apiService.deleteImmunization(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف اللقاح بنجاح'), backgroundColor: Colors.green),
      );
      _refreshList(); // تحديث القائمة بعد الحذف
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحذف: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
      );
    }
  }
  // --- نهاية الإضافة ---

  void _navigateToAddEditScreen([Map<String, dynamic>? record]) {
    Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => AddEditImmunizationScreen(immunizationRecord: record)))
        .then((result) {
      if (result == true) _refreshList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اللقاحات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _immunizationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد لقاحات مسجلة.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final immunizations = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _refreshList(),
            color: Colors.teal,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80), // مسافة للـ FAB
              itemCount: immunizations.length,
              itemBuilder: (context, index) {
                final record = immunizations[index] as Map<String, dynamic>;
                final date = record['date'] != null ? DateTime.tryParse(record['date']) : null;
                final formattedDate = date != null ? DateFormat('d / M / yyyy', 'ar_SA').format(date) : 'لا يوجد تاريخ';

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        child: Icon(Icons.vaccines_outlined, color: Colors.teal[700]),
                      ),
                      title: Text(record['vaccineName'] ?? 'اسم اللقاح غير معروف', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                          'تاريخ اللقاح: $formattedDate\n'
                              'الجرعة رقم: ${record['doseNumber']} - التشغيلة: ${record['lotNumber'] ?? 'N/A'}'
                      ),
                      isThreeLine: true,
                      // --- بداية التعديل: إضافة زر الحذف ---
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_outlined, color: Colors.amber[800]),
                            tooltip: 'تعديل',
                            onPressed: () => _navigateToAddEditScreen(record),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                            tooltip: 'حذف',
                            onPressed: () => _deleteImmunization(record['_id']),
                          ),
                        ],
                      ),
                      // --- نهاية التعديل ---
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
        tooltip: 'إضافة لقاح جديد',
      ),
    );
  }
}