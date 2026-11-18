import 'package:flutter/material.dart';
import 'package:filmcock_app/app/app.dart';
import 'package:filmcock_app/core/config/secrets.dart';
import 'package:filmcock_app/core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiSecrets.init();
  await ThemeController.init();
  runApp(const MyApp());
}
