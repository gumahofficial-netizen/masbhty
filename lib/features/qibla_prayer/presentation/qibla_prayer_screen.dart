import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'package:masbhty/core/constants/app_colors.dart';
import 'package:masbhty/core/services/location_service.dart';

class QiblaPrayerScreen extends StatefulWidget {
  final LocationService locationService;

  const QiblaPrayerScreen({Key? key, required this.locationService}) : super(key: key);

  @override
  State<QiblaPrayerScreen> createState() => _QiblaPrayerScreenState();
}

class _QiblaPrayerScreenState extends State<QiblaPrayerScreen> {
  Position? _position;
  PrayerTimes? _prayerTimes;
  double _qiblaDirection = 0.0;
  double? _compassHeading;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initLocationAndPrayers();
  }

  Future<void> _initLocationAndPrayers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final pos = await widget.locationService.getCurrentLocation();
    if (pos == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر الحصول على الموقع. يرجى تفعيل خدمة الموقع GPS وصلاحياته.';
      });
      return;
    }

    final prayers = widget.locationService.getPrayerTimes(pos);
    final qibla = widget.locationService.calculateQiblaDirection(pos.latitude, pos.longitude);

    setState(() {
      _position = pos;
      _prayerTimes = prayers;
      _qiblaDirection = qibla;
      _isLoading = false;
    });

    // Listen to compass
    widget.locationService.getCompassStream()?.listen((event) {
      if (mounted) {
        setState(() {
          _compassHeading = event.heading;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القبلة وأوقات الصلاة', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldPrimary))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldPrimary, foregroundColor: Colors.white),
                          onPressed: _initLocationAndPrayers,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Qibla Compass Card
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              const Text(
                                'اتجاه القبلة المشرفة',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.emeraldPrimary),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: 220,
                                height: 220,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Compass Dial Background
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.goldPrimary, width: 3),
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                    // Rotating Qibla Needle
                                    Transform.rotate(
                                      angle: ((_qiblaDirection - (_compassHeading ?? 0)) * (math.pi / 180)),
                                      child: const Icon(Icons.navigation, size: 90, color: AppColors.emeraldPrimary),
                                    ),
                                    const Center(
                                      child: CircleAvatar(
                                        radius: 10,
                                        backgroundColor: AppColors.goldPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'زاوية القبلة: ${_qiblaDirection.toStringAsFixed(1)}°',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Prayer Times Schedule Card
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'مواقيت الصلاة لليوم',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.emeraldPrimary),
                              ),
                              const Divider(),
                              const SizedBox(height: 8),
                              if (_prayerTimes != null) ...[
                                _buildPrayerRow('الفجر', _formatTime(_prayerTimes!.fajr)),
                                _buildPrayerRow('الشروق', _formatTime(_prayerTimes!.sunrise)),
                                _buildPrayerRow('الظهر', _formatTime(_prayerTimes!.dhuhr)),
                                _buildPrayerRow('العصر', _formatTime(_prayerTimes!.asr)),
                                _buildPrayerRow('المغرب', _formatTime(_prayerTimes!.maghrib)),
                                _buildPrayerRow('العشاء', _formatTime(_prayerTimes!.isha)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPrayerRow(String name, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.goldPrimary)),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final formattedHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$formattedHour:$minute $period';
  }
}
