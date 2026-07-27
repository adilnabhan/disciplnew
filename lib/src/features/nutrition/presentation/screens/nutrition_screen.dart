import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/nutrition/presentation/screens/food_search_screen.dart';
import 'package:dio/dio.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final Dio _dio = DioClient().dio;
  bool _isLoading = true;
  Map<String, dynamic> _summaryData = {};

  int _calorieGoal = 2000;
  int _caloriesEaten = 0;
  int _caloriesBurned = 0;

  double _proteinGrams = 0;
  double _proteinGoal = 120;
  double _carbsGrams = 0;
  double _carbsGoal = 250;
  double _fatGrams = 0;
  double _fatGoal = 65;

  int _waterMl = 0;
  int _waterGoalMl = 3000;

  List<dynamic> _mealLogs = [];

  int _parseInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) {
      final d = double.tryParse(val);
      if (d != null) return d.toInt();
    }
    return fallback;
  }

  double _parseDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) {
      final d = double.tryParse(val);
      if (d != null) return d;
    }
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _fetchCalorieSummary();
  }

  Future<void> _fetchCalorieSummary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.get<dynamic>(
        ApiUris.calorieSummary,
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final todaySummary = data['today_summary'] as Map<String, dynamic>?;
        final goals = data['goals'] as Map<String, dynamic>?;

        setState(() {
          _summaryData = data;
          _calorieGoal = _parseInt(data['calorie_goal'] ?? goals?['daily_calorie_goal'], 2000);
          _caloriesEaten = _parseInt(data['total_calories_eaten'] ?? todaySummary?['consumed_calories']);
          _caloriesBurned = _parseInt(data['total_calories_burned']);

          _proteinGrams = _parseDouble(data['total_protein_g'] ?? todaySummary?['consumed_protein_g']);
          _carbsGrams = _parseDouble(data['total_carbs_g'] ?? todaySummary?['consumed_carbs_g']);
          _fatGrams = _parseDouble(data['total_fat_g'] ?? todaySummary?['consumed_fat_g']);

          _waterMl = _parseInt(data['water_ml']);
          _mealLogs = (data['meal_logs'] as List<dynamic>?) ?? (data['all_logs'] as List<dynamic>?) ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addWater(int amountMl) async {
    try {
      final newTotal = _waterMl + amountMl;
      setState(() {
        _waterMl = newTotal;
      });
      await _dio.post<dynamic>(
        ApiUris.waterLog,
        data: {'amount_ml': amountMl},
        options: Options(headers: {'X-Platform': platformSource}).token,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _calorieGoal - _caloriesEaten + _caloriesBurned;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Nutrition Tracker',
          style: AppStyles.text20Px.poppins.w700.copyWith(
            color: const Color(0xFF1E293B),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            onPressed: _fetchCalorieSummary,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : RefreshIndicator(
              onRefresh: _fetchCalorieSummary,
              color: const Color(0xFF10B981),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calorie Summary Card
                    _buildCalorieCard(remaining),
                    const SizedBox(height: 16),

                    // Macros Breakdown Card
                    _buildMacrosCard(),
                    const SizedBox(height: 16),

                    // Water Tracker Card
                    _buildWaterCard(),
                    const SizedBox(height: 24),

                    // Meal Timeline Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today\'s Meals',
                          style: AppStyles.text18Px.poppins.w700.copyWith(
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FoodSearchScreen(),
                              ),
                            );
                            _fetchCalorieSummary();
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Log Meal'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Meals Timeline
                    _buildMealSection('Breakfast', '🌅', 'breakfast'),
                    _buildMealSection('Lunch', '☀️', 'lunch'),
                    _buildMealSection('Dinner', '🌆', 'dinner'),
                    _buildMealSection('Snacks', '🍿', 'snack'),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCalorieCard(int remaining) {
    final progress = (_caloriesEaten / (_calorieGoal > 0 ? _calorieGoal : 1)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Ring Progress
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${remaining < 0 ? 0 : remaining}',
                        style: AppStyles.text24Px.poppins.w800.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'kcal left',
                        style: AppStyles.text10Px.poppins.w400.copyWith(
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Stats column
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow('Base Goal', '$_calorieGoal kcal', Colors.white70),
                  const SizedBox(height: 8),
                  _buildStatRow('Food Eaten', '$_caloriesEaten kcal', const Color(0xFF10B981)),
                  const SizedBox(height: 8),
                  _buildStatRow('Exercise', '$_caloriesBurned kcal', const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.text12Px.poppins.w400.copyWith(
            color: const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppStyles.text14Px.poppins.w700.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildMacrosCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Macronutrients',
            style: AppStyles.text16Px.poppins.w700.copyWith(
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMacroBar('Protein', _proteinGrams, 120, const Color(0xFF6366F1)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroBar('Carbs', _carbsGrams, 250, const Color(0xFF10B981)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMacroBar('Fat', _fatGrams, 65, const Color(0xFFF59E0B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String name, double val, double maxVal, Color color) {
    final pct = (val / (maxVal > 0 ? maxVal : 1)).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: AppStyles.text12Px.poppins.w600.copyWith(
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: color.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${val.toStringAsFixed(0)}g / ${maxVal.toStringAsFixed(0)}g',
          style: AppStyles.text10Px.poppins.w400.copyWith(
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildWaterCard() {
    final pct = (_waterMl / (_waterGoalMl > 0 ? _waterGoalMl : 1)).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water Tracker',
                  style: AppStyles.text14Px.poppins.w700.copyWith(
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_waterMl / $_waterGoalMl ml (${(pct * 100).toInt()}%)',
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: const Color(0xFF1E40AF),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _addWater(250),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('+ 250ml'),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection(String title, String emoji, String mealTypeKey) {
    final filteredLogs = _mealLogs.where((m) {
      final typeStr = (m['meal_type'] as String? ?? '').toLowerCase();
      if (mealTypeKey == 'snack') {
        return typeStr.contains('snack');
      }
      return typeStr.contains(mealTypeKey);
    }).toList();

    int totalMealCals = 0;
    for (var m in filteredLogs) {
      totalMealCals += _parseInt(m['calories']);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: filteredLogs.isNotEmpty,
        shape: Border.all(color: Colors.transparent),
        leading: Text(emoji, style: const TextStyle(fontSize: 22)),
        title: Text(
          title,
          style: AppStyles.text14Px.poppins.w600.copyWith(
            color: const Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          '$totalMealCals kcal',
          style: AppStyles.text12Px.poppins.w500.copyWith(
            color: const Color(0xFF10B981),
          ),
        ),
        children: [
          if (filteredLogs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No food logged for $title yet.',
                style: AppStyles.text12Px.poppins.w400.copyWith(
                  color: const Color(0xFF94A3B8),
                ),
              ),
            )
          else
            ...filteredLogs.map((item) {
              final foodName = item['food_name'] as String? ?? 'Food';
              final cals = _parseInt(item['calories']);
              final qty = item['servings'] ?? item['quantity'] ?? 1;
              final unit = item['serving_unit'] ?? '100g';

              return ListTile(
                dense: true,
                title: Text(
                  foodName,
                  style: AppStyles.text14Px.poppins.w500.copyWith(
                    color: const Color(0xFF334155),
                  ),
                ),
                subtitle: Text(
                  '$qty $unit',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                trailing: Text(
                  '$cals kcal',
                  style: AppStyles.text12Px.poppins.w600.copyWith(
                    color: const Color(0xFF1E293B),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
