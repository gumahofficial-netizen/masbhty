import 'package:flutter/material.dart';
import 'package:masbhty/core/constants/app_colors.dart';
import 'package:masbhty/core/services/storage_service.dart';
import 'package:masbhty/core/services/audio_service.dart';
import 'package:masbhty/core/services/speech_service.dart';
import 'package:masbhty/core/services/location_service.dart';

import 'package:masbhty/features/counter/presentation/counter_screen.dart';
import 'package:masbhty/features/dhikr_library/presentation/dhikr_library_screen.dart';
import 'package:masbhty/features/analytics/presentation/analytics_screen.dart';
import 'package:masbhty/features/qibla_prayer/presentation/qibla_prayer_screen.dart';
import 'package:masbhty/features/settings/presentation/settings_screen.dart';

class MainNavScreen extends StatefulWidget {
  final StorageService storageService;
  final AudioService audioService;
  final SpeechService speechService;
  final LocationService locationService;
  final VoidCallback onThemeChanged;

  const MainNavScreen({
    super.key,
    required this.storageService,
    required this.audioService,
    required this.speechService,
    required this.locationService,
    required this.onThemeChanged,
  });

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _buildScreens();
  }

  void _buildScreens() {
    _screens = [
      CounterScreen(
        storageService: widget.storageService,
        audioService: widget.audioService,
        speechService: widget.speechService,
      ),
      DhikrLibraryScreen(
        storageService: widget.storageService,
        onSelectDhikr: (id) {
          setState(() => _selectedIndex = 0);
          // The CounterScreen will reload the selected ID automatically on its next build
        },
      ),
      AnalyticsScreen(storageService: widget.storageService),
      const SizedBox.shrink(),
      SettingsScreen(
        storageService: widget.storageService,
        onThemeChanged: widget.onThemeChanged,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3 && _screens[3] is SizedBox) {
            _screens[3] = QiblaPrayerScreen(locationService: widget.locationService);
          }
          setState(() => _selectedIndex = index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: AppColors.goldPrimary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.radio_button_checked), label: 'المسبحة'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'المكتبة'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'الإحصائيات'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'القبلة'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'الإعدادات'),
        ],
      ),
    );
  }
}
