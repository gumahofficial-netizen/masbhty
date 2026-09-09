import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:masbhty/core/constants/app_colors.dart';
import 'package:masbhty/core/services/storage_service.dart';
import 'package:masbhty/core/services/audio_service.dart';
import 'package:masbhty/core/services/speech_service.dart';
import 'package:masbhty/core/services/location_service.dart';
import 'package:masbhty/features/onboarding/presentation/onboarding_screen.dart';

class SettingsScreen extends StatefulWidget {
  final StorageService storageService;
  final VoidCallback onThemeChanged;

  const SettingsScreen({super.key, required this.storageService, required this.onThemeChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDark;
  late bool _isSound;
  late bool _isVibrate;
  late int _dailyGoal;

  @override
  void initState() {
    super.initState();
    _isDark = widget.storageService.isDarkTheme();
    _isSound = widget.storageService.isSoundEnabled();
    _isVibrate = widget.storageService.isVibrationEnabled();
    _dailyGoal = widget.storageService.getDailyGoal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          // Theme & Sound Section
          _buildSectionHeader('التفضيلات والمظهر'),
          SwitchListTile(
            title: const Text('الوضع الليلي'),
            subtitle: const Text('تفعيل السمة الداكنة المريحة للعين'),
            value: _isDark,
            activeColor: AppColors.goldPrimary,
            onChanged: (val) async {
              setState(() => _isDark = val);
              await widget.storageService.setDarkTheme(val);
              widget.onThemeChanged();
            },
          ),
          SwitchListTile(
            title: const Text('أصوات النقر'),
            subtitle: const Text('تشغيل صوت عند كل تسبيحة'),
            value: _isSound,
            activeColor: AppColors.goldPrimary,
            onChanged: (val) async {
              setState(() => _isSound = val);
              await widget.storageService.setSoundEnabled(val);
            },
          ),
          SwitchListTile(
            title: const Text('الاهتزاز'),
            subtitle: const Text('تفعيل الرد الاهتزازي عند اللمس'),
            value: _isVibrate,
            activeColor: AppColors.goldPrimary,
            onChanged: (val) async {
              setState(() => _isVibrate = val);
              await widget.storageService.setVibrationEnabled(val);
            },
          ),

          // Goals Section
          _buildSectionHeader('الأهداف اليومية'),
          ListTile(
            title: const Text('هدف التسبيح اليومي'),
            subtitle: Text('الحالي: $_dailyGoal تسبيحة'),
            trailing: const Icon(Icons.edit, color: AppColors.goldPrimary),
            onTap: _showGoalEditDialog,
          ),

          // Backup Section
          _buildSectionHeader('النسخ الاحتياطي والمزامنة'),
          ListTile(
            title: const Text('تصدير بياناتي (Backup)'),
            subtitle: const Text('حفظ نسخة احتياطية من الأذكار والإحصائيات'),
            leading: const Icon(Icons.cloud_upload, color: AppColors.emeraldPrimary),
            onTap: () {
              final backup = widget.storageService.exportBackupJson();
              Share.share(backup, subject: 'نسخة احتياطية مسبحتي الذكية');
            },
          ),
          ListTile(
            title: const Text('استيراد بياناتي (Restore)'),
            subtitle: const Text('استعادة البيانات من كود النسخة الاحتياطية'),
            leading: const Icon(Icons.cloud_download, color: AppColors.goldPrimary),
            onTap: _showImportDialog,
          ),

          // About Section
          _buildSectionHeader('عن التطبيق والصدقة الجارية'),
          ListTile(
            title: const Text('مسبحتي الذكية'),
            subtitle: const Text('الإصدار 1.0.0 (Premium) - اضغط للتفاصيل'),
            leading: const Icon(Icons.info_outline, color: AppColors.goldPrimary),
            onTap: _showAboutDialog,
          ),
          ListTile(
            title: const Text('عرض شاشة الترحيب والميزات'),
            subtitle: const Text('جولة تعريفية بكيفية عمل التطبيق'),
            leading: const Icon(Icons.explore, color: AppColors.emeraldPrimary),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OnboardingScreen(
                    storageService: widget.storageService,
                    audioService: AudioService(widget.storageService),
                    speechService: SpeechService(),
                    locationService: LocationService(),
                    onThemeChanged: widget.onThemeChanged,
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('شارك التطبيق مع أصدقائك'),
            subtitle: const Text('الدال على الخير كفاعله'),
            leading: const Icon(Icons.share, color: Colors.blue),
            onTap: () {
              Share.share('حمل تطبيق مسبحتي الذكية - رفيقك للتسبيح والأذكار: com.gumah.masbhty');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.goldPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  void _showGoalEditDialog() {
    final controller = TextEditingController(text: '$_dailyGoal');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الهدف اليومي'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'أدخل العدد المستهدف يومياً'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldPrimary, foregroundColor: Colors.white),
            onPressed: () async {
              final val = int.tryParse(controller.text) ?? 1000;
              setState(() => _dailyGoal = val);
              await widget.storageService.setDailyGoal(val);
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('استيراد البيانات'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'الصق كود النسخة الاحتياطية هنا...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final success = await widget.storageService.importBackupJson(controller.text);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت استعادة البيانات بنجاح!')));
                Navigator.pop(context);
                // Refresh app state if needed
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كود غير صالح، يرجى المحاولة مرة أخرى.')));
              }
            },
            child: const Text('استيراد'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('عن التطبيق والصدقة الجارية', style: TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.bold)),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مسبحتي الذكية (الإصدار 1.0.0)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'ميزات التطبيق:\n• تسبيح تفاعلي باللمس والصوت والاهتزاز.\n• أذكار متنوعة وإمكانية إضافة أذكار مخصصة.\n• بوصلة القبلة ومواقيت الصلاة.\n• تتبع الأهداف والإحصائيات اليومية والأسبوعية.',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
              SizedBox(height: 16),
              Divider(color: AppColors.goldPrimary),
              SizedBox(height: 8),
              Text(
                'صدقة جارية:',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldPrimary, fontSize: 15),
              ),
              SizedBox(height: 4),
              Text(
                'هذا التطبيق صدقة جارية لوالدي المرحوم (محمد نصار العجاج) رحمه الله، ونسأل الله العظيم أن يشفي ابني (عامر جمعة العجاج) شفاءً لا يغادر سقماً.',
                style: TextStyle(fontSize: 14, height: 1.6),
              ),
              SizedBox(height: 16),
              Text(
                'المبرمج:',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.goldPrimary, fontSize: 15),
              ),
              SizedBox(height: 4),
              Text(
                'تم تصميم وبرمجة التطبيق بواسطة:\nجمعة العجاج (مبرمج تطبيقات بتصميم أنيق ومميز).',
                style: TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldPrimary, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
