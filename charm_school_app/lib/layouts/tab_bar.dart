import 'package:flutter/material.dart';
import 'package:charm_school_app/views/home.dart';
import 'package:charm_school_app/views/info.dart';
import 'package:charm_school_app/views/agenda.dart';
import 'package:charm_school_app/views/gallery.dart';
import 'constants.dart';
import 'tab_bar_item.dart';

class BottomTabBar extends StatefulWidget {
  const BottomTabBar({super.key});

  @override
  State<BottomTabBar> createState() => _BottomTabBarState();
}

class _BottomTabBarState extends State<BottomTabBar> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Tween<double> positionTween;
  late Animation<double> positionAnimation;

  late AnimationController fadeOutController;
  late Animation<double> fadeOutAnimation;
  late Animation<double> fadeInAnimation;

  double iconAlpha = 1;
  IconData nextIcon = Icons.home; // Set default ikon ke Home
  IconData activeIcon = Icons.home; // Set default ikon aktif ke Home

  int currentSelected = 0; // Set tab pertama kali ke tab Home (0)
  final List<Widget> pages = [
    const HomeScreen(),
    const InfoScreen(),
    const AgendaScreen(),
    const GalleryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    setupAnimation();

    // Set posisi awal ke halaman Home
    setState(() {
      positionTween.begin = -1; // Pastikan posisi mulai dari kiri (Home tab)
      positionTween.end = -1;
      activeIcon = Icons.home; // Set ikon aktif ke Home
    });
  }

  void setupAnimation() {
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: ANIM_DURATION));
    fadeOutController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: (ANIM_DURATION ~/ 5)));

    positionTween = Tween<double>(begin: -1, end: 0); // Set posisi awal
    positionAnimation = positionTween.animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));

    fadeOutAnimation = Tween<double>(begin: 1, end: 0).animate(
        CurvedAnimation(parent: fadeOutController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          iconAlpha = fadeOutAnimation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            activeIcon = nextIcon;
          });
        }
      });

    fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.8, 1, curve: Curves.easeOut)))
      ..addListener(() {
        setState(() {
          iconAlpha = fadeInAnimation.value;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentSelected, // Menampilkan halaman sesuai tab yang dipilih
        children: pages,
      ),
      bottomNavigationBar: Stack(
        alignment: Alignment.center,
        children: [
          _buildBottomNavigationBar(), // Tab bar di lapisan dasar
          ignorePointer(), // Ikon animasi di lapisan atas
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 65,
      decoration: BoxDecoration(
          color: Colors.purple.shade300,
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, offset: Offset(0, -1), blurRadius: 8)
          ]),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TabBarItem(
            title: "Home",
            iconData: Icons.home,
            selected: currentSelected == 0,
            callbackFunction: () {
              setState(() {
                nextIcon = Icons.home;
                currentSelected = 0;
              });
              initAnimation(positionAnimation.value, -1);
            },
          ),
          TabBarItem(
            title: "Info",
            iconData: Icons.info,
            selected: currentSelected == 1,
            callbackFunction: () {
              setState(() {
                nextIcon = Icons.info;
                currentSelected = 1;
              });
              initAnimation(positionAnimation.value, -0.34);
            },
          ),
          TabBarItem(
            title: "Agenda",
            iconData: Icons.book,
            selected: currentSelected == 2,
            callbackFunction: () {
              setState(() {
                nextIcon = Icons.book;
                currentSelected = 2;
              });
              initAnimation(positionAnimation.value, 0.34);
            },
          ),
          TabBarItem(
            title: "Gallery",
            iconData: Icons.photo, // Ganti ikon sesuai dengan Gallery
            selected: currentSelected == 3,
            callbackFunction: () {
              setState(() {
                nextIcon = Icons.photo; // Ganti ikon sesuai dengan Gallery
                currentSelected = 3;
              });
              initAnimation(positionAnimation.value, 1);
            },
          ),
        ],
      ),
    );
  }

void initAnimation(double from, double to) {
  positionTween.begin = from;
  positionTween.end = to;
  animationController.reset();
  fadeOutController.reset();
  animationController.forward();
  fadeOutController.forward();
}


  IgnorePointer ignorePointer() {
    return IgnorePointer(
      child: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: Align(
          heightFactor: 0.8,
          alignment: Alignment(positionAnimation.value,5.0), // Posisi awal di -1 untuk Home tab
          child: FractionallySizedBox(
            widthFactor: 1 / 4, // Pastikan ini disesuaikan dengan jumlah tab
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 214, 175, 220),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Opacity(
                        opacity: iconAlpha,
                        child: Icon(
                          activeIcon,
                          color: Colors.purple,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
