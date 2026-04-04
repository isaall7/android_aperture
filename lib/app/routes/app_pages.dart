import 'package:aperturely_app/app/modules/auth/views/sign_in_view.dart';
import 'package:aperturely_app/app/modules/auth/views/sign_up_view.dart';
import 'package:aperturely_app/app/modules/home/views/dashboard_view.dart';
import 'package:aperturely_app/app/modules/home/views/explore_view.dart';
import 'package:aperturely_app/app/modules/home/views/notifications_view.dart';
import 'package:aperturely_app/app/modules/home/views/profile_view.dart';
import 'package:aperturely_app/app/modules/home/views/trending_view.dart';
import 'package:aperturely_app/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.login,
      page: SignInView.new,
    ),
    GetPage(
      name: Routes.register,
      page: SignUpView.new,
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardView(),
    ),
    GetPage(
      name: Routes.explore,
      page: () => const ExploreView(),
    ),
    GetPage(
      name: Routes.trending,
      page: () => const TrendingView(),
    ),
    GetPage(
      name: Routes.notifications,
      page: () => const NotificationsView(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(isCurrentUser: true),
    ),
  ];
}
