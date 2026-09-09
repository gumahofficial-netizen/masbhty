import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:masbhty/core/services/storage_service.dart';
import 'package:masbhty/core/services/audio_service.dart';
import 'package:masbhty/core/services/speech_service.dart';
import 'package:masbhty/core/services/location_service.dart';
import 'package:masbhty/core/theme/app_theme.dart';
import 'package:masbhty/features/main_navigation/presentation/main_nav_screen.dart';
import 'package:masbhty/features/onboarding/presentation/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set Preferred Orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize Services
  final storageService = await StorageService.init();
  final audioService = AudioService(storageService);
  final speechService = SpeechService();
  final locationService = LocationService();

  runApp(MyApp(
    storageService: storageService,
    audioService: audioService,
    speechService: speechService,
    locationService: locationService,
  ));
}

class MyApp extends StatefulWidget {
  final StorageService storageService;
  final AudioService audioService;
  final SpeechService speechService;
  final LocationService locationService;

  const MyApp({
    Key? key,
    required this.storageService,
    required this.audioService,
    required this.speechService,
    required this.locationService,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.storageService.isDarkTheme();
  }

  void _toggleTheme() {
    setState(() {
      _isDark = widget.storageService.isDarkTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مسبحتي الذكية',
      debugShowCheckedModeBanner: false,
      
      // Localization & RTL Configuration
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theme Configuration
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      home: widget.storageService.hasSeenOnboarding()
          ? MainNavScreen(
              storageService: widget.storageService,
              audioService: widget.audioService,
              speechService: widget.speechService,
              locationService: widget.locationService,
              onThemeChanged: _toggleTheme,
            )
          : OnboardingScreen(
              storageService: widget.storageService,
              audioService: widget.audioService,
              speechService: widget.speechService,
              locationService: widget.locationService,
              onThemeChanged: _toggleTheme,
            ),
    );
  }
}
