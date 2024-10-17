import 'package:flutter/material.dart';
import '../layouts/tab_bar.dart';
import '../layouts/sidebar.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Charm High School',
          style: TextStyle(
            color: Color.fromARGB(255, 246, 246, 248), // Warna teks
            fontWeight: FontWeight.bold, // Memberikan gaya tebal pada teks
            fontSize: 24, // Ukuran teks
          ),
        ),
        centerTitle: true, // Untuk memusatkan teks judul
        elevation: 4, // Memberikan bayangan pada AppBar
        shadowColor: Colors.black.withOpacity(0.5), // Warna bayangan
      ),
      drawer: const SideMenu(),
      body: const BottomTabBar(),
    );
  }
}
