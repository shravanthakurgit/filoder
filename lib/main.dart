import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'providers/file_manager_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FileManagerProvider()),
      ],
      child: const BluFileApp(),
    ),
  );
}

Future<void> requestPermissions() async {
  if (await Permission.storage.request().isGranted) {
    debugPrint('Storage permission granted');
  }
  
  // For Android 11+, we need manageExternalStorage
  if (await Permission.manageExternalStorage.isDenied) {
    await Permission.manageExternalStorage.request();
  }
}

class BluFileApp extends StatelessWidget {
  const BluFileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filoder',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
