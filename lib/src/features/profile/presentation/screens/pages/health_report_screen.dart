import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class HealthReportScreen extends StatefulWidget {
  const HealthReportScreen({super.key});

  @override
  State<HealthReportScreen> createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends State<HealthReportScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = CustomerDetailsRepository();
    final result = await repo.getHealthReport();

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.msg;
        });
      },
      (data) {
        setState(() {
          _isLoading = false;
          _reportData = data;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF444444),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Health Report',
          style: AppStyles.text18Px.poppins.w600,
        ),
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primary),
              onPressed: _fetchReport,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Failed to load health report',
                style: AppStyles.text16Px.poppins.w600.dark,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: AppStyles.text14Px.poppins.w400.textGrey,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_reportData == null) {
      return const Center(child: Text('No data available'));
    }

    final personalInfo = _reportData!['personal_info'] as Map<String, dynamic>? ?? {};
    final measurements = _reportData!['measurements'] as Map<String, dynamic>? ?? {};
    final calculations = _reportData!['calculations'] as Map<String, dynamic>? ?? {};
    final goals = _reportData!['goals'] as Map<String, dynamic>? ?? {};
    final medicalInfo = _reportData!['medical_info'] as Map<String, dynamic>? ?? {};

    return RefreshIndicator(
      onRefresh: _fetchReport,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          _buildCalculationsSection(calculations),
          const SizedBox(height: 20),
          _buildPersonalInfoCard(personalInfo, goals),
          const SizedBox(height: 16),
          _buildMeasurementsCard(measurements, personalInfo),
          const SizedBox(height: 16),
          _buildMedicalInfoCard(medicalInfo),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Calculated Results Section ──
  Widget _buildCalculationsSection(Map<String, dynamic> calculations) {
    final bmi = calculations['bmi'] as Map<String, dynamic>? ?? {};
    final bmr = calculations['bmr'] as Map<String, dynamic>? ?? {};
    final tdee = calculations['tdee'] as Map<String, dynamic>? ?? {};
    final maintenance = calculations['maintenance_calories'] as Map<String, dynamic>? ?? {};
    final bodyFat = calculations['body_fat'] as Map<String, dynamic>? ?? {};
    final whr = calculations['whr'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calculated Results',
          style: AppStyles.text16Px.poppins.w600.copyWith(color: AppColors.textDark),
        ),
        const SizedBox(height: 12),

        // BMI Card
        _buildBmiCard(bmi),
        const SizedBox(height: 12),

        // Grid of BMR, TDEE, Maintenance, Body Fat %, WHR
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildMetricCard(
              title: 'BMR',
              value: bmr['value'] != null ? '${bmr['value']}' : 'N/A',
              unit: 'kcal/day',
              subtitle: 'Basal Metabolic Rate',
              icon: Icons.flash_on,
              color: Colors.orange,
            ),
            _buildMetricCard(
              title: 'TDEE',
              value: tdee['value'] != null ? '${tdee['value']}' : 'N/A',
              unit: 'kcal/day',
              subtitle: 'Daily Expenditure',
              icon: Icons.local_fire_department,
              color: Colors.red,
            ),
            _buildMetricCard(
              title: 'Maintenance',
              value: maintenance['value'] != null ? '${maintenance['value']}' : 'N/A',
              unit: 'kcal/day',
              subtitle: 'Calorie Budget',
              icon: Icons.restaurant,
              color: Colors.blue,
            ),
            _buildMetricCard(
              title: 'Body Fat %',
              value: bodyFat['value'] != null ? '${bodyFat['value']}%' : 'N/A',
              unit: bodyFat['category'] ?? 'U.S. Navy Method',
              subtitle: 'Body Composition',
              icon: Icons.accessibility_new,
              color: Colors.purple,
              badgeColor: _getBodyFatCategoryColor(bodyFat['category']),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // WHR Card
        _buildWhrCard(whr),
      ],
    );
  }

  Widget _buildBmiCard(Map<String, dynamic> bmi) {
    final value = bmi['value'];
    final category = bmi['category'] ?? 'N/A';
    final categoryLower = category.toString().toLowerCase();

    Color bmiColor = Colors.green;
    if (categoryLower.contains('underweight')) {
      bmiColor = Colors.blue;
    } else if (categoryLower.contains('overweight')) {
      bmiColor = Colors.orange;
    } else if (categoryLower.contains('obese')) {
      bmiColor = Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: bmiColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.speed, color: bmiColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMI (Body Mass Index)',
                  style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  value != null ? 'Value: $value' : 'Enter height/weight',
                  style: AppStyles.text12Px.poppins.w400.textGrey,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bmiColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category,
              style: AppStyles.text12Px.poppins.w600.copyWith(color: bmiColor),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWhrCard(Map<String, dynamic> whr) {
    final value = whr['value'];
    final category = whr['category'] ?? 'N/A';
    final categoryLower = category.toString().toLowerCase();

    Color whrColor = Colors.green;
    if (categoryLower.contains('moderate')) {
      whrColor = Colors.orange;
    } else if (categoryLower.contains('high')) {
      whrColor = Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: whrColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.straighten, color: whrColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Waist-Hip Ratio (WHR)',
                  style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  value != null ? 'Ratio: $value' : 'Enter waist/hip measurements',
                  style: AppStyles.text12Px.poppins.w400.textGrey,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: whrColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              category,
              style: AppStyles.text12Px.poppins.w600.copyWith(color: whrColor),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required String subtitle,
    required IconData icon,
    required Color color,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                title,
                style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: AppStyles.text20Px.poppins.w700.copyWith(color: AppColors.textDark),
                ),
              ),
              const SizedBox(height: 2),
              if (badgeColor != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    unit,
                    style: AppStyles.text10Px.poppins.w600.copyWith(color: badgeColor),
                  ),
                )
              else
                Text(
                  unit,
                  style: AppStyles.text10Px.poppins.w400.textGrey,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Personal Info Card ──
  Widget _buildPersonalInfoCard(Map<String, dynamic> personalInfo, Map<String, dynamic> goals) {
    final age = personalInfo['age'];
    final gender = personalInfo['gender'] ?? 'N/A';
    final activity = personalInfo['activity_level'] ?? 'N/A';
    final fitnessGoal = goals['fitness_goal'] ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                'Personal & Lifestyle Info',
                style: AppStyles.text16Px.poppins.w600.copyWith(color: AppColors.textDark),
              ),
              GestureDetector(
                onTap: _navigateToEdit,
                child: Text(
                  'Edit',
                  style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          _buildInfoRow('Age', age != null ? '$age years' : 'N/A'),
          _buildInfoRow('Gender', gender.toString().toUpperCase()),
          _buildInfoRow('Activity Level', activity),
          _buildInfoRow('Fitness Goal', fitnessGoal),
        ],
      ),
    );
  }

  // ── Body Measurements Card ──
  Widget _buildMeasurementsCard(Map<String, dynamic> measurements, Map<String, dynamic> personalInfo) {
    final height = personalInfo['height_cm'];
    final weight = personalInfo['weight_kg'];
    final waist = measurements['waist_cm'];
    final hip = measurements['hip_cm'];
    final neck = measurements['neck_cm'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                'Body Measurements',
                style: AppStyles.text16Px.poppins.w600.copyWith(color: AppColors.textDark),
              ),
              GestureDetector(
                onTap: _navigateToEdit,
                child: Text(
                  'Edit',
                  style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          _buildInfoRow('Height', height != null ? '$height cm' : 'N/A'),
          _buildInfoRow('Weight', weight != null ? '$weight kg' : 'N/A'),
          _buildInfoRow('Waist Circumference', waist != null ? '$waist cm' : 'N/A'),
          _buildInfoRow('Hip Circumference', hip != null ? '$hip cm' : 'N/A'),
          _buildInfoRow('Neck Circumference', neck != null ? '$neck cm' : 'N/A'),
        ],
      ),
    );
  }

  // ── Medical Information Card ──
  Widget _buildMedicalInfoCard(Map<String, dynamic> medicalInfo) {
    final isHealthy = medicalInfo['is_healthy'] ?? true;
    final healthConditions = medicalInfo['health_conditions'] as List<dynamic>? ?? [];
    final injuries = medicalInfo['injuries'] as List<dynamic>? ?? [];
    final medicalConditions = medicalInfo['medical_conditions'] as List<dynamic>? ?? [];

    final List<String> allConditions = [];
    allConditions.addAll(healthConditions.map((e) => e.toString().replaceAll('_', ' ')));
    allConditions.addAll(medicalConditions.map((e) => e.toString()));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                'Medical Information',
                style: AppStyles.text16Px.poppins.w600.copyWith(color: AppColors.textDark),
              ),
              GestureDetector(
                onTap: _navigateToEdit,
                child: Text(
                  'Edit',
                  style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          _buildInfoRow('Status', isHealthy ? 'Healthy' : 'Has conditions/injuries'),
          if (allConditions.isNotEmpty)
            _buildListInfoRow('Conditions', allConditions),
          if (injuries.isNotEmpty)
            _buildListInfoRow('Injuries', injuries.map((e) => e.toString()).toList()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.text14Px.poppins.w400.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildListInfoRow(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppStyles.text14Px.poppins.w400.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  item,
                  style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textDark),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _navigateToEdit() {
    final profileCubit = context.read<ProfileCubit>();
    profileCubit.state.customerDetails.fold(
      () {
        Dialogs.showSnack(msg: 'Unable to load profile data');
      },
      (either) {
        either.fold(
          (failure) => Dialogs.showSnack(msg: failure.msg),
          (details) {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: profileCubit,
                  child: FitnessDetailsScreen(customerDetailsModel: details),
                ),
              ),
            ).then((_) {
              // Refresh on return
              _fetchReport();
            });
          },
        );
      },
    );
  }

  Color _getBodyFatCategoryColor(String? category) {
    if (category == null) return Colors.grey;
    final cat = category.toLowerCase();
    if (cat.contains('essential') || cat.contains('athlete') || cat.contains('fitness')) {
      return Colors.green;
    } else if (cat.contains('average')) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
