import 'package:flutter/material.dart';
import 'BMICalculator.dart'; // تأكد من أن هذه الملفات موجودة ومستوردة بشكل صحيح
import 'CalorieCalculator.dart';
import 'OvulationCalculator.dart';
import 'PregnancyCalculator.dart';
import 'WaterCalculator.dart'; // اسم الملف كان BodyWaterCalculator، تأكد من الاسم الصحيح

class MedicalAccounts extends StatefulWidget {
  const MedicalAccounts({super.key});

  @override
  State<MedicalAccounts> createState() => _MedicalAccountsState();
}

class _MedicalAccountsState extends State<MedicalAccounts> {
  @override
  Widget build(BuildContext context) {
    // استخدام Theme.of(context) للوصول إلى ألوان الـ Theme المحددة في main.dart
    // إذا لم تكن قد حددت theme مخصصًا هناك، يمكنك تحديد الألوان مباشرة هنا.
    final Color primaryColor = Theme.of(context).colorScheme.primary; // يفترض أنه teal
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary; // لون النص على اللون الأساسي

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الحسابات الطبية',style: TextStyle(color: Colors.white,),
          // يمكنك إضافة style هنا إذا لم يكن معرفًا بشكل جيد في الـ AppBarTheme
          // style: TextStyle(color: onPrimaryColor, fontWeight: FontWeight.bold),
        ),
        // backgroundColor: primaryColor, // تم تعريفه في MaterialApp Theme
        // centerTitle: true, // تم تعريفه في MaterialApp Theme
        elevation: 2.0,
      ),
      body: ListView( // استخدام ListView للسماح بالتمرير إذا زاد عدد البطاقات
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCard(
            context, // تمرير context
            title: 'حاسبة الحمل والولادة',
            icon: Icons.pregnant_woman_outlined, // أيقونة مختلفة قليلاً
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PregnancyCalculator()),
              );
            },
          ),
          _buildCard(
            context,
            title: 'حاسبة أيام التبويض',
            icon: Icons.calendar_today_outlined, // أيقونة مختلفة قليلاً
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OvulationCalculator()),
              );
            },
          ),
          _buildCard(
            context,
            title: 'حاسبة مؤشر كتلة الجسم (BMI)',
            icon: Icons.accessibility_new_outlined, // أيقونة مختلفة قليلاً
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BMICalculator()), // تأكد أن هذا الودجت const إذا أمكن
              );
            },
          ),
          _buildCard(
            context,
            title: 'حاسبة السعرات الحرارية (BMR)',
            icon: Icons.local_fire_department_outlined, // أيقونة مختلفة قليلاً
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalorieCalculator()), // تأكد أن هذا الودجت const إذا أمكن
              );
            },
          ),
          _buildCard(
            context,
            title: 'حاسبة كمية الماء اليومية',
            icon: Icons.opacity_outlined, // أيقونة مختلفة قليلاً (قطرة ماء)
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BodyWaterCalculator()), // تأكد من اسم الكلاس الصحيح
              );
            },
          ),
          // يمكنك إضافة المزيد من البطاقات هنا بنفس الطريقة
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    final Color primaryColor = Colors.teal;
    final Color cardBackgroundColor = Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5); // لون خلفية أفتح للبطاقة
    final Color iconColor = primaryColor;
    final Color textColor = Theme.of(context).colorScheme.onSurface; // لون النص الأساسي على السطح

    return Card(
      // margin تم تعريفه في MaterialApp Theme
      // shape تم تعريفه في MaterialApp Theme
      // elevation تم تعريفه في MaterialApp Theme
      clipBehavior: Clip.antiAlias, // لضمان أن InkWell يتبع شكل البطاقة
      color: cardBackgroundColor, // لون خلفية البطاقة
      child: InkWell(
        onTap: onTap,
        splashColor: primaryColor.withOpacity(0.12),
        highlightColor: primaryColor.withOpacity(0.1),
        // borderRadius تم تعريفه في ListTileTheme أو CardTheme
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0), // زيادة الـ padding الداخلي
          child: Row(
            children: [
              Container( // إضافة خلفية دائرية للأيقونة
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.15), // لون خلفية شفاف قليلاً للأيقونة
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: iconColor), // تعديل حجم ولون الأيقونة
              ),
              const SizedBox(width: 20), // زيادة المسافة
              Expanded( // للسماح للنص بالتمدد وأخذ المساحة المتبقية
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith( // استخدام نمط من الـ Theme
                    fontWeight: FontWeight.w600, // خط أعرض قليلاً
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis, // لمنع تجاوز النص إذا كان طويلاً
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.arrow_forward_ios, size: 18, color: primaryColor.withOpacity(0.7)), // أيقونة سهم للإشارة إلى الانتقال
            ],
          ),
        ),
      ),
    );
  }
}