class DrugListItem {
  final String brandName;
  final String genericName;
  final String splSetId;
  final String productNdc;

  DrugListItem({
    required this.brandName,
    required this.genericName,
    required this.splSetId,
    required this.productNdc,
  });

  static String _getStringFromField(dynamic field) {
    if (field == null) return "N/A";
    if (field is List) {
      if (field.isNotEmpty && field[0] != null) {
        String itemStr = field[0].toString().trim();
        return itemStr.isEmpty ? "N/A" : itemStr;
      } else {
        return "N/A";
      }
    }
    String strField = field.toString().trim();
    return strField.isEmpty ? "N/A" : strField;
  }

  factory DrugListItem.fromJson(
      Map<String, dynamic> productJson, // هذا هو results[i].products[j]
      [Map<String, dynamic>? openfdaDataDirectlyFromResult] // هذا هو results[i].openfda
      ) {
    dynamic openfdaDataForProductItself = productJson['openfda'];

    String bName = "N/A";
    String gName = "N/A";
    String setId = "";
    String ndc = "";

    // Brand Name:
    if (productJson['brand_name'] != null) {
      bName = _getStringFromField(productJson['brand_name']);
    } else if (openfdaDataForProductItself != null && openfdaDataForProductItself['brand_name'] != null) {
      bName = _getStringFromField(openfdaDataForProductItself['brand_name']);
    } else if (openfdaDataDirectlyFromResult != null && openfdaDataDirectlyFromResult['brand_name'] != null) {
      bName = _getStringFromField(openfdaDataDirectlyFromResult['brand_name']);
    }

    // Generic Name:
    if (productJson['generic_name'] != null) {
      gName = _getStringFromField(productJson['generic_name']);
    } else if (openfdaDataForProductItself != null && openfdaDataForProductItself['generic_name'] != null) {
      gName = _getStringFromField(openfdaDataForProductItself['generic_name']);
    } else if (openfdaDataDirectlyFromResult != null && openfdaDataDirectlyFromResult['generic_name'] != null) {
      gName = _getStringFromField(openfdaDataDirectlyFromResult['generic_name']);
    }

    // SPL Set ID: الأولوية لـ openfdaDataDirectlyFromResult
    if (openfdaDataDirectlyFromResult != null && openfdaDataDirectlyFromResult['spl_set_id'] != null) {
      String tempSetId = _getStringFromField(openfdaDataDirectlyFromResult['spl_set_id']);
      if (tempSetId != "N/A") setId = tempSetId;
    } else if (openfdaDataForProductItself != null && openfdaDataForProductItself['spl_set_id'] != null) {
      String tempSetId = _getStringFromField(openfdaDataForProductItself['spl_set_id']);
      if (tempSetId != "N/A") setId = tempSetId;
    }

    // Product NDC: الأولوية لـ openfdaDataDirectlyFromResult
    if (openfdaDataDirectlyFromResult != null && openfdaDataDirectlyFromResult['product_ndc'] != null) {
      String tempNdc = _getStringFromField(openfdaDataDirectlyFromResult['product_ndc']);
      if (tempNdc != "N/A") ndc = tempNdc;
    } else if (productJson['product_ndc'] != null) {
      String tempNdc = _getStringFromField(productJson['product_ndc']);
      if (tempNdc != "N/A") ndc = tempNdc;
    } else if (openfdaDataForProductItself != null && openfdaDataForProductItself['product_ndc'] != null) {
      String tempNdc = _getStringFromField(openfdaDataForProductItself['product_ndc']);
      if (tempNdc != "N/A") ndc = tempNdc;
    }

    if (bName == "N/A" && gName != "N/A") {
      bName = gName;
    }

    return DrugListItem(
      brandName: bName,
      genericName: gName,
      splSetId: setId,
      productNdc: ndc,
    );
  }
}