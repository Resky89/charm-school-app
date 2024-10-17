import 'package:flutter/material.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
           Navigator.pushReplacementNamed(context, '/welcome');
          },
          color: theme.colorScheme.onPrimary,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileImage(),
          const SizedBox(height: 16),
          const Text(
            'Resky',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Class: 10A',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          _buildProfileMenuItem(context, Icons.person, 'Edit Profile', () {
            // TODO: Implement edit profile functionality
          }),
          _buildProfileMenuItem(context, Icons.school, 'Academic Records', () {
            // TODO: Implement academic records functionality
          }),
          _buildProfileMenuItem(context, Icons.calendar_today, 'Attendance', () {
            // TODO: Implement attendance functionality
          }),
          _buildProfileMenuItem(context, Icons.notifications, 'Notifications', () {
            // TODO: Implement notifications functionality
          }),
          _buildProfileMenuItem(context, Icons.settings, 'Settings', () {
            // TODO: Implement settings functionality
          }),
          _buildProfileMenuItem(context, Icons.exit_to_app, 'Logout', () {
            // TODO: Implement logout functionality
          }),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'images/me.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading profile image: $error');
                  return _buildProfileImagePlaceholder();
                },
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 4,
                  color: Colors.white,
                ),
                color: Colors.purple,
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.person,
        size: 80,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildProfileMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    final ThemeData theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
