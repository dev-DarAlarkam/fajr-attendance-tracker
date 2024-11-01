import 'package:attendance_tracker/firebase_options.dart';
import 'package:attendance_tracker/providers/auth_provider.dart';
import 'package:attendance_tracker/providers/group_provider.dart';
import 'package:attendance_tracker/providers/user_profile_provider.dart';
import 'package:attendance_tracker/screens/Auth/signin_screen.dart';
import 'package:attendance_tracker/screens/Auth/create_profile_screen.dart';
import 'package:attendance_tracker/screens/admin/admin_dashboard.dart';
import 'package:attendance_tracker/screens/splash_screen.dart';
import 'package:attendance_tracker/screens/teacher/teacher_dashboard.dart';
import 'package:attendance_tracker/screens/user/user_dashboard_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => UserProfileProvider(authProvider: AuthProvider())),
        ChangeNotifierProvider(create: (context) => GroupProvider()),
      ],

      child: MaterialApp(
        locale: Locale('ar'), // Arabic locale
        supportedLocales: [
          Locale('ar', ''), // Arabic
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        title: AppConstants.appTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppConstants.primaryColor),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) =>  SplashScreen(),
          '/login': (context) => SigninScreen(),
          '/create-profile': (context) => CreateProfileScreen(),
          '/user': (context) => UserDashboardScreen(),
          '/teacher': (context) => TeacherDashboard(),
          '/admin': (context) => AdminDashboardScreen(),
        },
      ),
    );
  }
}

