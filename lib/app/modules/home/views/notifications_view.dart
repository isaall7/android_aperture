import 'package:aperturely_app/app/modules/home/views/explore_view.dart';
import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SimplePage(
      title: 'Notifikasi',
      description: 'Halaman notifikasi akan kita samakan dengan riwayat/notifikasi di website.',
      icon: Icons.notifications_none_rounded,
    );
  }
}
