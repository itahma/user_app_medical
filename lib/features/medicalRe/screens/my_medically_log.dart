import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newappgradu/features/medicalRe/screens/Immunization/Immunization.dart';
import 'dart:async';

// قم باستيراد صفحاتك الفعلية هنا
import 'package:newappgradu/features/medicalRe/screens/familyHist/familyHistoryPage.dart';
import 'package:newappgradu/features/medicalRe/screens/labRe/labResultsPage.dart';
import 'package:newappgradu/features/medicalRe/screens/medication/medicationsPage.dart';
import 'package:newappgradu/features/medicalRe/screens/procedures_page/my_procedures_page..dart';
import 'package:newappgradu/features/medicalRe/screens/radiology/radiologyResultsPage.dart';
import 'package:newappgradu/features/medicalRe/screens/userinfo/userInformationPage.dart';

import 'allergy_page/chronicConditionsPage.dart';
import 'conditions_page/my_conditions_page.dart';
import 'medicalExa/medicalExaminationPage.dart';

class MainMenuPage extends StatelessWidget {

  // تعريف عناصر القائمة كما هي، فهي منظمة بشكل جيد
  final List<_MenuItem> menuItems = [
    _MenuItem(
      title: 'معلومات المستخدم',
      page: UserInformationPage(),
      icon: Icons.person_outline,
    ),
    _MenuItem(
      title: 'تاريخ العائلة المرضي',
      page: FamilyHistoryPage(),
      icon: Icons.family_restroom_outlined,
    ),
    _MenuItem(
      title: 'الحساسيات',
      page: MyAllergiesPage(),
      icon: CupertinoIcons.shield_lefthalf_fill,
    ),
    _MenuItem(
      title: 'اللقاحات',
      page: ImmunizationsPage(),
      icon: Icons.vaccines_outlined,
    ),
    _MenuItem(
      title: 'الفحوصات الطبية والتشخيص المرضي',
      page: MyEncountersPage(),
      icon: Icons.medical_services_outlined,
    ),
    _MenuItem(
      title: 'نتائج التحالIL الطبية',
      page: LabResultsPage(),
      icon: Icons.biotech_outlined,
    ),
    _MenuItem(
      title: 'الأدوية',
      page: MyMedicationsPage(),
      icon: Icons.medication_liquid_outlined, // أيقونة مختلفة قليلاً
    ),
    _MenuItem(
      title: 'الأمراض',
      page: MyConditionsPage(),
      icon: Icons.coronavirus_outlined, // أيقونة مختلفة قليلاً
    ),
    _MenuItem(
      title: 'العمليات الجراحية ',
      page: MyProceduresPage(),
      icon: Icons.coronavirus_outlined, // أيقونة مختلفة قليلاً
    ),
    _MenuItem(
      title: 'نتائج الصور الشعائية',
      page: RadiologyResultsPage(),
      icon: CupertinoIcons.photo_on_rectangle, // أيقونة مختلفة قليلاً
    ),
  ];

  MainMenuPage({super.key,   });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- AppBar: تغيير الألوان والارتفاع لمظهر أنظف ---
      appBar: AppBar(
        title: const Text(
          'السجل الطبي للمريض',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2, // ظل خفيف
        backgroundColor: Colors.teal, // اللون الأساسي الجديد
      ),
      // --- Background: استخدام تدرج لوني ناعم بأساس لون teal ---
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal.shade50, // بداية بتدرج فاتح جدًا
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            // --- Animation: إضافة تأثير ظهور متدرج للعناصر ---
            return AnimatedListItem(
              index: index,
              child: _buildMenuItemCard(context, menuItems[index]),
            );
          },
        ),
      ),
    );
  }

  // --- Card: تصميم محسن للبطاقات ---
  Widget _buildMenuItemCard(BuildContext context, _MenuItem item) {
    return Card(
      elevation: 2, // ظل أنعم
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // يمكنك إضافة حدود رقيقة إذا أردت
        // side: BorderSide(color: Colors.teal.shade100, width: 1),
      ),
      // --- Interaction: استخدام InkWell لتأثير بصري عند اللمس ---
      child: InkWell(
        borderRadius: BorderRadius.circular(15), // لجعل تأثير اللمس ضمن حواف البطاقة
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item.page),
          );
        },
        splashColor: Colors.teal.withOpacity(0.1), // لون تأثير اللمس
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            textDirection: TextDirection.rtl, // لضمان ترتيب العناصر من اليمين لليسار
            children: [
              // --- ListTile Leading: استخدام CircleAvatar للأيقونة لمظهر أجمل ---
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.teal.withOpacity(0.1),
                child: Icon(
                  item.icon,
                  size: 28,
                  color: Colors.teal.shade700,
                ),
              ),
              const SizedBox(width: 16),
              // --- Title: توسيط النص وإعطاء مساحة مرنة ---
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.right, // محاذاة النص لليمين
                ),
              ),
              const SizedBox(width: 8),
              // --- ListTile Trailing: أيقونة متناسقة ---
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// تعريف صنف عنصر القائمة كما هو
class _MenuItem {
  final String title;
  final Widget page;
  final IconData icon;

  _MenuItem({
    required this.title,
    required this.page,
    required this.icon,
  });
}

// --- ويدجت إضافي للتحريك (Animation) ---
// هذا الويدجت يعطي تأثير ظهور متدرج لكل عنصر في القائمة
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const AnimatedListItem({super.key, required this.index, required this.child});

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    // ابدأ التحريك بعد تأخير بسيط يعتمد على ترتيب العنصر
    Future.delayed(Duration(milliseconds: widget.index * 75), () {
      if (mounted) {
        setState(() {
          _animate = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _animate ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        transform: Matrix4.translationValues(
          0, _animate ? 0 : 50, 0, // يبدأ من الأسفل بمقدار 50 بكسل ثم يصعد
        ),
        child: widget.child,
      ),
    );
  }
}