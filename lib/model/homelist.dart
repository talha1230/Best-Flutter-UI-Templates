import 'package:flutter/widgets.dart';
import 'package:FITBACK/fitness_app/fitness_app_home_screen.dart';

class HomeList {
  HomeList({
    this.navigateScreen,
    this.imagePath = '',
  });

  Widget? navigateScreen;
  String imagePath;

  static List<HomeList> homeList = [
    HomeList(
      imagePath: 'assets/fitness_app/fitness_app.png',
      navigateScreen: FitnessAppHomeScreen(),
    ),
    // Commenting out unavailable screens
    // HomeList(
    //   imagePath: 'assets/hotel/hotel_booking.png',
    //   navigateScreen: HotelHomeScreen(),
    // ),
    // HomeList(
    //   imagePath: 'assets/design_course/design_course.png',
    //   navigateScreen: DesignCourseHomeScreen(),
    // ),
  ];
}
