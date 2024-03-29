import "package:flutter/material.dart";
import "package:flutter_project/screens/Homepage/homepage_screen.dart";
import "package:flutter_project/screens/Setting/setting_screen.dart";
import "package:flutter_project/screens/Tutor/TutorSearch/tutor_search_screen.dart";
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import "package:flutter_project/utils/routes.dart";
import "package:provider/provider.dart";

import '../../l10n/l10n.dart';
import "../../providers/auth_provider.dart";
import "../../providers/language_provider.dart";
import "../Course/course_screen.dart";
import "../Schedule/schedule_screen.dart";

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  List<Widget> pages = [
    const HomepageScreen(),
    const TutorSearchScreen(),
    const ScheduleScreen(),
    const CourseScreen(),
    const SettingScreen(),
  ];
  List<String> pagesTitles = ['home', 'tutor', 'schedule', 'course', 'setting'];

  int _chosenPageIndex = 0;

  late Locale currentLocale;

  @override
  void initState() {
    super.initState();
    currentLocale = context.read<LanguageProvider>().currentLocale;
    context.read<LanguageProvider>().addListener(() {
      setState(() {
        currentLocale = context.read<LanguageProvider>().currentLocale;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: Row(
            children: [
              Image.asset(
                'public/icons/lettutor.png',
                width: 50,
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Expanded(
                  child: Text(
                    AppLocalizations(currentLocale).translate(
                      pagesTitles[_chosenPageIndex],
                    )!,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
              ),
            ],
          ),
          actions: _chosenPageIndex == 0
              ? [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, Routes.userProfile);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: (authProvider.currentUser.avatar?.isNotEmpty ??
                            false)
                            ? Image.network(
                          authProvider.currentUser.avatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person_rounded),
                        )
                            : const SizedBox(),
                      ),
                    ),
                  )
          ]
              : [],
        ),
        body: pages[_chosenPageIndex],
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: Theme.of(context).colorScheme.secondary,
          buttonBackgroundColor: Theme.of(context).colorScheme.secondary,
          height: 50,
          onTap: (index) {
            setState(() {
              _chosenPageIndex = index;
            });
          },
          index: _chosenPageIndex,
          items: <Widget>[
            Icon(
              Icons.home_filled,
              size: 30,
              color: Theme.of(context).primaryColor,
            ),
            Icon(Icons.people, size: 30, color: Theme.of(context).primaryColor),
            Icon(Icons.schedule_outlined,
                size: 30, color: Theme.of(context).primaryColor),
            Icon(Icons.school, size: 30, color: Theme.of(context).primaryColor),
            Icon(Icons.settings,
                size: 30, color: Theme.of(context).primaryColor),
          ],
        ));
  }
}
