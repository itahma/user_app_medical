import 'package:flutter/material.dart';
import '../screen/docto_ details/presentation/screen/doctor_details_page.dart';
import '../search/data/api_service_search.dart';
import 'data/api_service.dart'; // تأكد من صحة المسار

class AllDoctorsPage extends StatefulWidget {
  const AllDoctorsPage({super.key});

  @override
  State<AllDoctorsPage> createState() => _AllDoctorsPageState();
}

class _AllDoctorsPageState extends State<AllDoctorsPage> {
  late Future<List<dynamic>> _doctorsFuture;
  final ApiServiceAllDoctor _apiService = ApiServiceAllDoctor();

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _apiService.getAllDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كل الأطباء', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _doctorsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا يوجد أطباء مسجلون حاليًا.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final doctors = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              return _DoctorListCard(doctor: doctors[index]);
            },
          );
        },
      ),
    );
  }
}

// ويدجت لعرض بطاقة الطبيب في القائمة
class _DoctorListCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  const _DoctorListCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiService().dio.options.baseUrl;
    final photoPath = doctor['photo'] as String?;
    final imageUrl = (photoPath != null && photoPath.isNotEmpty) ? '$baseUrl/$photoPath' : null;

    final firstName = doctor['name']?['first'] ?? '';
    final lastName = doctor['name']?['last'] ?? '';

    // الآن يمكننا عرض اسم التخصص بفضل .populate()
    final jurisdictionText = doctor['jurisdiction']?['mainJurisdiction'] ?? 'تخصص غير محدد';
    final locationText = '${doctor['location']?['region'] ?? ''}, ${doctor['location']?['subRegion'] ?? ''}';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          // الانتقال إلى صفحة تفاصيل الطبيب عند الضغط
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoctorDetailsPage(doctorId: doctor['_id'])),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.teal.withOpacity(0.1),
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null ? const Icon(Icons.person, size: 40, color: Colors.teal) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('د. $firstName $lastName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(jurisdictionText, style: TextStyle(fontSize: 15, color: Colors.teal[700], fontWeight: FontWeight.w500)),
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