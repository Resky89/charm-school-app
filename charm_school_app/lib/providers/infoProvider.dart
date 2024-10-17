import 'package:flutter/foundation.dart';
import '../service/info_service.dart';

class InfoProvider with ChangeNotifier {
  final InfoService _infoService = InfoService();
  List<Map<String, dynamic>> _infoItems = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get infoItems => _infoItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchInfoItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Fetching info items...');
      final items = await _infoService.getAllInfo();
      _infoItems = items.cast<Map<String, dynamic>>();
      print('Fetched ${_infoItems.length} items');
    } catch (e) {
      _error = 'Error fetching info items: $e';
      print(_error);
      print('Stack trace: ${StackTrace.current}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addInfo(Map<String, dynamic> newInfo) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Attempting to add info: $newInfo'); // Debug print
      await _infoService.addInfo(newInfo);
      print('Info added successfully'); // Debug print
      await fetchInfoItems();
    } catch (e) {
      if (e is Exception && e.toString().contains('201')) {
        // 201 status code means the resource was created successfully
        print('Info added successfully (201 status)');
        await fetchInfoItems();
      } else {
        _error = 'Error adding info: $e';
        print(_error);
        throw Exception('Failed to add info: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateInfo(Map<String, dynamic> updatedInfo) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Attempting to update info: $updatedInfo'); // Debug print
      await _infoService.updateInfo(updatedInfo);
      print('Info updated successfully'); // Debug print
      await fetchInfoItems();
    } catch (e) {
      _error = 'Error updating info: $e';
      print(_error);
      throw Exception('Failed to update info: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInfo(String kdInfo) async {
    try {
      await _infoService.deleteInfo(kdInfo);
      await fetchInfoItems();
    } catch (e) {
      print('Error deleting info: $e');
    }
  }
}
