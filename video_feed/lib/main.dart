import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_feed/core/api/api_client.dart';
import 'package:video_feed/presentation/providers/auth_providor.dart';
import 'package:video_feed/presentation/providers/category_providor.dart';
import 'package:video_feed/presentation/providers/feed_providor.dart';
import 'package:video_feed/presentation/providers/upload_providor.dart';
import 'package:video_feed/presentation/screens/homescreen.dart';
import 'package:video_feed/presentation/screens/loginscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final apiClient = ApiClient();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiClient, prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(apiClient),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FeedProvider>(
          create: (_) => FeedProvider(apiClient),
          update: (_, auth, previous) => previous ?? FeedProvider(apiClient),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UploadProvider>(
          create: (_) => UploadProvider(apiClient),
          update: (_, auth, previous) => previous ?? UploadProvider(apiClient),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
          if (auth.isAuthenticated) {
            return const HomeScreen();
          }
          return const HomeScreen();
        },
      ),
    );
  }
}