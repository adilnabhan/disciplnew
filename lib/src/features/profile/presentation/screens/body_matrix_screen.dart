import 'dart:math';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/extensions/typography_extension.dart';

class BodyMatrixScreen extends StatefulWidget {
  const BodyMatrixScreen({super.key, required this.customerDetails});
  final CustomerDetailsModel customerDetails;

  @override
  State<BodyMatrixScreen> createState() => _BodyMatrixScreenState();
}

class _BodyMatrixScreenState extends State<BodyMatrixScreen> {
  bool _aboutBmiExpanded = false;
  bool _aboutBmrExpanded = false;
  bool _aboutBfExpanded = false;

  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  final FocusNode _heightFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();

  String? _currentHeight;
  String? _currentWeight;

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.customerDetails.height;
    _currentWeight = widget.customerDetails.weight;
    _heightController = TextEditingController(text: _currentHeight ?? '');
    _weightController = TextEditingController(text: _currentWeight ?? '');

    _heightFocusNode.addListener(() {
      if (!_heightFocusNode.hasFocus) {
        _saveMetrics();
      }
    });
    _weightFocusNode.addListener(() {
      if (!_weightFocusNode.hasFocus) {
        _saveMetrics();
      }
    });
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    super.dispose();
  }

  void _saveMetrics() {
    final hStr = _heightController.text.trim();
    final wStr = _weightController.text.trim();

    final hVal = double.tryParse(hStr);
    final wVal = double.tryParse(wStr);

    if (hVal == null || wVal == null || hVal <= 0 || wVal <= 0) {
      return;
    }

    final details = context.read<ProfileCubit>().state.customerDetails.fold(
      () => widget.customerDetails,
      (either) => either.fold((_) => widget.customerDetails, (r) => r),
    );

    if (hStr == details.height && wStr == details.weight) {
      return;
    }

    setState(() {
      _currentHeight = hStr;
      _currentWeight = wStr;
    });

    context.read<ProfileCubit>().updateHealthProfile(
          bloodGroup: details.bloodGroup ?? '',
          height: hStr,
          weight: wStr,
        );
  }

  double? get _bf {
    final hasEdited = _currentHeight != widget.customerDetails.height ||
        _currentWeight != widget.customerDetails.weight;

    if (!hasEdited) {
      final raw = widget.customerDetails.bfPercentage;
      if (raw != null) {
        if (raw is num) return raw.toDouble();
        if (raw is String) {
          final parsed = double.tryParse(raw);
          if (parsed != null) return parsed;
        }
      }
    }

    final bmiVal = _bmi;
    final dob = widget.customerDetails.dateOfBirth;
    if (bmiVal == null || dob == null) return 16.4;

    final age = DateTime.now().year - dob.year;
    final gender = widget.customerDetails.gender?.toString().toLowerCase() ?? 'male';

    if (gender.startsWith('f')) {
      return (1.20 * bmiVal) + (0.23 * age) - 5.4;
    } else {
      return (1.20 * bmiVal) + (0.23 * age) - 16.2;
    }
  }

  Map<String, dynamic> get _bfInfo {
    final val = _bf;
    if (val == null) {
      return {
        'value': null,
        'label': '--',
        'subtext': 'Body fat percentage not set.',
        'color': const Color(0xFF868E96),
        'fraction': 0.0,
      };
    }
    String label;
    String subtext;
    Color color;
    double fraction;
    if (val < 2.0) {
      label = 'Low';
      subtext = 'Below Essential threshold (2%)';
      color = const Color(0xFF2F6FED);
      fraction = 0.0;
    } else if (val < 6.0) {
      label = 'Essential';
      subtext = '${(6.0 - val).toStringAsFixed(1)}% below Athletic threshold (6%)';
      color = const Color(0xFF2F6FED);
      fraction = 0.2 * (val - 2.0) / (6.0 - 2.0);
    } else if (val < 14.0) {
      label = 'Athletic';
      subtext = '${(14.0 - val).toStringAsFixed(1)}% below Fitness threshold (14%)';
      color = const Color(0xFF00A896);
      fraction = 0.2 + 0.2 * (val - 6.0) / (14.0 - 6.0);
    } else if (val < 18.0) {
      label = 'Fitness';
      subtext = '${(18.0 - val).toStringAsFixed(1)}% below Average threshold (18%)';
      color = const Color(0xFF80C23A);
      fraction = 0.4 + 0.2 * (val - 14.0) / (18.0 - 14.0);
    } else if (val < 25.0) {
      label = 'Average';
      subtext = '${(25.0 - val).toStringAsFixed(1)}% below Above Average threshold (25%)';
      color = const Color(0xFFF9B824);
      fraction = 0.6 + 0.2 * (val - 18.0) / (25.0 - 18.0);
    } else {
      label = 'Above Average';
      subtext = 'Above Average body fat levels';
      color = const Color(0xFFFA5252);
      fraction = 0.8 + 0.2 * (val - 25.0).clamp(0.0, 20.0) / 20.0;
    }
    return {
      'value': val,
      'label': label,
      'subtext': subtext,
      'color': color,
      'fraction': fraction.clamp(0.0, 1.0),
    };
  }

  // ── Computed values ────────────────────────────────────────────────────────
  double? get _bmi {
    final h = double.tryParse(_currentHeight ?? '');
    final w = double.tryParse(_currentWeight ?? '');
    if (h == null || w == null || h <= 0) return null;
    return w / pow(h / 100, 2);
  }

  double? get _bmr {
    final h = double.tryParse(_currentHeight ?? '');
    final w = double.tryParse(_currentWeight ?? '');
    final dob = widget.customerDetails.dateOfBirth;
    if (h == null || w == null || dob == null) return null;
    final age = DateTime.now().year - dob.year;
    final gender =
        widget.customerDetails.gender?.toString().toLowerCase() ?? 'male';
    if (gender.startsWith('f')) {
      return 447.593 + (9.247 * w) + (3.098 * h) - (4.330 * age);
    }
    return 88.362 + (13.397 * w) + (4.799 * h) - (5.677 * age);
  }

  // ── BMI helpers ────────────────────────────────────────────────────────────
  _BmiCategory get _bmiCategory {
    final b = _bmi;
    if (b == null) return _BmiCategory.normal;
    if (b < 18.5) return _BmiCategory.underweight;
    if (b < 25.0) return _BmiCategory.normal;
    if (b < 30.0) return _BmiCategory.overweight;
    return _BmiCategory.obese;
  }

  Color get _bmiColor {
    switch (_bmiCategory) {
      case _BmiCategory.underweight:
        return Colors.blue;
      case _BmiCategory.normal:
        return const Color(0xFF2CB67D);
      case _BmiCategory.overweight:
        return Colors.orange;
      case _BmiCategory.obese:
        return Colors.red;
    }
  }

  String get _bmiLabel {
    switch (_bmiCategory) {
      case _BmiCategory.underweight:
        return 'Underweight';
      case _BmiCategory.normal:
        return 'Normal';
      case _BmiCategory.overweight:
        return 'Overweight';
      case _BmiCategory.obese:
        return 'Obese';
    }
  }

  String get _bmiSubtext {
    final b = _bmi;
    if (b == null) return '';
    switch (_bmiCategory) {
      case _BmiCategory.underweight:
        final diff = (18.5 - b).toStringAsFixed(1);
        return '$diff below Normal threshold (18.5)';
      case _BmiCategory.normal:
        final diff = (25.0 - b).toStringAsFixed(1);
        return '$diff below Overweight threshold (25.0)';
      case _BmiCategory.overweight:
        final diff = (30.0 - b).toStringAsFixed(1);
        return '$diff below Obese threshold (30.0)';
      case _BmiCategory.obese:
        final diff = (b - 30.0).toStringAsFixed(1);
        return '$diff above Obese threshold (30.0)';
    }
  }

  // Position on the scale bar [0..1] mapped non-linearly to BMI categories
  double get _bmiFraction {
    final b = _bmi ?? 22.0;
    if (b <= 15.0) return 0.0;
    if (b >= 40.0) return 1.0;

    if (b < 18.5) {
      // Underweight segment: 15.0 to 18.5 maps to 0.0 to 0.25
      return 0.0 + 0.25 * (b - 15.0) / (18.5 - 15.0);
    } else if (b < 25.0) {
      // Normal segment: 18.5 to 25.0 maps to 0.25 to 0.50
      return 0.25 + 0.25 * (b - 18.5) / (25.0 - 18.5);
    } else if (b < 30.0) {
      // Overweight segment: 25.0 to 30.0 maps to 0.50 to 0.75
      return 0.50 + 0.25 * (b - 25.0) / (30.0 - 25.0);
    } else {
      // Obese segment: 30.0 to 40.0 maps to 0.75 to 1.0
      return 0.75 + 0.25 * (b - 30.0) / (40.0 - 30.0);
    }
  }

  String _formatNum(num v) {
    if (v == v.toInt()) return '${v.toInt()}';
    return v.toStringAsFixed(1);
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final details = state.customerDetails.fold(
          () => widget.customerDetails,
          (either) => either.fold(
            (error) => widget.customerDetails,
            (r) => r,
          ),
        );

        if (!_heightFocusNode.hasFocus &&
            _heightController.text != (details.height ?? '')) {
          _heightController.text = details.height ?? '';
          _currentHeight = details.height;
        }
        if (!_weightFocusNode.hasFocus &&
            _weightController.text != (details.weight ?? '')) {
          _weightController.text = details.weight ?? '';
          _currentWeight = details.weight;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: const PopButton().center,
            title: Text(
              'Body Matrix',
              style: AppStyles.text18Px.poppins.w600
                  .copyWith(color: AppColors.textDark),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Health Matrix',
                  style: AppStyles.text18Px.poppins.w700
                      .copyWith(color: AppColors.textDark),
                ),
                const SizedBox(height: 16),
                _buildBmiCard(),
                const SizedBox(height: 16),
                _buildBmrCard(),
                const SizedBox(height: 16),
                _buildBodyFatCard(),
                const SizedBox(height: 16),
                _buildMetricsCard(),
                const SizedBox(height: 24),
                _buildDisclaimer(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── BMI Card ───────────────────────────────────────────────────────────────
  Widget _buildBmiCard() {
    final bmiVal = _bmi;
    final bmiStr = bmiVal != null ? bmiVal.toStringAsFixed(1) : '--';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.monitor_weight_outlined,
                  color: Color(0xFF4C6EF5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'BMI ',
                          style: AppStyles.text14Px.poppins.w600
                              .copyWith(color: AppColors.textDark),
                        ),
                        Text(
                          '(Body Mass Index)',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: const Color(0xFF868E96),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Your body composition indicator',
                          style: AppStyles.text10Px.poppins.w400.copyWith(
                            color: const Color(0xFFADB5BD),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Big value
          Center(
            child: Text(
              bmiStr,
              style: AppStyles.text20Px.poppins.w700.copyWith(
                fontSize: 52,
                color: AppColors.textDark,
                height: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Category badge
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: _bmiColor, size: 10),
                const SizedBox(width: 6),
                Text(
                  _bmiLabel,
                  style: AppStyles.text14Px.poppins.w600
                      .copyWith(color: _bmiColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Sub info
          if (bmiVal != null)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: _bmiColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _bmiSubtext,
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: const Color(0xFF868E96),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 56),
          // Scale bar
          _buildBmiScale(),
          const SizedBox(height: 20),
          // Legend
          _buildBmiLegend(),
          const SizedBox(height: 16),
          // About BMI
          _buildAboutSection(
            title: 'About BMI',
            body:
                'BMI is a useful screening tool, but doesn\'t distinguish muscle, bone, or body fat. Use it along with other metrics for a complete picture.',
            expanded: _aboutBmiExpanded,
            onTap: () => setState(() => _aboutBmiExpanded = !_aboutBmiExpanded),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiScale() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Marker bubble
            Positioned(
              top: -48,
              left: (_bmiFraction * width - 28).clamp(0.0, width - 56),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _bmiColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _bmi != null ? _bmi!.toStringAsFixed(1) : '--',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: const Size(10, 6),
                    painter: _TriangleDownPainter(color: _bmiColor),
                  ),
                ],
              ),
            ),
            // Gradient bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 10,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4C6EF5),
                      Color(0xFF2CB67D),
                      Color(0xFFFFA94D),
                      Color(0xFFFA5252),
                    ],
                    stops: [0.125, 0.375, 0.625, 0.875],
                  ),
                ),
              ),
            ),
            // Circle marker on bar
            Positioned(
              top: -2,
              left: (_bmiFraction * width - 7).clamp(0.0, width - 14),
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: _bmiColor, width: 3),
                ),
              ),
            ),
            // Labels below
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: SizedBox(
                height: 18,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: const _ScaleLabel('15'),
                    ),
                    Positioned(
                      left: (0.25 * width - 12).clamp(0.0, width),
                      child: const _ScaleLabel('18.5'),
                    ),
                    Positioned(
                      left: (0.50 * width - 12).clamp(0.0, width),
                      child: const _ScaleLabel('25.0'),
                    ),
                    Positioned(
                      left: (0.75 * width - 8).clamp(0.0, width),
                      child: const _ScaleLabel('30'),
                    ),
                    Positioned(
                      right: 0,
                      child: const _ScaleLabel('40'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBmiLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLegendItem(
          icon: Icons.person_outline,
          color: const Color(0xFF4C6EF5),
          label: 'Underweight',
          range: '< 18.5',
        ),
        _buildLegendItem(
          icon: Icons.check_circle_outline,
          color: const Color(0xFF2CB67D),
          label: 'Normal',
          range: '18.5 – 24.9',
        ),
        _buildLegendItem(
          icon: Icons.warning_amber_rounded,
          color: Colors.orange,
          label: 'Overweight',
          range: '25 – 29.9',
        ),
        _buildLegendItem(
          icon: Icons.circle,
          color: Colors.red,
          label: 'Obese',
          range: '≥ 30',
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
    required String range,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppStyles.text10Px.poppins.w600
              .copyWith(color: AppColors.textDark),
        ),
        Text(
          range,
          style: AppStyles.text10Px.poppins.w400
              .copyWith(color: const Color(0xFF868E96)),
        ),
      ],
    );
  }

  // ── BMR Card ───────────────────────────────────────────────────────────────
  Widget _buildBmrCard() {
    final bmrVal = _bmr;
    final bmrStr = bmrVal != null
        ? bmrVal.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            )
        : '--';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_fire_department_outlined,
                  color: Color(0xFFFF9800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'BMR ',
                          style: AppStyles.text14Px.poppins.w600
                              .copyWith(color: AppColors.textDark),
                        ),
                        Text(
                          '(Basal Metabolic Rate)',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: const Color(0xFF868E96),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Calories burned at complete rest',
                          style: AppStyles.text10Px.poppins.w400.copyWith(
                            color: const Color(0xFFADB5BD),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: bmrStr,
                    style: AppStyles.text20Px.poppins.w700.copyWith(
                      fontSize: 52,
                      color: AppColors.textDark,
                      height: 1.0,
                    ),
                  ),
                  TextSpan(
                    text: '  kcal/day',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: const Color(0xFF868E96),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Activity multiplier hints
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFE0B2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Calorie Needs',
                  style: AppStyles.text12Px.poppins.w600
                      .copyWith(color: const Color(0xFFE65100)),
                ),
                const SizedBox(height: 8),
                if (bmrVal != null) ...[
                  _buildActivityRow(
                      '🛋️ Sedentary', bmrVal * 1.2, '(little/no exercise)'),
                  _buildActivityRow('🚶 Light', bmrVal * 1.375,
                      '(light exercise 1–3 days/wk)'),
                  _buildActivityRow('🏃 Moderate', bmrVal * 1.55,
                      '(moderate 3–5 days/wk)'),
                  _buildActivityRow(
                      '💪 Active', bmrVal * 1.725, '(hard 6–7 days/wk)'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildAboutSection(
            title: 'About BMR',
            body:
                'BMR is the number of calories your body burns at complete rest to maintain basic functions like breathing and circulation. Use it as your baseline for calorie planning.',
            expanded: _aboutBmrExpanded,
            onTap: () => setState(() => _aboutBmrExpanded = !_aboutBmrExpanded),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String label, double kcal, String note) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppStyles.text12Px.poppins.w500
                .copyWith(color: AppColors.textDark),
          ),
          Text(
            '${_formatNum(kcal)} kcal  ',
            style: AppStyles.text12Px.poppins.w600
                .copyWith(color: const Color(0xFFE65100)),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyFatCard() {
    final info = _bfInfo;
    final double? bfVal = info['value'] as double?;
    final String label = info['label'] as String;
    final String subtext = info['subtext'] as String;
    final Color color = info['color'] as Color;
    final double fraction = info['fraction'] as double;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.percent_outlined,
                  color: Color(0xFF00A896),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Body Fat ',
                          style: AppStyles.text14Px.poppins.w600
                              .copyWith(color: AppColors.textDark),
                        ),
                        Text(
                          '(Body Fat Percentage)',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: const Color(0xFF868E96),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Estimated body fat composition indicator',
                          style: AppStyles.text10Px.poppins.w400.copyWith(
                            color: const Color(0xFFADB5BD),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: bfVal != null ? bfVal.toStringAsFixed(1) : '--',
                    style: AppStyles.text20Px.poppins.w700.copyWith(
                      fontSize: 52,
                      color: AppColors.textDark,
                      height: 1.0,
                    ),
                  ),
                  if (bfVal != null)
                    TextSpan(
                      text: '  %',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: const Color(0xFF868E96),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (bfVal != null)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: color, size: 10),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppStyles.text14Px.poppins.w600.copyWith(color: color),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Estimated body fat based on your inputs.',
              style: AppStyles.text12Px.poppins.w400.copyWith(
                color: const Color(0xFF868E96),
              ),
            ),
          ),
          const SizedBox(height: 56),
          _buildFatScale(bfVal, color, fraction),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildFatHeaderItem('Essential', '2-5%', const Color(0xFF2F6FED))),
              Expanded(child: _buildFatHeaderItem('Athletic', '6-13%', const Color(0xFF00A896))),
              Expanded(child: _buildFatHeaderItem('Fitness', '14-17%', const Color(0xFF80C23A))),
              Expanded(child: _buildFatHeaderItem('Average', '18-24%', const Color(0xFFF9B824))),
              Expanded(child: _buildFatHeaderItem('Above Average', '25%+', const Color(0xFFFA5252))),
            ],
          ),
          const SizedBox(height: 24),
          _buildAboutSection(
            title: 'About Body Fat Percentage',
            body:
                'Body fat percentage is the amount of fat in your body compared to your total body weight. It\'s a better indicator of fitness than weight alone.',
            expanded: _aboutBfExpanded,
            onTap: () => setState(() => _aboutBfExpanded = !_aboutBfExpanded),
          ),
        ],
      ),
    );
  }

  Widget _buildFatHeaderItem(String title, String range, Color color) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppStyles.text10Px.poppins.w600.copyWith(color: color),
        ),
        const SizedBox(height: 2),
        Text(
          range,
          textAlign: TextAlign.center,
          style: AppStyles.text10Px.poppins.w500.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildFatScale(double? bfVal, Color color, double fraction) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final markerLeft = (fraction * width - 7).clamp(0.0, width - 14);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 10,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2F6FED),
                      Color(0xFF00A896),
                      Color(0xFF80C23A),
                      Color(0xFFF9B824),
                      Color(0xFFFA5252),
                    ],
                    stops: [0.1, 0.3, 0.5, 0.7, 0.9],
                  ),
                ),
              ),
            ),
            Positioned(left: 0.2 * width - 0.75, top: 0, bottom: 0, child: Container(width: 1.5, color: Colors.white.withValues(alpha: 0.6))),
            Positioned(left: 0.4 * width - 0.75, top: 0, bottom: 0, child: Container(width: 1.5, color: Colors.white.withValues(alpha: 0.6))),
            Positioned(left: 0.6 * width - 0.75, top: 0, bottom: 0, child: Container(width: 1.5, color: Colors.white.withValues(alpha: 0.6))),
            Positioned(left: 0.8 * width - 0.75, top: 0, bottom: 0, child: Container(width: 1.5, color: Colors.white.withValues(alpha: 0.6))),
            Positioned(
              top: -2,
              left: markerLeft,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: color, width: 3),
                ),
              ),
            ),
            Positioned(
              top: -48,
              left: (fraction * width - 28).clamp(0.0, width - 56),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      bfVal != null ? '${bfVal.toStringAsFixed(1)}%' : '--',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  CustomPaint(
                    size: const Size(10, 6),
                    painter: _TriangleDownPainter(color: color),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -18,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 14,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: const _ScaleLabel('2%'),
                    ),
                    Positioned(
                      left: (0.20 * width - 10).clamp(0.0, width),
                      child: const _ScaleLabel('6%'),
                    ),
                    Positioned(
                      left: (0.40 * width - 12).clamp(0.0, width),
                      child: const _ScaleLabel('14%'),
                    ),
                    Positioned(
                      left: (0.60 * width - 12).clamp(0.0, width),
                      child: const _ScaleLabel('18%'),
                    ),
                    Positioned(
                      left: (0.80 * width - 12).clamp(0.0, width),
                      child: const _ScaleLabel('25%'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Metrics Card ───────────────────────────────────────────────────────────
  Widget _buildMetricsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Body Measurements',
            style: AppStyles.text14Px.poppins.w600
                .copyWith(color: AppColors.textDark),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMeasurementTile(
                  icon: Icons.height,
                  iconColor: const Color(0xFFFA5252),
                  label: 'Height',
                  controller: _heightController,
                  focusNode: _heightFocusNode,
                  suffix: 'cm',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMeasurementTile(
                  icon: Icons.monitor_weight_outlined,
                  iconColor: const Color(0xFFFA5252),
                  label: 'Weight',
                  controller: _weightController,
                  focusNode: _weightFocusNode,
                  suffix: 'kg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppStyles.text10Px.poppins.w500
                      .copyWith(color: const Color(0xFF868E96)),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _saveMetrics(),
                        onChanged: (val) {
                          setState(() {
                            if (label == 'Height') {
                              _currentHeight = val;
                            } else {
                              _currentWeight = val;
                            }
                          });
                        },
                        style: AppStyles.text14Px.poppins.w700
                            .copyWith(color: AppColors.textDark),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      suffix,
                      style: AppStyles.text12Px.poppins.w500
                          .copyWith(color: const Color(0xFF868E96)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.gpp_good_outlined,
            color: Color(0xFF6E80A4),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Results are estimates and not a substitute for professional medical advice.',
              style: AppStyles.text12Px.poppins.w500.copyWith(
                color: const Color(0xFF6E80A4),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared: About section ──────────────────────────────────────────────────
  Widget _buildAboutSection({
    required String title,
    required String body,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1FAF5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF2CB67D),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: AppStyles.text13Px.poppins.w600
                        .copyWith(color: AppColors.textDark),
                  ),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.chevron_right,
                  color: const Color(0xFF868E96),
                  size: 18,
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 8),
              Text(
                body,
                style: AppStyles.text12Px.poppins.w400.copyWith(
                  color: const Color(0xFF495057),
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Scale label helper ─────────────────────────────────────────────────────
class _ScaleLabel extends StatelessWidget {
  const _ScaleLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF868E96),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TriangleDownPainter extends CustomPainter {
  final Color color;
  _TriangleDownPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _BmiCategory { underweight, normal, overweight, obese }
