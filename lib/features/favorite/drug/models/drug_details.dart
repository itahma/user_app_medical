class DrugDetails {
  final String? applicationNumber;
  final List<String>? brandName;
  final List<String>? genericName;
  final List<String>? manufacturerName;

  final List<String>? description;
  final List<String>? indicationsAndUsage;
  final List<String>? dosageAndAdministration;
  final List<String>? contraindications;
  final List<String>? warnings;
  final List<String>? adverseReactions;
  final List<String>? drugInteractions;
  final List<String>? useInSpecificPopulations;
  final List<String>? overdosage;
  final List<String>? clinicalPharmacology;
  final List<String>? nonclinicalToxicology;
  final List<String>? storageAndHandling;
  final List<String>? howSupplied;

  DrugDetails({
    this.applicationNumber,
    this.brandName,
    this.genericName,
    this.manufacturerName,
    this.description,
    this.indicationsAndUsage,
    this.dosageAndAdministration,
    this.contraindications,
    this.warnings,
    this.adverseReactions,
    this.drugInteractions,
    this.useInSpecificPopulations,
    this.overdosage,
    this.clinicalPharmacology,
    this.nonclinicalToxicology,
    this.storageAndHandling,
    this.howSupplied,
  });

  static List<String>? _ensureStringList(dynamic field) {
    if (field == null) return null;
    if (field is List) {
      return field.map((e) => e?.toString() ?? "").where((s) => s.trim().isNotEmpty).toList();
    }
    if (field is String) {
      return field.trim().isEmpty ? null : [field];
    }
    String strVal = field.toString().trim();
    return strVal.isEmpty ? null : [strVal];
  }

  factory DrugDetails.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> effectiveJson = json['openfda'] ?? json;

    return DrugDetails(
      applicationNumber: effectiveJson['application_number'] != null
          ? (_ensureStringList(effectiveJson['application_number'])?.join(', '))
          : null,
      brandName: _ensureStringList(effectiveJson['brand_name']),
      genericName: _ensureStringList(effectiveJson['generic_name']),
      manufacturerName: _ensureStringList(effectiveJson['manufacturer_name']),

      description: _ensureStringList(json['description']),
      indicationsAndUsage: _ensureStringList(json['indications_and_usage']),
      dosageAndAdministration: _ensureStringList(json['dosage_and_administration']),
      contraindications: _ensureStringList(json['contraindications']),
      warnings: _ensureStringList(json['warnings_and_cautions'] ?? json['warnings']),
      adverseReactions: _ensureStringList(json['adverse_reactions']),
      drugInteractions: _ensureStringList(json['drug_interactions']),
      useInSpecificPopulations: _ensureStringList(json['use_in_specific_populations']),
      overdosage: _ensureStringList(json['overdosage']),
      clinicalPharmacology: _ensureStringList(json['clinical_pharmacology'] ?? json['pharmacodynamics'] ?? json['pharmacokinetics']),
      nonclinicalToxicology: _ensureStringList(json['nonclinical_toxicology']),
      storageAndHandling: _ensureStringList(json['storage_and_handling']),
      howSupplied: _ensureStringList(json['how_supplied_section'] ?? json['how_supplied']),
    );
  }
}