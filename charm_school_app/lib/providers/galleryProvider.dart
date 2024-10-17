import 'package:flutter/foundation.dart';
import '../service/gallery_service.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class GalleryProvider with ChangeNotifier {
  final GalleryService _galleryService = GalleryService();
  List<Map<String, dynamic>> _galleryItems = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get galleryItems => _galleryItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void sortGalleryItems() {
    _galleryItems.sort((a, b) => DateTime.parse(b['tgl_post_galery']).compareTo(DateTime.parse(a['tgl_post_galery'])));
    notifyListeners();
  }

  Future<void> fetchGalleryItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _galleryService.getAllGallery();
      _galleryItems = items.cast<Map<String, dynamic>>();
      sortGalleryItems(); // Panggil ini setelah mengambil data
    } catch (e) {
      _error = 'Error fetching gallery items: $e';
      print(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGallery(Map<String, dynamic> newGallery, File fotoGalery) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (!newGallery.containsKey('tgl_post_galery')) {
        newGallery['tgl_post_galery'] = DateFormat('yyyy-MM-dd').format(DateTime.now());
      }

      print('Attempting to add gallery: $newGallery');
      print('File path: ${fotoGalery.path}');
      print('File exists: ${await fotoGalery.exists()}');
      print('File size: ${await fotoGalery.length()} bytes');

      await _galleryService.addGallery(newGallery, fotoGalery);
      print('Gallery added successfully');
      await fetchGalleryItems();
    } catch (e) {
      _error = 'Error adding gallery: $e';
      print(_error);
      throw Exception('Failed to add gallery: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateGallery(Map<String, dynamic> item, File? newPhoto, String existingPhotoPath) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Memperbarui item galeri: $item');
      print('Foto baru: ${newPhoto?.path}');
      print('Path foto yang ada: $existingPhotoPath');

      final updatedItem = await _galleryService.updateGallery(item, newPhoto, existingPhotoPath);
      
      print('Item yang diperbarui: $updatedItem');

      // Perbarui item dalam daftar lokal
      int index = _galleryItems.indexWhere((element) => element['kd_galery'] == item['kd_galery']);
      if (index != -1) {
        _galleryItems[index] = updatedItem;
        print('Item galeri lokal diperbarui');
      } else {
        print('Item galeri tidak ditemukan dalam daftar lokal');
      }

      _isLoading = false;
      notifyListeners();
      print('Item galeri berhasil diperbarui');
    } catch (e) {
      _isLoading = false;
      _error = 'Error memperbarui galeri: $e';
      print(_error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteGallery(String kdGallery) async {
    try {
      await _galleryService.deleteGallery(kdGallery);
      await fetchGalleryItems();
    } catch (e) {
      print('Error deleting gallery: $e');
    }
  }
}
