import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class PregnancyCalculator extends StatefulWidget {
  const PregnancyCalculator({super.key});

  @override
  State<PregnancyCalculator> createState() => _PregnancyCalculatorState();
}

class _PregnancyCalculatorState extends State<PregnancyCalculator> {
  DateTime? _selectedDate; // First day of the last menstrual period (LMP)
  String? _dueDateResult;
  String? _currentWeekResult;
  String? _conceptionDateResult; // Added conception date
  String? _remainingTimeResult; // Added remaining time

  Future<void> _pickDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    // LMP can be up to ~10 months ago
    final DateTime firstSelectableDate = DateTime(now.year, now.month - 10, now.day);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstSelectableDate,
      lastDate: now, // LMP cannot be in the future
      helpText: "اختر اليوم الأول من آخر دورة",
      cancelText: "إلغاء",
      confirmText: "اختيار",
      locale: const Locale('ar'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary, // Teal
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // Teal
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _dueDateResult = null;
        _currentWeekResult = null;
        _conceptionDateResult = null;
        _remainingTimeResult = null;
      });
    }
  }

  void _calculatePregnancyDetails() {
    if (_selectedDate == null) {
      setState(() {
        _dueDateResult = "يرجى اختيار تاريخ بدء آخر دورة.";
        _currentWeekResult = null;
        _conceptionDateResult = null;
        _remainingTimeResult = null;
      });
      return;
    }

    // Naegele's rule: LMP - 3 months + 7 days + 1 year
    // Or simply LMP + 280 days (40 weeks)
    DateTime dueDate = _selectedDate!.add(const Duration(days: 280));

    // Estimated conception date is typically 2 weeks after LMP
    DateTime conceptionDate = _selectedDate!.add(const Duration(days: 14));

    DateTime now = DateTime.now();
    int daysSinceLMP = now.difference(_selectedDate!).inDays;

    if (daysSinceLMP < 0) daysSinceLMP = 0; // Should not happen if lastDate is now

    int currentWeek = (daysSinceLMP / 7).floor();
    int currentDayInWeek = (daysSinceLMP % 7);

    int remainingDays = dueDate.difference(now).inDays;
    String remainingTimeText;
    if (remainingDays < 0) {
      remainingTimeText = "لقد تجاوزتِ تاريخ الولادة المتوقع!";
    } else if (remainingDays == 0) {
      remainingTimeText = "اليوم هو تاريخ الولادة المتوقع!";
    }
    else {
      int remainingWeeks = (remainingDays / 7).floor();
      int remainingDaysInWeek = remainingDays % 7;
      remainingTimeText = "الوقت المتبقي: $remainingWeeks أسابيع و $remainingDaysInWeek أيام تقريبًا";
    }


    final DateFormat formatter = DateFormat('EEEE, dd MMMM yyyy', 'ar');
    final DateFormat shortFormatter = DateFormat('dd MMMM yyyy', 'ar');


    setState(() {
      _dueDateResult = "تاريخ الولادة المتوقع: ${formatter.format(dueDate)}";
      _currentWeekResult = "أنتِ حاليًا في الأسبوع $currentWeek ويوم $currentDayInWeek من الحمل";
      _conceptionDateResult = "تاريخ الحمل المقدر: ${shortFormatter.format(conceptionDate)}";
      _remainingTimeResult = remainingTimeText;
    });
  }

  void _reset() {
    setState(() {
      _selectedDate = null;
      _dueDateResult = null;
      _currentWeekResult = null;
      _conceptionDateResult = null;
      _remainingTimeResult = null;
    });
  }

  Widget _buildSectionCard({required String title, required Widget child, IconData? titleIcon}) {
    final Color primaryColor = Colors.teal;
    return Card(
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

  Widget _buildResultCard({required String title, required String content, required IconData icon, Color? iconColor}) {
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
                Icon(icon, color: iconColor ?? primaryColor, size: 26),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
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
        title: const Text('حاسبة الحمل والولادة',style: TextStyle(color: Colors.white),),
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
                  'أدخلي تاريخ أول يوم من آخر دورة شهرية لكِ لتقدير موعد الولادة المتوقع ومعرفة أسبوع الحمل الحالي.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionCard(
                title: 'تاريخ آخر دورة شهرية (LMP)',
                titleIcon: Icons.calendar_month_outlined,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.edit_calendar_outlined, color: onPrimaryColor),
                  label: Text(
                    _selectedDate == null
                        ? 'اختيار التاريخ'
                        : 'التاريخ المختار: ${DateFormat('dd MMMM yyyy', 'ar').format(_selectedDate!)}',
                    style: TextStyle(color: onPrimaryColor, fontSize: 16),
                  ),
                  onPressed: () => _pickDate(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                icon: const Icon(Icons.child_friendly_outlined,color: Colors.white,), // Changed icon
                onPressed: _calculatePregnancyDetails,
                label: const Text('احسبي تفاصيل الحمل',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18, color: onPrimaryColor),
                ),
              ),
              const SizedBox(height: 24),

              if (_dueDateResult != null || _currentWeekResult != null || _conceptionDateResult != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      if (_conceptionDateResult != null)
                        _buildResultCard(
                          title: 'تاريخ الحمل المقدر',
                          content: _conceptionDateResult!,
                          icon: Icons.wb_sunny_outlined, // Represents beginning
                          iconColor: Colors.orangeAccent.shade200,
                        ),
                      if (_currentWeekResult != null)
                        _buildResultCard(
                          title: 'أسبوع الحمل الحالي',
                          content: _currentWeekResult!,
                          icon: Icons.hourglass_bottom_outlined,
                          iconColor: Colors.blue.shade300,
                        ),
                      if (_dueDateResult != null)
                        _buildResultCard(
                          title: 'تاريخ الولادة المتوقع',
                          content: _dueDateResult!,
                          icon: Icons.celebration_outlined, // Represents due date
                          iconColor: Colors.pinkAccent.shade100,
                        ),
                      if (_remainingTimeResult != null)
                        _buildResultCard(
                          title: 'الوقت المتبقي للولادة',
                          content: _remainingTimeResult!,
                          icon: Icons.timelapse_outlined,
                          iconColor: Colors.green.shade400,
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
