import 'package:flutter/material.dart';
import '../../screen/docto_ details/presentation/screen/doctor_details_page.dart';
import '../data/api_service_search.dart';

class DoctorResultsPage extends StatefulWidget {
  final Map<String, dynamic> searchFilters;
  const DoctorResultsPage({super.key, required this.searchFilters});

  @override
  State<DoctorResultsPage> createState() => _DoctorResultsPageState();
}

class _DoctorResultsPageState extends State<DoctorResultsPage> {
  late Future<List<dynamic>> _resultsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _resultsFuture = _apiService.searchDoctors(widget.searchFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نتائج البحث', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لم يتم العثور على أطباء يطابقون معايير البحث.', style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          final doctors = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              return _DoctorResultCard(doctor: doctors[index]);
            },
          );
        },
      ),
    );
  }
}


// --- ويدجت لعرض بطاقة الطبيب بالتصميم الجديد والمحسّن ---
class _DoctorResultCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  const _DoctorResultCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiService().dio.options.baseUrl;
    final photoPath = doctor['photo'] as String?;
    final imageUrl = (photoPath != null && photoPath.isNotEmpty) ? '$baseUrl/$photoPath' : null;
    final firstName = doctor['name']?['first'] ?? '';
    final lastName = doctor['name']?['last'] ?? '';
    final locationText = '${doctor['location']?['region'] ?? ''}, ${doctor['location']?['subRegion'] ?? ''}';

    // تم حذف التخصص من هنا لأنه غير متوفر في بيانات البحث
    // سيظهر بشكل كامل في صفحة التفاصيل

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DoctorDetailsPage(doctorId: doctor['_id'])));
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // --- تعديل: الصورة أصبحت دائرية ---
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal.withOpacity(0.1),
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null ? const Icon(Icons.person, size: 45, color: Colors.teal) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('د. $firstName $lastName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2c3e50))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.grey[600], size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(locationText, style: TextStyle(fontSize: 14, color: Colors.grey[800]))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700], size: 20),
                        const SizedBox(width: 4),
                        Text((doctor['rating'] as num? ?? 0).toStringAsFixed(1), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        Text(' (${doctor['ratingsCount'] ?? 0} تقييم)', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    )
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}