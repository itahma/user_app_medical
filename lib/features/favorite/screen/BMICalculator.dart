import 'package:flutter/material.dart';
import 'dart:math' as math; // لاستخدام Pi في الرسوم البيانية (اختياري)

class BMICalculator extends StatefulWidget {
  // جعله const إذا لم يكن هناك سبب آخر لعدم كونه const
  const BMICalculator({super.key});

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  double _height = 170; // الطول الافتراضي بالسنتيمتر
  double _weight = 70;  // الوزن الافتراضي بالكيلوجرام
  String? _bmiResult;
  String? _bmiCategory;
  List<String>? _bmiAdvice;
  Color? _bmiCategoryColor;

  // دالة لحساب مؤشر كتلة الجسم وتحديد الفئة والنصيحة
  void _calculateBMI() {
    if (_height <= 0 || _weight <= 0) return; // تحقق من القيم الموجبة

    double heightInMeters = _height / 100;
    double bmi = _weight / (heightInMeters * heightInMeters);

    String category;
    List<String> advice;
    Color categoryColor;

    if (bmi < 18.5) {
      category = "نقص الوزن";
      advice = [
        "تناول وجبات غذائية متوازنة وغنية بالسعرات الحرارية.",
        "زيادة عدد الوجبات اليومية وتضمين المكسرات والبروتين.",
        "مراجعة طبيب مختص لمعرفة الأسباب والحصول على خطة غذائية."
      ];
      categoryColor = Colors.blue[300]!;
    } else if (bmi >= 18.5 && bmi < 24.9) {
      category = "وزن طبيعي";
      advice = [
        "حافظ على نظام غذائي متوازن.",
        "مارس الرياضة بانتظام للحفاظ على الوزن المثالي.",
        "تناول كميات كافية من الماء يوميًا."
      ];
      categoryColor = Colors.teal;
    } else if (bmi >= 25 && bmi < 29.9) {
      category = "زيادة في الوزن";
      advice = [
        "تقليل استهلاك الأطعمة ذات السعرات الحرارية العالية.",
        "زيادة النشاط البدني اليومي وممارسة التمارين الرياضية.",
        "استشر أخصائي تغذية للحصول على نصائح غذائية مناسبة."
      ];
      categoryColor = Colors.orange[400]!;
    } else if (bmi >= 30 && bmi < 34.9) {
      category = "سمنة (الدرجة الأولى)";
      advice = [
        "ابدأ بخطة غذائية تهدف إلى تقليل الوزن تدريجيًا.",
        "مارس رياضة المشي أو التمارين الخفيفة بانتظام.",
        "استشر طبيبًا متخصصًا للحصول على برنامج غذائي ورياضي ملائم."
      ];
      categoryColor = Colors.red[300]!;
    } else if (bmi >= 35 && bmi < 39.9) {
      category = "سمنة (الدرجة الثانية)";
      advice = [
        "من الضروري استشارة طبيب لوضع خطة علاجية شاملة.",
        "قد تحتاج إلى تدخلات أكثر تخصصًا بالإضافة إلى النظام الغذائي والرياضة.",
        "الدعم النفسي قد يكون مفيدًا خلال رحلة إنقاص الوزن."
      ];
      categoryColor = Colors.red[400]!;
    } else { // bmi >= 40
      category = "سمنة مفرطة (الدرجة الثالثة)";
      advice = [
        "هذه حالة تتطلب تدخلًا طبيًا عاجلاً ومتخصصًا.",
        "الخيارات العلاجية قد تشمل الجراحة بالإضافة إلى تغييرات نمط الحياة المكثفة.",
        "لا تتردد في طلب المساعدة الطبية فورًا."
      ];
      categoryColor = Colors.red[700]!;
    }

    setState(() {
      _bmiResult = bmi.toStringAsFixed(1);
      _bmiCategory = category;
      _bmiAdvice = advice;
      _bmiCategoryColor = categoryColor;
    });
  }

  // دالة لإعادة تعيين القيم
  void _reset() {
    setState(() {
      _height = 170;
      _weight = 70;
      _bmiResult = null;
      _bmiCategory = null;
      _bmiAdvice = null;
      _bmiCategoryColor = null;
    });
  }

  // ويدجت لبناء قسم الإدخال (الطول أو الوزن)
  Widget _buildInputSlider({
    required String label,
    required String unit,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    final Color primaryColor = Colors.teal;

    return Card(
      // elevation تم تعريفه في Theme
      // shape تم تعريفه في Theme
      // margin تم تعريفه في Theme
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  '$label ($unit):',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${value.toInt()} $unit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: '${value.toInt()} $unit',
              activeColor: primaryColor,
              inactiveColor: primaryColor.withOpacity(0.3),
              thumbColor: primaryColor,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة مؤشر كتلة الجسم',style: TextStyle(color: Colors.white),),
        // backgroundColor و centerTitle يجب أن يتم تعريفهما في MaterialApp Theme
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), // تقليل الـ padding السفلي
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // النص التوضيحي
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: primaryColor.withOpacity(0.3))
                ),
                child: Text(
                  'مؤشر كتلة الجسم هو قياس للدهون في الجسم على أساس الطول والوزن، ويساعد في تقييم ما إذا كان وزنك صحيًا.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: primaryColor, // استخدام لون متناسق
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // مدخل الطول
              _buildInputSlider(
                label: 'الطول',
                unit: 'سم',
                value: _height,
                min: 100,
                max: 250,
                divisions: 150,
                icon: Icons.height_rounded,
                onChanged: (value) {
                  setState(() {
                    _height = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // مدخل الوزن
              _buildInputSlider(
                label: 'الوزن',
                unit: 'كجم',
                value: _weight,
                min: 30,
                max: 200,
                divisions: 170,
                icon: Icons.monitor_weight_outlined,
                onChanged: (value) {
                  setState(() {
                    _weight = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // زر الحساب
              ElevatedButton.icon(
                icon: const Icon(Icons.calculate_outlined,color: Colors.white,),
                onPressed: _calculateBMI,
                label: const Text('احسب مؤشر كتلة الجسم',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  // backgroundColor و foregroundColor يجب أن يتم تعريفهما في MaterialApp Theme
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),

              // عرض النتيجة والنصائح
              if (_bmiResult != null && _bmiCategory != null && _bmiAdvice != null)
                AnimatedOpacity( // إضافة تأثير ظهور تدريجي للنتائج
                  opacity: _bmiResult != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      // بطاقة النتيجة
                      Card(
                        // elevation و shape من Theme
                        color: _bmiCategoryColor?.withOpacity(0.15) ?? primaryColor.withOpacity(0.1), // لون خلفية البطاقة بناءً على الفئة
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'نتيجتك:',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: _bmiCategoryColor ?? primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _bmiResult!,
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: _bmiCategoryColor ?? primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _bmiCategory!,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _bmiCategoryColor ?? primaryColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // بطاقة النصائح
                      Card(
                        // elevation و shape من Theme
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.lightbulb_outline_rounded, color: primaryColor, size: 28),
                                  const SizedBox(width: 10),
                                  Text(
                                    'نصائح لك:',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ..._bmiAdvice!.map((advice) => Padding(
                                padding: const EdgeInsets.only(bottom: 10.0, right: 8.0, left: 8.0), // تعديل الـ padding
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 20, color: Colors.green[600]),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        advice,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // زر إعادة الحساب
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: _reset,
                        label: const Text('إعادة الحساب'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.7)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24), // مسافة إضافية في الأسفل
            ],
          ),
        ),
      ),
    );
  }
}
