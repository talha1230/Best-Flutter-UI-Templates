import 'package:flutter/material.dart';
import 'my_diary/my_diary_screen.dart';
import 'training/training_screen.dart';
import 'profile/profile_screen.dart';
import 'models/tabIcon_data.dart';
import 'bottom_navigation_view/bottom_bar_view.dart';
import 'fitness_app_theme.dart';
import '../services/auth_service.dart';  // Add this import

class FitnessAppHomeScreen extends StatefulWidget {
  @override
  _FitnessAppHomeScreenState createState() => _FitnessAppHomeScreenState();
}

class _FitnessAppHomeScreenState extends State<FitnessAppHomeScreen>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  Widget? tabBody;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    tabBody = MyDiaryScreen(animationController: animationController);
    
    for (var tab in tabIconsList) {
      tab.animationController = animationController;
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  void changeIndex(int index) {
    if (index == 0 || index == 2) {
      tabBody = MyDiaryScreen(animationController: animationController);
    } else if (index == 1) {
      tabBody = TrainingScreen(animationController: animationController);
    } else if (index == 3) {
      tabBody = ProfileScreen();
    }
    setState(() {});
  }

  void setRemoveAllSelection(TabIconData tabIconData) {
    if (!mounted) return;
    setState(() {
      for (var tab in tabIconsList) {
        tab.isSelected = false;
        if (tabIconData.index == tab.index) {
          tab.isSelected = true;
        }
      }
    });
  }

  void onBottomBarTap(int index) {
    setState(() {
      tabBody = getTabBody(index);
      setRemoveAllSelection(tabIconsList[index]);
    });
  }

  Widget getTabBody(int index) {
    switch (index) {
      case 0:
        return MyDiaryScreen(animationController: animationController);
      case 1:
        return TrainingScreen(animationController: animationController);
      case 2:
        return MyDiaryScreen(animationController: animationController);
      case 3:
        return ProfileScreen(); // This will now show the profile screen
      default:
        return MyDiaryScreen(animationController: animationController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[
                  tabBody!,
                  bottomBar(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    return true;
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        const Divider(height: 1),
        const Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {},
          changeIndex: (int index) {
            setRemoveAllSelection(tabIconsList[index]);
            onBottomBarTap(index);
          },
        ),
      ],
    );
  }
}
