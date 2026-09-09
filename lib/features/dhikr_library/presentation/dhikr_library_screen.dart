import 'package:flutter/material.dart';
import 'package:masbhty/core/constants/app_colors.dart';
import 'package:masbhty/core/models/dhikr_model.dart';
import 'package:masbhty/core/services/storage_service.dart';

class DhikrLibraryScreen extends StatefulWidget {
  final StorageService storageService;
  final Function(String dhikrId) onSelectDhikr;

  const DhikrLibraryScreen({
    super.key,
    required this.storageService,
    required this.onSelectDhikr,
  });

  @override
  State<DhikrLibraryScreen> createState() => _DhikrLibraryScreenState();
}

class _DhikrLibraryScreenState extends State<DhikrLibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<DhikrModel> _allAzkar;
  String _searchQuery = '';

  final List<String> _categories = [
    'الكل',
    'تسابيح عامة',
    'أذكار الصباح والمساء',
    'أذكار ما بعد الصلاة',
    'أسماء الله الحسنى',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadAzkar();
  }

  void _loadAzkar() {
    setState(() {
      _allAzkar = widget.storageService.getAzkar();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCustomDhikrDialog() {
    final titleController = TextEditingController();
    final targetController = TextEditingController(text: '33');
    final benefitController = TextEditingController();
    String selectedCategory = 'تسابيح عامة';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة ذكر مخصص'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'نص الذكر الدعاء'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الهدف المستهدف (مثلاً 33 أو 100)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: benefitController,
                  decoration: const InputDecoration(labelText: 'الفضل / الأجر / المرجع'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldPrimary, foregroundColor: Colors.white),
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                final newDhikr = DhikrModel(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  title: titleController.text.trim(),
                  category: selectedCategory,
                  targetCount: int.tryParse(targetController.text) ?? 33,
                  benefit: benefitController.text.trim(),
                  isCustom: true,
                );
                await widget.storageService.addCustomDhikr(newDhikr);
                _loadAzkar();
                Navigator.pop(context);
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مكتبة الأذكار والأدعية', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.goldPrimary,
          labelColor: AppColors.goldLight,
          unselectedLabelColor: Colors.white70,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'ابحث في الأذكار...',
                prefixIcon: const Icon(Icons.search, color: AppColors.emeraldPrimary),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // List per Tab
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final filtered = _allAzkar.where((item) {
                  final matchesCategory = category == 'للجميع' || category == 'الكل' || item.category == category;
                  final matchesSearch = item.title.contains(_searchQuery) || item.benefit.contains(_searchQuery);
                  return matchesCategory && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  const Center(child: Text('لا توجد أذكار مطابقة'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text('الهدف: ${item.targetCount} مره', style: const TextStyle(color: AppColors.goldPrimary, fontWeight: FontWeight.w600)),
                            if (item.benefit.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(item.benefit, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                            ],
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_circle_fill, color: AppColors.emeraldPrimary, size: 36),
                          tooltip: 'بدء التسبيح',
                          onPressed: () {
                            widget.storageService.setSelectedDhikrId(item.id);
                            widget.onSelectDhikr(item.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCustomDhikrDialog,
        backgroundColor: AppColors.emeraldPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('ذكر مخصص'),
      ),
    );
  }
}
