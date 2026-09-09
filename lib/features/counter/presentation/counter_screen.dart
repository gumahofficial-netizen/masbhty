import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:masbhty/core/constants/app_colors.dart';
import 'package:masbhty/core/models/dhikr_model.dart';
import 'package:masbhty/core/models/counter_session.dart';
import 'package:masbhty/core/models/theme_mode_enum.dart';
import 'package:masbhty/core/services/storage_service.dart';
import 'package:masbhty/core/services/audio_service.dart';
import 'package:masbhty/core/services/speech_service.dart';

class CounterScreen extends StatefulWidget {
  final StorageService storageService;
  final AudioService audioService;
  final SpeechService speechService;

  const CounterScreen({
    super.key,
    required this.storageService,
    required this.audioService,
    required this.speechService,
  });

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> with SingleTickerProviderStateMixin {
  late List<DhikrModel> _azkarList;
  late DhikrModel _currentDhikr;
  int _sessionCount = 0;
  DateTime _sessionStartTime = DateTime.now();
  bool _isVoiceActive = false;
  late CounterSkin _currentSkin;
  bool _keepAwake = false;

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _azkarList = widget.storageService.getAzkar();
    final selectedId = widget.storageService.getSelectedDhikrId();
    _currentDhikr = _azkarList.firstWhere(
      (element) => element.id == selectedId,
      orElse: () => _azkarList.first,
    );
    _currentSkin = widget.storageService.getCounterSkin();
    _keepAwake = widget.storageService.isKeepAwakeEnabled();

    if (_keepAwake) {
      WakelockPlus.enable();
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.92,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    if (_keepAwake) {
      WakelockPlus.disable();
    }
    _animController.dispose();
    super.dispose();
  }

  void _incrementCounter() async {
    setState(() {
      _currentDhikr.currentCount++;
      _sessionCount++;
    });

    _animController.reverse().then((_) => _animController.forward());

    // Check haptics & audio
    await widget.audioService.playClick();
    await widget.audioService.vibrateTap();

    // Check if target reached
    if (_currentDhikr.currentCount > 0 &&
        _currentDhikr.currentCount % _currentDhikr.targetCount == 0) {
      await widget.audioService.playSuccess();
      await widget.audioService.vibrateTargetReached();

      _showTargetReachedSnackBar();
    }

    // Save progress periodically
    await widget.storageService.updateDhikr(_currentDhikr);
  }

  void _resetCounter() {
    if (_sessionCount > 0) {
      // Log session
      final session = CounterSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dhikrId: _currentDhikr.id,
        dhikrTitle: _currentDhikr.title,
        count: _sessionCount,
        timestamp: DateTime.now(),
        durationSeconds: DateTime.now().difference(_sessionStartTime).inSeconds,
      );
      widget.storageService.addSession(session);
    }

    setState(() {
      _currentDhikr.currentCount = 0;
      _sessionCount = 0;
      _sessionStartTime = DateTime.now();
    });
    widget.storageService.updateDhikr(_currentDhikr);
  }

  void _toggleVoiceCounting() async {
    if (_isVoiceActive) {
      await widget.speechService.stopListening();
      setState(() => _isVoiceActive = false);
    } else {
      setState(() => _isVoiceActive = true);
      await widget.speechService.startListening(
        expectedPhrase: _currentDhikr.title,
        onDhikrDetected: () {
          _incrementCounter();
        },
      );
    }
  }

  void _showTargetReachedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'أحسنت! أتممت العدة المستهدفة لـ "${_currentDhikr.title}"',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.emeraldPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openDhikrSelector() async {
    final selected = await showModalBottomSheet<DhikrModel>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 450,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر الذكر للتسبيح',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _azkarList.length,
                  itemBuilder: (context, index) {
                    final item = _azkarList[index];
                    return ListTile(
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('الهدف: ${item.targetCount} - ${item.category}'),
                      trailing: item.id == _currentDhikr.id
                          ? const Icon(Icons.check_circle, color: AppColors.goldPrimary)
                          : null,
                      onTap: () => Navigator.pop(context, item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _currentDhikr = selected;
        _sessionCount = 0;
        _sessionStartTime = DateTime.now();
      });
      await widget.storageService.setSelectedDhikrId(selected.id);
    }
  }

  void _openSkinSelector() async {
    final skin = await showModalBottomSheet<CounterSkin>(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اختر مظهر العداد (الثيم)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...CounterSkin.values.map((s) => ListTile(
                title: Text(s.nameAr),
                trailing: _currentSkin == s ? const Icon(Icons.check, color: AppColors.goldPrimary) : null,
                onTap: () => Navigator.pop(context, s),
              )),
            ],
          ),
        );
      },
    );

    if (skin != null) {
      setState(() => _currentSkin = skin);
      await widget.storageService.setCounterSkin(skin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentDhikr.currentCount % _currentDhikr.targetCount) / _currentDhikr.targetCount;
    final totalRounds = _currentDhikr.currentCount ~/ _currentDhikr.targetCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مسبحتي الذكية', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_keepAwake ? Icons.lightbulb : Icons.lightbulb_outline),
            tooltip: 'ابق الشاشة مضاءة',
            onPressed: () async {
              setState(() => _keepAwake = !_keepAwake);
              await widget.storageService.setKeepAwakeEnabled(_keepAwake);
              if (_keepAwake) {
                WakelockPlus.enable();
              } else {
                WakelockPlus.disable();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            tooltip: 'تغيير المظهر',
            onPressed: _openSkinSelector,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              AppColors.emeraldDark.withValues(alpha: 0.15),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Dhikr Selector Bar
              GestureDetector(
                onTap: _openDhikrSelector,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentDhikr.category,
                              style: const TextStyle(fontSize: 12, color: AppColors.goldPrimary, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _currentDhikr.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.swap_horiz, color: AppColors.emeraldPrimary),
                    ],
                  ),
                ),
              ),

              // Voice Assistant Status Banner
              if (_isVoiceActive)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mic, color: Colors.redAccent).animate(onPlay: (c) => c.repeat()).scale(duration: 600.ms),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.speechService.lastWords.isNotEmpty
                              ? 'سمعت: "${widget.speechService.lastWords}"'
                              : 'جاري الاستماع لصوتك (انطق الذكر لتسجيله تلقائياً)...',
                          style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Interactive Main Counter Ring / Button
              Center(
                child: GestureDetector(
                  onTap: _incrementCounter,
                  child: ScaleTransition(
                    scale: _animController,
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Progress Circular Ring
                          SizedBox(
                            width: 270,
                            height: 270,
                            child: CircularProgressIndicator(
                              value: progress == 0 && _currentDhikr.currentCount > 0 ? 1.0 : progress,
                              strokeWidth: 12,
                              backgroundColor: AppColors.goldPrimary.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldPrimary),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          // Center Button Body
                          Container(
                            width: 230,
                            height: 230,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.emeraldGoldGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.emeraldPrimary.withValues(alpha: 0.4),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_currentDhikr.currentCount}',
                                  style: const TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'الهدف: ${_currentDhikr.targetCount}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.goldLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (totalRounds > 0)
                                  Text(
                                    'الختمات: $totalRounds',
                                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Action Controls (Voice Toggle, Reset, Info)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Reset Button
                    FloatingActionButton.extended(
                      heroTag: 'reset',
                      onPressed: _resetCounter,
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      icon: const Icon(Icons.refresh),
                      label: const Text('تصفير'),
                    ),

                    // Voice Listening Toggle Button
                    FloatingActionButton.extended(
                      heroTag: 'voice',
                      onPressed: _toggleVoiceCounting,
                      backgroundColor: _isVoiceActive ? Colors.redAccent : AppColors.goldPrimary,
                      foregroundColor: Colors.white,
                      icon: Icon(_isVoiceActive ? Icons.mic : Icons.mic_none),
                      label: Text(_isVoiceActive ? 'إيقاف الصوت' : 'تسبيح صوتي'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
