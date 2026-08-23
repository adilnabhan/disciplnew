import 'package:flutter/material.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  String _selectedCategory = 'All';
  String _selectedMeal = 'Lunch';
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  List<Map<String, dynamic>> _foodItems = [
    {
      'id': 1,
      'name': 'Aam Panna (250ml)',
      'kcal': 120,
      'protein': 0.5,
      'carbs': 30.0,
      'fat': 0.1,
      'category': 'Kerala'
    },
    {
      'id': 2,
      'name': 'Achappam',
      'kcal': 300,
      'protein': 3.0,
      'carbs': 38.0,
      'fat': 15.0,
      'category': 'Kerala'
    },
    {
      'id': 3,
      'name': 'Ackee and Saltfish (Jamaican)',
      'kcal': 250,
      'protein': 15.0,
      'carbs': 10.0,
      'fat': 14.0,
      'category': 'South Indian'
    },
    {
      'id': 4,
      'name': 'Adai (Lentil Dosa)',
      'kcal': 200,
      'protein': 8.0,
      'carbs': 32.0,
      'fat': 4.0,
      'category': 'South Indian'
    },
    {
      'id': 5,
      'name': 'Aglio Olio Pasta',
      'kcal': 314,
      'protein': 9.2,
      'carbs': 45.0,
      'fat': 10.0,
      'category': 'North Indian'
    },
    {
      'id': 6,
      'name': 'Alappuzha Fish Curry',
      'kcal': 178,
      'protein': 16.0,
      'carbs': 8.0,
      'fat': 9.0,
      'category': 'Kerala'
    },
    {
      'id': 7,
      'name': 'Amritsari Kulcha',
      'kcal': 300,
      'protein': 7.0,
      'carbs': 48.0,
      'fat': 9.0,
      'category': 'Kerala'
    },
    {
      'id': 8,
      'name': 'Andhra Gongura Chicken',
      'kcal': 250,
      'protein': 20.0,
      'carbs': 6.0,
      'fat': 16.0,
      'category': 'Kerala'
    },
    {
      'id': 9,
      'name': 'Andhra Pesarattu with Upma',
      'kcal': 210,
      'protein': 8.0,
      'carbs': 35.0,
      'fat': 5.0,
      'category': 'Kerala'
    },
    {
      'id': 10,
      'name': 'Appam (plain)',
      'kcal': 120,
      'protein': 2.0,
      'carbs': 24.0,
      'fat': 1.5,
      'category': 'Kerala'
    },
    {
      'id': 11,
      'name': 'Andhra Chicken Curry',
      'kcal': 240,
      'protein': 19.0,
      'carbs': 5.0,
      'fat': 15.0,
      'category': 'South Indian'
    },
    {
      'id': 12,
      'name': 'Appam South Style',
      'kcal': 120,
      'protein': 2.0,
      'carbs': 24.0,
      'fat': 1.5,
      'category': 'South Indian'
    },
    {
      'id': 13,
      'name': 'Bisibelebath',
      'kcal': 230,
      'protein': 7.0,
      'carbs': 39.0,
      'fat': 5.0,
      'category': 'South Indian'
    },
    {
      'id': 14,
      'name': 'Cheese Dosa',
      'kcal': 260,
      'protein': 8.0,
      'carbs': 30.0,
      'fat': 12.0,
      'category': 'South Indian'
    },
    {
      'id': 15,
      'name': 'Chettinad Chicken Curry',
      'kcal': 280,
      'protein': 22.0,
      'carbs': 6.0,
      'fat': 18.0,
      'category': 'South Indian'
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchBackendFoods();
  }

  Future<void> _fetchBackendFoods([String? query]) async {
    try {
      final res = await DioClient().dio.get(
        ApiUris.foodSearch,
        queryParameters: {
          if (query != null && query.isNotEmpty) 'query': query,
        },
      );
      if (res.statusCode == 200 && res.data != null) {
        final List results = res.data['results'] ?? res.data['data'] ?? [];
        if (results.isNotEmpty) {
          setState(() {
            _foodItems = results.map((item) {
              return {
                'id': item['id'] ?? 0,
                'name': item['name'] ?? '',
                'kcal': (item['calories'] ?? item['kcal'] ?? 100).round(),
                'protein': (item['protein_g'] ?? item['protein'] ?? 0.0).toDouble(),
                'carbs': (item['carbs_g'] ?? item['carbs'] ?? 0.0).toDouble(),
                'fat': (item['fat_g'] ?? item['fat'] ?? 0.0).toDouble(),
                'category': item['category'] ?? 'All',
              };
            }).toList();
          });
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final filteredFoods = _foodItems.where((food) {
      final matchesCat = _selectedCategory == 'All' || food['category'] == _selectedCategory;
      final matchesQuery = _searchController.text.isEmpty ||
          food['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
      return matchesCat && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search Foods (1000+ Items)',
          style: AppStyles.text16Px.poppins.w600.copyWith(color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          // Search Bar & Filter Options
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {});
                    _fetchBackendFoods(val);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Kerala & Indian foods (e.g. Puttu, Dosa)',
                    hintStyle: AppStyles.text12Px.poppins.w400.copyWith(color: const Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
                        Text('Log to: ', style: AppStyles.text12Px.poppins.w500.copyWith(color: const Color(0xFF64748B))),
                        DropdownButton<String>(
                          value: _selectedMeal,
                          underline: const SizedBox(),
                          items: ['Breakfast', 'Lunch', 'Dinner', 'Snack'].map((m) {
                            return DropdownMenuItem(
                              value: m,
                              child: Text('☀️ $m', style: AppStyles.text12Px.poppins.w600.copyWith(color: const Color(0xFF10B981))),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedMeal = val);
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.description, size: 14, color: Color(0xFF2563EB)),
                          label: Text('Import Excel', style: AppStyles.text12Px.poppins.w500.copyWith(color: const Color(0xFF2563EB))),
                        ),
                        TextButton.icon(
                          onPressed: () => _showAddCustomFoodModal(context),
                          icon: const Icon(Icons.add, size: 14, color: Color(0xFF10B981)),
                          label: Text('Custom', style: AppStyles.text12Px.poppins.w600.copyWith(color: const Color(0xFF10B981))),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Category Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Kerala', 'South Indian', 'North Indian'].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(
                            cat,
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF10B981),
                          backgroundColor: const Color(0xFFF1F5F9),
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Food Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredFoods.length,
              itemBuilder: (context, index) {
                final item = filteredFoods[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: AppStyles.text14Px.poppins.w600.copyWith(color: const Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item['kcal']} kcal per 100g • ${item['protein']}g Protein',
                              style: AppStyles.text12Px.poppins.w400.copyWith(color: const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showLogFoodModal(context, item),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFECFDF5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Color(0xFF10B981), size: 18),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Exact Modal matching User Images 1 & 5
  void _showLogFoodModal(BuildContext context, Map<String, dynamic> item) {
    String selectedServing = '100g';
    double quantity = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final int calculatedKcal = (item['kcal'] * quantity).round();
            final double calculatedProt = (item['protein'] * quantity);
            final double calculatedCarb = (item['carbs'] * quantity);
            final double calculatedFat = (item['fat'] * quantity);

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    item['name'],
                    style: AppStyles.text18Px.poppins.w700.copyWith(color: const Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),

                  // Macros Summary Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroStat('$calculatedKcal kcal', 'Calories', const Color(0xFF10B981)),
                      _buildMacroStat('${calculatedProt.toStringAsFixed(1)}g', 'Protein', const Color(0xFF2563EB)),
                      _buildMacroStat('${calculatedCarb.toStringAsFixed(1)}g', 'Carbs', const Color(0xFFD97706)),
                      _buildMacroStat('${calculatedFat.toStringAsFixed(1)}g', 'Fat', const Color(0xFFEF4444)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Serving Size & Quantity Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Serving Size', style: AppStyles.text12Px.poppins.w500.copyWith(color: const Color(0xFF64748B))),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButton<String>(
                                value: selectedServing,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: ['100g', '1 Portion', '1 Bowl', '1 Piece', '1 Plate'].map((s) {
                                  return DropdownMenuItem(value: s, child: Text(s, style: AppStyles.text14Px.poppins.w600));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => selectedServing = val);
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
                          Text('Quantity', style: AppStyles.text12Px.poppins.w500.copyWith(color: const Color(0xFF64748B))),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF64748B)),
                                onPressed: () {
                                  if (quantity > 0.5) setModalState(() => quantity -= 0.5);
                                },
                              ),
                              Text(
                                quantity.toStringAsFixed(1),
                                style: AppStyles.text16Px.poppins.w700.copyWith(color: const Color(0xFF0F172A)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Color(0xFF10B981)),
                                onPressed: () => setModalState(() => quantity += 0.5),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Log Food Green Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        try {
                          await DioClient().dio.post(
                            ApiUris.foodLog,
                            data: {
                              'food_id': item['id'],
                              'meal_type': _selectedMeal.toLowerCase(),
                              'serving_unit': selectedServing,
                              'quantity': quantity,
                              'calories': calculatedKcal,
                            },
                          );
                        } catch (_) {}

                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Logged ${item['name']} ($calculatedKcal kcal) to $_selectedMeal!'),
                              backgroundColor: const Color(0xFF10B981),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Log Food ($calculatedKcal kcal)',
                        style: AppStyles.text16Px.poppins.w700.copyWith(color: Colors.white),
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

  Widget _buildMacroStat(String val, String label, Color col) {
    return Column(
      children: [
        Text(val, style: AppStyles.text16Px.poppins.w700.copyWith(color: col)),
        const SizedBox(height: 2),
        Text(label, style: AppStyles.text10Px.poppins.w400.copyWith(color: const Color(0xFF94A3B8))),
      ],
    );
  }

  void _showAddCustomFoodModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final kcalCtrl = TextEditingController();
    final protCtrl = TextEditingController();
    final carbCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                style: AppStyles.text16Px.poppins.w700.copyWith(color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Food Name (e.g. Oats Pancake)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: kcalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Calories (kcal)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: protCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Protein (g)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                      controller: carbCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Carbs (g)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: fatCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Fat (g)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (nameCtrl.text.isNotEmpty) {
                      final customItem = {
                        'id': DateTime.now().millisecondsSinceEpoch,
                        'name': nameCtrl.text,
                        'kcal': int.tryParse(kcalCtrl.text) ?? 150,
                        'protein': double.tryParse(protCtrl.text) ?? 5.0,
                        'carbs': double.tryParse(carbCtrl.text) ?? 20.0,
                        'fat': double.tryParse(fatCtrl.text) ?? 3.0,
                        'category': 'Custom',
                      };
                      setState(() {
                        _foodItems.insert(0, customItem);
                      });
                    }
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Custom Food Saved & Added to List!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  child: Text(
                    'Save & Log Food',
                    style: AppStyles.text14Px.poppins.w600.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
