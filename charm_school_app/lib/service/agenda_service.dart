import 'dart:convert';
import 'package:http/http.dart' as http;

class AgendaService {

final String baseUrl = 'https://praktikum-cpanel-unbin.com/kelompok_ojan/charm_school_api/index.php/agenda';

  Future<List<dynamic>> getAllAgenda() async {
    print('Fetching agenda from: $baseUrl');
    try {
      final response = await http.get(Uri.parse(baseUrl));
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
        throw Exception('Failed to load agenda: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllAgenda: $e');
      rethrow;
    }
  }

  Future<void> addAgenda(Map<String, dynamic> agendaData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(agendaData),
    );
    print('Add agenda response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to add agenda: ${response.statusCode}');
    }
  }

  Future<void> updateAgenda(Map<String, dynamic> agendaData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update/${agendaData['kd_agenda']}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(agendaData),
    );
    print('Update agenda response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to update agenda: ${response.statusCode}');
    }
  }

  Future<void> deleteAgenda(String kdAgenda) async {
    final response = await http.delete(Uri.parse('$baseUrl/destroy/$kdAgenda'));
    print('Delete agenda response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete agenda: ${response.statusCode}');
    }
  }
}
