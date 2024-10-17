import 'package:flutter/foundation.dart';
import '../service/agenda_service.dart';

class AgendaProvider with ChangeNotifier {
  final AgendaService _agendaService = AgendaService();
  List<Map<String, dynamic>> _agendaItems = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get agendaItems => _agendaItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAgendaItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _agendaService.getAllAgenda();
      _agendaItems = items.cast<Map<String, dynamic>>();
    } catch (e) {
      _error = 'Error fetching agenda items: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAgenda(Map<String, dynamic> newAgenda) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Attempting to add agenda: $newAgenda'); // Debug print
      await _agendaService.addAgenda(newAgenda);
      print('Agenda added successfully'); // Debug print
      await fetchAgendaItems();
    } catch (e) {
      _error = 'Error adding agenda: $e';
      print(_error);
      throw Exception('Failed to add agenda: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAgenda(Map<String, dynamic> updatedAgenda) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Attempting to update agenda: $updatedAgenda'); // Debug print
      await _agendaService.updateAgenda(updatedAgenda);
      print('Agenda updated successfully'); // Debug print
      await fetchAgendaItems();
    } catch (e) {
      _error = 'Error updating agenda: $e';
      print(_error);
      throw Exception('Failed to update agenda: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAgenda(String kdAgenda) async {
    try {
      await _agendaService.deleteAgenda(kdAgenda);
      await fetchAgendaItems();
    } catch (e) {
      print('Error deleting agenda: $e');
    }
  }
}
