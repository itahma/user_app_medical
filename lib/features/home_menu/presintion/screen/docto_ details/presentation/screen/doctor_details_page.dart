import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:newappgradu/features/booking/data/api_service_booking.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../booking/presentation/screeen/booking_page.dart';
import '../../../../../../myConsultations/presentation/chat_page.dart';
import '../../../../search/data/api_service_search.dart';

class DoctorDetailsPage extends StatefulWidget {
  final String doctorId;
  final String? centerId;

  const DoctorDetailsPage({
    super.key,
    required this.doctorId,
    this.centerId,
  });

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  late Future<Map<String, dynamic>> _detailsFuture;
  final ApiService _apiService = ApiService();
  final ApiServiceBooking apiService = ApiServiceBooking();

  bool _isFindingNextSlot = false;
  bool _isSubmittingRating = false;
  double _userSelectedRating = 0.0;

  @override
  void initState() {
    super.initState();
    _refreshDetails();
  }

  void _refreshDetails() {
    setState(() {
      _detailsFuture = _apiService.getDoctorDetails(widget.doctorId);
    });
  }

  Future<void> _findAndBookNextAvailable() async {
    setState(() => _isFindingNextSlot = true);
    try {
      final nextSlotData = await _apiService.getNextAvailableSlot(widget.doctorId, centerId: widget.centerId);
      final String date = nextSlotData['nextAvailableDate'];
      final String startTime = nextSlotData['nextAvailableSlot']['start'];

      if (!mounted) return;
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('تم العثور على موعد!'),
          content: Text('أقرب موعد متاح هو يوم ${DateFormat('EEEE, d MMMM', 'ar_SA').format(DateTime.parse(date))} الساعة $startTime.\nهل تود تأكيد الحجز؟'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('تأكيد الحجز')),
          ],
        ),
      );

      if (confirm == true) {
        await apiService.bookSlot(doctorId: widget.doctorId, date: date, startTime: startTime);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تأكيد حجزك بنجاح!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst("Exception: ", "")), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isFindingNextSlot = false);
    }
  }

  Future<void> _submitRating() async {
    if (_userSelectedRating == 0.0) return;
    setState(() => _isSubmittingRating = true);
    try {
      await _apiService.rateDoctor(doctorId: widget.doctorId, rating: _userSelectedRating);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شكرًا لتقييمك!'), backgroundColor: Colors.green));
      _refreshDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل إرسال التقييم: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmittingRating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطبيب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('لم يتم العثور على تفاصيل لهذا الطبيب.'));
          }
          final doctor = snapshot.data!;
          return _buildDoctorDetailsView(context, doctor);
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.calendar_month_outlined),
          label: const Text('حجز موعد'),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BookingPage(doctorId: widget.doctorId)));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorDetailsView(BuildContext context, Map<String, dynamic> doctor) {
    // 1. هنا نقوم باستخلاص كل البيانات في متغيرات محلية
    final baseUrl = _apiService.dio.options.baseUrl;
    final photoPath = doctor['photo'] as String?;
    final imageUrl = (photoPath != null && photoPath.isNotEmpty) ? '$baseUrl/$photoPath' : null;
    final firstName = doctor['name']?['first'] ?? '';
    final lastName = doctor['name']?['last'] ?? '';

    final jurisdictionInfo = doctor['jurisdiction'] as Map<String, dynamic>?;
    final jurisdictionText = jurisdictionInfo?['mainJurisdiction'] ?? 'تخصص غير محدد';

    final rating = (doctor['rating'] as num? ?? 0);
    final ratingsCount = (doctor['ratingsCount'] as int? ?? 0);
    final qualifications = doctor['qualifications'] ?? 'لا يوجد.';
    final locationDesc = doctor['about_location'] ?? 'لا يوجد.';
    final phone = doctor['phone_number'] ?? '';
    final coordinates = doctor['geoLocation']?['coordinates'] as List<dynamic>?;
    final workingDays = doctor['workingDays'] as List<dynamic>? ?? [];
    final price = doctor['preview']?['price']?.toString() ?? 'N/A';
    final time = doctor['preview']?['time']?.toString() ?? 'N/A';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. هنا نقوم بتمرير المتغيرات إلى الدوال المساعدة
          _buildHeaderCard(context, doctor),
          const SizedBox(height: 16),
          _buildSectionCard(
              title: 'عن الطبيب',
              children: [
                Text(qualifications, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5)),
              ]
          ),
          const SizedBox(height: 12),
          _buildContactAndLocationCard(context, phone, locationDesc, coordinates),
          const SizedBox(height: 12),
          _buildWorkingHoursCard(workingDays),
          const SizedBox(height: 12),
          _buildPreviewInfoCard(price, time),
          const SizedBox(height: 12),
          _buildRatingCard(),
        ],
      ),
    );
  }

  // Widget _buildHeaderCard(BuildContext context, String? imageUrl, String firstName, String lastName, String jurisdiction, num rating, int ratingsCount) {
  //   return Card(
  //     elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), clipBehavior: Clip.antiAlias,
  //     child: Column(
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
  //           child: Row(
  //             children: [
  //               CircleAvatar(
  //                 radius: 40, backgroundColor: Colors.teal.withOpacity(0.1),
  //                 backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
  //                 child: imageUrl == null ? Icon(Icons.person, size: 45, color: Colors.teal[800]) : null,
  //               ),
  //               const SizedBox(width: 16),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text('د. $firstName $lastName', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
  //                     const SizedBox(height: 4),
  //                     // 4. وهنا يتم استخدام المعامل 'jurisdiction' الذي تم تمريره لعرض القيمة بشكل صحيح
  //                     Text(jurisdiction, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
  //                     const SizedBox(height: 8),
  //                     Row(children: [
  //                       Icon(Icons.star, color: Colors.amber[700], size: 20),
  //                       const SizedBox(width: 4),
  //                       Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
  //                       Text(' ($ratingsCount تقييم)', style: const TextStyle(color: Colors.grey, fontSize: 13)),
  //                     ]),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //         const Divider(height: 1, indent: 16, endIndent: 16),
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               Expanded(
  //                 child: TextButton.icon(
  //                   onPressed: _isFindingNextSlot ? null : _findAndBookNextAvailable,
  //                   icon: _isFindingNextSlot
  //                       ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
  //                       : const Icon(Icons.flash_on),
  //                   label: const Text('حجز أقرب موعد'),
  //                   style: TextButton.styleFrom(foregroundColor: Colors.teal[700]),
  //                 ),
  //               ),
  //               const SizedBox(height: 30, child: VerticalDivider(width: 1)),
  //               Expanded(
  //                 child: TextButton.icon(
  //                   onPressed: () {
  //
  //                   },
  //                   icon: const Icon(Icons.video_call_outlined),
  //                   label: const Text('بدء استشارة'),
  //                   style: TextButton.styleFrom(foregroundColor: Colors.blue[700]),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
// --- بداية: الدالة الكاملة والمعدلة ---
  Widget _buildHeaderCard(BuildContext context, Map<String, dynamic> doctor) {
    // استخلاص البيانات داخل الدالة نفسها
    final baseUrl = _apiService.dio.options.baseUrl;
    final photoPath = doctor['photo'] as String?;
    final imageUrl = (photoPath != null && photoPath.isNotEmpty) ? '$baseUrl/$photoPath' : null;
    final firstName = doctor['name']?['first'] ?? '';
    final lastName = doctor['name']?['last'] ?? '';
    final doctorFullName = 'د. $firstName $lastName';
    final jurisdictionInfo = doctor['jurisdiction'] as Map<String, dynamic>?;
    final jurisdictionText = jurisdictionInfo?['mainJurisdiction'] ?? 'تخصص غير محدد';
    final rating = (doctor['rating'] as num? ?? 0);
    final ratingsCount = (doctor['ratingsCount'] as int? ?? 0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null ? Icon(Icons.person, size: 45, color: Colors.teal[800]) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctorFullName, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(jurisdictionText, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 4),
                        Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(' ($ratingsCount تقييم)', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ]),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _isFindingNextSlot ? null : _findAndBookNextAvailable,
                    icon: _isFindingNextSlot
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.flash_on),
                    label: const Text('حجز أقرب موعد'),
                    style: TextButton.styleFrom(foregroundColor: Colors.teal[700]),
                  ),
                ),
                const SizedBox(height: 30, child: VerticalDivider(width: 1)),
                Expanded(
                  child: TextButton.icon(
                    // --- هنا تم تفعيل الزر ---
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            otherUserId: doctor['userid'], // تمرير ID المستخدم الخاص بالطبيب
                            otherUserName: doctorFullName,
                            otherUserAvatarUrl: imageUrl,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.video_call_outlined),
                    label: const Text('بدء استشارة'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
// --- نهاية: الدالة الكاملة والمعدلة ---
  Widget _buildRatingCard() {
    return Card(
      elevation: 2, margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('ما هو تقييمك للخدمة المقدمة من الطبيب؟', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.teal[900])),
            const SizedBox(height: 16),
            _isSubmittingRating
                ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Colors.amber))
                : RatingBar.builder(
              initialRating: _userSelectedRating,
              minRating: 1,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _userSelectedRating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_userSelectedRating > 0 && !_isSubmittingRating)
              ElevatedButton(
                onPressed: _submitRating,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
                child: const Text('إرسال تقييمي', style: TextStyle(color: Colors.white)),
              )
          ],
        ),
      ),
    );
  }
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2, margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            const Divider(height: 20, thickness: 1),

            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingHoursCard(List<dynamic> workdays) {
    final Map<String, String> dayTranslations = {
      'Sunday': 'الأحد', 'Monday': 'الاثنين', 'Tuesday': 'الثلاثاء',
      'Wednesday': 'الأربعاء', 'Thursday': 'الخميس', 'Friday': 'الجمعة', 'Saturday': 'سبت',
    };
    return Card(
      elevation: 2, margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('أوقات الدوام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            const Divider(height: 20, thickness: 1),
            if (workdays.isEmpty)
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('لم يحدد الطبيب أوقات دوامه بعد.'))
            else
              Column(
                children: workdays.map((day) {
                  final dayName = dayTranslations[day['day']] ?? day['day'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dayName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        Text('${day['start']} - ${day['end']}', style: TextStyle(color: Colors.grey[800], fontSize: 15)),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewInfoCard(String price, String time) {
    return Card(
      elevation: 2, margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoColumn(Icons.price_change_outlined, 'سعر المعاينة', '$price ل.س'),
            Container(height: 50, width: 1, color: Colors.grey[200]),
            _buildInfoColumn(Icons.timer_outlined, 'مدة المعاينة', '$time دقيقة'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAndLocationCard(BuildContext context, String phone, String locationDesc, List<dynamic>? coordinates) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('معلومات التواصل والموقع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            const Divider(height: 20, thickness: 1),
            InkWell(
              onTap: () async {
                if (phone.isNotEmpty) {
                  final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                  if (await canLaunchUrl(phoneUri)) { await launchUrl(phoneUri); }
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: _InfoRow(icon: Icons.phone_outlined, label: 'رقم الهاتف', value: phone),
            ),
            const Divider(height: 16, color: Colors.transparent),
            _InfoRow(icon: Icons.location_on_outlined, label: 'وصف العنوان', value: locationDesc, isMultiLine: true),
            if (coordinates != null && coordinates.length == 2)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('عرض الموقع على الخريطة'),
                    onPressed: () async {
                      final lat = (coordinates[1] as num).toDouble();
                      final lng = (coordinates[0] as num).toDouble();
                      final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                      final uri = Uri.parse(googleMapsUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Icon(icon, color: Colors.teal, size: 28),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _InfoRow({required IconData icon, required String label, required String value, bool isMultiLine = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 16),
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15, color: Colors.grey[800]))),
        ],
      ),
    );
  }
}