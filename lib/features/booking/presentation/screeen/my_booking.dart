import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/api_service_booking.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  late Future<List<dynamic>> _bookingsFuture;
  final ApiServiceBooking _apiService = ApiServiceBooking();

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  void _fetchBookings() {
    setState(() {
      _bookingsFuture = _apiService.getMyBookings();
    });
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل أنت متأكد أنك تريد إلغاء هذا الحجز؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('لا')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('نعم، قم بالإلغاء', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.cancelBooking(bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الحجز بنجاح'), backgroundColor: Colors.green));
      _fetchBookings(); // تحديث القائمة لإزالة الحجز الملغي
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل الإلغاء: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد حجوزات لديك.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          // --- بداية: منطق فصل الحجوزات القادمة عن السابقة ---
          final now = DateTime.now();
          final List<dynamic> upcomingBookings = [];
          final List<dynamic> pastBookings = [];

          for (var booking in snapshot.data!) {
            try {
              // الـ backend يرسل التاريخ كنص، نقوم بتحويله
              final bookingDate = DateTime.parse(booking['date']);
              // للتحقق من الوقت، يمكنك تحويل وقت البدء أيضًا إذا أردت دقة أكبر
              if (bookingDate.isAfter(now) || isSameDay(bookingDate, now)) {
                upcomingBookings.add(booking);
              } else {
                pastBookings.add(booking);
              }
            } catch(e) {
              print("Error parsing date for booking: ${booking['_id']}");
              // يمكن إضافة الحجز الذي فشل تحويل تاريخه إلى قائمة منفصلة إذا أردت
            }
          }
          // --- نهاية: منطق الفصل ---

          return RefreshIndicator(
            onRefresh: () async => _fetchBookings(),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (upcomingBookings.isNotEmpty)
                  _buildBookingSection(title: 'الحجوزات القادمة', bookings: upcomingBookings, isUpcoming: true),
                if (pastBookings.isNotEmpty)
                  _buildBookingSection(title: 'الحجوزات السابقة', bookings: pastBookings, isUpcoming: false),
              ],
            ),
          );
        },
      ),
    );
  }

  // ويدجت لبناء كل قسم (قادم أو سابق)
  Widget _buildBookingSection({required String title, required List<dynamic> bookings, required bool isUpcoming}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
          child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[800])),
        ),
        ...bookings.map((booking) => _BookingCard(
          booking: booking,
          isUpcoming: isUpcoming,
          onCancel: () => _cancelBooking(booking['_id']),
        )).toList(),
      ],
    );
  }
}

// ويدجت لعرض بطاقة الحجز
class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final bool isUpcoming;
  final VoidCallback onCancel;

  const _BookingCard({required this.booking, required this.isUpcoming, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    // بناء اسم الطبيب من الكائن المتداخل
    final doctorInfo = booking['doctor_id'] as Map<String, dynamic>?;
    final firstName = doctorInfo?['name']?['first'] ?? 'طبيب';
    final lastName = doctorInfo?['name']?['last'] ?? 'غير معروف';
    final doctorName = 'د. $firstName $lastName';

    // تنسيق التاريخ والوقت
    final bookingDate = DateTime.tryParse(booking['date'] ?? '');
    final formattedDate = bookingDate != null ? DateFormat('EEEE, d MMMM, y', 'ar_SA').format(bookingDate) : 'تاريخ غير صالح';
    final timeSlot = '${booking['start'] ?? ''} - ${booking['end'] ?? ''}';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isUpcoming ? Colors.teal : Colors.grey.shade300)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(doctorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(height: 16),
            _InfoRow(icon: Icons.calendar_today_outlined, text: formattedDate),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.access_time_filled_outlined, text: timeSlot),
            if (isUpcoming) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: const Text('إلغاء الحجز', style: TextStyle(color: Colors.red)),
                  onPressed: onCancel,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _InfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}