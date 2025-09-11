import 'dart:convert';
import 'package:http/http.dart' as http;

class CommodityService {
  final String baseUrl;

  CommodityService({this.baseUrl = 'http://192.168.1.11:3000'});

  Future<Map<String, dynamic>> fetchCommodityData(String commodityType) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/commodity/$commodityType'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load commodity data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load commodity data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchAllCommodities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/commodities'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        console.log('Response body:========================= ${response.body}');
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load commodities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load commodities: $e');
    }
  }
}