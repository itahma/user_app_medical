import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // لتنسيق التاريخ والوقت
import 'package:hive/hive.dart'; // لاستخدامه مع Hive
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // للإشعارات المحلية
import 'package:timezone/data/latest_all.dart' as tz; // لـ TimeZone
import 'package:timezone/timezone.dart' as tz;

import '../models/medicine_model.dart'; // لـ TimeZone

// تم إزالة السطر: extern FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// سيتم الآن تمرير flutterLocalNotificationsPlugin عبر المُنشئ.

// تعريف نموذج مبسط للجرعة داخل هذه الشاشة لإدارة الحالة المحلية
class DoseInput {
  TimeOfDay? time;
  String? quantity;
  // يمكنك إضافة حقل لليوم إذا كنت تريد تحديد أيام معينة للجرعة
  // String? day;

  DoseInput({this.time, this.quantity});
}

class AddMedicineDetailsScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin; // تمت الإضافة هنا

  const AddMedicineDetailsScreen({
    super.key,
    required this.flutterLocalNotificationsPlugin, // تمت الإضافة هنا
  });

  @override
  State<AddMedicineDetailsScreen> createState() => _AddMedicineDetailsScreenState();
}

class _AddMedicineDetailsScreenState extends State<AddMedicineDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _medicineNameController = TextEditingController();

  List<DoseInput> _doses = [DoseInput()]; // تبدأ بجرعة واحدة فارغة
  String _stopDateType = 'lifelong'; // القيم الممكنة: 'lifelong', 'specificDate'
  DateTime? _selectedStopDate;

  final List<String> _quantityOptions = [
    '0.25', '0.5', '1', '1.5', '2', '2.5', '3',
    'قرص واحد', 'نصف قرص', 'كبسولة واحدة',
    '5 مل', '10 مل', '15 مل',
    '1 سم مكعب', '2 سم مكعب', '5 سم مكعب',
    'حقنة واحدة',
    'قطرة واحدة', 'قطرتان',
    // يمكنك إضافة المزيد من الخيارات الشائعة هنا
  ];

  @override
  void initState() {
    super.initState();
    _initializeTimezone(); // تهيئة المناطق الزمنية للإشعارات
  }

  Future<void> _initializeTimezone() async {
    tz.initializeTimeZones();
    // يمكنك تعيين المنطقة الزمنية المحلية إذا لزم الأمر، ولكن عادة ما يكتشفها تلقائيًا
    // مثال: tz.setLocalLocation(tz.getLocation('Asia/Damascus'));
    // تأكد من أن اسم المنطقة الزمنية صحيح إذا كنت ستستخدمها
    final String currentTimeZone = await DateTime.now().timeZoneName;
    if (currentTimeZone.isNotEmpty && tz.timeZoneDatabase.locations.containsKey(currentTimeZone)) {
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } else {
      // Fallback or default timezone if detection fails or is not in the database
      // For Syria, 'Asia/Damascus' is a common one.
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Damascus'));
      } catch (e) {
        print("Failed to set default timezone Asia/Damascus: $e. Using UTC.");
        // tz.setLocalLocation(tz.UTC); // Or handle appropriately
      }
    }
  }

  // --- وظائف اختيار الوقت والتاريخ ---
  Future<void> _selectTime(BuildContext context, int doseIndex) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _doses[doseIndex].time ?? TimeOfDay.now(),
      helpText: 'اختر وقت الجرعة',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      builder: (BuildContext context, Widget? child) {
        return Localizations.override(
          context: context,
          locale: const Locale('ar'), // لتعريب أزرار منتقي الوقت
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
        );
      },
    );
    if (pickedTime != null && pickedTime != _doses[doseIndex].time) {
      setState(() {
        _doses[doseIndex].time = pickedTime;
      });
    }
  }

  Future<void> _selectStopDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStopDate ?? DateTime.now().add(const Duration(days:1)), // تاريخ البدء المقترح
      firstDate: DateTime.now(), // لا يمكن اختيار تاريخ في الماضي
      lastDate: DateTime(2101),
      helpText: 'اختر تاريخ التوقف عن الدواء',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
      locale: const Locale('ar'), // لدعم التقويم العربي
    );
    if (pickedDate != null && pickedDate != _selectedStopDate) {
      setState(() {
        _selectedStopDate = pickedDate;
      });
    }
  }
  // --- نهاية وظائف اختيار الوقت والتاريخ ---

  void _addDoseField() {
    setState(() {
      _doses.add(DoseInput());
    });
  }

  void _removeDoseField(int index) {
    if (_doses.length > 1) { // لا تسمح بإزالة آخر جرعة
      setState(() {
        _doses.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يجب أن تكون هناك جرعة واحدة على الأقل.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _resetDoseTimeAndQuantity(int doseIndex) {
    setState(() {
      _doses[doseIndex].time = null;
      _doses[doseIndex].quantity = null;
    });
  }

  Future<void> _scheduleNotification(
      int id, String title, String body, TimeOfDay timeOfDay, String stopDateType, DateTime? stopDate) async {

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    if (stopDateType == 'specificDate' && stopDate != null) {
      // نجعل تاريخ التوقف في نهاية اليوم المحدد للمقارنة بشكل صحيح
      final tz.TZDateTime tzStopDate = tz.TZDateTime(tz.local, stopDate.year, stopDate.month, stopDate.day, 23, 59, 59);
      if (scheduledDate.isAfter(tzStopDate)) {
        print('تنبيه لـ "$title" في الوقت ${timeOfDay.format(context)} هو بعد تاريخ التوقف. لن يتم جدولته.');
        return;
      }
    }

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'medicine_reminder_channel_id',
      'تذكيرات الأدوية',
      channelDescription: 'قناة خاصة بتذكيرات مواعيد الأدوية',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      // sound: RawResourceAndroidNotificationSound('notification_sound'), // إذا كان لديك صوت مخصص
      ticker: 'تذكير بالدواء',
      icon: '@mipmap/ic_launcher', // تأكد من وجود هذا الرمز
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      // iOS: DarwinNotificationDetails(...), // لإضافة دعم iOS لاحقًا
    );

    try {
      // استخدام النسخة الممررة عبر widget.flutterLocalNotificationsPlugin
      await widget.flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // للتكرار اليومي في نفس الوقت
        payload: 'medicine_id_$id',
      );
      print('تم جدولة الإشعار: المعرف $id, العنوان: $title, الوقت: ${timeOfDay.format(context)}, تاريخ الجدولة: $scheduledDate');
    } catch (e) {
      print('حدث خطأ أثناء جدولة الإشعار: $e');
      // يمكنك عرض رسالة خطأ للمستخدم هنا إذا لزم الأمر
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في جدولة الإشعار: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelNotification(int id) async {
    try {
      // استخدام النسخة الممررة عبر widget.flutterLocalNotificationsPlugin
      await widget.flutterLocalNotificationsPlugin.cancel(id);
      print('تم إلغاء الإشعار ذو المعرف: $id');
    } catch (e) {
      print('حدث خطأ أثناء إلغاء الإشعار: $e');
    }
  }

  void _submitForm() async { // تم تحويلها إلى async
    if (_formKey.currentState!.validate()) {
      // التحقق من أن جميع الجرعات لديها وقت وكمية
      bool allDosesValid = true;
      for (var i = 0; i < _doses.length; i++) {
        if (_doses[i].time == null || _doses[i].quantity == null || _doses[i].quantity!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('يرجى إكمال بيانات الجرعة رقم ${i + 1} (الوقت والكمية).'), backgroundColor: Colors.redAccent),
          );
          allDosesValid = false;
          break;
        }
      }
      if (!allDosesValid) return;

      // التحقق من تاريخ التوقف إذا كان محددًا
      if (_stopDateType == 'specificDate' && _selectedStopDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى تحديد تاريخ التوقف عن الدواء.'), backgroundColor: Colors.redAccent),
        );
        return;
      }

      final medicineName = _medicineNameController.text;
      List<Dose> hiveDoses = [];
      List<int> notificationIds = [];
      // استخدام جزء من الطابع الزمني الحالي كأساس لمعرفات الإشعارات لزيادة فرصة التفرد
      // مع إضافة فهرس الجرعة لضمان التفرد داخل نفس الدواء
      int baseNotificationId = DateTime.now().millisecondsSinceEpoch % 1000000;

      for (var i = 0; i < _doses.length; i++) {
        final uiDose = _doses[i];
        // التأكد من أن الوقت والكمية ليسا null قبل المتابعة (تم التحقق أعلاه ولكن كإجراء احترازي إضافي)
        if (uiDose.time == null || uiDose.quantity == null) continue;

        hiveDoses.add(Dose(
          time: uiDose.time!.format(context), // تخزين الوقت كسلسلة نصية
          quantity: uiDose.quantity!,
          // day: uiDose.day, // إذا أضفت حقل اليوم
        ));

        int notificationId = baseNotificationId + i;
        notificationIds.add(notificationId);

        // جدولة الإشعار لكل جرعة
        await _scheduleNotification(
            notificationId,
            'تذكير بدواء: $medicineName',
            'حان الآن موعد تناول جرعة (${uiDose.quantity}) من $medicineName.',
            uiDose.time!,
            _stopDateType,
            _selectedStopDate
        );
      }

      final newMedicine = Medicine(
        name: medicineName,
        doses: hiveDoses,
        stopDateType: _stopDateType,
        stopDate: _stopDateType == 'specificDate' ? _selectedStopDate : null,
        notificationIds: notificationIds, // حفظ معرفات الإشعارات
      );

      try {
        final medicinesBox = Hive.box<Medicine>('medicinesBox');
        await medicinesBox.add(newMedicine);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم حفظ دواء "$medicineName" وجدولة التنبيهات بنجاح!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // العودة إلى الواجهة الأولى، مع إشارة إلى أنه تم إضافة دواء
        }
      } catch (e) {
        print('حدث خطأ أثناء حفظ الدواء في Hive: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في حفظ الدواء: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة تفاصيل الدواء'),
        // backgroundColor: Colors.teal, // تم تعريفه في الـ theme الرئيسي
        // foregroundColor: Colors.white, // تم تعريفه في الـ theme الرئيسي
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _submitForm,
            tooltip: 'حفظ الدواء',
            iconSize: 28,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 40.0), // مسافة إضافية في الأسفل
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'أدخل تفاصيل الدواء ليتم تذكيرك بمواعيد الجرعات بدقة.',
                style: TextStyle(fontSize: 16.0, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25.0),

              // --- حقل اسم الدواء ---
              TextFormField(
                controller: _medicineNameController,
                decoration: InputDecoration(
                  labelText: 'اسم الدواء',
                  hintText: 'مثال: بنادول، فيتامين سي، أنسولين',
                  // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), // من الـ theme
                  prefixIcon: const Icon(Icons.medication_liquid_outlined, color: Colors.teal),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال اسم الدواء';
                  }
                  if (value.length < 2) {
                    return 'اسم الدواء قصير جدًا';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20.0),

              // --- حقول الجرعات الديناميكية ---
              Text('الجرعات:', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.teal, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10.0),
              if (_doses.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('لم تتم إضافة أي جرعات بعد. انقر على "إضافة جرعة أخرى".', textAlign: TextAlign.center,),
                )),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _doses.length,
                itemBuilder: (context, index) {
                  return _buildDoseInputCard(index);
                },
              ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.teal, size: 22),
                  label: const Text('إضافة جرعة أخرى', style: TextStyle(color: Colors.teal, fontSize: 16, fontWeight: FontWeight.w600)),
                  onPressed: _addDoseField,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 25.0),

              // --- تاريخ التوقف عن الدواء ---
              Text('مدة العلاج:', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.teal, fontWeight: FontWeight.bold)),
              RadioListTile<String>(
                title: const Text('دواء مدى الحياة / حسب الحاجة'),
                value: 'lifelong',
                groupValue: _stopDateType,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _stopDateType = value;
                    });
                  }
                },
                activeColor: Colors.teal,
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<String>(
                title: const Text('حتى تاريخ معين'),
                value: 'specificDate',
                groupValue: _stopDateType,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _stopDateType = value;
                      if (value == 'specificDate' && _selectedStopDate == null) {
                        // فتح منتقي التاريخ تلقائيًا إذا لم يتم اختيار تاريخ بعد
                        _selectStopDate(context);
                      }
                    });
                  }
                },
                activeColor: Colors.teal,
                contentPadding: EdgeInsets.zero,
              ),
              if (_stopDateType == 'specificDate')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 8.0), // تقليل الـ horizontal padding
                  child: InkWell(
                    onTap: () => _selectStopDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'تاريخ التوقف المحدد',
                        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), // من الـ theme
                        prefixIcon: const Icon(Icons.calendar_today_outlined, color: Colors.teal),
                        hintText: 'انقر لاختيار التاريخ',
                      ),
                      child: Text(
                        _selectedStopDate == null
                            ? 'اختر التاريخ'
                            : DateFormat('EEEE, d MMMM finalList', 'ar').format(_selectedStopDate!),
                        style: TextStyle(
                          color: _selectedStopDate == null ? Colors.grey[700] : Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 35.0),

              // --- زر إضافة الدواء ---
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_alt_outlined, size: 22),
                  label: const Text('حفظ الدواء والتذكيرات', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Colors.teal, // من الـ theme
                    // foregroundColor: Colors.white, // من الـ theme
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // من الـ theme
                    elevation: 5,
                  ),
                  onPressed: _submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoseInputCard(int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('الجرعة ${index + 1}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.teal[700])),
                if (_doses.length > 1)
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red[600]),
                    iconSize: 26,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _removeDoseField(index),
                    tooltip: 'إزالة هذه الجرعة',
                  ),
              ],
            ),
            const SizedBox(height: 15),
            // --- حقل الوقت ---
            InkWell(
              onTap: () => _selectTime(context, index),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'وقت الجرعة',
                  // border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), // من الـ theme
                  prefixIcon: const Icon(Icons.access_time_filled_rounded, color: Colors.teal),
                  hintText: 'انقر لاختيار الوقت',
                ),
                child: Text(
                  _doses[index].time == null
                      ? 'اختر الوقت'
                      : _doses[index].time!.format(context), // يستخدم تنسيق الوقت المحلي
                  style: TextStyle(
                    color: _doses[index].time == null ? Colors.grey[700] : Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // --- حقل الكمية ---
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'الكمية',
                // border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), // من الـ theme
                prefixIcon: const Icon(Icons.local_drink_outlined, color: Colors.teal), // أيقونة أنسب للكمية
                hintText: 'اختر أو أدخل الكمية',
              ),
              value: _doses[index].quantity,
              isExpanded: true,
              items: _quantityOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 16)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _doses[index].quantity = newValue;
                });
              },
              validator: (value) => value == null || value.isEmpty ? 'يرجى اختيار الكمية' : null,
              // لإضافة إمكانية إدخال كمية مخصصة، ستحتاج إلى تصميم أكثر تعقيدًا
              // قد يتضمن TextField بجانب القائمة المنسدلة أو زر "كمية أخرى"
            ),
            const SizedBox(height: 12),
            // --- زر إعادة اختيار الوقت والكمية ---
            Align(
              alignment: AlignmentDirectional.centerStart, // ليدعم RTL/LTR
              child: TextButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('إعادة تعيين الجرعة', style: TextStyle(fontSize: 14)),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange[800],
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                onPressed: () => _resetDoseTimeAndQuantity(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    super.dispose();
  }
}
