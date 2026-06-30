import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/workout/domain/repositories/workout_repository.dart';

// ============================================================================
// 1. HEALTH DASHBOARD WIDGET (SECTION RENDERED ON HOME SCREEN)
// ============================================================================

class HealthDashboardSection extends StatefulWidget {
  const HealthDashboardSection({super.key});

  @override
  State<HealthDashboardSection> createState() => _HealthDashboardSectionState();
}

class _HealthDashboardSectionState extends State<HealthDashboardSection> {
  bool _isLoading = true;
  double _bmr = 1500;
  double _tdee = 2000;
  double _targetCalories = 2000;
  double _consumedCalories = 0;
  double _burnedCalories = 0;
  double _remainingCalories = 2000;
  int _waterMl = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      final response = await DioClient().dio.get<dynamic>(ApiUris.calorieSummary);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _bmr = (data['bmr'] as num?)?.toDouble() ?? 1500;
          _tdee = (data['tdee'] as num?)?.toDouble() ?? 2000;
          _targetCalories = (data['target_calories'] as num?)?.toDouble() ?? 2000;
          _consumedCalories = (data['consumed_calories'] as num?)?.toDouble() ?? 0;
          _burnedCalories = (data['burned_calories'] as num?)?.toDouble() ?? 0;
          _remainingCalories = (data['remaining_calories'] as num?)?.toDouble() ?? 2000;
          _waterMl = (data['water_ml'] as num?)?.toInt() ?? 0;
          _streak = (data['streak'] as num?)?.toInt() ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final double progress = _targetCalories > 0 ? (_consumedCalories / _targetCalories).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Fitness Dashboard',
                style: AppStyles.text16Px.poppins.w600.dark,
              ),
              if (_streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$_streak Day Streak',
                        style: AppStyles.text12Px.poppins.w600.copyWith(color: Colors.orange[800]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Calorie Row (Circular Indicator + Stats)
          Row(
            children: [
              CircularPercentIndicator(
                radius: 45.0,
                lineWidth: 8.0,
                percent: progress,
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_remainingCalories.round()}',
                      style: AppStyles.text16Px.poppins.w700.dark,
                    ),
                    Text(
                      'Left',
                      style: AppStyles.text10Px.poppins.textGrey,
                    ),
                  ],
                ),
                progressColor: AppColors.primary,
                backgroundColor: const Color(0xFFF1F1F1),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow('Target Calories', '${_targetCalories.round()} kcal', Icons.flag_outlined, Colors.blue),
                    const SizedBox(height: 8),
                    _buildStatRow('Consumed', '${_consumedCalories.round()} kcal', Icons.restaurant, Colors.green),
                    const SizedBox(height: 8),
                    _buildStatRow('Burned', '${_burnedCalories.round()} kcal', Icons.local_fire_department_outlined, Colors.red),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          // Water Log Status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Water Intakes: $_waterMl ml',
                      style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.blue[900]),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                  onPressed: () => _showWaterDialog(context),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Quick Action Icons
          Text(
            'Quick Actions',
            style: AppStyles.text14Px.poppins.w600.dark,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(context, 'Food Log', Icons.restaurant, Colors.orange, const FoodLoggingScreen()),
              _buildActionItem(context, 'Weight', Icons.scale, Colors.teal, const WeightMeasurementsScreen()),
              _buildActionItem(context, 'Social', Icons.people, Colors.indigo, const CommunityFeedScreen()),
              _buildActionItem(context, 'Badges', Icons.emoji_events, Colors.amber, const AchievementsScreen()),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: AppStyles.text12Px.poppins.w500.textGrey),
          ],
        ),
        Text(value, style: AppStyles.text12Px.poppins.w600.dark),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String label, IconData icon, Color color, Widget screen) {
    return InkWell(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute<dynamic>(builder: (_) => screen));
        _fetchSummary();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppStyles.text12Px.poppins.w500.dark,
          )
        ],
      ),
    );
  }

  void _showWaterDialog(BuildContext context) {
    showDialog<dynamic>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Log Water Intake', style: AppStyles.text16Px.poppins.w600.dark),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.local_drink, color: Colors.blue),
                title: Text('Glass of Water (250 ml)', style: AppStyles.text14Px.poppins.dark),
                onTap: () => _logWater(context, 250),
              ),
              ListTile(
                leading: const Icon(Icons.local_cafe, color: Colors.blue),
                title: Text('Bottle of Water (500 ml)', style: AppStyles.text14Px.poppins.dark),
                onTap: () => _logWater(context, 500),
              ),
              ListTile(
                leading: const Icon(Icons.wine_bar, color: Colors.blue),
                title: Text('Large Bottle (1000 ml)', style: AppStyles.text14Px.poppins.dark),
                onTap: () => _logWater(context, 1000),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logWater(BuildContext context, int amount) async {
    Navigator.pop(context);
    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.waterLog,
        data: {'amount_ml': amount},
      );
      if (response.statusCode == 201) {
        _fetchSummary();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged $amount ml of water successfully!')),
        );
      }
    } catch (e) {
      // Handle error
    }
  }
}

// ============================================================================
// 2. FOOD LOGGING & MEAL TRACKING SCREEN
// ============================================================================

class FoodLoggingScreen extends StatefulWidget {
  const FoodLoggingScreen({super.key});

  @override
  State<FoodLoggingScreen> createState() => _FoodLoggingScreenState();
}

class _FoodLoggingScreenState extends State<FoodLoggingScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _todayLogs = [];
  bool _isLoading = false;
  String _selectedMealType = 'breakfast';

  @override
  void initState() {
    super.initState();
    _fetchTodayLogs();
  }

  Future<void> _fetchTodayLogs() async {
    try {
      final response = await DioClient().dio.get<dynamic>(ApiUris.foodLog);
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _todayLogs = response.data as List<dynamic>;
        });
      }
    } catch (e) {
      // error
    }
  }

  Future<void> _searchFood(String q) async {
    if (q.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await DioClient().dio.get<dynamic>('${ApiUris.foodList}?q=$q');
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _searchResults = response.data as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logFoodItem(int foodId, double servings) async {
    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.foodLog,
        data: {
          'food': foodId,
          'meal_type': _selectedMealType,
          'servings': servings,
        },
      );
      if (response.statusCode == 201) {
        _searchController.clear();
        _searchResults = [];
        _fetchTodayLogs();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food logged successfully!')),
        );
      }
    } catch (e) {
      // error
    }
  }

  Future<void> _deleteFoodLog(int logId) async {
    try {
      final response = await DioClient().dio.delete<dynamic>('${ApiUris.foodLog}$logId/');
      if (response.statusCode == 204) {
        _fetchTodayLogs();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food log removed.')),
        );
      }
    } catch (e) {
      // error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: Text('Food & Nutrition Log', style: AppStyles.text18Px.poppins.w600.dark),
      ),
      body: Column(
        children: [
          // Search Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMealTab('breakfast', 'Breakfast'),
                    _buildMealTab('lunch', 'Lunch'),
                    _buildMealTab('dinner', 'Dinner'),
                    _buildMealTab('snack', 'Snacks'),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search food (e.g. Apple, Chicken, Rice)...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color(0xffF5F5F5),
                  ),
                  onChanged: _searchFood,
                ),
              ],
            ),
          ),
          // Search results
          if (_searchResults.isNotEmpty || _isLoading)
            Expanded(
              flex: 2,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, idx) {
                        final item = _searchResults[idx] as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            title: Text(item['name']?.toString() ?? '', style: AppStyles.text14Px.poppins.w600.dark),
                            subtitle: Text('${item['calories']} kcal | Serv: ${item['serving_size']}', style: AppStyles.text12Px.poppins.textGrey),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle, color: AppColors.primary),
                              onPressed: () => _logFoodItem(item['id'] as int, 1.0),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          // Logged Foods Today
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Logged Today', style: AppStyles.text16Px.poppins.w600.dark),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _todayLogs.isEmpty
                        ? Center(child: Text('No food logged today.', style: AppStyles.text14Px.poppins.textGrey))
                        : ListView.builder(
                            itemCount: _todayLogs.length,
                            itemBuilder: (context, idx) {
                              final log = _todayLogs[idx] as Map<String, dynamic>;
                              final food = log['food_details'] as Map<String, dynamic>? ?? {};
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  title: Text(food['name']?.toString() ?? '', style: AppStyles.text14Px.poppins.w600.dark),
                                  subtitle: Text('${log['meal_type'].toString().toUpperCase()} - ${(double.parse(log['servings'].toString()) * double.parse(food['calories'].toString())).round()} kcal', style: AppStyles.text12Px.poppins.textGrey),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteFoodLog(log['id'] as int),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMealTab(String type, String label) {
    final bool isSelected = _selectedMealType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedMealType = type);
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }
}

// ============================================================================
// 3. WEIGHT & MEASUREMENTS SCREEN
// ============================================================================

class WeightMeasurementsScreen extends StatefulWidget {
  const WeightMeasurementsScreen({super.key});

  @override
  State<WeightMeasurementsScreen> createState() => _WeightMeasurementsScreenState();
}

class _WeightMeasurementsScreenState extends State<WeightMeasurementsScreen> {
  final TextEditingController _weightController = TextEditingController();
  List<dynamic> _weightHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeightHistory();
  }

  Future<void> _fetchWeightHistory() async {
    try {
      final response = await DioClient().dio.get<dynamic>(ApiUris.weightHistory);
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _weightHistory = response.data as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitWeight() async {
    final double? weight = double.tryParse(_weightController.text);
    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid weight in kg.')),
      );
      return;
    }

    try {
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.weightHistory,
        data: {'weight_kg': weight},
      );
      if (response.statusCode == 201) {
        _weightController.clear();
        _fetchWeightHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weight logged successfully!')),
        );
      }
    } catch (e) {
      // error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: Text('Weight & Body Progress', style: AppStyles.text18Px.poppins.w600.dark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Log card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Log Daily Weight', style: AppStyles.text14Px.poppins.w600.dark),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _weightController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  hintText: 'Weight in kg (e.g. 75.5)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _submitWeight,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Log Weight', style: TextStyle(color: Colors.white)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Weight History List
                  Text('Weight Logs', style: AppStyles.text16Px.poppins.w600.dark),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _weightHistory.length,
                    itemBuilder: (context, idx) {
                      final log = _weightHistory[idx] as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.scale, color: Colors.teal),
                          title: Text('${log['weight_kg']} kg', style: AppStyles.text14Px.poppins.w600.dark),
                          trailing: Text(log['logged_at']?.toString() ?? '', style: AppStyles.text12Px.poppins.textGrey),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
    );
  }
}

// ============================================================================
// 4. COMMUNITY / SOCIAL FEED SCREEN
// ============================================================================

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  List<dynamic> _posts = [];
  bool _isLoading = true;
  final TextEditingController _postController = TextEditingController();
  XFile? _selectedImage;
  Map<String, dynamic>? _todaysWorkout;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
    _fetchTodaysWorkout();
  }

  Future<void> _fetchFeed() async {
    try {
      final response = await DioClient().dio.get<dynamic>(ApiUris.communityFeed);
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _posts = response.data as List<dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchTodaysWorkout() async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await WorkoutRepository().getWorkoutLogForDate(date: dateStr);
      response.fold(
        (error) => null,
        (list) {
          if (list.isNotEmpty) {
            setState(() {
              _todaysWorkout = list.first as Map<String, dynamic>;
            });
          }
        },
      );
    } catch (_) {}
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _createPost() async {
    final caption = _postController.text.trim();
    if (caption.isEmpty && _selectedImage == null) return;
    try {
      final formData = FormData.fromMap({
        'post_type': 'custom',
        'caption': caption,
      });
      if (_selectedImage != null) {
        formData.files.add(
          MapEntry(
            'media_file',
            await MultipartFile.fromFile(_selectedImage!.path, filename: _selectedImage!.name),
          ),
        );
      }
      final response = await DioClient().dio.post<dynamic>(
        ApiUris.communityPosts,
        data: formData,
      );
      if (response.statusCode == 201) {
        _postController.clear();
        setState(() {
          _selectedImage = null;
        });
        _fetchFeed();
      }
    } catch (e) {
      // error
    }
  }

  Future<void> _likePost(int postId) async {
    try {
      final response = await DioClient().dio.post<dynamic>('${ApiUris.communityPosts}$postId/like/');
      if (response.statusCode == 200) {
        _fetchFeed();
      }
    } catch (e) {
      // error
    }
  }

  Future<void> _commentPost(int postId, String commentText) async {
    try {
      final response = await DioClient().dio.post<dynamic>(
        '${ApiUris.communityPosts}$postId/comment/',
        data: {'comment_text': commentText},
      );
      if (response.statusCode == 201) {
        _fetchFeed();
      }
    } catch (e) {
      // error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: Text('Community Feed', style: AppStyles.text18Px.poppins.w600.dark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedImage != null) ...[
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_selectedImage!.path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImage = null),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _postController,
                              decoration: InputDecoration(
                                hintText: "What's on your mind? Share your workout progress...",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                            onPressed: _pickImage,
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: AppColors.primary),
                            onPressed: _createPost,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _posts.length,
                    itemBuilder: (context, idx) {
                      final post = _posts[idx] as Map<String, dynamic>;
                      final bool liked = post['has_liked'] as bool? ?? false;
                      final comments = post['comments'] as List<dynamic>? ?? [];
                      return Card(
                        margin: const EdgeInsets.all(12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                           padding: const EdgeInsets.all(12),
                           child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: Text(
                                      post['customer_name']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    post['customer_name']?.toString() ?? '',
                                    style: AppStyles.text14Px.poppins.w600.dark,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(post['caption']?.toString() ?? '', style: AppStyles.text14Px.poppins.dark),
                              if (post['media_url'] != null && post['media_url'].toString().isNotEmpty) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    post['media_url'].toString().startsWith('http')
                                        ? post['media_url'].toString()
                                        : '${ApiUris.base}${post['media_url']}',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 220,
                                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(liked ? Icons.favorite : Icons.favorite_border, color: liked ? Colors.red : Colors.grey),
                                    onPressed: () => _likePost(post['id'] as int),
                                  ),
                                  Text('${post['likes_count']} likes', style: AppStyles.text12Px.poppins.textGrey),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.chat_bubble_outline, color: Colors.grey, size: 20),
                                  const SizedBox(width: 6),
                                  Text('${post['comments_count']} comments', style: AppStyles.text12Px.poppins.textGrey),
                                ],
                              ),
                              if (comments.isNotEmpty) ...[
                                const Divider(),
                                ...comments.map((comment) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: RichText(
                                      text: TextSpan(
                                        style: DefaultTextStyle.of(context).style,
                                        children: [
                                          TextSpan(text: '${comment['customer_name']}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                                          TextSpan(text: comment['comment_text']?.toString() ?? ''),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ],
                              const SizedBox(height: 6),
                              TextField(
                                decoration: const InputDecoration(
                                  hintText: 'Add a comment...',
                                  isDense: true,
                                  border: UnderlineInputBorder(),
                                ),
                                onSubmitted: (text) => _commentPost(post['id'] as int, text),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
    );
  }
}

// ============================================================================
// 5. ACHIEVEMENTS & STREAKS SCREEN
// ============================================================================

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, dynamic> _points = {};
  List<dynamic> _earnedBadges = [];
  List<dynamic> _allBadges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAchievements();
  }

  Future<void> _fetchAchievements() async {
    try {
      final response = await DioClient().dio.get<dynamic>(ApiUris.achievements);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          _points = data['points'] as Map<String, dynamic>? ?? {};
          _earnedBadges = data['earned_badges'] as List<dynamic>? ?? [];
          _allBadges = data['all_badges'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int xp = _points['xp'] as int? ?? 0;
    final int coins = _points['coins'] as int? ?? 0;
    final int streak = _points['streak_days'] as int? ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: Text('Achievements & Badges', style: AppStyles.text18Px.poppins.w600.dark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // XP Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 30),
                            const SizedBox(height: 6),
                            Text('$xp XP', style: AppStyles.text16Px.poppins.w700.light),
                            Text('Experience Points', style: AppStyles.text10Px.poppins.light),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.monetization_on, color: Colors.amber, size: 30),
                            const SizedBox(height: 6),
                            Text('$coins Coins', style: AppStyles.text16Px.poppins.w700.light),
                            Text('Discipl Coins', style: AppStyles.text10Px.poppins.light),
                          ],
                        ),
                        Column(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orange, size: 30),
                            const SizedBox(height: 6),
                            Text('$streak Days', style: AppStyles.text16Px.poppins.w700.light),
                            Text('Active Streak', style: AppStyles.text10Px.poppins.light),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Badges List
                  Text('Badges Locker', style: AppStyles.text16Px.poppins.w600.dark),
                  const SizedBox(height: 12),
                  _allBadges.isEmpty
                      ? Center(child: Text('No badges configured.', style: AppStyles.text14Px.poppins.textGrey))
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _allBadges.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemBuilder: (context, idx) {
                            final badge = _allBadges[idx] as Map<String, dynamic>;
                            final bool isEarned = _earnedBadges.any((eb) => (eb['badge'] as int) == badge['id']);
                            return Opacity(
                              opacity: isEarned ? 1.0 : 0.4,
                              child: Card(
                                color: isEarned ? Colors.white : Colors.grey[200],
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.emoji_events, color: Colors.amber, size: 36),
                                      const SizedBox(height: 8),
                                      Text(badge['name']?.toString() ?? '', style: AppStyles.text12Px.poppins.w600.dark),
                                      const SizedBox(height: 4),
                                      Text(
                                        badge['description']?.toString() ?? '',
                                        style: AppStyles.text9Px.poppins.textGrey,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                ],
              ),
            ),
    );
  }
}

// ============================================================================
// 6. HEALTH & ANALYSIS REPORTS SCREEN
// ============================================================================

class HealthReportsScreen extends StatefulWidget {
  const HealthReportsScreen({super.key});

  @override
  State<HealthReportsScreen> createState() => _HealthReportsScreenState();
}

class _HealthReportsScreenState extends State<HealthReportsScreen> {
  Map<String, dynamic> _reportData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    try {
      final response = await DioClient().dio.get<dynamic>(ApiUris.dailyReport);
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _reportData = response.data as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportReport() async {
    final Uri url = Uri.parse(ApiUris.exportReport);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch report download URL.')),
        );
      }
    } catch (e) {
      // error
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bmi = (_reportData['current_bmi'] as num?)?.toDouble() ?? 0.0;
    final double bmr = (_reportData['current_bmr'] as num?)?.toDouble() ?? 0.0;
    final String category = _reportData['bmi_category']?.toString() ?? 'N/A';
    final String analysis = _reportData['bmi_analysis']?.toString() ?? 'Configure height/weight to calculate your body stats.';

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: Text('Body Analytics & BMR/BMI', style: AppStyles.text18Px.poppins.w600.dark),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Analysis Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Health Summary', style: AppStyles.text16Px.poppins.w600.dark),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('BMI Score', style: AppStyles.text12Px.poppins.textGrey),
                                const SizedBox(height: 4),
                                Text(bmi > 0 ? '$bmi' : 'N/A', style: AppStyles.text20Px.poppins.w700.dark),
                                const SizedBox(height: 4),
                                Text(category, style: TextStyle(color: Colors.teal[800], fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('BMR Rate', style: AppStyles.text12Px.poppins.textGrey),
                                const SizedBox(height: 4),
                                Text(bmr > 0 ? '${bmr.round()} kcal' : 'N/A', style: AppStyles.text20Px.poppins.w700.dark),
                                const SizedBox(height: 4),
                                const Text('Basal Metabolism', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Text(
                          'BMI Analysis & Advice:',
                          style: AppStyles.text12Px.poppins.w600.dark,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          analysis,
                          style: AppStyles.text12Px.poppins.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _exportReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[800],
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('Export Fitness Report (CSV)', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}
