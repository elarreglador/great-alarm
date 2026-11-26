import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'presentation/pages/home_page.dart';
import 'utils/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.water,
      systemNavigationBarColor: AppColors.water,
    ),
  );
  runApp(const GreatAlarmApp());
}

class GreatAlarmApp extends StatelessWidget {
  const GreatAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Great Alarm',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.water,
      ),
      home: const HomePage(),
    );
  }
}
