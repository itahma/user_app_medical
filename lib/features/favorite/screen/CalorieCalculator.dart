import 'package:flutter/material.dart';

class CalorieCalculator extends StatefulWidget {
  const CalorieCalculator({super.key});

  @override
  State<CalorieCalculator> createState() => _CalorieCalculatorState();
}

class _CalorieCalculatorState extends State<CalorieCalculator> {
  String _gender = 'ذكر'; // Default gender
  double _height = 170; // Default height in cm
  double _weight = 70; // Default weight in kg
  int _age = 25; // Default age in years
  String _activityLevel = 'خامل'; // Default activity level
  double? _calories;

  final Map<String, double> _activityMultiplier = {
    'خامل': 1.2,
    'نشاط خفيف (رياضة 1-3 أيام/أسبوع)': 1.375,
    'نشاط متوسط (رياضة 3-5 أيام/أسبوع)': 1.55,
    'نشاط عالي (رياضة 6-7 أيام/أسبوع)': 1.725,
    'نشاط مكثف (رياضة مرتين/يوم)': 1.9,
  };

  // Labels for activity levels for display
  final Map<String, String> _activityLevelLabels = {
    'خامل': 'خامل (قليل أو بدون تمارين)',
    'نشاط خفيف (رياضة 1-3 أيام/أسبوع)': 'نشاط خفيف',
    'نشاط متوسط (رياضة 3-5 أيام/أسبوع)': 'نشاط متوسط',
    'نشاط عالي (رياضة 6-7 أيام/أسبوع)': 'نشاط عالي',
    'نشاط مكثف (رياضة مرتين/يوم)': 'نشاط مكثف',
  };


  void _calculateCalories() {
    if (_weight <= 0 || _height <= 0 || _age <= 0) return;
    double bmr;
    if (_gender == 'ذكر') {
      // Mifflin-St Jeor Equation for Men
      bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) + 5;
    } else {
      // Mifflin-St Jeor Equation for Women
      bmr = (10 * _weight) + (6.25 * _height) - (5 * _age) - 161;
    }

    double multiplier = _activityMultiplier[_activityLevel]!;
    setState(() {
      _calories = bmr * multiplier;
    });
  }

  void _reset() {
    setState(() {
      _gender = 'ذكر';
      _height = 170;
      _weight = 70;
      _age = 25;
      _activityLevel = 'خامل';
      _calories = null;
    });
  }

  Widget _buildSectionCard({required String title, required Widget child, IconData? titleIcon}) {
    final Color primaryColor = Colors.teal;
    return Card(
      // elevation, shape, margin should come from CardTheme in main.dart
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (titleIcon != null) Icon(titleIcon, color: primaryColor, size: 24),
                if (titleIcon != null) const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildSliderInput({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryColor.withOpacity(0.8), size: 22),
            const SizedBox(width: 10),
            Text(
              '$label:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${value.toInt()} $unit',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary; // For text on primary color buttons

    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة السعرات الحرارية',style: TextStyle(color: Colors.white),),
        // backgroundColor and centerTitle should be defined in MaterialApp's ThemeData
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: primaryColor.withOpacity(0.2))
                ),
                child: Text(
                  'تساعدك هذه الحاسبة على تقدير احتياجاتك اليومية من السعرات الحرارية (TDEE) للحفاظ على وزنك الحالي.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Gender Selection
              _buildSectionCard(
                title: 'الجنس',
                titleIcon: Icons.wc,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('ذكر', style: Theme.of(context).textTheme.bodyLarge),
                        value: 'ذكر',
                        groupValue: _gender,
                        onChanged: (value) {
                          if (value != null) setState(() => _gender = value);
                        },
                        activeColor: primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: Text('أنثى', style: Theme.of(context).textTheme.bodyLarge),
                        value: 'أنثى',
                        groupValue: _gender,
                        onChanged: (value) {
                          if (value != null) setState(() => _gender = value);
                        },
                        activeColor: primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Height, Weight, Age Sliders in one card
              _buildSectionCard(
                title: 'القياسات الجسمانية',
                titleIcon: Icons.straighten, // Ruler icon
                child: Column(
                  children: [
                    _buildSliderInput(
                      label: 'الطول',
                      unit: 'سم',
                      value: _height,
                      min: 100,
                      max: 250,
                      divisions: 150,
                      icon: Icons.height,
                      onChanged: (value) => setState(() => _height = value),
                    ),
                    const SizedBox(height: 12),
                    _buildSliderInput(
                      label: 'الوزن',
                      unit: 'كجم',
                      value: _weight,
                      min: 30,
                      max: 200,
                      divisions: 170,
                      icon: Icons.monitor_weight_outlined,
                      onChanged: (value) => setState(() => _weight = value),
                    ),
                    const SizedBox(height: 12),
                    _buildSliderInput(
                      label: 'العمر',
                      unit: 'سنوات',
                      value: _age.toDouble(),
                      min: 10,
                      max: 100,
                      divisions: 90,
                      icon: Icons.cake_outlined,
                      onChanged: (value) => setState(() => _age = value.toInt()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Activity Level
              _buildSectionCard(
                title: 'مستوى النشاط اليومي',
                titleIcon: Icons.directions_run,
                child: Wrap(
                  spacing: 8.0, // spacing between chips
                  runSpacing: 8.0, // spacing between lines of chips
                  children: _activityMultiplier.keys.map((levelKey) {
                    return ChoiceChip(
                      label: Text(_activityLevelLabels[levelKey] ?? levelKey), // Use display labels
                      selected: _activityLevel == levelKey,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _activityLevel = levelKey);
                        }
                      },
                      selectedColor: primaryColor.withOpacity(0.85),
                      labelStyle: TextStyle(
                          color: _activityLevel == levelKey ? onPrimaryColor : Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500
                      ),
                      backgroundColor: primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(
                            color: _activityLevel == levelKey ? primaryColor : primaryColor.withOpacity(0.3),
                          )
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Calculate Button
              ElevatedButton.icon(
                icon: const Icon(Icons.calculate_outlined,color: Colors.white,),
                onPressed: _calculateCalories,
                label: const Text('احسب السعرات الحرارية',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  // backgroundColor and foregroundColor should come from MaterialApp Theme
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18, color: onPrimaryColor),
                ),
              ),
              const SizedBox(height: 24),

              // Result Display
              if (_calories != null)
                AnimatedOpacity(
                  opacity: _calories != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      Card(
                        color: primaryColor.withOpacity(0.15),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'الاحتياج اليومي المقدر:',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _calories!.toStringAsFixed(0), // بدون كسور عشرية
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 6.0), // لضبط محاذاة "كيلو كالوري"
                                    child: Text(
                                      'كيلو كالوري / يوم',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: primaryColor.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'هذه هي كمية السعرات الحرارية التي تحتاجها للحفاظ على وزنك الحالي بناءً على المدخلات.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
