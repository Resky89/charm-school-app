import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/agendaProvider.dart';
import 'package:intl/intl.dart';
import '../providers/userProvider.dart';

class AgendaItem {
  String title;
  String description;
  DateTime date;
  DateTime postDate;

  AgendaItem({required this.title, required this.description, required this.date, required this.postDate});
}

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  String? expandedItemId;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple.shade300,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: userProvider.isPetugas
            ? [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _addAgenda(context),
                ),
              ]
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchAgendaItems(context),
        child: Consumer<AgendaProvider>(
          builder: (context, agendaProvider, child) {
            if (agendaProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (agendaProvider.agendaItems.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No agenda items available',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _fetchAgendaItems(context),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            } else {
              final displayedItems = userProvider.isPetugas
                  ? agendaProvider.agendaItems
                  : agendaProvider.agendaItems.where((item) => item['status_agenda'] == '1').toList();
              
              // Sort the displayed items by post date
              displayedItems.sort((a, b) => DateTime.parse(b['tgl_post_agenda']).compareTo(DateTime.parse(a['tgl_post_agenda'])));
              
              return ListView.builder(
                itemCount: displayedItems.length,
                itemBuilder: (context, index) {
                  final item = displayedItems[index];
                  return _buildAgendaItem(context, item, userProvider.isPetugas);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildAgendaItem(BuildContext context, Map<String, dynamic> item, bool isPetugas) {
    final DateTime agendaDate = DateTime.parse(item['tgl_agenda']);
    final DateTime postDate = DateTime.parse(item['tgl_post_agenda']);
    final String formattedAgendaDate = DateFormat('MMM d, y').format(agendaDate);
    final String formattedPostDate = DateFormat('MMM d, y').format(postDate);
    final bool isExpanded = item['kd_agenda'] == expandedItemId;

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
                    item['judul_agenda'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                if (isPetugas)
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 12,
                        color: item['status_agenda'] == '1' ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['status_agenda'] == '1' ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: item['status_agenda'] == '1' ? Colors.green : Colors.red,
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
                  item['isi_agenda'],
                  style: const TextStyle(fontSize: 16),
                  maxLines: isExpanded ? null : 3,
                  overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (item['isi_agenda'].length > 100) // Only show for longer texts
                  TextButton(
                    onPressed: () {
                      setState(() {
                        expandedItemId = isExpanded ? null : item['kd_agenda'];
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
                  'Due Date: $formattedAgendaDate',
                  style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedPostDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (isPetugas)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        color: Colors.blue,
                        onPressed: () => _updateAgenda(context, item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.red,
                        onPressed: () => _deleteAgenda(context, item['kd_agenda']),
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

  void _addAgenda(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        String judul = '';
        String isi = '';
        DateTime selectedDate = DateTime.now();
        String status = '1';
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add New Agenda'),
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
                      ElevatedButton(
                        child: Text('Agenda Date: ${DateFormat('MMM d, y').format(selectedDate)}'),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && picked != selectedDate) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
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
                  child: const Text('Add'),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      Navigator.pop(context);
                      try {
                        final agendaProvider = Provider.of<AgendaProvider>(context, listen: false);
                        await agendaProvider.addAgenda({
                          'judul_agenda': judul,
                          'isi_agenda': isi,
                          'tgl_agenda': selectedDate.toIso8601String(),
                          'tgl_post_agenda': DateTime.now().toIso8601String(),
                          'status_agenda': status,
                          'kd_petugas': '1', // You might need to adjust this
                        });
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Agenda added successfully')),
                        );
                        agendaProvider.fetchAgendaItems();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add agenda item: $e')),
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

  void _updateAgenda(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        String judul = item['judul_agenda'];
        String isi = item['isi_agenda'];
        DateTime selectedDate = DateTime.parse(item['tgl_agenda']);
        String status = item['status_agenda'];

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Update Agenda'),
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
                      ElevatedButton(
                        child: Text('Agenda Date: ${DateFormat('MMM d, y').format(selectedDate)}'),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && picked != selectedDate) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      formKey.currentState?.save();
                      Navigator.of(context).pop();
                      try {
                        final updatedAgenda = {
                          ...item,
                          'judul_agenda': judul,
                          'isi_agenda': isi,
                          'tgl_agenda': selectedDate.toIso8601String(),
                          'status_agenda': status,
                          'kd_petugas': item['kd_petugas'],
                        };
                        await context.read<AgendaProvider>().updateAgenda(updatedAgenda);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Agenda updated successfully')),
                        );
                        setState(() {
                          // Refresh the agenda items by triggering a rebuild
                        });
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update agenda item: $e')),
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

  Future<void> _deleteAgenda(BuildContext context, String kdAgenda) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this agenda item?'),
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
        await Provider.of<AgendaProvider>(context, listen: false).deleteAgenda(kdAgenda);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agenda deleted successfully')),
        );
        _fetchAgendaItems(context);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete agenda item: $e')),
        );
      }
    }
  }

  Future<void> _fetchAgendaItems(BuildContext context) async {
    try {
      await Provider.of<AgendaProvider>(context, listen: false).fetchAgendaItems();
      // Sort the items after fetching
      final agendaProvider = Provider.of<AgendaProvider>(context, listen: false);
      agendaProvider.agendaItems.sort((a, b) => DateTime.parse(b['tgl_post_agenda']).compareTo(DateTime.parse(a['tgl_post_agenda'])));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load agenda items: $e')),
        );
      }
    }
  }
}
