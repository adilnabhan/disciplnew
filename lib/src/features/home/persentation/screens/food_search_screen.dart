import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';

class FoodSearchScreen extends StatefulWidget {
  final String initialMeal;
  final DateTime? targetDate;

  const FoodSearchScreen({
    super.key,
    this.initialMeal = 'lunch',
    this.targetDate,
  });

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  String _selectedCategoryKey = 'all';
  late String _selectedMeal;
  late DateTime _targetDate;
  bool _isLoading = false;

  final List<Map<String, String>> _categories = [
    {'key': 'all', 'label': 'All Foods'},
    {'key': 'kerala', 'label': 'Kerala Cuisine 🌴'},
    {'key': 'south_indian', 'label': 'South Indian 🍛'},
    {'key': 'north_indian', 'label': 'North Indian 🥘'},
    {'key': 'rice_grains', 'label': 'Rice & Grains 🍚'},
    {'key': 'curries_dals', 'label': 'Curries & Dals 🍲'},
    {'key': 'seafood', 'label': 'Fish & Seafood 🐟'},
    {'key': 'poultry_meat', 'label': 'Poultry & Meat 🍗'},
    {'key': 'vegetables', 'label': 'Vegetables 🥦'},
    {'key': 'fruits', 'label': 'Fruits 🍎'},
    {'key': 'snacks_street', 'label': 'Snacks & Street 🥨'},
    {'key': 'beverages', 'label': 'Beverages & Juices 🥤'},
    {'key': 'nuts_seeds', 'label': 'Nuts & Seeds 🥜'},
    {'key': 'sweets_desserts', 'label': 'Sweets & Desserts 🍨'},
    {'key': 'international', 'label': 'International 🌎'},
  ];

  List<Map<String, dynamic>> _foodItems = [];

  @override
  void initState() {
    super.initState();
    _selectedMeal = widget.initialMeal.toLowerCase();
    _targetDate = widget.targetDate ?? DateTime.now();
    _searchFoods('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchFoods(query);
    });
  }

  Future<void> _searchFoods(String query) async {
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> params = {
        'limit': 100,
      };
      if (query.trim().isNotEmpty) {
        params['q'] = query.trim();
      }
      if (_selectedCategoryKey != 'all') {
        params['category'] = _selectedCategoryKey;
      }

      final res = await DioClient().dio.get(
        ApiUris.foodSearch,
        queryParameters: params,
      );

      if (res.statusCode == 200 && res.data != null) {
        final List results = res.data['results'] ?? res.data['data'] ?? [];
        if (results.isNotEmpty) {
          setState(() {
            _foodItems = results.map<Map<String, dynamic>>((item) {
              return {
                'id': item['id'] ?? 0,
                'name': item['name'] ?? 'Food',
                'malayalam_name': item['malayalam_name'] ?? '',
                'english_name': item['english_name'] ?? '',
                'calories': _toInt(item['calories'] ?? 100),
                'protein': _toDouble(item['protein'] ?? 0.0),
                'carbs': _toDouble(item['carbs'] ?? 0.0),
                'fat': _toDouble(item['fat'] ?? 0.0),
                'fiber': _toDouble(item['fiber'] ?? 0.0),
                'category': item['category'] ?? 'kerala',
                'serving_size': item['serving_size'] ?? '100g',
                'units': item['units'] ?? ['100g', '1 Portion', '1 Plate'],
              };
            }).toList();
          });
        } else {
          setState(() => _foodItems = []);
        }
      }
    } catch (e) {
      debugPrint("Food search error: $e");
    }
    if (mounted) setState(() => _isLoading = false);
  }

  int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is double) return val.round();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  double _toDouble(dynamic val) {
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  void _showFoodLogModal(Map<String, dynamic> food) {
    double servings = 1.0;
    String selectedMealType = _selectedMeal;
    final int baseCals = food['calories'] as int;
    final double baseProtein = food['protein'] as double;
    final double baseCarbs = food['carbs'] as double;
    final double baseFat = food['fat'] as double;
    final String foodName = food['name'] as String;
    final String servingSize = food['serving_size'] as String;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141420),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final int calcCals = (baseCals * servings).round();
            final double calcProt = baseProtein * servings;
            final double calcCarbs = baseCarbs * servings;
            final double calcFat = baseFat * servings;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              foodName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Base: $servingSize • $baseCals kcal',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white60),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Calculated Macro Snapshot Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1424),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroSnapshotItem('CALORIES', '$calcCals', 'kcal', CyberWorkoutTheme.crimsonRed),
                        _buildMacroSnapshotItem('PROTEIN', calcProt.toStringAsFixed(1), 'g', const Color(0xFFFF334B)),
                        _buildMacroSnapshotItem('CARBS', calcCarbs.toStringAsFixed(1), 'g', const Color(0xFFFFAA00)),
                        _buildMacroSnapshotItem('FAT', calcFat.toStringAsFixed(1), 'g', const Color(0xFF00D2FF)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Servings Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Portion Multiplier',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Row(
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(backgroundColor: const Color(0xFF222230)),
                            icon: const Icon(Icons.remove_rounded, color: Colors.white),
                            onPressed: () {
                              if (servings > 0.5) {
                                setModalState(() => servings -= 0.5);
                              }
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161622),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${servings}x',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ),
                          IconButton(
                            style: IconButton.styleFrom(backgroundColor: const Color(0xFF222230)),
                            icon: const Icon(Icons.add_rounded, color: Colors.white),
                            onPressed: () {
                              if (servings < 10.0) {
                                setModalState(() => servings += 0.5);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Meal Type Selector
                  const Text(
                    'Log to Meal',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildMealPill('breakfast', 'Breakfast', selectedMealType, (m) => setModalState(() => selectedMealType = m)),
                      const SizedBox(width: 8),
                      _buildMealPill('lunch', 'Lunch', selectedMealType, (m) => setModalState(() => selectedMealType = m)),
                      const SizedBox(width: 8),
                      _buildMealPill('dinner', 'Dinner', selectedMealType, (m) => setModalState(() => selectedMealType = m)),
                      const SizedBox(width: 8),
                      _buildMealPill('snack', 'Snack', selectedMealType, (m) => setModalState(() => selectedMealType = m)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CyberWorkoutTheme.crimsonRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        shadowColor: CyberWorkoutTheme.crimsonRed.withOpacity(0.5),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _logMealItem(food['id'] as int, selectedMealType, servings);
                      },
                      child: Text(
                        'LOG $calcCals KCAL TO ${selectedMealType.toUpperCase()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMacroSnapshotItem(String label, String val, String unit, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        Text(unit, style: const TextStyle(color: Colors.white38, fontSize: 9)),
      ],
    );
  }

  Widget _buildMealPill(String key, String label, String currentSelected, Function(String) onSelect) {
    final bool isSelected = currentSelected == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? CyberWorkoutTheme.crimsonRed : const Color(0xFF1C1C28),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? CyberWorkoutTheme.crimsonRed : Colors.white12,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logMealItem(int foodId, String mealType, double servings) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_targetDate);
      final res = await DioClient().dio.post(
        ApiUris.foodLog,
        data: {
          'food_id': foodId,
          'meal_type': mealType,
          'servings': servings,
          'logged_at': dateStr,
        },
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Food logged to ${mealType.toUpperCase()}!', style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: const Color(0xFF00E676),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not log food item'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101018),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '1,000+ Food Database',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF101018),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search food, e.g. Appam, Chicken, Sadya, Oats...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: CyberWorkoutTheme.crimsonRed, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Colors.white60, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _searchFoods('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF161622),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Categories Horizontal List
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final bool isSelected = _selectedCategoryKey == cat['key'];

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategoryKey = cat['key']!);
                    _searchFoods(_searchController.text);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? CyberWorkoutTheme.crimsonRed : const Color(0xFF141420),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? CyberWorkoutTheme.crimsonRed : Colors.white10,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        cat['label']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white60,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // Food List Roster
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: CyberWorkoutTheme.crimsonRed),
                  )
                : _foodItems.isEmpty
                    ? const Center(
                        child: Text('No foods found matching your search', style: TextStyle(color: Colors.white38)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _foodItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final food = _foodItems[idx];
                          final name = food['name'] as String;
                          final cals = food['calories'] as int;
                          final prot = food['protein'] as double;
                          final carbs = food['carbs'] as double;
                          final fat = food['fat'] as double;
                          final servingSize = food['serving_size'] as String;

                          return GestureDetector(
                            onTap: () => _showFoodLogModal(food),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141420),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.06)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$servingSize • ${prot.toStringAsFixed(1)}g P • ${carbs.toStringAsFixed(1)}g C • ${fat.toStringAsFixed(1)}g F',
                                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: CyberWorkoutTheme.crimsonRed.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$cals kcal',
                                          style: const TextStyle(
                                            color: CyberWorkoutTheme.crimsonRed,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.add_circle_rounded, color: CyberWorkoutTheme.crimsonRed, size: 22),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
