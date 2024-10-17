import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/infoProvider.dart';
import 'package:intl/intl.dart'; // Tambahkan ini untuk memformat tanggal
import '../providers/userProvider.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  String? expandedItemId;

  @override
  void initState() {
    super.initState();
    _fetchInfoItems(context);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Informasi',
          style: TextStyle(color: Colors.white), 
        ),
        backgroundColor: Colors.purple.shade300,
        iconTheme: const IconThemeData(color: Colors.white), 
        actions: userProvider.isPetugas
            ? [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _addInfo(context),
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchInfoItems(context),
        child: Consumer<InfoProvider>(
          builder: (context, infoProvider, child) {
            if (infoProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (infoProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${infoProvider.error}'),
                    ElevatedButton(
                      onPressed: () => _fetchInfoItems(context),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (infoProvider.infoItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No info items available',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _fetchInfoItems(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            } else {
              final displayedItems = userProvider.isPetugas
                  ? infoProvider.infoItems
                  : infoProvider.infoItems.where((item) => item['status_info'] == '1').toList();
              
              // Sort the displayed items by date
              displayedItems.sort((a, b) => DateTime.parse(b['tgl_post_info']).compareTo(DateTime.parse(a['tgl_post_info'])));
              
              return ListView.builder(
                itemCount: displayedItems.length,
                itemBuilder: (context, index) {
                  final item = displayedItems[index];
                  return _buildInfoItem(context, item, userProvider.isPetugas);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, Map<String, dynamic> item, bool isPetugas) {
    final DateTime postDate = DateTime.parse(item['tgl_post_info']);
    final String formattedDate = DateFormat('MMM d, y').format(postDate);
    final bool isExpanded = item['kd_info'] == expandedItemId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['judul_info'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    // Hapus maxLines dan overflow
                  ),
                ),
                if (isPetugas)
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: item['status_info'] == '1' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['status_info'] == '1' ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: item['status_info'] == '1' ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['isi_info'],
                  style: const TextStyle(fontSize: 16),
                  maxLines: isExpanded ? null : 3,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (item['isi_info'].length > 100) // Only show for longer texts
                  TextButton(
                    onPressed: () {
                      setState(() {
                        expandedItemId = isExpanded ? null : item['kd_info'];
                      });
                    },
                    child: Text(isExpanded ? 'Show Less' : 'Show More'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (isPetugas)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: Colors.blue,
                        onPressed: () => _updateInfo(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.red,
                        onPressed: () => _deleteInfo(context, item['kd_info']),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        String judul = '';
        String isi = '';
        bool status = true;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Info'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        onSaved: (value) => judul = value ?? '',
                        decoration: const InputDecoration(hintText: "Enter title"),
                        validator: (value) => value?.isEmpty ?? true ? 'Title cannot be empty' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        onSaved: (value) => isi = value ?? '',
                        decoration: const InputDecoration(hintText: "Enter content"),
                        maxLines: 3,
                        validator: (value) => value?.isEmpty ?? true ? 'Content cannot be empty' : null,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: status ? '1' : '0',
                        onChanged: (String? newValue) {
                          setState(() {
                            status = newValue == '1';
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
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      Navigator.pop(context);
                      try {
                        final infoProvider = Provider.of<InfoProvider>(context, listen: false);
                        await infoProvider.addInfo({
                          'judul_info': judul,
                          'isi_info': isi,
                          'tgl_post_info': DateTime.now().toIso8601String(),
                          'status_info': status ? '1' : '0',
                          'kd_petugas': '1', // You might need to adjust this
                        });
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Info added successfully')),
                        );
                        _fetchInfoItems(context);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add info item: $e')),
                        );
                      }
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

  void _updateInfo(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        String judul = item['judul_info'];
        String isi = item['isi_info'];
        String status = item['status_info'];

        // Memastikan status memiliki nilai yang valid
        if (status != '1' && status != '0') {
          status = '1'; // Default ke '1' (active) jika nilai tidak valid
        }

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Update Info'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: judul,
                        onSaved: (value) => judul = value ?? '',
                        decoration: const InputDecoration(hintText: "Enter title"),
                        validator: (value) => value?.isEmpty ?? true ? 'Title cannot be empty' : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: isi,
                        onSaved: (value) => isi = value ?? '',
                        decoration: const InputDecoration(hintText: "Enter content"),
                        maxLines: 3,
                        validator: (value) => value?.isEmpty ?? true ? 'Content cannot be empty' : null,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: status,
                        onChanged: (String? newValue) {
                          setState(() {
                            status = newValue!;
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
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      Navigator.pop(context);
                      try {
                        final updatedInfo = {
                          'kd_info': item['kd_info'],
                          'judul_info': judul,
                          'isi_info': isi,
                          'tgl_post_info': DateTime.now().toIso8601String(),
                          'status_info': status,
                          'kd_petugas': item['kd_petugas'],
                        };
                        print('Updating info with data: $updatedInfo'); // Debug print
                        await Provider.of<InfoProvider>(context, listen: false).updateInfo(updatedInfo);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Info updated successfully')),
                        );
                        _fetchInfoItems(context);
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update info item: $e')),
                        );
                      }
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

  Future<void> _deleteInfo(BuildContext context, String kdInfo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this info item?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await Provider.of<InfoProvider>(context, listen: false).deleteInfo(kdInfo);
        _fetchInfoItems(context);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete info item: $e')),
          );
        }
      }
    }
  }

  Future<void> _fetchInfoItems(BuildContext context) async {
    try {
      await Provider.of<InfoProvider>(context, listen: false).fetchInfoItems();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load info items: $e')),
        );
      }
    }
  }
}
