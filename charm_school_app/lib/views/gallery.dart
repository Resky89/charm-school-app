import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/galleryProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import '../providers/userProvider.dart';

class GalleryItem {
  final String imageUrl;
  final String description;

  GalleryItem({required this.imageUrl, required this.description});
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  final String baseUrl =
      'https://praktikum-cpanel-unbin.com/kelompok_ojan/charm_school_api/'; // Tambahkan ini
  final String uploadPath = 'uploads/'; // Tambahkan ini

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<GalleryProvider>().fetchGalleryItems());
  }

  Future<File?> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Kompres gambar untuk mengurangi ukuran file
    );
    if (image != null) {
      File file = File(image.path);
      String extension = path.extension(file.path).toLowerCase();
      if (['.jpg', '.jpeg', '.png', '.gif'].contains(extension)) {
        return file;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipe file tidak diizinkan. Pilih file JPG, JPEG, PNG, atau GIF.')),
        );
        return null;
      }
    }
    return null;
  }

  void _addGalleryItem(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String judulGalery = '';
        File? fotoGalery;
        String isiGalery = '';
        String statusGalery = '1'; // Default masih active, tapi bisa diubah

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Gallery'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration:
                          const InputDecoration(hintText: 'Enter title'),
                      onChanged: (value) => judulGalery = value,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final File? pickedFile = await _pickImage();
                        if (pickedFile != null) {
                          setState(() {
                            fotoGalery = pickedFile;
                          });
                        }
                      },
                      child: Text(
                          fotoGalery != null ? 'Change a Photo' : 'Choose a Photo'),
                    ),
                    if (fotoGalery != null)
                      Image.file(fotoGalery!,
                          height: 100, width: 100, fit: BoxFit.cover),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Enter content'),
                      onChanged: (value) => isiGalery = value,
                    ),
                    DropdownButtonFormField<String>(
                      value: statusGalery,
                      onChanged: (String? newValue) {
                        setState(() {
                          statusGalery = newValue ?? '1';
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: '1', child: Text('Active')),
                        DropdownMenuItem(value: '0', child: Text('Inactive')),
                      ],
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    if (fotoGalery != null) {
                      try {
                        // Tambahkan tanggal posting otomatis
                        String currentDate =
                            DateFormat('yyyy-MM-dd').format(DateTime.now());

                        await context.read<GalleryProvider>().addGallery({
                          'judul_galery': judulGalery,
                          'isi_galery': isiGalery,
                          'status_galery': statusGalery,
                          'kd_petugas': '123', // Anda mungkin ingin mengambil ini dari sesi pengguna
                          'tgl_post_galery': currentDate, // Tambahkan ini
                        }, fotoGalery!);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Gallery added successfully')),
                        );
                      } catch (e) {
                        print('Error adding gallery: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add gallery item: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Pilih foto terlebih dahulu')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editGalleryItem(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { 
        String judulGalery = item['judul_galery'] ?? '';
        File? fotoGalery;
        String isiGalery = item['isi_galery'] ?? '';
        String statusGalery = item['status_galery'] ?? '1';
        String existingPhotoPath = item['foto_galery'] ?? '';
        String kdPetugas = item['kd_petugas'] ?? '123';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Gallery Item'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration:
                          const InputDecoration(hintText: 'Enter title'),
                      controller: TextEditingController(text: judulGalery),
                      onChanged: (value) => judulGalery = value,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final File? pickedFile = await _pickImage();
                        if (pickedFile != null) {
                          setState(() {
                            fotoGalery = pickedFile;
                          });
                        }
                      },
                      child: Text(fotoGalery != null
                          ? 'Choose a Photo'
                          : 'Change a Photo'),
                    ),
                    if (fotoGalery != null)
                      Image.file(fotoGalery!,
                          height: 100, width: 100, fit: BoxFit.cover)
                    else if (existingPhotoPath.isNotEmpty)
                      Image.network(
                        Uri.parse('$baseUrl$uploadPath$existingPhotoPath').toString(),
                        width: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error');
                          return Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported, size: 50),
                          );
                        },
                      ),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Enter content'),
                      controller: TextEditingController(text: isiGalery),
                      onChanged: (value) => isiGalery = value,
                    ),
                    DropdownButtonFormField<String>(
                      value: statusGalery,
                      onChanged: (String? newValue) {
                        setState(() {
                          statusGalery = newValue ?? '1';
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: '1', child: Text('Active')),
                        DropdownMenuItem(value: '0', child: Text('Inactive')),
                      ],
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    try {
                      String currentDate =
                          DateFormat('yyyy-MM-dd').format(DateTime.now());
                      await context.read<GalleryProvider>().updateGallery(
                        {
                          ...item,
                          'judul_galery': judulGalery,
                          'isi_galery': isiGalery,
                          'status_galery': statusGalery,
                          'tgl_post_galery': currentDate,
                          'kd_petugas': kdPetugas,
                        },
                        fotoGalery,
                        existingPhotoPath,
                      );
                      Navigator.of(dialogContext).pop();
                      // Muat ulang data setelah update
                      await context.read<GalleryProvider>().fetchGalleryItems();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gallery updated successfully')),
                      );
                    } catch (e) {
                      print('Error updating gallery: $e');
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('Failed to update gallery item: ${e.toString()}')),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteGalleryItem(BuildContext context, String kdGallery) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Gallery Item'),
          content: const Text('Are you sure you want to delete this?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  await context
                      .read<GalleryProvider>()
                      .deleteGallery(kdGallery);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Gallery item deleted successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete gallery item: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshGallery() async {
    await context.read<GalleryProvider>().fetchGalleryItems();
    // Sort the items after fetching
    final galleryProvider = context.read<GalleryProvider>();
    galleryProvider.sortGalleryItems(); // Tambahkan metode ini di GalleryProvider
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Sekolah', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple.shade300,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: userProvider.isPetugas
            ? [
                IconButton(
                  icon: const Icon(Icons.add_photo_alternate),
                  onPressed: () => _addGalleryItem(context),
                  tooltip: 'Tambah Foto',
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshGallery,
        child: Consumer<GalleryProvider>(
          builder: (context, galleryProvider, child) {
            if (galleryProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (galleryProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${galleryProvider.error}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshGallery,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            } else if (galleryProvider.galleryItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_album, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No gallery items available',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshGallery,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            } else {
              final displayedItems = userProvider.isPetugas
                  ? List.from(galleryProvider.galleryItems)
                  : galleryProvider.galleryItems.where((item) => item['status_galery'] == '1').toList();
              
              // Sort the displayed items by post date
              displayedItems.sort((a, b) => DateTime.parse(b['tgl_post_galery']).compareTo(DateTime.parse(a['tgl_post_galery'])));
              
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
                itemCount: displayedItems.length,
                itemBuilder: (context, index) {
                  final item = displayedItems[index];
                  return _buildGalleryItem(context, item, userProvider.isPetugas);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGalleryItem(BuildContext context, Map<String, dynamic> item, bool isPetugas) {
    String imageUrl = item['foto_galery'];
    if (imageUrl.isNotEmpty) {
      imageUrl = baseUrl + uploadPath + imageUrl;
    }

    return GestureDetector(
      onTap: () => _showGalleryDetail(context, item, imageUrl, isPetugas),
      onLongPress: isPetugas ? () => _deleteGalleryItem(context, item['kd_galery']) : null,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading image: $error for URL: $imageUrl');
                          return _buildImagePlaceholder();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : _buildImagePlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['judul_galery'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['isi_galery'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showGalleryDetail(BuildContext context, Map<String, dynamic> item, String imageUrl, bool isPetugas) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Parse the date string and format it
        DateTime postDate = DateTime.parse(item['tgl_post_galery']);
        String formattedDate = DateFormat('MMM d, yyyy').format(postDate);

        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error loading image: $error for URL: $imageUrl');
                              return _buildImagePlaceholder();
                            },
                          )
                        : _buildImagePlaceholder(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item['judul_galery'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(item['isi_galery']),
                  const SizedBox(height: 12),
                  if (isPetugas) ...[
                    Row(
                      children: [
                        Icon(Icons.circle, size: 12, color: item['status_galery'] == '1' ? Colors.green : Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          item['status_galery'] == '1' ? 'Active' : 'Inactive',
                          style: TextStyle(color: item['status_galery'] == '1' ? Colors.green : Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'Posted on: $formattedDate',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isPetugas)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _editGalleryItem(context, item);
                          },
                          child: const Text('Edit'),
                        ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
