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

  try {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final storageService = await StorageService.init();
    runApp(MyApp(
      storageService: storageService,
      audioService: AudioService(storageService),
      speechService: SpeechService(),
      locationService: LocationService(),
    ));
  } catch (error) {
    runApp(StartupFailureApp(message: error.toString()));
  }
}

class StartupFailureApp extends StatelessWidget {
  final String message;

  const StartupFailureApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'SA')],
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text('تعذر تشغيل التطبيق', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('أعد تشغيل التطبيق أو امسح بياناته إذا استمرت المشكلة.', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  final StorageService storageService;
  final AudioService audioService;
  final SpeechService speechService;
  final LocationService locationService;

  const MyApp({
    super.key,
    required this.storageService,
    required this.audioService,
    required this.speechService,
    required this.locationService,
  });

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
