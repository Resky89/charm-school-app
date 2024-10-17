import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;


class GalleryService {

  final String baseUrl = 'https://praktikum-cpanel-unbin.com/kelompok_ojan/charm_school_api/index.php/gallery';

  Future<List<dynamic>> getAllGallery() async {
    print('Fetching gallery from: $baseUrl');
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
        throw Exception('Failed to load gallery: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllGallery: $e');
      rethrow;
    }
  }

  Future<void> addGallery(
      Map<String, dynamic> galleryData, File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

    // Add fields
    request.fields['judul_galery'] = galleryData['judul_galery'];
    request.fields['isi_galery'] = galleryData['isi_galery'];
    request.fields['status_galery'] = galleryData['status_galery'];
    request.fields['kd_petugas'] = galleryData['kd_petugas'];
    request.fields['tgl_post_galery'] = galleryData['tgl_post_galery'];

    // Add file
    var stream = http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();
    var extension = path.extension(imageFile.path).toLowerCase();
    var fileName = path.basename(imageFile.path);

    print('Adding file to request:');
    print('File name: $fileName');
    print('File extension: $extension');
    print('File size: $length bytes');

    var multipartFile = http.MultipartFile(
      'foto_galery',
      stream,
      length,
      filename: fileName,
      contentType: MediaType('image', extension.substring(1)), // Remove the dot from extension
    );
    request.files.add(multipartFile);

    print('Request fields: ${request.fields}');
    print('Request files: ${request.files}');

    var response = await request.send();
    var responseData = await response.stream.toBytes();
    var responseString = String.fromCharCodes(responseData);
    print('Add gallery response: ${response.statusCode} - $responseString');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(responseString);
      if (jsonResponse['data'] != null && jsonResponse['data']['foto_galery'] != null) {
        print('Saved image path: ${jsonResponse['data']['foto_galery']}');
        // Pastikan path ini sesuai dengan yang diharapkan
      }
    } else {
      throw Exception('Failed to add gallery: ${response.statusCode} - $responseString');
    }
  }

  Future<Map<String, dynamic>> updateGallery(Map<String, dynamic> item, File? newPhoto, String existingPhotoPath) async {
    try {
      final Uri url = Uri.parse('$baseUrl/update/${item['kd_galery']}');

      Map<String, dynamic> requestBody = {
        'judul_galery': item['judul_galery'],
        'isi_galery': item['isi_galery'],
        'status_galery': item['status_galery'],
        'tgl_post_galery': item['tgl_post_galery'],
        'kd_petugas': item['kd_petugas'],
      };

      if (newPhoto != null) {
        // Convert image to base64
        List<int> imageBytes = await newPhoto.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        String fileExtension = path.extension(newPhoto.path).toLowerCase().replaceAll('.', '');
        requestBody['foto_galery'] = 'data:image/$fileExtension;base64,$base64Image';
      } else if (existingPhotoPath.isNotEmpty) {
        requestBody['foto_galery'] = existingPhotoPath;
      }

      print('Mengirim permintaan update ke: $url');
      print('Body permintaan: $requestBody');

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Status respons update: ${response.statusCode}');
      print('Body respons update: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          return {
            ...item,
            ...requestBody,
            ...jsonResponse['data'] ?? {},
          };
        } else {
          throw Exception('Gagal memperbarui galeri: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Gagal memperbarui galeri. Kode status: ${response.statusCode}. Pesan: ${response.body}');
      }
    } catch (e) {
      print('Error dalam layanan updateGallery: $e');
      rethrow;
    }
  }

  Future<void> deleteGallery(String kdGallery) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/destroy/$kdGallery'));
    print('Delete gallery response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete gallery: ${response.statusCode}');
    }
  }
}
