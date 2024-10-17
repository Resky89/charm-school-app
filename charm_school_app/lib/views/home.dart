import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_custom_carousel_slider/flutter_custom_carousel_slider.dart';
import '../providers/infoProvider.dart';
import '../providers/agendaProvider.dart';
import '../providers/galleryProvider.dart';
import 'package:intl/intl.dart';
import 'info.dart';
import 'agenda.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await Provider.of<InfoProvider>(context, listen: false).fetchInfoItems();
    await Provider.of<AgendaProvider>(context, listen: false).fetchAgendaItems();
    await Provider.of<GalleryProvider>(context, listen: false).fetchGalleryItems();
  }

  List<CarouselItem> _buildCarouselItems(List<Map<String, dynamic>> galleryItems) {
    const String baseUrl = 'https://praktikum-cpanel-unbin.com/kelompok_ojan/charm_school_api/';
    const String uploadPath = 'uploads/';

    final activeItems = galleryItems.where((item) => item['status_galery'] == '1').toList();

    if (activeItems.isEmpty) {
      return [
        CarouselItem(
          image: const AssetImage('assets/no_image.png'), // Replace with your placeholder image
          title: 'Tidak ada gambar',
          titleTextStyle: const TextStyle(fontSize: 18, color: Colors.black),
          leftSubtitle: '',
          rightSubtitle: '',
        )
      ];
    }

    return activeItems.map((item) {
      final String imageUrl = baseUrl + uploadPath + item['foto_galery'];
      return CarouselItem(
        image: NetworkImage(imageUrl),
        title: item['judul_galery'],
        titleTextStyle: const TextStyle(fontSize: 14, color: Colors.white),
        leftSubtitle: item['isi_galery'],
        rightSubtitle: DateFormat('d MMM y').format(DateTime.parse(item['tgl_post_galery'])),
        onImageTap: (i) {
          _showGalleryDetail(context, item, imageUrl);
        },
      );
    }).toList();
  }

  void _showGalleryDetail(BuildContext context, Map<String, dynamic> item, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error for URL: $imageUrl');
                        return _buildImagePlaceholder();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item['judul_galery'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(item['isi_galery']),
                  const SizedBox(height: 12),
                  Text(
                    'Posted on: ${DateFormat('d MMM yyyy').format(DateTime.parse(item['tgl_post_galery']))}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      height: 200,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Consumer<GalleryProvider>(
                builder: (context, galleryProvider, child) {
                  if (galleryProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (galleryProvider.error != null) {
                    return Center(child: Text('Error: ${galleryProvider.error}'));
                  } else {
                    final carouselItems = _buildCarouselItems(galleryProvider.galleryItems);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomCarouselSlider(
                        items: carouselItems,
                        height: 200,
                        subHeight: 50,
                        width: MediaQuery.of(context).size.width - 32,
                        autoplay: carouselItems.length > 1, // Only autoplay if there's more than one item
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('Agenda Terbaru'),
              _buildAgendaList(),
              const SizedBox(height: 20),
              _buildSectionTitle('Informasi Terbaru'),
              _buildInfoList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAgendaList() {
    return Consumer<AgendaProvider>(
      builder: (context, agendaProvider, child) {
        if (agendaProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final activeAgendaItems = agendaProvider.agendaItems
              .where((item) => item['status_agenda'] == '1')
              .toList();

          // Sort the active agenda items by tgl_post_agenda in descending order
          activeAgendaItems.sort((a, b) => DateTime.parse(b['tgl_post_agenda']).compareTo(DateTime.parse(a['tgl_post_agenda'])));

          if (activeAgendaItems.isEmpty) {
            return const Center(child: Text('No active agenda items available'));
          } else {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeAgendaItems.length,
              itemBuilder: (context, index) {
                final item = activeAgendaItems[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AgendaScreen()),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('d').format(DateTime.parse(item['tgl_agenda'])),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          Text(
                            DateFormat('MMM').format(DateTime.parse(item['tgl_agenda'])),
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      title: Text(
                        item['judul_agenda'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              item['isi_agenda'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Posted on: ${DateFormat('d MMM yyyy').format(DateTime.parse(item['tgl_post_agenda']))}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
      },
    );
  }

  Widget _buildInfoList() {
    return Consumer<InfoProvider>(
      builder: (context, infoProvider, child) {
        if (infoProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          final activeInfoItems = infoProvider.infoItems
              .where((item) => item['status_info'] == '1')
              .toList();

          // Sort the active info items by tgl_post_info in descending order
          activeInfoItems.sort((a, b) => DateTime.parse(b['tgl_post_info']).compareTo(DateTime.parse(a['tgl_post_info'])));

          if (activeInfoItems.isEmpty) {
            return const Center(child: Text('No active info items available'));
          } else {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeInfoItems.length,
              itemBuilder: (context, index) {
                final item = activeInfoItems[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InfoScreen()),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.info_outline, color: Colors.white),
                      ),
                      title: Text(
                        item['judul_info'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            item['isi_info'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Posted on: ${DateFormat('d MMM yyyy').format(DateTime.parse(item['tgl_post_info']))}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
      },
    );
  }
}
