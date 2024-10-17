import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildProfileHeader(),
          _buildMenuItem(
            icon: Icons.person_outline,
            text: 'Profile',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            text: 'Help & Support',
            onTap: () {
              Navigator.pushReplacementNamed(context, '/help');
            },
          ),
          const Spacer(),
          _buildMenuItem(
            icon: Icons.logout_outlined,
            text: 'Logout',
            onTap: () {
              // Handle logout action here
              Navigator.pushReplacementNamed(context, '/logout');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        color: Colors.purple.shade300,
      ),
      accountName: const Text(
        'Resky',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      accountEmail: const Text(
        'Welcome!',
        style: TextStyle(color: Colors.white70),
      ),
      currentAccountPicture: CircleAvatar(
        radius: 35,
        backgroundColor: Colors.purple.shade700,
        child: ClipOval(
          child: Image.asset(
            'images/me.jpg', // Replace with actual profile image URL
            width: 70,
            height: 70,
            fit: BoxFit.cover,
          ),
        ),
      ),
      otherAccountsPictures: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            // Handle profile edit action
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.purple.shade600,
          size: 28,
        ),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: Colors.purple.shade50,
        hoverColor: Colors.purple.shade100,
      ),
    );
  }
}
