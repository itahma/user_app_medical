import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/drug_details.dart';
// لا حاجة لاستيراد AppLocalizations

class DrugDetailScreen extends StatefulWidget {
  final String identifier;
  final String drugName;
  final bool isNdc;

  const DrugDetailScreen({
    super.key,
    required this.identifier,
    required this.drugName,
    required this.isNdc,
  });

  @override
  State<DrugDetailScreen> createState() => _DrugDetailScreenState();
}

class _DrugDetailScreenState extends State<DrugDetailScreen> {
  final ApiService _apiService = ApiService();
  Future<DrugDetails>? _drugDetailsFuture;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    if (!mounted) return;
    setState(() {
      _drugDetailsFuture = _apiService.fetchDrugDetails(widget.identifier, isNdc: widget.isNdc);
    });
  }

  // النصوص العربية لعناوين الأقسام
  Map<String, String> sectionTitlesAr = {
    "brandNameSection": "الاسم التجاري",
    "genericNameSection": "الاسم العام",
    "manufacturerSection": "الشركة المصنعة",
    "applicationNumberSection": "رقم التسجيل",
    "descriptionSection": "الوصف",
    "indicationsAndUsageSection": "دواعي الاستعمال",
    "dosageAndAdministrationSection": "الجرعة وطريقة الاستعمال",
    "contraindicationsSection": "موانع الاستعمال",
    "warningsAndPrecautionsSection": "التحذيرات والاحتياطات",
    "adverseReactionsSection": "الأعراض الجانبية",
    "drugInteractionsSection": "التفاعلات الدوائية",
    "useInSpecificPopulationsSection": "الاستخدام في فئات معينة",
    "overdosageSection": "الجرعة الزائدة",
    "clinicalPharmacologySection": "علم الأدوية السريري",
    "nonclinicalToxicologySection": "علم السموم غير السريري",
    "storageAndHandlingSection": "التخزين والمناولة",
    "howSuppliedSection": "كيفية التوريد / الأشكال الصيدلانية",
  };


  Widget _buildDetailSection({
    // required AppLocalizations l10n, // إزالة
    required String titleKey, // سنستخدم هذا للحصول على العنوان العربي
    required List<String>? originalContent,
    IconData? icon,
    bool isBulletPoints = false,
    bool initiallyExpanded = false,
  }) {
    String localizedTitle = sectionTitlesAr[titleKey] ?? titleKey; // الحصول على العنوان العربي

    if (originalContent == null || originalContent.isEmpty || originalContent.every((s) => s.trim().isEmpty)) {
      return const SizedBox.shrink();
    }

    Widget contentWidget = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: isBulletPoints
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: originalContent
              .map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("•  ", style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 18)),
                Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          ))
              .toList(),
        )
            : Text(
          originalContent.join('\n\n'),
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.start,
        ),
      ),
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        key: PageStorageKey(titleKey),
        initiallyExpanded: initiallyExpanded,
        leading: icon != null ? Icon(icon, color: Theme.of(context).colorScheme.primary) : null,
        title: Text(
          localizedTitle, // العنوان العربي للقسم
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        children: <Widget>[contentWidget],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // لا حاجة لـ l10n هنا بعد الآن لعناوين الأقسام، سنستخدم sectionTitlesAr

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drugName), // اسم الدواء الأصلي (إنجليزي)
      ),
      body: FutureBuilder<DrugDetails>(
        future: _drugDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('جار التحميل...', style: Theme.of(context).textTheme.titleMedium) // نص عربي ثابت
              ],
            ));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 60),
                    const SizedBox(height: 20),
                    Text('خطأ في تحميل التفاصيل: ${snapshot.error}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.error)), // يمكن ترك الخطأ
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadDetails,
                      label: const Text('إعادة المحاولة'), // نص عربي ثابت
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final details = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(12.0),
              children: <Widget>[
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.drugName, style: Theme.of(context).textTheme.titleLarge), // الاسم الإنجليزي
                        if (details.genericName != null &&
                            details.genericName!.isNotEmpty &&
                            (details.brandName == null || details.genericName!.join(', ') != details.brandName!.join(', ')))
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            // نص عربي لـ "الاسم العام"
                            child: Text("${sectionTitlesAr['genericNameSection'] ?? 'الاسم العام'}: ${details.genericName!.join(', ')}", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700])),
                          ),
                        if (details.manufacturerName != null && details.manufacturerName!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            // نص عربي لـ "الشركة المصنعة"
                            child: Text("${sectionTitlesAr['manufacturerSection'] ?? 'الشركة المصنعة'}: ${details.manufacturerName!.join(', ')}", style: Theme.of(context).textTheme.bodyLarge),
                          ),
                        if (details.applicationNumber != null && details.applicationNumber!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            // نص عربي لـ "رقم التسجيل"
                            child: Text("${sectionTitlesAr['applicationNumberSection'] ?? 'رقم التسجيل'}: ${details.applicationNumber!}", style: Theme.of(context).textTheme.bodyMedium),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                _buildDetailSection(titleKey: "descriptionSection", originalContent: details.description, icon: Icons.info_outline, initiallyExpanded: true),
                _buildDetailSection(titleKey: "indicationsAndUsageSection", originalContent: details.indicationsAndUsage, icon: Icons.healing_outlined, isBulletPoints: true, initiallyExpanded: true),
                _buildDetailSection(titleKey: "dosageAndAdministrationSection", originalContent: details.dosageAndAdministration, icon: Icons.medical_services_outlined),
                _buildDetailSection(titleKey: "contraindicationsSection", originalContent: details.contraindications, icon: Icons.do_not_disturb_on_outlined, isBulletPoints: true),
                _buildDetailSection(titleKey: "warningsAndPrecautionsSection", originalContent: details.warnings, icon: Icons.warning_amber_rounded),
                _buildDetailSection(titleKey: "adverseReactionsSection", originalContent: details.adverseReactions, icon: Icons.sentiment_very_dissatisfied_outlined, isBulletPoints: true),
                _buildDetailSection(titleKey: "drugInteractionsSection", originalContent: details.drugInteractions, icon: Icons.compare_arrows_outlined),
                _buildDetailSection(titleKey: "useInSpecificPopulationsSection", originalContent: details.useInSpecificPopulations, icon: Icons.people_alt_outlined),
                _buildDetailSection(titleKey: "overdosageSection", originalContent: details.overdosage, icon: Icons.dangerous_outlined),
                _buildDetailSection(titleKey: "clinicalPharmacologySection", originalContent: details.clinicalPharmacology, icon: Icons.science_outlined),
                _buildDetailSection(titleKey: "nonclinicalToxicologySection", originalContent: details.nonclinicalToxicology, icon: Icons.biotech_outlined),
                _buildDetailSection(titleKey: "storageAndHandlingSection", originalContent: details.storageAndHandling, icon: Icons.inventory_2_outlined),
                _buildDetailSection(titleKey: "howSuppliedSection", originalContent: details.howSupplied, icon: Icons.local_pharmacy_outlined),
              ],
            );
          } else {
            // نص عربي ثابت
            return Center(child: Text('لا تتوفر تفاصيل لهذا الدواء.', style: Theme.of(context).textTheme.titleMedium));
          }
        },
      ),
    );
  }
}