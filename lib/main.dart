import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter_project/providers/auth_provider.dart';
import 'package:flutter_project/providers/language_provider.dart';
import 'package:flutter_project/screens/Auth/login_phone_screen.dart';
import 'package:flutter_project/screens/Tutor/Review/review_screen.dart';
import 'package:flutter_project/screens/UserProfile/become_tutor_screen.dart';
import 'package:flutter_project/screens/UserProfile/change_password_screen.dart';
import 'package:flutter_project/screens/UserProfile/user_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_project/screens/Auth/forget_password_screen.dart';
import 'package:flutter_project/screens/Auth/login_screen.dart';
import 'package:flutter_project/screens/Auth/register_screen.dart';
import 'package:flutter_project/screens/Course/CourseDetail/course_detail_screen.dart';
import 'package:flutter_project/screens/Tutor/TutorSearch/tutor_result_screen.dart';
import 'package:flutter_project/screens/Tutor/TutorDetail/tutor_detail_screen.dart';
import 'package:flutter_project/screens/Navigation/navigation_screen.dart';
import 'package:flutter_project/utils/routes.dart';
import 'package:flutter_project/providers/theme_provider.dart';

import 'envs/environment.dart';
import 'l10n/l10n.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  final flavor = String.fromEnvironment('FLAVOR');
  // flutter run --dart-define=FLAVOR=dev
  if (flavor == 'dev') {
    EnvironmentConfig.setEnvironment(Environment.dev);
  } else if (flavor == 'product') {
    EnvironmentConfig.setEnvironment(Environment.product);
  } else {
    EnvironmentConfig.setEnvironment(Environment.dev);
  }

  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(create: (context) => LanguageProvider()),
          ChangeNotifierProvider(create: (context) => AuthProvider()),
        ],
        child: Consumer3<ThemeProvider, LanguageProvider, AuthProvider>(
          builder: (ctx, themeProvider, languageProvider, authProvider, _) => MaterialApp(
            title: 'Lettutor',
            locale: languageProvider.currentLocale,
            supportedLocales: const [
              Locale('en'),
              Locale('vi'),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            theme:
                themeProvider.mode == ThemeMode.light ? lightTheme : darkTheme,
            home: const LoginScreen(),
            debugShowCheckedModeBanner: false,
            routes: {
              Routes.login: (context) => const LoginScreen(),
              Routes.loginByPhone: (context) => const LoginByPhoneScreen(),
              Routes.register: (context) => const RegisterScreen(),
              Routes.forgotPassword: (context) => const ForgotPasswordScreen(),
              Routes.main: (context) => const NavigationScreen(),
              Routes.teacherDetail: (context) => const TutorDetailScreen(),
              Routes.courseDetail: (context) => const CourseDetailScreen(),
              Routes.tutorSearchResult: (context) => const TutorResultScreen(),
              Routes.userProfile: (context) => const UserProfileScreen(),
              Routes.review: (context) => const ReviewScreen(),
              Routes.becomeTutor: (context) => const BecomeTutorScreen(),
              Routes.changePassword: (context) => const ChangePasswordScreen(),
            },
          ),
        ));
  }
}
