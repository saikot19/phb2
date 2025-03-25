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
/*  onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/employeeLists':
            if (settings.arguments is Map<String, dynamic>) {
              final Map<String, dynamic> args =
                  settings.arguments as Map<String, dynamic>;

              final int unitId =
                  args.containsKey('unitId') && args['unitId'] is int
                      ? args['unitId']
                      : 0;

              final List<dynamic> allStaff =
                  args.containsKey('allStaff') && args['allStaff'] is List
                      ? args['allStaff']
                      : [];

              if (unitId == 0 || allStaff.isEmpty) {
                return _errorRoute(
                    "Invalid or missing arguments for EmployeeListScreen");
              }

              return MaterialPageRoute(
                builder: (context) => EmployeeListScreen(
                  unitId: unitId,
                  allStaff: allStaff,
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
}*/
