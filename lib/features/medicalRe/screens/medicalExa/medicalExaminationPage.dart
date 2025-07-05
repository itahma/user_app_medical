import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newappgradu/features/medicalRe/screens/medicalExa/patient_encounter_details_page.dart';

import '../../data/api_service.dart';

class MyEncountersPage extends StatefulWidget {
  const MyEncountersPage({super.key});

  @override
  State<MyEncountersPage> createState() => _MyEncountersPageState();
}

class _MyEncountersPageState extends State<MyEncountersPage> {
  late Future<List<dynamic>> _encountersFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _encountersFuture = _apiService.getMyEncounters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لقاءاتي الطبية', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _encountersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد لقاءات مسجلة لك.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final encounters = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: encounters.length,
            itemBuilder: (context, index) {
              final encounter = encounters[index];
              final startDate = DateTime.parse(encounter['start']).toLocal();
              final formattedDate = DateFormat('EEEE, d MMMM, y', 'ar_SA').format(startDate);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.receipt_long, color: Colors.white)),
                  title: Text('لقاء بتاريخ: $formattedDate', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('السبب: ${encounter['reason'] ?? 'غير محدد'}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientEncounterDetailsPage(
                          encounterId: encounter['_id'],
                          patientId: encounter['userid'], // تمرير ID المريض نفسه
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}