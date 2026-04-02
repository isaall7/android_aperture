import 'package:aperturely_app/app/modules/auth/views/dashboard.dart';
import 'package:aperturely_app/app/modules/auth/views/login_view.dart';
import 'package:aperturely_app/app/routes/app_routes.dart';
import 'package:get/get.dart';



class AppRoutes {
  static final routes = [
    GetPage(
      name: Routes.BerandaScreen,
      page: () => const BerandaScreen(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
    ),
  ];
}