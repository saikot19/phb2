import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/user_model.dart'; // Import UserModel
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/employee_list_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserModel(), // Provide the UserModel
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
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/employeeList':
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (context) => EmployeeListScreen(
                  unitId: args['unitId'] ?? '', // Default empty string if null
                  allStaff:
                      args['allStaff'] ?? [], // Default empty list if null
                ),
              );
            }
            return _errorRoute("Invalid arguments for EmployeeListScreen");

          default:
            return _errorRoute("Page not found");
        }
      },
    );
  }

  /// Returns an error page if an invalid route is accessed.
  Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(
          child: Text("Error: $message", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
