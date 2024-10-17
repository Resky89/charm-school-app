import 'package:charm_school_app/views/home.dart';
import 'package:charm_school_app/views/agenda.dart';
import 'package:charm_school_app/views/info.dart';
import 'package:flutter/material.dart';
import '../views/login.dart';
import '../views/welcome.dart';
import '../views/profile.dart';

 
class AppRoutes {
  static Map<String, Widget Function(BuildContext)> routes = {
  '/logout': (context) =>  const LoginScreen(),
  '/welcome': (context) => const WelcomeScreen(),
  '/profile': (context) => const ProfileMenu(),
  '/home': (context) => const HomeScreen(),
  '/agenda': (context) => const AgendaScreen(),
  '/info': (context) =>  const InfoScreen(), 

};

}