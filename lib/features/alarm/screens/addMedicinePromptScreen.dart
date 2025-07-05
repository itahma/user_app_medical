import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/medicine_model.dart';
import 'addMedicineDetailsScreen.dart'; // لاستيراد النوع

// افترض أن هذا المتغير متاح هنا ليتم تمريره، أو أن AddMedicinePromptScreen يستقبله في مُنشئه
// extern FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin; // أو يتم تمريره للمنشئ

class AddMedicinePromptScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const AddMedicinePromptScreen({
    super.key,
    required this.flutterLocalNotificationsPlugin,
  });

  @override
  State<AddMedicinePromptScreen> createState() => _AddMedicinePromptScreenState();
}

class _AddMedicinePromptScreenState extends State<AddMedicinePromptScreen> {
  List<Medicine> _activeMedicines = [];
  bool _isLoading = true;
  bool _isInit = true; // متغير جديد لمنع إعادة التشغيل

  @override
  void initState() {
    super.initState();

  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) { // تحقق من أن هذه هي المرة الأولى فقط
      _checkPermissionsAndLoadMedicines();
    }
    _isInit = false; // قم بتعيينه إلى false بعد التشغيل الأول
  }

  Future<void> _checkPermissionsAndLoadMedicines() async {
    await _checkAndRequestNotificationPermission();
    _loadActiveMedicines();
  }

  Future<void> _checkAndRequestNotificationPermission() async {
    // التحقق فقط إذا كنا على أندرويد
    if (!mounted) return;
    if (Theme.of(context).platform == TargetPlatform.android) {
      PermissionStatus status = await Permission.notification.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        if (!context.mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false, // لا يمكن إغلاق الحوار بالضغط في الخارج
          builder: (BuildContext context) => AlertDialog(
            title: const Text("إذن الإشعارات مطلوب"),
            content: const Text(
                "يعتمد هذا التطبيق على الإشعارات لتذكيرك بمواعيد الأدوية. "
                    "يرجى منح إذن الإشعارات من إعدادات التطبيق لضمان عمل التذكيرات بشكل صحيح.\n\n"
                    "يمكنك فعل ذلك بالذهاب إلى: الإعدادات > التطبيقات > (منبه الأدوية) > الإشعارات، وتفعيلها."),
            actions: <Widget>[
              TextButton(
                child: const Text("فتح الإعدادات"),
                onPressed: () {
                  openAppSettings(); // يفتح إعدادات التطبيق مباشرة
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("حسنًا"),
                onPressed: () {
                  Navigator.of(context).pop();
                  // يمكنك هنا محاولة طلب الإذن مرة أخرى إذا أردت، أو ترك المستخدم يفعله يدويًا
                  // Permission.notification.request();
                },
              ),
            ],
          ),
        );
        // إعادة التحقق من الحالة بعد أن قد يكون المستخدم منح الإذن
        status = await Permission.notification.status;
        if(status.isGranted){
          debugPrint("إذن الإشعارات تم منحه من الإعدادات.");
        } else {
          debugPrint("إذن الإشعارات ما زال غير ممنوح.");
        }
      } else if (status.isGranted) {
        debugPrint("إذن الإشعارات ممنوح بالفعل.");
      }
    }
  }

  Future<void> _loadActiveMedicines() async {
    setState(() {
      _isLoading = true;
    });
    final box = await Hive.openBox<Medicine>('medicinesBox'); // تأكد من فتح الـ box إذا لم يكن مفتوحًا
    // فلترة الأدوية النشطة
    _activeMedicines = box.values.where((medicine) {
      if (medicine.stopDateType == 'specificDate' && medicine.stopDate != null) {
        // إذا كان هناك تاريخ توقف محدد، تأكد أنه لم يمض بعد
        // نضيف يومًا لتاريخ التوقف ليشمل اليوم الأخير كاملاً
        return medicine.stopDate!.add(const Duration(days: 1)).isAfter(DateTime.now());
      }
      return true; // إذا كان مدى الحياة أو لا يوجد تاريخ توقف، فهو نشط
    }).toList();

    // يمكنك هنا ترتيب الأدوية إذا أردت، مثلاً بالاسم
    _activeMedicines.sort((a, b) => a.name.compareTo(b.name));

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteMedicine(Medicine medicine, int index) async {
    // أولاً، إلغاء جميع الإشعارات المجدولة لهذا الدواء
    for (int notificationId in medicine.notificationIds) {
      try {
        await widget.flutterLocalNotificationsPlugin.cancel(notificationId);
        debugPrint('تم إلغاء الإشعار ذو المعرف: $notificationId للدواء ${medicine.name}');
      } catch (e) {
        debugPrint('خطأ أثناء إلغاء الإشعار $notificationId: $e');
      }
    }

    // ثانياً، حذف الدواء من Hive
    // بما أن كائنات HiveObject تعرف مفتاحها، يمكن استخدام medicine.delete()
    try {
      await medicine.delete(); // يفترض أن Medicine extends HiveObject
      debugPrint('تم حذف الدواء ${medicine.name} من Hive.');
      _loadActiveMedicines(); // إعادة تحميل القائمة لعكس الحذف
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف دواء "${medicine.name}" بنجاح.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      debugPrint('خطأ أثناء حذف الدواء ${medicine.name} من Hive: $e');
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ أثناء حذف دواء "${medicine.name}".'), backgroundColor: Colors.red),
        );
      }
    }
  }


  void _navigateAndAddMedicine() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicineDetailsScreen(
          flutterLocalNotificationsPlugin: widget.flutterLocalNotificationsPlugin,
        ),
      ),
    );

    if (result == true && mounted) { // إذا تم إضافة دواء بنجاح
      _loadActiveMedicines(); // أعد تحميل قائمة الأدوية
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'منبه الأدوية',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // backgroundColor: Colors.teal, // من الـ Theme
        // foregroundColor: Colors.white, // من الـ Theme
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activeMedicines.isEmpty
          ? _buildEmptyState() // عرض الواجهة الأصلية إذا لم يكن هناك أدوية
          : _buildMedicinesList(), // عرض قائمة الأدوية
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateAndAddMedicine,
        label: const Text('إضافة دواء جديد'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(
            Icons.medical_services_outlined,
            size: 100.0,
            color: Colors.teal[700],
          ),
          const SizedBox(height: 30.0),
          Text(
            'أضف الأدوية التي تتناولها ... وسوف نذكرك بمواعيدها',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15.0),
          Text(
            'انقر على زر "إضافة دواء جديد" بالأسفل لتبدأ.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 50), // مساحة لـ FAB
        ],
      ),
    );
  }

  Widget _buildMedicinesList() {
    return RefreshIndicator(
      onRefresh: _loadActiveMedicines, // لتحديث القائمة عند السحب للأسفل
      child: ListView.builder(
        padding: const EdgeInsets.all(10.0).copyWith(bottom: 80), // مساحة لـ FAB
        itemCount: _activeMedicines.length,
        itemBuilder: (context, index) {
          final medicine = _activeMedicines[index];
          // تنسيق مواعيد الجرعات
          String doseTimes = medicine.doses.map((dose) {
            // نفترض أن الوقت مُخزن كسلسلة HH:mm a أو ما شابه
            return "${dose.time} (${dose.quantity})";
          }).join('\n');

          String stopDateInfo = "مدى الحياة / حسب الحاجة";
          if (medicine.stopDateType == 'specificDate' && medicine.stopDate != null) {
            stopDateInfo = "حتى: ${DateFormat('yyyy/MM/dd', 'ar').format(medicine.stopDate!)}";
          }

          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
              leading: CircleAvatar(
                backgroundColor: Colors.teal[100],
                child: Icon(Icons.medication_outlined, color: Colors.teal[800], size: 28),
              ),
              title: Text(
                medicine.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text(
                    doseTimes,
                    style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    stopDateInfo,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[400], size: 26),
                onPressed: () {
                  // تأكيد الحذف
                  showDialog(
                    context: context,
                    builder: (BuildContext ctx) => AlertDialog(
                      title: const Text('تأكيد الحذف'),
                      content: Text('هل أنت متأكد أنك تريد حذف دواء "${medicine.name}"؟ سيتم إلغاء جميع تنبيهاته.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('إلغاء'),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('حذف'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            _deleteMedicine(medicine, index);
                          },
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'حذف الدواء',
              ),
              isThreeLine: true, // لجعل الـ ListTile يتسع للمحتوى
            ),
          );
        },
      ),
    );
  }
}