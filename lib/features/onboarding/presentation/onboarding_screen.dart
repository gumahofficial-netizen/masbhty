import 'package:flutter/material.dart';
import 'package:masbhty/core/constants/app_colors.dart';
import 'package:masbhty/core/services/storage_service.dart';
import 'package:masbhty/core/services/audio_service.dart';
import 'package:masbhty/core/services/speech_service.dart';
import 'package:masbhty/core/services/location_service.dart';
import 'package:masbhty/features/main_navigation/presentation/main_nav_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final StorageService storageService;
  final AudioService audioService;
  final SpeechService speechService;
  final LocationService locationService;
  final VoidCallback onThemeChanged;

  const OnboardingScreen({
    super.key,
    required this.storageService,
    required this.audioService,
    required this.speechService,
    required this.locationService,
    required this.onThemeChanged,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'مرحباً بك في مسبحتي الذكية',
      subtitle: 'رفيقك الإيماني المتكامل للتسبيح والأذكار بتصميم أنيق ومميز مستوحى من التراث الإسلامي الأصيل.',
      icon: Icons.mosque_rounded,
    ),
    OnboardingItem(
      title: 'ميزات التطبيق المتكاملة',
      subtitle: '• تسبيح تفاعلي باللمس والصوت والاهتزاز.\n• أذكار متنوعة مع إمكانية إضافة أذكار مخصصة.\n• بوصلة القبلة ومواقيت الصلاة بدقة.\n• إحصائيات يومية وأسبوعية لمتابعة أوردتك.',
      icon: Icons.star_rounded,
    ),
    OnboardingItem(
      title: 'كيف يعمل التطبيق؟',
      subtitle: '1. اختر الذكر المطلوب من مكتبة الأذكار.\n2. انقر على حلقة التسبيح أو شاشة العد لتسجيل تسبيحاتك بكل سلاسة.\n3. تابع هدفك اليومي وإنجازك الروحي باستمرار.',
      icon: Icons.touch_app_rounded,
    ),
    OnboardingItem(
      title: 'إهداء وصدقة جارية',
      subtitle: 'هذا التطبيق صدقة جارية لوالدي المرحوم\n(محمد نصار العجاج)\nرحمه الله وأسكنه فسيح جناته.\n\nونسأل الله العظيم أن يشفي ابني\n(عامر جمعة العجاج)\nشفاءً لا يغادر سقماً.\n\nتصميم وبرمجة:\nجمعة العجاج (مبرمج تطبيقات)',
      icon: Icons.volunteer_activism_rounded,
      isSpecial: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_handlePageChanged);
  }

  void _handlePageChanged() {
    final page = _pageController.page?.round();
    if (page != null && page != _currentPage && mounted) {
      setState(() => _currentPage = page);
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_handlePageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    await widget.storageService.setHasSeenOnboarding(true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainNavScreen(
          storageService: widget.storageService,
          audioService: widget.audioService,
          speechService: widget.speechService,
          locationService: widget.locationService,
          onThemeChanged: widget.onThemeChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.emeraldBackgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'مسبحتي الذكية',
                    style: TextStyle(
                      color: AppColors.goldPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (_currentPage < _items.length - 1)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text(
                        'تخطي',
                        style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.goldGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.goldPrimary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Icon(
                            item.icon,
                            size: 64,
                            color: AppColors.emeraldDark,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.goldPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: item.isSpecial ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
                            fontSize: item.isSpecial ? 16 : 15,
                            height: 1.6,
                            fontWeight: item.isSpecial ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicators & Navigation
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(
                      _items.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.goldPrimary : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Start Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldPrimary,
                      foregroundColor: AppColors.emeraldDark,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      if (_currentPage < _items.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(
                      _currentPage == _items.length - 1 ? 'ابدأ الآن' : 'التالي',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSpecial;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isSpecial = false,
  });
}
