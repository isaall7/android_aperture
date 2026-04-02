import 'package:aperturely_app/app/modules/auth/views/dashboard.dart';
import 'package:flutter/material.dart';
import 'app/modules/auth/views/login_view.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BerandaScreen(),
      routes: {
        '/beranda': (context) => const BerandaScreen(),
        '/login': (context) => LoginView(),
      },
    );
  }
}
