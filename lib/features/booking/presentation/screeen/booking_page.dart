import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/api_service_booking.dart';

class BookingPage extends StatefulWidget {
  final String doctorId;
  const BookingPage({super.key, required this.doctorId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final ApiServiceBooking _apiService = ApiServiceBooking();

  // متغيرات الحالة للتقويم والأيام المتاحة
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _availableDates = [];
  bool _isLoadingDays = true;
  bool _isLoading = false;
  // متغيرات الحالة للأوقات المتاحة
  List<dynamic>? _availableSlots;
  bool _isLoadingSlots = false;
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _fetchAvailableDays();
  }

  Future<void> _fetchAvailableDays() async {
    setState(() {
      _isLoadingDays = true;
      _availableDates = [];
    });
    try {
      final days = await _apiService.getAvailableDays(widget.doctorId);
      setState(() {
        _availableDates = days.map((day) => DateTime.parse(day['date'])).toList();
        _isLoadingDays = false;
      });
    } catch (e) {
      setState(() => _isLoadingDays = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _fetchAvailableSlots(DateTime date) async {
    setState(() {
      _isLoadingSlots = true;
      _availableSlots = null;
      _selectedSlot = null; // إعادة تعيين الوقت المختار عند تغيير اليوم
    });
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final slots = await _apiService.getAvailableSlots(doctorId: widget.doctorId, date: dateString);
      setState(() {
        _availableSlots = slots;
        _isLoadingSlots = false;
      });
    } catch (e) {
      setState(() => _isLoadingSlots = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedDay == null || _selectedSlot == null) return;

    setState(() => _isLoading = true);
    try {
      await _apiService.bookSlot(
        doctorId: widget.doctorId,
        date: DateFormat('yyyy-MM-dd').format(_selectedDay!),
        startTime: _selectedSlot!,
      );
      if (!mounted) return;
      // إظهار رسالة نجاح والعودة للشاشة السابقة
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تم الحجز بنجاح'),
          content: Text('تم تأكيد حجزك في تاريخ ${DateFormat('d MMMM, y', 'ar_SA').format(_selectedDay!)} الساعة $_selectedSlot.'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('حسنًا'))],
        ),
      );
      Navigator.of(context).pop(); // العودة من شاشة الحجز
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر موعد الحجز', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- القسم الأول: اختيار اليوم ---
            const Text('1. اختر اليوم المناسب', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: _isLoadingDays
                  ? const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
                  : TableCalendar(
                locale: 'ar_SA',
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 30)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                // دالة لتفعيل الأيام المتاحة فقط
                enabledDayPredicate: (day) {
                  return _availableDates.any((availableDate) => isSameDay(availableDate, day));
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _fetchAvailableSlots(selectedDay);
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) setState(() => _calendarFormat = format);
                },
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.teal.withOpacity(0.5), shape: BoxShape.circle),
                  selectedDecoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                  disabledTextStyle: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- القسم الثاني: اختيار التوقيت (يظهر فقط بعد اختيار يوم) ---
            if (_selectedDay != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('2. اختر التوقيت المتاح', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _isLoadingSlots
                      ? const Center(child: CircularProgressIndicator())
                      : (_availableSlots == null || _availableSlots!.isEmpty)
                      ? const Card(child: ListTile(title: Text('لا توجد أوقات متاحة في هذا اليوم.')))
                      : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _availableSlots!.map<Widget>((slot) {
                      final time = slot['start'];
                      final isSelected = _selectedSlot == time;
                      return ChoiceChip(
                        label: Text(time),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSlot = selected ? time : null;
                          });
                        },
                        selectedColor: Colors.teal,
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                        backgroundColor: Colors.grey[200],
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
      // --- زر تأكيد الحجز (يظهر فقط بعد اختيار يوم ووقت) ---
      bottomNavigationBar: _selectedDay != null && _selectedSlot != null
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(
          onPressed: _confirmBooking,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 15)),
          child: const Text('تأكيد الحجز', style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      )
          : null,
    );
  }
}