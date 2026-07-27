import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final Dio _dio = DioClient().dio;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  List<dynamic> _searchResults = [];
  String _selectedCategory = 'All';
  String _selectedMealType = 'lunch';

  final List<String> _categories = [
    'All',
    'Kerala',
    'South Indian',
    'North Indian',
    'Meat & Seafood',
    'Vegetables',
    'Fruits',
    'Snacks',
  ];

  final Map<String, String> _mealTypes = {
    'breakfast': '🌅 Breakfast',
    'lunch': '☀️ Lunch',
    'dinner': '🌙 Dinner',
    'snack': '🍿 Snack',
  };

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
    _performSearch('all');
  }

  Future<void> _uploadExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;

        setState(() {
          _isLoading = true;
        });

        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(filePath, filename: fileName),
        });

        final response = await _dio.post<dynamic>(
          ApiUris.foodBulkUpload,
          data: formData,
          options: Options(headers: {'X-Platform': platformSource}).token,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          if (response.statusCode == 200) {
            final data = response.data as Map<String, dynamic>?;
            final created = data?['created'] ?? 0;
            final updated = data?['updated'] ?? 0;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Excel Imported! Created: $created, Updated: $updated foods.'),
                backgroundColor: const Color(0xFF10B981),
              ),
            );
            _performSearch('all');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import Excel: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _dio.get<dynamic>(
        ApiUris.foodSearch,
        queryParameters: {
          'q': query,
          'category': _selectedCategory == 'All' ? null : _selectedCategory,
        },
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (mounted) {
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          final results = data['results'] as List<dynamic>? ?? [];
          setState(() {
            _searchResults = results;
            _isLoading = false;
          });
        } else {
          setState(() {
            _searchResults = [];
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logFood(Map<String, dynamic> food, String servingUnit, double quantity) async {
    try {
      final foodId = food['id'] ?? food['name'];
      final cals = _parseInt(food['calories']);
      final prot = _parseDouble(food['protein']);
      final carb = _parseDouble(food['carbs']);
      final fat = _parseDouble(food['fat']);

      await _dio.post<dynamic>(
        ApiUris.foodLog,
        data: {
          'food': foodId,
          'food_name': food['name'] ?? 'Food',
          'calories': (cals * quantity).toInt(),
          'protein': prot * quantity,
          'carbs': carb * quantity,
          'fat': fat * quantity,
          'meal_type': _selectedMealType,
          'serving_unit': servingUnit,
          'quantity': quantity,
        },
        options: Options(headers: {'X-Platform': platformSource}).token,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${food['name']} logged to ${_selectedMealType.toUpperCase()}!'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log ${food['name']}. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddCustomFoodSheet() {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '+ Add Custom Food to History',
                style: AppStyles.text18Px.poppins.w700.copyWith(
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Food Name (e.g. Oats Pancake)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Calories (kcal)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: proteinController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Protein (g)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: carbsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Carbs (g)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: fatController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fat (g)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final customFood = {
                      'id': DateTime.now().millisecondsSinceEpoch,
                      'name': nameController.text.trim().isEmpty ? 'Custom Food' : nameController.text.trim(),
                      'calories': int.tryParse(caloriesController.text) ?? 200,
                      'protein': double.tryParse(proteinController.text) ?? 10.0,
                      'carbs': double.tryParse(carbsController.text) ?? 25.0,
                      'fat': double.tryParse(fatController.text) ?? 5.0,
                    };
                    Navigator.pop(ctx);
                    _logFood(customFood, '1 Serving', 1.0);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Save & Log Food',
                    style: AppStyles.text16Px.poppins.w700.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFoodDetailBottomSheet(Map<String, dynamic> food) {
    String selectedUnit = '100g';
    double quantity = 1.0;
    final int baseCals = _parseInt(food['calories']);
    final double prot = _parseDouble(food['protein']);
    final double carb = _parseDouble(food['carbs']);
    final double fat = _parseDouble(food['fat']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            final calculatedCals = (baseCals * quantity).toInt();

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
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    food['name'] as String? ?? 'Food',
                    style: AppStyles.text18Px.poppins.w700.copyWith(
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  if (food['malayalam_name'] != null &&
                      (food['malayalam_name'] as String).isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      food['malayalam_name'] as String,
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNutrientBadge('Calories', '$calculatedCals kcal', const Color(0xFF10B981)),
                      _buildNutrientBadge('Protein', '${(prot * quantity).toStringAsFixed(1)}g', const Color(0xFF3B82F6)),
                      _buildNutrientBadge('Carbs', '${(carb * quantity).toStringAsFixed(1)}g', const Color(0xFFF59E0B)),
                      _buildNutrientBadge('Fat', '${(fat * quantity).toStringAsFixed(1)}g', const Color(0xFFEF4444)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Serving Size',
                              style: AppStyles.text12Px.poppins.w600.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<String>(
                                value: selectedUnit,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: ['100g', '1 Portion', '1 Bowl', '1 Piece', '1 Plate'].map((u) {
                                  return DropdownMenuItem(
                                    value: u,
                                    child: Text(u, style: AppStyles.text14Px.poppins.w500),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setBottomSheetState(() {
                                      selectedUnit = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quantity',
                            style: AppStyles.text12Px.poppins.w600.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF64748B)),
                                onPressed: () {
                                  if (quantity > 0.5) {
                                    setBottomSheetState(() {
                                      quantity -= 0.5;
                                    });
                                  }
                                },
                              ),
                              Text(
                                quantity.toStringAsFixed(1),
                                style: AppStyles.text16Px.poppins.w700,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                                onPressed: () {
                                  setBottomSheetState(() {
                                    quantity += 0.5;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _logFood(food, selectedUnit, quantity);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Log Food ($calculatedCals kcal)',
                        style: AppStyles.text16Px.poppins.w700.copyWith(
                          color: Colors.white,
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

  Widget _buildNutrientBadge(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppStyles.text14Px.poppins.w700.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppStyles.text10Px.poppins.w400.copyWith(color: const Color(0xFF64748B)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search Foods (1000+ Items)',
          style: AppStyles.text18Px.poppins.w700.copyWith(
            color: const Color(0xFF1E293B),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    _performSearch(val.trim());
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Kerala & Indian foods (e.g. Puttu, Dosa)...',
                    hintStyle: AppStyles.text12Px.poppins.w400.copyWith(
                      color: const Color(0xFF94A3B8),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Log to:',
                          style: AppStyles.text12Px.poppins.w600.copyWith(
                            color: const Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(width: 4),
                        DropdownButton<String>(
                          value: _selectedMealType,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF10B981), size: 18),
                          items: _mealTypes.entries.map((e) {
                            return DropdownMenuItem(
                              value: e.key,
                              child: Text(
                                e.value,
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedMealType = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: _uploadExcelFile,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.upload_file, size: 15, color: Color(0xFF3B82F6)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Import Excel',
                                      style: AppStyles.text12Px.poppins.w600.copyWith(
                                        color: const Color(0xFF3B82F6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: _showAddCustomFoodSheet,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(Icons.add, size: 15, color: Color(0xFF10B981)),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Custom',
                                      style: AppStyles.text12Px.poppins.w600.copyWith(
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                            _performSearch(_searchController.text.trim());
                          },
                          selectedColor: const Color(0xFF10B981),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
                : _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.restaurant_menu_rounded, size: 48, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 12),
                            Text(
                              'No foods found',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final food = _searchResults[index] as Map<String, dynamic>;
                          final name = food['name'] as String? ?? 'Food';
                          final malName = food['malayalam_name'] as String? ?? '';
                          final cals = _parseInt(food['calories']);
                          final prot = _parseDouble(food['protein']);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
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
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onTap: () => _showFoodDetailBottomSheet(food),
                              title: Text(
                                name,
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (malName.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      malName,
                                      style: AppStyles.text12Px.poppins.w500.copyWith(
                                        color: const Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    '$cals kcal per 100g • ${prot.toStringAsFixed(1)}g Protein',
                                    style: AppStyles.text12Px.poppins.w400.copyWith(
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
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
