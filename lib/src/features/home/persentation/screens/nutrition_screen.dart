import 'package:flutter/material.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/home/persentation/screens/food_search_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int _waterMl = 750;
  final int _waterTarget = 3000;
  int _foodEatenKcal = 1250;
  int _exerciseKcal = 520;
  int _baseGoalKcal = 1500;
  double _proteinG = 85.0;
  double _carbsG = 150.0;
  double _fatG = 40.0;
  double _fiberG = 18.0;
  bool _isLoading = false;

  Map<String, double> _mealCalories = {
    'breakfast': 350,
    'lunch': 650,
    'dinner': 250,
    'snack': 150,
  };
  List<Map<String, dynamic>> _mealLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchNutritionData();
  }

  Future<void> _fetchNutritionData() async {
    setState(() => _isLoading = true);
    try {
      final res = await DioClient().dio.get(ApiUris.nutritionGoals);
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data is Map ? res.data : {};
        setState(() {
          _baseGoalKcal = _toInt(data['target_calories'] ?? data['calorie_goal'] ?? 1500);
          _foodEatenKcal = _toInt(data['consumed_calories'] ?? data['total_calories_eaten'] ?? 1250);
          _exerciseKcal = _toInt(data['burned_calories'] ?? data['total_calories_burned'] ?? 520);
          _waterMl = _toInt(data['water_ml'] ?? data['water'] ?? 750);
          _proteinG = _toDouble(data['total_protein_g'] ?? data['protein'] ?? 85.0);
          _carbsG = _toDouble(data['total_carbs_g'] ?? data['carbs'] ?? 150.0);
          _fatG = _toDouble(data['total_fat_g'] ?? data['fat'] ?? 40.0);
          _fiberG = _toDouble(data['total_fiber_g'] ?? data['fiber'] ?? 18.0);

          final List mealLogs = data['meal_logs'] ?? [];
          if (mealLogs.isNotEmpty) {
            _mealLogs = mealLogs.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
            _mealCalories = {'breakfast': 0, 'lunch': 0, 'dinner': 0, 'snack': 0};
            for (final log in _mealLogs) {
              final mealType = (log['meal_type'] ?? '').toString().toLowerCase();
              final cal = _toDouble(log['calories'] ?? 0);
              if (_mealCalories.containsKey(mealType)) {
                _mealCalories[mealType] = (_mealCalories[mealType] ?? 0) + cal;
              } else {
                _mealCalories['snack'] = (_mealCalories['snack'] ?? 0) + cal;
              }
            }
          }
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is double) return val.round();
    if (val is String) return double.tryParse(val)?.round() ?? 0;
    return 0;
  }

  double _toDouble(dynamic val) {
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  Future<void> _logWater() async {
    try {
      await DioClient().dio.post(
        ApiUris.waterLog,
        data: {'amount_ml': 250},
      );
      setState(() {
        if (_waterMl < _waterTarget) _waterMl += 250;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('+250ml Water Logged!'),
            backgroundColor: Color(0xFF0284C7),
          ),
        );
      }
    } catch (_) {
      setState(() {
        if (_waterMl < _waterTarget) _waterMl += 250;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double percentGoal = (_foodEatenKcal / _baseGoalKcal * 100).clamp(0, 100);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            const Text('🥗 ', style: TextStyle(fontSize: 18)),
            Text(
              'Nutrition Tracker',
              style: AppStyles.text16Px.poppins.w600.copyWith(color: const Color(0xFF0F172A)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF64748B)),
            onPressed: _fetchNutritionData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNutritionData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Marigold Floral Garland Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Text('🌼 🌸 🌿 🌼 🌸 🌿 🌼 🌸 🌿 🌼', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Hero Onam Sadya Tracker Card (1:1 with Reference Image 1 & 2 Screen 3)
              _buildOnamSadyaHeroCard(),
              const SizedBox(height: 16),

              // Today's Nutrition Section with Gauge (1:1 Match)
              _buildTodaysNutritionCard(percentGoal),
              const SizedBox(height: 16),

              // Macros Card Grid (Protein, Carbs, Fats, Fiber)
              _buildMacrosGrid(),
              const SizedBox(height: 20),

              // Quick Add Meal Row (1:1 Match: Breakfast, Lunch, Dinner, Snack, Water)
              _buildQuickAddSection(),
              const SizedBox(height: 20),

              // Today's Meals Breakdown List
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Meals',
                    style: AppStyles.text16Px.poppins.w600.copyWith(color: const Color(0xFF0F172A)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D3B2E),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FoodSearchScreen()),
                      );
                      _fetchNutritionData();
                    },
                    icon: const Icon(Icons.add, color: Colors.white, size: 16),
                    label: Text(
                      'Log Meal',
                      style: AppStyles.text12Px.poppins.w600.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildMealTile('Breakfast 🌅', '${(_mealCalories['breakfast'] ?? 350).toStringAsFixed(0)} kcal'),
              _buildMealTile('Lunch ☀️ (Sadya Ela)', '${(_mealCalories['lunch'] ?? 650).toStringAsFixed(0)} kcal'),
              _buildMealTile('Dinner 🌙', '${(_mealCalories['dinner'] ?? 250).toStringAsFixed(0)} kcal'),
              _buildMealTile('Snacks 🍎 (Banana Chips)', '${(_mealCalories['snack'] ?? 150).toStringAsFixed(0)} kcal'),
            ],
          ),
        ),
      ),
    );
  }

  // 1:1 Match for Onam Sadya Tracker Hero Card
  Widget _buildOnamSadyaHeroCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F888888),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌾 ', style: TextStyle(fontSize: 18)),
              Text(
                'Onam Sadya Tracker',
                style: AppStyles.text16Px.poppins.w700.copyWith(color: const Color(0xFF78350F)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Track your Onam Sadya, stay mindful & burn those extra calories!',
            style: AppStyles.text12Px.poppins.w400.copyWith(color: const Color(0xFF92400E)),
          ),
          const SizedBox(height: 14),

          // Green Log Sadya & Calories Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B2E),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FoodSearchScreen()),
              );
              _fetchNutritionData();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Log Sadya & Calories',
                  style: AppStyles.text12Px.poppins.w600.copyWith(color: Colors.white),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1:1 Match for Today's Nutrition Gauge Card
  Widget _buildTodaysNutritionCard(double percentGoal) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Nutrition',
            style: AppStyles.text14Px.poppins.w600.copyWith(color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Consumed Gauge Ring
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          value: (_foodEatenKcal / _baseGoalKcal).clamp(0.0, 1.0),
                          strokeWidth: 8,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_foodEatenKcal',
                            style: AppStyles.text16Px.poppins.w700.copyWith(color: const Color(0xFF0F172A)),
                          ),
                          Text(
                            'Consumed\nkcal',
                            textAlign: TextAlign.center,
                            style: AppStyles.text8Px.poppins.w500.copyWith(color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Target Gauge Ring
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 8,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF94A3B8)),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_baseGoalKcal',
                            style: AppStyles.text16Px.poppins.w700.copyWith(color: const Color(0xFF0F172A)),
                          ),
                          Text(
                            'Target\nkcal',
                            textAlign: TextAlign.center,
                            style: AppStyles.text8Px.poppins.w500.copyWith(color: const Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          Center(
            child: Text(
              '${percentGoal.toStringAsFixed(0)}% of Daily Goal',
              style: AppStyles.text12Px.poppins.w600.copyWith(color: const Color(0xFF10B981)),
            ),
          ),
        ],
      ),
    );
  }

  // 1:1 Match for Macros Grid
  Widget _buildMacrosGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMacroItem('Protein', '${_proteinG.toStringAsFixed(0)}g', '/120g', const Color(0xFF3B82F6), '🥛'),
          _buildMacroItem('Carbs', '${_carbsG.toStringAsFixed(0)}g', '/200g', const Color(0xFFF97316), '🌾'),
          _buildMacroItem('Fats', '${_fatG.toStringAsFixed(0)}g', '/60g', const Color(0xFF10B981), '🥑'),
          _buildMacroItem('Fiber', '${_fiberG.toStringAsFixed(0)}g', '/25g', const Color(0xFF06B6D4), '🍌'),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String val, String target, Color col, String iconStr) {
    return Column(
      children: [
        Text(label, style: AppStyles.text12Px.poppins.w600.copyWith(color: const Color(0xFF64748B))),
        const SizedBox(height: 4),
        Text(val, style: AppStyles.text14Px.poppins.w700.copyWith(color: col)),
        Text(target, style: AppStyles.text10Px.poppins.w400.copyWith(color: const Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        Text(iconStr, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  // 1:1 Match for Quick Add Section
  Widget _buildQuickAddSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Add',
          style: AppStyles.text14Px.poppins.w600.copyWith(color: const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickAddItem('Breakfast', '🍚'),
            _buildQuickAddItem('Lunch', '🥗'),
            _buildQuickAddItem('Dinner', '🍲'),
            _buildQuickAddItem('Snack', '🍌'),
            _buildQuickAddWaterItem('Water', '🥛'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddItem(String label, String iconEmoji) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FoodSearchScreen()),
        );
        _fetchNutritionData();
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
            ),
            child: Text(iconEmoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppStyles.text10Px.poppins.w500.copyWith(color: const Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildQuickAddWaterItem(String label, String iconEmoji) {
    return InkWell(
      onTap: _logWater,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0284C7).withOpacity(0.5)),
            ),
            child: Text(iconEmoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppStyles.text10Px.poppins.w500.copyWith(color: const Color(0xFF0284C7))),
        ],
      ),
    );
  }

  Widget _buildMealTile(String name, String kcal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: AppStyles.text14Px.poppins.w600.copyWith(color: const Color(0xFF1E293B))),
          Row(
            children: [
              Text(kcal, style: AppStyles.text12Px.poppins.w600.copyWith(color: const Color(0xFF10B981))),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
