import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class InfoService {

final String baseUrl = 'https://praktikum-cpanel-unbin.com/kelompok_ojan/charm_school_api/index.php/info';

  Future<List<dynamic>> getAllInfo() async {
    print('Fetching info from: $baseUrl');
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('The connection has timed out, Please try again!');
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse is Map && jsonResponse.containsKey('data')) {
          return jsonResponse['data'] as List<dynamic>;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load info: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllInfo: $e');
      rethrow;
    }
  }

  Future<void> addInfo(Map<String, dynamic> infoData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(infoData),
    );
    print('Add info response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to add info: ${response.statusCode}');
    }
  }

  Future<void> updateInfo(Map<String, dynamic> infoData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update/${infoData['kd_info']}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(infoData),
    );
    print('Update info response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to update info: ${response.statusCode}');
    }
  }

  Future<void> deleteInfo(String kdInfo) async {
    final response = await http.delete(Uri.parse('$baseUrl/destroy/$kdInfo'));
    print('Delete info response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete info: ${response.statusCode}');
    }
  }
}
