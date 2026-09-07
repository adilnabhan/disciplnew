import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/home/persentation/screens/food_search_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  int _waterMl = 0;
  int _waterTarget = 3000;
  int _foodEatenKcal = 0;
  int _exerciseKcal = 0;
  int _baseGoalKcal = 2200;
  Map<String, dynamic>? _assignedDietPlan;

  double _proteinG = 0.0;
  double _proteinTargetG = 150.0;

  double _carbsG = 0.0;
  double _carbsTargetG = 220.0;

  double _fatG = 0.0;
  double _fatTargetG = 65.0;

  double _fiberG = 0.0;
  double _fiberTargetG = 32.0;

  List<Map<String, dynamic>> _allMealLogs = [];
  List<Map<String, dynamic>> _breakfastLogs = [];
  List<Map<String, dynamic>> _lunchLogs = [];
  List<Map<String, dynamic>> _dinnerLogs = [];
  List<Map<String, dynamic>> _snackLogs = [];

  Map<String, double> _mealCalories = {
    'breakfast': 0,
    'lunch': 0,
    'dinner': 0,
    'snack': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchNutritionData();
  }

  Future<void> _fetchNutritionData() async {
    setState(() => _isLoading = true);
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    try {
      final res = await DioClient().dio.get(
        ApiUris.nutritionGoals,
        queryParameters: {'date': dateStr},
      );

      if (res.statusCode == 200 && res.data != null) {
        final data = res.data is Map ? res.data : {};
        final goals = data['goals'] is Map ? data['goals'] : {};

        final List mealLogsRaw = data['meal_logs'] ?? [];
        final List<Map<String, dynamic>> parsedLogs = mealLogsRaw
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();

        final bLogs = <Map<String, dynamic>>[];
        final lLogs = <Map<String, dynamic>>[];
        final dLogs = <Map<String, dynamic>>[];
        final sLogs = <Map<String, dynamic>>[];

        double bCal = 0, lCal = 0, dCal = 0, sCal = 0;

        for (final log in parsedLogs) {
          final mealType = (log['meal_type'] ?? '').toString().toLowerCase().trim();
          final cal = _toDouble(log['calories'] ?? 0);

          if (mealType == 'breakfast') {
            bLogs.add(log);
            bCal += cal;
          } else if (mealType == 'lunch') {
            lLogs.add(log);
            lCal += cal;
          } else if (mealType == 'dinner') {
            dLogs.add(log);
            dCal += cal;
          } else {
            sLogs.add(log);
            sCal += cal;
          }
        }

        setState(() {
          _baseGoalKcal = _toInt(data['target_calories'] ?? data['calorie_goal'] ?? 2200);
          _foodEatenKcal = _toInt(data['consumed_calories'] ?? data['total_calories_eaten'] ?? (bCal + lCal + dCal + sCal));
          _exerciseKcal = _toInt(data['burned_calories'] ?? data['total_calories_burned'] ?? 0);
          _waterMl = _toInt(data['water_ml'] ?? data['water'] ?? 0);

          _proteinG = _toDouble(data['total_protein_g'] ?? data['protein'] ?? 0.0);
          _carbsG = _toDouble(data['total_carbs_g'] ?? data['carbs'] ?? 0.0);
          _fatG = _toDouble(data['total_fat_g'] ?? data['fat'] ?? 0.0);
          _fiberG = _toDouble(data['total_fiber_g'] ?? data['fiber'] ?? 0.0);

          if (goals.isNotEmpty) {
            _proteinTargetG = _toDouble(goals['daily_protein_g'] ?? 150.0);
            _carbsTargetG = _toDouble(goals['daily_carbs_g'] ?? 220.0);
            _fatTargetG = _toDouble(goals['daily_fat_g'] ?? 65.0);
            _fiberTargetG = _toDouble(goals['daily_fiber_g'] ?? 32.0);
          }

          final assignedDiet = data['assigned_diet_plan'] as Map<String, dynamic>?;
          _assignedDietPlan = assignedDiet;
          if (assignedDiet != null) {
            _baseGoalKcal = _toInt(assignedDiet['daily_calorie_target'] ?? _baseGoalKcal);
            _proteinTargetG = _toDouble(assignedDiet['protein_target_g'] ?? _proteinTargetG);
            _carbsTargetG = _toDouble(assignedDiet['carbs_target_g'] ?? _carbsTargetG);
            _fatTargetG = _toDouble(assignedDiet['fat_target_g'] ?? _fatTargetG);
            _waterTarget = _toInt(assignedDiet['water_target_ml'] ?? _waterTarget);
          }

          _allMealLogs = parsedLogs;
          _breakfastLogs = bLogs;
          _lunchLogs = lLogs;
          _dinnerLogs = dLogs;
          _snackLogs = sLogs;

          _mealCalories = {
            'breakfast': bCal,
            'lunch': lCal,
            'dinner': dCal,
            'snack': sCal,
          };
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

  void _shiftDate(int deltaDays) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: deltaDays));
    });
    _fetchNutritionData();
  }

  String _getDateHeaderString() {
    final now = DateTime.now();
    if (_selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day) {
      return 'Today, ${DateFormat('d MMMM').format(_selectedDate)}';
    }
    return DateFormat('EEEE, d MMMM').format(_selectedDate);
  }

  Future<void> _deleteFoodLog(int logId) async {
    try {
      await DioClient().dio.delete(ApiUris.foodLogDelete(logId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item deleted from today\'s meals', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Color(0xFFE50914),
            duration: Duration(seconds: 2),
          ),
        );
      }
      _fetchNutritionData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete item'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _logWater(int amountMl) async {
    setState(() {
      _waterMl = (_waterMl + amountMl).clamp(0, 10000);
    });
    try {
      await DioClient().dio.post(
        ApiUris.waterLog,
        data: {
          'amount_ml': amountMl,
          'logged_at': DateFormat('yyyy-MM-dd').format(_selectedDate),
        },
      );
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('💧 +${amountMl}ml Water Logged! Total: ${_waterMl}ml', style: const TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF0091EA),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openFoodSearch([String initialMeal = 'lunch']) async {
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodSearchScreen(
          initialMeal: initialMeal,
          targetDate: _selectedDate,
        ),
      ),
    );
    if (res == true || mounted) {
      _fetchNutritionData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int remainingKcal = (_baseGoalKcal - _foodEatenKcal + _exerciseKcal).clamp(0, 9999);
    final double percentGoal = _baseGoalKcal > 0 ? (_foodEatenKcal / _baseGoalKcal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101018),
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.restaurant_rounded, color: CyberWorkoutTheme.crimsonRed, size: 22),
            SizedBox(width: 8),
            Text(
              'NUTRITION & MACROS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _fetchNutritionData,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: CyberWorkoutTheme.crimsonRed,
        backgroundColor: const Color(0xFF141420),
        onRefresh: _fetchNutritionData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Date Navigator Bar
              _buildDateNavigator(),
              const SizedBox(height: 16),

              // 2. Hero Calorie Ring & Gauge Card
              _buildHeroCalorieCard(remainingKcal, percentGoal),
              const SizedBox(height: 16),

              // 3. Macro Nutrients Glow Grid (Protein, Carbs, Fats, Fiber)
              _buildMacrosGrid(),
              const SizedBox(height: 16),

              // 4. Hydration Station (Water Tracker)
              _buildHydrationStation(),
              const SizedBox(height: 20),

              // 5. Smart Coach Guidance
              _buildSmartCoachBanner(),
              const SizedBox(height: 20),

              // 6. Meal Logs Header with Log Food Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TODAY\'S MEALS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CyberWorkoutTheme.crimsonRed,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: CyberWorkoutTheme.crimsonRed.withOpacity(0.4),
                    ),
                    onPressed: () => _openFoodSearch('lunch'),
                    icon: const Icon(Icons.search_rounded, color: Colors.white, size: 16),
                    label: const Text(
                      'Search 1000+ Foods',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 7. Meal Sections (Breakfast, Lunch, Dinner, Snack)
              _buildMealSection(
                mealKey: 'breakfast',
                title: 'Breakfast 🌅',
                kcal: _mealCalories['breakfast'] ?? 0,
                items: _breakfastLogs,
              ),
              const SizedBox(height: 12),

              _buildMealSection(
                mealKey: 'lunch',
                title: 'Lunch ☀️',
                kcal: _mealCalories['lunch'] ?? 0,
                items: _lunchLogs,
              ),
              const SizedBox(height: 12),

              _buildMealSection(
                mealKey: 'dinner',
                title: 'Dinner 🌙',
                kcal: _mealCalories['dinner'] ?? 0,
                items: _dinnerLogs,
              ),
              const SizedBox(height: 12),

              _buildMealSection(
                mealKey: 'snack',
                title: 'Snacks & Supplements 🍎',
                kcal: _mealCalories['snack'] ?? 0,
                items: _snackLogs,
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Date Navigation Bar
  Widget _buildDateNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 26),
            onPressed: () => _shiftDate(-1),
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: CyberWorkoutTheme.crimsonRed,
                        onPrimary: Colors.white,
                        surface: Color(0xFF161622),
                        onSurface: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
                _fetchNutritionData();
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getDateHeaderString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.calendar_month_rounded, color: CyberWorkoutTheme.crimsonRed, size: 16),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 26),
            onPressed: () => _shiftDate(1),
          ),
        ],
      ),
    );
  }

  // 2. Hero Calorie Ring & Gauge Card
  Widget _buildHeroCalorieCard(int remainingKcal, double percentGoal) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF220E16),
            Color(0xFF141420),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: CyberWorkoutTheme.crimsonRed.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ENERGY BALANCE',
                style: TextStyle(
                  color: CyberWorkoutTheme.crimsonRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'Daily Goal: $_baseGoalKcal kcal',
                style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Double Ring Gauge
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 105,
                    height: 105,
                    child: CircularProgressIndicator(
                      value: percentGoal,
                      strokeWidth: 8,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(CyberWorkoutTheme.crimsonRed),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$remainingKcal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Text(
                        'KCAL LEFT',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Metrics Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalorieStatRow('Consumed', '$_foodEatenKcal kcal', const Color(0xFFFF5252), Icons.restaurant_rounded),
                  const SizedBox(height: 8),
                  _buildCalorieStatRow('Burned', '$_exerciseKcal kcal', const Color(0xFFFF9100), Icons.local_fire_department_rounded),
                  const SizedBox(height: 8),
                  _buildCalorieStatRow('Net Calories', '${_foodEatenKcal - _exerciseKcal} kcal', const Color(0xFF00E676), Icons.bolt_rounded),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieStatRow(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 14),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
            Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }

  // 3. Macro Nutrients Glow Grid
  Widget _buildMacrosGrid() {
    return Row(
      children: [
        Expanded(child: _buildMacroCard('PROTEIN', _proteinG, _proteinTargetG, 'g', const Color(0xFFFF334B))),
        const SizedBox(width: 8),
        Expanded(child: _buildMacroCard('CARBS', _carbsG, _carbsTargetG, 'g', const Color(0xFFFFAA00))),
        const SizedBox(width: 8),
        Expanded(child: _buildMacroCard('FATS', _fatG, _fatTargetG, 'g', const Color(0xFF00D2FF))),
        const SizedBox(width: 8),
        Expanded(child: _buildMacroCard('FIBER', _fiberG, _fiberTargetG, 'g', const Color(0xFF00E676))),
      ],
    );
  }

  Widget _buildMacroCard(String name, double current, double target, String unit, Color color) {
    final double factor = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${current.toInt()}$unit',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
          ),
          Text(
            'of ${target.toInt()}$unit',
            style: const TextStyle(color: Colors.white38, fontSize: 9),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: factor,
              minHeight: 4,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Hydration Station (Water Tracker)
  Widget _buildHydrationStation() {
    final double waterFactor = (_waterMl / _waterTarget).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0091EA).withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.water_drop_rounded, color: Color(0xFF00B0FF), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'HYDRATION TRACKER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                '$_waterMl / $_waterTarget ml',
                style: const TextStyle(
                  color: Color(0xFF00B0FF),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: waterFactor,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00B0FF)),
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00B0FF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _logWater(250),
                  child: const Text('+250ml 💧', style: TextStyle(color: Color(0xFF00B0FF), fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF00B0FF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _logWater(500),
                  child: const Text('+500ml 🧊', style: TextStyle(color: Color(0xFF00B0FF), fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.restart_alt_rounded, color: Colors.white38, size: 20),
                onPressed: () => setState(() => _waterMl = 0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Smart Coach Nutrition Banner / Assigned Diet Plan
  Widget _buildSmartCoachBanner() {
    if (_assignedDietPlan != null) {
      final diet = _assignedDietPlan!;
      final trainerName = diet['trainer_name'] ?? 'Coach';
      final title = diet['title'] ?? 'Custom Nutrition Plan';
      final desc = diet['description'] as String?;
      final meals = (diet['meals'] as List<dynamic>?) ?? [];

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161622),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: CyberWorkoutTheme.goldPrimary.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: CyberWorkoutTheme.goldPrimary.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CyberWorkoutTheme.goldPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberWorkoutTheme.goldPrimary),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, color: CyberWorkoutTheme.goldPrimary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'ASSIGNED BY $trainerName'.toUpperCase(),
                        style: const TextStyle(
                          color: CyberWorkoutTheme.goldPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Icon(Icons.restaurant_menu_rounded, color: Colors.white38, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (desc != null && desc.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.3),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDietPlanTargetItem('Calories', '${diet['daily_calorie_target'] ?? _baseGoalKcal} kcal'),
                  _buildDietPlanTargetItem('Protein', '${diet['protein_target_g'] ?? _proteinTargetG.toInt()}g'),
                  _buildDietPlanTargetItem('Carbs', '${diet['carbs_target_g'] ?? _carbsTargetG.toInt()}g'),
                  _buildDietPlanTargetItem('Fat', '${diet['fat_target_g'] ?? _fatTargetG.toInt()}g'),
                ],
              ),
            ),
            if (meals.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'PRESCRIBED MEALS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              ...meals.map((m) {
                final mealMap = m is Map ? m : {};
                final mType = (mealMap['meal_type'] ?? 'Meal').toString().toUpperCase();
                final foods = (mealMap['recommended_foods'] ?? '').toString();
                final portion = (mealMap['portion_size'] ?? '').toString();
                final cal = mealMap['target_calories'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: CyberWorkoutTheme.crimsonRed.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            mType,
                            style: const TextStyle(
                              color: CyberWorkoutTheme.crimsonRed,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foods.isNotEmpty ? foods : (mealMap['meal_name'] ?? 'Recommended meal'),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              if (portion.isNotEmpty)
                                Text(
                                  'Portion: $portion',
                                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                                ),
                            ],
                          ),
                        ),
                        if (cal != null)
                          Text(
                            '$cal kcal',
                            style: const TextStyle(
                              color: CyberWorkoutTheme.goldPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1826),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CyberWorkoutTheme.goldPrimary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, color: CyberWorkoutTheme.goldPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _foodEatenKcal == 0
                  ? 'Discipl Smart Coach: Log your meals from over 1,000 foods to track your daily calorie and macro goals!'
                  : 'Daily Target: ${_proteinTargetG.toInt()}g protein & ${_carbsTargetG.toInt()}g carbs for optimal athletic performance.',
              style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietPlanTargetItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 9),
        ),
      ],
    );
  }

  // 7. Meal Section Widget with real list of food items
  Widget _buildMealSection({
    required String mealKey,
    required String title,
    required double kcal,
    required List<Map<String, dynamic>> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CyberWorkoutTheme.crimsonRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${kcal.toInt()} kcal',
                  style: const TextStyle(
                    color: CyberWorkoutTheme.crimsonRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Logged Food items list from API
          if (items.isNotEmpty) ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.04), height: 12),
              itemBuilder: (context, idx) {
                final log = items[idx];
                final logId = log['id'] as int? ?? 0;
                final foodName = log['food_name'] ?? log['name'] ?? 'Food';
                final cals = _toDouble(log['calories'] ?? 0);
                final prot = _toDouble(log['protein'] ?? 0);
                final carbs = _toDouble(log['carbs'] ?? 0);
                final unit = log['serving_unit'] ?? '100g';
                final servings = _toDouble(log['servings'] ?? 1.0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodName,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${servings == 1.0 ? "" : "${servings}x "}$unit • ${cals.toInt()} kcal • ${prot.toStringAsFixed(1)}g P • ${carbs.toStringAsFixed(1)}g C',
                            style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white38, size: 18),
                      onPressed: logId > 0 ? () => _deleteFoodLog(logId) : null,
                    ),
                  ],
                );
              },
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'No foods logged for $title yet.',
                style: const TextStyle(color: Colors.white30, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],

          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: const Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _openFoodSearch(mealKey),
              icon: const Icon(Icons.add_circle_outline_rounded, color: CyberWorkoutTheme.crimsonRed, size: 14),
              label: Text(
                '+ Add Food',
                style: const TextStyle(color: CyberWorkoutTheme.crimsonRed, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
