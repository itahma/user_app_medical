import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class OvulationCalculator extends StatefulWidget {
  const OvulationCalculator({super.key});

  @override
  State<OvulationCalculator> createState() => _OvulationCalculatorState();
}

class _OvulationCalculatorState extends State<OvulationCalculator> {
  DateTime? _selectedDate;
  String? _ovulationDayText;
  String? _fertileWindowText;
  String? _nextCycleDateText;
  // Default cycle length, can be made configurable if needed
  int _selectedCycleLength = 28; // Default cycle length
  final List<int> _cycleLengths = List.generate(20, (index) => 21 + index); // Cycles from 21 to 40 days

  // Date Picker function
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    // Allow selecting dates in the past, up to a reasonable limit (e.g., 3 months)
    final DateTime firstSelectableDate = DateTime(now.year, now.month - 3, now.day);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstSelectableDate,
      lastDate: now, // Cannot select future dates for last period
      helpText: "اختر اليوم الأول من آخر دورة", // "Select first day of last period"
      cancelText: "إلغاء", // "Cancel"
      confirmText: "اختيار", // "Select"
      locale: const Locale('ar'), // Ensure date picker is in Arabic
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary, // Teal for header background
              onPrimary: Theme.of(context).colorScheme.onPrimary, // White for header text
              onSurface: Theme.of(context).colorScheme.onSurface, // Color for date text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // Teal for button text
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _ovulationDayText = null;
        _fertileWindowText = null;
        _nextCycleDateText = null;
      });
    }
  }

  void _calculateOvulation() {
    if (_selectedDate == null) {
      setState(() {
        _ovulationDayText = "يرجى اختيار تاريخ بدء آخر دورة.";
        _fertileWindowText = null;
        _nextCycleDateText = null;
      });
      return;
    }

    // Ovulation is typically 14 days BEFORE the next cycle starts
    DateTime ovulationDate = _selectedDate!.add(Duration(days: _selectedCycleLength - 14));

    // Fertile window: 5 days before ovulation + ovulation day
    DateTime fertileStart = ovulationDate.subtract(const Duration(days: 5));
    DateTime fertileEnd = ovulationDate; // Ovulation day is the last fertile day

    DateTime nextCycleDate = _selectedDate!.add(Duration(days: _selectedCycleLength));

    final DateFormat formatter = DateFormat('EEEE, dd MMMM yyyy', 'ar'); // Arabic date format

    setState(() {
      _ovulationDayText = "يوم التبويض المتوقع: ${formatter.format(ovulationDate)}";
      _fertileWindowText = "نافذة الخصوبة المتوقعة: من ${formatter.format(fertileStart)} إلى ${formatter.format(fertileEnd)}";
      _nextCycleDateText = "موعد الدورة القادمة المتوقع: ${formatter.format(nextCycleDate)}";
    });
  }

  void _reset() {
    setState(() {
      _selectedDate = null;
      _selectedCycleLength = 28; // Reset to default
      _ovulationDayText = null;
      _fertileWindowText = null;
      _nextCycleDateText = null;
    });
  }

  Widget _buildSectionCard({required String title, required Widget child, IconData? titleIcon}) {
    final Color primaryColor = Colors.teal;
    return Card(
      // elevation, shape, margin from CardTheme
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

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.teal;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حاسبة أيام التبويض',style: TextStyle(color: Colors.white),),
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
                  'تساعدك هذه الحاسبة في تقدير أيام التبويض ونافذة الخصوبة بناءً على تاريخ بدء آخر دورة شهرية ومتوسط طول الدورة.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Date Selection Card
              _buildSectionCard(
                title: 'تاريخ آخر دورة',
                titleIcon: Icons.calendar_month_outlined,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.edit_calendar_outlined, color: onPrimaryColor),
                  label: Text(
                    _selectedDate == null
                        ? 'اختيار اليوم الأول من آخر دورة'
                        : 'التاريخ المختار: ${DateFormat('dd MMMM yyyy', 'ar').format(_selectedDate!)}',
                    style: TextStyle(color: onPrimaryColor, fontSize: 16),
                  ),
                  onPressed: () => _selectDate(context),
                  style: ElevatedButton.styleFrom(
                    // backgroundColor from theme
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cycle Length Selection Card
              _buildSectionCard(
                title: 'متوسط طول الدورة الشهرية',
                titleIcon: Icons.sync_outlined,
                child: DropdownButtonFormField<int>(
                  value: _selectedCycleLength,
                  items: _cycleLengths.map((int length) {
                    return DropdownMenuItem<int>(
                      value: length,
                      child: Text('$length يومًا', style: Theme.of(context).textTheme.bodyLarge),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCycleLength = value;
                        // Reset results if cycle length changes
                        _ovulationDayText = null;
                        _fertileWindowText = null;
                        _nextCycleDateText = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    // labelText: 'اختر طول الدورة',
                    // labelStyle: TextStyle(color: primaryColor.withOpacity(0.7)),
                    filled: true,
                    fillColor: primaryColor.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  dropdownColor: Theme.of(context).colorScheme.surfaceVariant,
                  iconEnabledColor: primaryColor,
                ),
              ),
              const SizedBox(height: 24),

              // Calculate Button
              ElevatedButton.icon(
                icon: const Icon(Icons.calculate_outlined,color:Colors.white,),
                onPressed: _calculateOvulation,
                label: const Text('احسب أيام التبويض',style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18, color: onPrimaryColor),
                ),
              ),
              const SizedBox(height: 24),

              // Result Display
              if (_ovulationDayText != null || _fertileWindowText != null || _nextCycleDateText != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      if (_fertileWindowText != null)
                        _buildResultCard(
                          title: 'نافذة الخصوبة المتوقعة',
                          content: _fertileWindowText!,
                          icon: Icons.favorite_border_outlined, // Heart or similar
                          iconColor: Colors.pinkAccent.shade100,
                        ),
                      if (_ovulationDayText != null)
                        _buildResultCard(
                          title: 'يوم التبويض المتوقع',
                          content: _ovulationDayText!,
                          icon: Icons.brightness_7_outlined, // Sun or star
                          iconColor: Colors.amber.shade600,
                        ),
                      if (_nextCycleDateText != null)
                        _buildResultCard(
                          title: 'موعد الدورة القادمة المتوقع',
                          content: _nextCycleDateText!,
                          icon: Icons.event_repeat_outlined,
                          iconColor: Colors.blueGrey.shade400,
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
              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard({required String title, required String content, required IconData icon, Color? iconColor}) {
    final Color primaryColor = Colors.teal;
    return Card(
      // elevation, shape, margin from CardTheme
      color: primaryColor.withOpacity(0.05), // Light tint for result cards
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
}
