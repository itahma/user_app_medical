import 'package:flutter/material.dart';

class BodyWaterCalculator extends StatefulWidget {
  const BodyWaterCalculator({super.key});

  @override
  State<BodyWaterCalculator> createState() => _BodyWaterCalculatorState();
}

class _BodyWaterCalculatorState extends State<BodyWaterCalculator> {
  double _weight = 70; // الوزن الافتراضي بالكيلوجرام
  String _activityLevel = 'نشاط خفيف'; // مستوى النشاط الافتراضي
  double? _dailyWaterIntakeLiters;
  double? _dailyWaterIntakeGlasses;

  // More descriptive labels for activity levels
  final Map<String, String> _activityLevelLabels = {
    'نشاط خفيف': 'خفيف (تمرين قليل أو بدون)',
    'نشاط متوسط': 'متوسط (تمرين 3-5 أيام/أسبوع)',
    'نشاط عالي': 'عالي (تمرين 6-7 أيام/أسبوع)',
  };

  // Factors for calculation, can be adjusted
  final Map<String, int> _activityFactorAdd = {
    'نشاط خفيف': 0,    // Base calculation will use 30-35 ml/kg
    'نشاط متوسط': 500, // Add 500 ml
    'نشاط عالي': 1000,  // Add 1000 ml
  };

  void _calculateWaterIntake() {
    if (_weight <= 0) return;

    // Base intake: 30-35 ml per kg of body weight. Let's use an average of 32.5 ml.
    double baseIntakeMl = _weight * 32.5;

    // Add extra for activity level
    double totalIntakeMl = baseIntakeMl + (_activityFactorAdd[_activityLevel] ?? 0);

    setState(() {
      _dailyWaterIntakeLiters = totalIntakeMl / 1000; // Convert ml to liters
      _dailyWaterIntakeGlasses = totalIntakeMl / 250; // Assuming a glass is 250ml
    });
  }

  void _reset() {
    setState(() {
      _weight = 70;
      _activityLevel = 'نشاط خفيف';
      _dailyWaterIntakeLiters = null;
      _dailyWaterIntakeGlasses = null;
    });
  }

  Widget _buildSectionCard({required String title, required Widget child, IconData? titleIcon}) {
    final Color primaryColor = Colors.teal;
    return Card(
      // elevation, shape, margin from CardTheme in main.dart
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

  Widget _buildResultCard({required String title, required String content, required IconData icon, Color? iconColor, String? subContent}) {
    final Color primaryColor =Colors.teal;
    return Card(
      color: primaryColor.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor ?? primaryColor, size: 28),
                const SizedBox(width: 10),
                Expanded( // Allow title to wrap if too long
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith( // Larger text for the main result
                color: iconColor ?? primaryColor, // Use iconColor for result text too
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subContent != null && subContent.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subContent,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.8),
                ),
              ),
            ]
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
        title: const Text('حاسبة احتياج الماء اليومي',style: TextStyle(color: Colors.white),),
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
                  'تساعدك هذه الحاسبة في تقدير كمية الماء التي يُنصح بشربها يوميًا للحفاظ على ترطيب الجسم ووظائفه الحيوية.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionCard(
                title: 'وزن الجسم',
                titleIcon: Icons.monitor_weight_outlined,
                child: _buildSliderInput(
                  label: 'الوزن الحالي',
                  unit: 'كجم',
                  value: _weight,
                  min: 30,
                  max: 200,
                  divisions: 170,
                  icon: Icons.accessibility_new, // Changed icon for visual distinction
                  onChanged: (value) => setState(() => _weight = value),
                ),
              ),
              const SizedBox(height: 16),

              _buildSectionCard(
                title: 'مستوى النشاط البدني',
                titleIcon: Icons.directions_run,
                child: Column(
                  // Using ChoiceChips for a more modern feel than Dropdown
                  children: _activityFactorAdd.keys.map((levelKey) {
                    return RadioListTile<String>(
                      title: Text(_activityLevelLabels[levelKey] ?? levelKey, style: Theme.of(context).textTheme.bodyLarge),
                      value: levelKey,
                      groupValue: _activityLevel,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _activityLevel = value);
                        }
                      },
                      activeColor: primaryColor,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.opacity_outlined,color: Colors.white,), // Water drop icon
                onPressed: _calculateWaterIntake,
                label: const Text('احسب كمية الماء',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18, color: onPrimaryColor),
                ),
              ),
              const SizedBox(height: 24),

              if (_dailyWaterIntakeLiters != null && _dailyWaterIntakeGlasses != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      _buildResultCard(
                        title: 'كمية الماء اليومية الموصى بها:',
                        content: '${_dailyWaterIntakeLiters!.toStringAsFixed(1)} لتر',
                        subContent: '(ما يعادل حوالي ${_dailyWaterIntakeGlasses!.toStringAsFixed(1)} كوب ماء)',
                        icon: Icons.local_drink_outlined,
                        iconColor: Colors.blue.shade400, // A distinct color for water result
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "تذكر: هذه قيمة تقديرية. قد تختلف احتياجاتك الفردية بناءً على عوامل أخرى مثل الطقس والحالة الصحية.",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
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
