import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/user_model.dart'; // Import UserModel
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/employee_list_screen.dart';
import 'state_management/employee_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => EmployeeProvider()), // EmployeeProvider
        ChangeNotifierProvider(create: (context) => UserModel()), // UserModel
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CDIP Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // Start with the SplashScreen
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/employeeLists': (context) => EmployeeListScreen(
              unitId: 0, // Provide a default or appropriate value for unitId
              allStaff: [], // Provide a default or appropriate value for allStaff
            ),
      },
    );
  }
}
