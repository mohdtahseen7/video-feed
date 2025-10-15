import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_feed/core/api/api_client.dart';
import 'package:video_feed/presentation/providers/auth_providor.dart';
import 'package:video_feed/presentation/screens/loginscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient();
  runApp(MyApp(prefs: prefs, apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final ApiClient apiClient;
  const MyApp({Key? key, required this.prefs, required this.apiClient})
    : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(apiClient, prefs)),
      ],
      child: MaterialApp(
        title: 'Video Feed App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
       home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            
            return const LoginScreen();
          },
        ),
      ),
      
    );
    
  }
}
