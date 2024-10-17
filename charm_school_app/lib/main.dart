import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/infoProvider.dart';
import 'providers/agendaProvider.dart';
import 'providers/galleryProvider.dart';
import 'providers/userProvider.dart';
import 'themes/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => InfoProvider()),
        ChangeNotifierProvider(create: (context) => AgendaProvider()),
        ChangeNotifierProvider(create: (context) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: AppTheme.customTheme,
      initialRoute: '/logout',
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
