import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/drug_list_item.dart';
import '../models/drug_details.dart';

class ApiService {
  final String _baseUrl = "https://api.fda.gov";

  Future<List<DrugListItem>> fetchDrugList({int limit = 20, int skip = 0}) async {
    final String apiUrl = '$_baseUrl/drug/drugsfda.json?search=_exists_:products.brand_name&limit=$limit&skip=$skip';

    if (kDebugMode) {
      print("Fetching drug list from (WIDER QUERY, V3): $apiUrl");
    }

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);

      if (data['results'] != null && (data['results'] as List).isNotEmpty) {
        final List<dynamic> results = data['results'];
        if (kDebugMode) {
          print("Number of results from API: ${results.length}");
        }

        List<DrugListItem> drugs = [];
        for (var result in results) { // result هو data['results'][i]
          Map<String, dynamic>? productJson; // هذا سيكون result['products'][0]
          if (result['products'] != null && (result['products'] as List).isNotEmpty) {
            productJson = (result['products'] as List)[0];
          }

          Map<String, dynamic>? openfdaDataFromResult = result['openfda'] as Map<String, dynamic>?;

          if (productJson != null) {
            // طباعة البيانات التي يتم تمريرها للمساعدة في التصحيح
            // if (kDebugMode) {
            //   String pName = DrugListItem._getStringFromField(productJson['brand_name'] ?? productJson['generic_name']);
            //   print("For drug $pName :: productJson: $productJson");
            //   print("For drug $pName :: openfdaDataFromResult: $openfdaDataFromResult");
            // }

            DrugListItem drugItem = DrugListItem.fromJson(productJson, openfdaDataFromResult);
            drugs.add(drugItem);

            if (drugItem.splSetId.isEmpty && drugItem.productNdc.isEmpty) {
              if (kDebugMode) {
                print("Drug '${drugItem.brandName} / ${drugItem.genericName}' still has NO splSetId AND NO productNdc. Check API response structure for result['openfda'].");
              }
            } else if (drugItem.splSetId.isEmpty && drugItem.productNdc.isNotEmpty) {
              if (kDebugMode) {
                print("Drug '${drugItem.brandName} / ${drugItem.genericName}' has NO splSetId, but has productNdc: ${drugItem.productNdc}.");
              }
            } else if (drugItem.splSetId.isNotEmpty) {
              if (kDebugMode) {
                print("Drug '${drugItem.brandName} / ${drugItem.genericName}' HAS splSetId: ${drugItem.splSetId}. ProductNDC: ${drugItem.productNdc}");
              }
            }
          } else {
            if (kDebugMode) {
              print("Skipping result item due to missing or empty 'products' array: $result");
            }
          }
        }
        if (kDebugMode) {
          print("Number of drugs parsed and added to list (WIDER, V3): ${drugs.length}");
        }
        return drugs;
      } else {
        if (kDebugMode) { print("API returned no 'results' or 'results' is empty."); if (data['error'] != null) print("API Error: ${data['error']}");}
        return [];
      }
    } else {
      if (kDebugMode) { print('Failed to load drug list. Status Code: ${response.statusCode}'); print('Response Body: ${response.body}');}
      throw Exception('Failed to load drug list. Status Code: ${response.statusCode}');
    }
  }

  Future<DrugDetails> fetchDrugDetails(String identifier, {bool isNdc = false}) async {
    if (identifier.isEmpty) {
      throw Exception('Identifier is empty. Cannot fetch details.');
    }
    String searchField = isNdc ? "openfda.product_ndc" : "set_id";
    final String apiUrl = '$_baseUrl/drug/label.json?search=$searchField:"$identifier"&limit=1';

    if (kDebugMode) {
      print("Fetching drug details from: $apiUrl (using ${isNdc ? 'NDC ($identifier)' : 'SET ID ($identifier)'})");
    }

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['results'] != null && (data['results'] as List).isNotEmpty) {
        return DrugDetails.fromJson((data['results'] as List)[0]);
      } else {
        if (kDebugMode) {
          print('Drug details not found for $searchField: "$identifier". Response: $data');
          if (data['error'] != null && data['error']['code'] == 'NOT_FOUND') {
            throw Exception('لم يتم العثور على تفاصيل للدواء بالمعرف ($identifier).');
          }
        }
        throw Exception('Drug details not found for $searchField: $identifier');
      }
    } else {
      if (kDebugMode) {
        print('Failed to load drug details for $identifier. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
      if (response.statusCode == 404) {
        throw Exception('لم يتم العثور على تفاصيل للدواء بالمعرف ($identifier) (خطأ 404).');
      }
      throw Exception('Failed to load drug details for $identifier. Status Code: ${response.statusCode}');
    }
  }
}