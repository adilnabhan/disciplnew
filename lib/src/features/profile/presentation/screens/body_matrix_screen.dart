import 'dart:math';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/extensions/typography_extension.dart';
import 'package:customer_mobile_app/src/features/profile/domain/models/body_matrix_model.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/widgets/body_matrix_history_views.dart';

class BodyMatrixScreen extends StatefulWidget {
  const BodyMatrixScreen({super.key, required this.customerDetails});
  final CustomerDetailsModel customerDetails;

  @override
  State<BodyMatrixScreen> createState() => _BodyMatrixScreenState();
}

class _BodyMatrixScreenState extends State<BodyMatrixScreen> {
  int _selectedTabIndex = 0;
  bool _aboutBmiExpanded = false;
  bool _aboutBmrExpanded = false;
  bool _aboutBfExpanded = false;
  bool _aboutWhrExpanded = false;
  bool _aboutWhtrExpanded = false;

  bool _isLoading = true;
  String? _errorMessage;
  BodyMatrixModel? _bodyMatrix;

  double? get _whr => _bodyMatrix?.whrRatio;
  double? get _whtr => _bodyMatrix?.whtrRatio;
  double? get _bmi => _bodyMatrix?.bmiValue;
  double? get _bmr => _bodyMatrix?.bmrValue;
  double? get _bf => _bodyMatrix?.bodyFatPercentage;

  @override
  void initState() {
    super.initState();
    _fetchBodyMatrix();
  }

  Future<void> _fetchBodyMatrix() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await CustomerDetailsRepository().fetchBodyMatrix();
    if (!mounted) return;

    res.fold(
      (error) {
        print('=== [BODY MATRIX FETCH ERROR] ===');
        print('Error message: ${error.msg}');
        print('=================================');
        setState(() {
          _isLoading = false;
          _errorMessage = AppErrorHandler.formatUserFriendlyMessage(error.msg, fallback: 'Failed to fetch body matrix. Please try again.');
        });
      },
      (matrix) {
        print('=== [BODY MATRIX MODEL VALUES] ===');
        print('BMI: ${matrix.bmiValue} | Category: ${matrix.bmiCategory} | Label: ${matrix.bmiLabel}');
        print('BMR: ${matrix.bmrValue} ${matrix.bmrUnit}');
        print('Body Fat: ${matrix.bodyFatPercentage}% | Category: ${matrix.bodyFatCategory}');
        print('WHR: ${matrix.whrRatio} | Category: ${matrix.whrCategory}');
        print('WHtR: ${matrix.whtrRatio} | Category: ${matrix.whtrCategory}');
        print('Inputs: Height=${matrix.heightCm}cm, Weight=${matrix.weightKg}kg, Neck=${matrix.neckCm}cm, Waist=${matrix.waistCm}cm, Hip=${matrix.hipCm}cm');
        print('==================================');
        setState(() {
          _isLoading = false;
          _bodyMatrix = matrix;
        });
      },
    );
  }

  Map<String, dynamic> _bfInfo() {
    final val = _bf;
    final cat = _bodyMatrix?.bodyFatCategory;
    if (val == null) {
      return {
        'value': null,
        'label': cat != null && cat.isNotEmpty ? cat : '-',
        'subtext': '-',
        'color': const Color(0xFF868E96),
        'fraction': 0.0,
      };
    }
    final label = cat != null && cat.isNotEmpty ? cat : _resolveBfCategory(val);
    final color = _resolveBfColor(label, val);
    double fraction;
    if (val < 2.0) {
      fraction = 0.0;
    } else if (val < 6.0) {
      fraction = 0.2 * (val - 2.0) / (6.0 - 2.0);
    } else if (val < 14.0) {
      fraction = 0.2 + 0.2 * (val - 6.0) / (14.0 - 6.0);
    } else if (val < 18.0) {
      fraction = 0.4 + 0.2 * (val - 14.0) / (18.0 - 14.0);
    } else if (val < 25.0) {
      fraction = 0.6 + 0.2 * (val - 18.0) / (25.0 - 18.0);
    } else {
      fraction = 0.8 + 0.2 * (val - 25.0).clamp(0.0, 20.0) / 20.0;
    }
    return {
      'value': val,
      'label': label,
      'subtext': 'Estimated body fat composition indicator',
      'color': color,
      'fraction': fraction.clamp(0.0, 1.0),
    };
  }

  String _resolveBfCategory(double val) {
    if (val < 2.0) return 'Low';
    if (val < 6.0) return 'Essential';
    if (val < 14.0) return 'Athletic';
    if (val < 18.0) return 'Fitness';
    if (val < 25.0) return 'Average';
    return 'Above Average';
  }

  Color _resolveBfColor(String label, double? val) {
    final l = label.toLowerCase();
    if (l.contains('low') || l.contains('essential')) return const Color(0xFF2F6FED);
    if (l.contains('athletic')) return const Color(0xFF00A896);
    if (l.contains('fitness')) return const Color(0xFF80C23A);
    if (l.contains('average') && !l.contains('above')) return const Color(0xFFF9B824);
    if (l.contains('above') || l.contains('high')) return const Color(0xFFFA5252);
    if (val != null) {
      if (val < 6.0) return const Color(0xFF2F6FED);
      if (val < 14.0) return const Color(0xFF00A896);
      if (val < 18.0) return const Color(0xFF80C23A);
      if (val < 25.0) return const Color(0xFFF9B824);
      return const Color(0xFFFA5252);
    }
    return const Color(0xFF868E96);
  }

  // ── BMI helpers ────────────────────────────────────────────────────────────
  String get _bmiLabel {
    if (_bodyMatrix?.bmiLabel != null && _bodyMatrix!.bmiLabel!.isNotEmpty) {
      return _bodyMatrix!.bmiLabel!;
    }
    if (_bodyMatrix?.bmiCategory != null &&
        _bodyMatrix!.bmiCategory!.isNotEmpty) {
      return _bodyMatrix!.bmiCategory!;
    }
    final b = _bmi;
    if (b == null) return '-';
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal';
    if (b < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiColor {
    final b = _bmi;
    final lbl = _bmiLabel.toLowerCase();
    if (lbl.contains('under')) return Colors.blue;
    if (lbl.contains('normal')) return const Color(0xFF2CB67D);
    if (lbl.contains('over')) return Colors.orange;
    if (lbl.contains('obese')) return Colors.red;
    if (b != null) {
      if (b < 18.5) return Colors.blue;
      if (b < 25.0) return const Color(0xFF2CB67D);
      if (b < 30.0) return Colors.orange;
      return Colors.red;
    }
    return const Color(0xFF868E96);
  }

  String get _bmiSubtext {
    final b = _bmi;
    if (b == null) return '-';
    if (b < 18.5) {
      final diff = (18.5 - b).toStringAsFixed(1);
      return '$diff below Normal threshold (18.5)';
    } else if (b < 25.0) {
      final diff = (25.0 - b).toStringAsFixed(1);
      return '$diff below Overweight threshold (25.0)';
    } else if (b < 30.0) {
      final diff = (30.0 - b).toStringAsFixed(1);
      return '$diff below Obese threshold (30.0)';
    } else {
      final diff = (b - 30.0).toStringAsFixed(1);
      return '$diff above Obese threshold (30.0)';
    }
  }

  double get _bmiFraction {
    final b = _bmi;
    if (b == null) return 0.0;
    if (b <= 15.0) return 0.0;
    if (b >= 40.0) return 1.0;

    if (b < 18.5) {
      return 0.0 + 0.25 * (b - 15.0) / (18.5 - 15.0);
    } else if (b < 25.0) {
      return 0.25 + 0.25 * (b - 18.5) / (25.0 - 18.5);
    } else if (b < 30.0) {
      return 0.50 + 0.25 * (b - 25.0) / (30.0 - 25.0);
    } else {
      return 0.75 + 0.25 * (b - 30.0) / (40.0 - 30.0);
    }
  }

  Color _resolveRatioColor(String label) {
    final l = label.toLowerCase();
    if (l.contains('excellent') || l.contains('low risk')) {
      return const Color(0xFF2E7D32);
    }
    if (l.contains('healthy')) return const Color(0xFF43A047);
    if (l.contains('average') || l.contains('moderate')) {
      return const Color(0xFFFB8C00);
    }
    if (l.contains('high')) return const Color(0xFFE53935);
    return const Color(0xFF9CA3AF);
  }

  String _formatNum(num v) {
    if (v == v.toInt()) return '${v.toInt()}';
    return v.toStringAsFixed(1);
  }

  Widget _buildErrorView(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFFEEEE),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE53935),
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Body Matrix',
            style: AppStyles.text18Px.poppins.w700.copyWith(
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message.isNotEmpty
                ? message
                : 'Unable to retrieve your body metrics. Please try again.',
            textAlign: TextAlign.center,
            style: AppStyles.text13Px.poppins.w400.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchBodyMatrix,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              'Try Again',
              style: AppStyles.text14Px.poppins.w600,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF3F4F6),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            if (i < 2) const SizedBox(height: 16),
          ],
        ],
      ),
    );
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
          body: RefreshIndicator(
            onRefresh: () async {
              if (_selectedTabIndex == 0) {
                await _fetchBodyMatrix();
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Health Matrix',
                    style: AppStyles.text20Px.poppins.w700
                        .copyWith(color: AppColors.textDark),
                  ),
                  const SizedBox(height: 14),
                  _buildTabBar(),
                  const SizedBox(height: 18),
                  if (_selectedTabIndex == 0) ...[
                    if (_isLoading)
                      _buildLoadingSkeleton()
                    else if (_errorMessage != null)
                      _buildErrorView(_errorMessage!)
                    else if (_bodyMatrix == null)
                      _buildErrorView('No body matrix data available.')
                    else ...[
                      _buildBmiCard(),
                      const SizedBox(height: 16),
                      _buildBmrCard(),
                      const SizedBox(height: 16),
                      _buildBodyFatCard(),
                      const SizedBox(height: 16),
                      _buildRatioCardsRow(details),
                      const SizedBox(height: 16),
                      _buildMetricsCard(),
                      const SizedBox(height: 24),
                      _buildDisclaimer(),
                      const SizedBox(height: 32),
                    ],
                  ] else ...[
                    BodyMatrixHistoryView(customerDetails: details),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECEF),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedTabIndex != 0) {
                  setState(() => _selectedTabIndex = 0);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Present Condition',
                  style: AppStyles.text14Px.poppins.copyWith(
                    fontWeight: _selectedTabIndex == 0
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: _selectedTabIndex == 0
                        ? Colors.white
                        : const Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedTabIndex != 1) {
                  setState(() => _selectedTabIndex = 1);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                ),
                alignment: Alignment.center,
                child: Text(
                  'History',
                  style: AppStyles.text14Px.poppins.copyWith(
                    fontWeight: _selectedTabIndex == 1
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: _selectedTabIndex == 1
                        ? Colors.white
                        : const Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BMI Card ───────────────────────────────────────────────────────────────
  Widget _buildBmiCard() {
    final bmiVal = _bmi;
    final bmiStr = bmiVal != null ? bmiVal.toStringAsFixed(1) : '-';

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
            formulaTitle: 'BMI Formula:',
            formulas: [
              'BMI = Weight (kg) / [Height (m)]²',
            ],
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
                      _bmi != null ? _bmi!.toStringAsFixed(1) : '-',
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
        : '-';

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
                  if (bmrVal != null)
                    TextSpan(
                      text: '  ${_bodyMatrix?.bmrUnit ?? "kcal/day"}',
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
                ] else ...[
                  _buildActivityRow(
                      '🛋️ Sedentary', null, '(little/no exercise)'),
                  _buildActivityRow('🚶 Light', null,
                      '(light exercise 1–3 days/wk)'),
                  _buildActivityRow('🏃 Moderate', null,
                      '(moderate 3–5 days/wk)'),
                  _buildActivityRow(
                      '💪 Active', null, '(hard 6–7 days/wk)'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildAboutSection(
            title: 'About BMR',
            body:
                'BMR is the number of calories your body burns at complete rest to maintain basic functions like breathing and circulation. Use it as your baseline for calorie planning.',
            formulaTitle: 'Harris-Benedict Formula:',
            formulas: [
              'Men: BMR = 88.362 + (13.397 × Weight kg) + (4.799 × Height cm) - (5.677 × Age)',
              'Women: BMR = 447.593 + (9.247 × Weight kg) + (3.098 × Height cm) - (4.330 × Age)',
            ],
            expanded: _aboutBmrExpanded,
            onTap: () => setState(() => _aboutBmrExpanded = !_aboutBmrExpanded),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String label, double? kcal, String note) {
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
            kcal != null ? '${_formatNum(kcal)} kcal  ' : '-  ',
            style: AppStyles.text12Px.poppins.w600
                .copyWith(color: const Color(0xFFE65100)),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyFatCard([CustomerDetailsModel? details]) {
    final info = _bfInfo();
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
                    text: bfVal != null ? bfVal.toStringAsFixed(1) : '-',
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
          if (bfVal != null || (label.isNotEmpty && label != '-'))
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
            formulaTitle: 'Deurenberg Formula:',
            formulas: [
              'Men: Body Fat % = (1.20 × BMI) + (0.23 × Age) - 16.2',
              'Women: Body Fat % = (1.20 × BMI) + (0.23 × Age) - 5.4',
            ],
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
                      bfVal != null ? '${bfVal.toStringAsFixed(1)}%' : '-',
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

  // ── WHR Card ───────────────────────────────────────────────────────────────
  // ── Waist-to-Hip & Waist-to-Height Ratio Cards Row (Rich UI) ────────────
  Widget _buildRatioCardsRow([CustomerDetailsModel? details]) {
    final whrVal = _whr;
    final whrStr = whrVal != null ? whrVal.toStringAsFixed(2) : '-';
    final gender = ((_bodyMatrix?.gender ?? details?.gender) ?? 'male')
        .toString()
        .toLowerCase();
    final isFemale = gender.startsWith('f');

    final apiWhrCategory = _bodyMatrix?.whrCategory;
    Color whrColor = const Color(0xFF9CA3AF);
    String whrLabel = '-';

    if (apiWhrCategory != null && apiWhrCategory.isNotEmpty) {
      whrLabel = apiWhrCategory;
      whrColor = _resolveRatioColor(apiWhrCategory);
    } else if (whrVal != null) {
      if (isFemale) {
        if (whrVal < 0.80) {
          whrColor = const Color(0xFF2E7D32);
          whrLabel = 'Excellent';
        } else if (whrVal <= 0.90) {
          whrColor = const Color(0xFF43A047);
          whrLabel = 'Healthy';
        } else if (whrVal <= 1.00) {
          whrColor = const Color(0xFFFB8C00);
          whrLabel = 'Average';
        } else {
          whrColor = const Color(0xFFE53935);
          whrLabel = 'High';
        }
      } else {
        if (whrVal < 0.80) {
          whrColor = const Color(0xFF2E7D32);
          whrLabel = 'Excellent';
        } else if (whrVal <= 0.90) {
          whrColor = const Color(0xFF43A047);
          whrLabel = 'Healthy';
        } else if (whrVal <= 1.00) {
          whrColor = const Color(0xFFFB8C00);
          whrLabel = 'Average';
        } else {
          whrColor = const Color(0xFFE53935);
          whrLabel = 'High';
        }
      }
    }

    final whtrVal = _whtr;
    final whtrStr = whtrVal != null ? whtrVal.toStringAsFixed(2) : '-';

    Color whtrColor = const Color(0xFF9CA3AF);
    String whtrLabel = '-';
    final apiWhtrCategory = _bodyMatrix?.whtrCategory;

    if (apiWhtrCategory != null && apiWhtrCategory.isNotEmpty) {
      whtrLabel = apiWhtrCategory;
      whtrColor = _resolveRatioColor(apiWhtrCategory);
    } else if (whtrVal != null) {
      if (whtrVal < 0.40) {
        whtrColor = const Color(0xFF2E7D32);
        whtrLabel = 'Low Risk';
      } else if (whtrVal <= 0.50) {
        whtrColor = const Color(0xFF43A047);
        whtrLabel = 'Healthy';
      } else if (whtrVal <= 0.60) {
        whtrColor = const Color(0xFFFB8C00);
        whtrLabel = 'Moderate';
      } else {
        whtrColor = const Color(0xFFE53935);
        whtrLabel = 'High Risk';
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildRatioCardDetailed(
            title: 'Waist-to-Hip Ratio',
            subtitle: 'Fat distribution indicator',
            valueStr: whrStr,
            valueNum: whrVal,
            icon: Icons.accessibility_new_rounded,
            statusLabel: whrLabel,
            statusColor: whrColor,
            minScale: 0.70,
            maxScale: 1.00,
            scaleLabels: ['0.70', '0.80', '0.90', '1.00'],
            categories: const [
              _RatioCategoryItem(label: 'Excellent', range: '< 0.80', color: Color(0xFF2E7D32)),
              _RatioCategoryItem(label: 'Healthy', range: '0.80-0.90', color: Color(0xFF43A047)),
              _RatioCategoryItem(label: 'Average', range: '0.90-1.00', color: Color(0xFFFB8C00)),
              _RatioCategoryItem(label: 'High', range: '> 1.00', color: Color(0xFFE53935)),
            ],
            onTap: () => _showBodyMetricsBottomSheet(context),
            aboutText:
                'WHR measures fat distribution around your abdomen and hips. Lower values indicate lower risk of cardiovascular disease.',
            formulaText: 'WHR = Waist / Hip',
            aboutExpanded: _aboutWhrExpanded,
            onAboutTap: () => setState(() => _aboutWhrExpanded = !_aboutWhrExpanded),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRatioCardDetailed(
            title: 'Waist-to-Height Ratio',
            subtitle: 'Health risk indicator',
            valueStr: whtrStr,
            valueNum: whtrVal,
            icon: Icons.square_foot_rounded,
            statusLabel: whtrLabel,
            statusColor: whtrColor,
            minScale: 0.30,
            maxScale: 0.60,
            scaleLabels: ['0.30', '0.40', '0.50', '0.60'],
            categories: const [
              _RatioCategoryItem(label: 'Low Risk', range: '< 0.40', color: Color(0xFF2E7D32)),
              _RatioCategoryItem(label: 'Healthy', range: '0.40-0.50', color: Color(0xFF43A047)),
              _RatioCategoryItem(label: 'Moderate', range: '0.50-0.60', color: Color(0xFFFB8C00)),
              _RatioCategoryItem(label: 'High Risk', range: '> 0.60', color: Color(0xFFE53935)),
            ],
            onTap: () => _showBodyMetricsBottomSheet(context),
            aboutText:
                'WHtR measures central obesity by comparing waist size to height. Keeping waist to less than half height reduces health risks.',
            formulaText: 'WHtR = Waist / Height',
            aboutExpanded: _aboutWhtrExpanded,
            onAboutTap: () => setState(() => _aboutWhtrExpanded = !_aboutWhtrExpanded),
          ),
        ),
      ],
    );
  }

  Widget _buildRatioCardDetailed({
    required String title,
    required String subtitle,
    required String valueStr,
    required double? valueNum,
    required IconData icon,
    required String statusLabel,
    required Color statusColor,
    required double minScale,
    required double maxScale,
    required List<String> scaleLabels,
    required List<_RatioCategoryItem> categories,
    required VoidCallback onTap,
    String? aboutText,
    String? formulaText,
    bool aboutExpanded = false,
    VoidCallback? onAboutTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: const Color(0xFFFF5252),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            style: AppStyles.text12Px.poppins.w700.copyWith(
                              color: const Color(0xFF111827),
                              fontSize: 11.5,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyles.text10Px.poppins.w400.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Metric Value
                Text(
                  valueStr,
                  style: AppStyles.text24Px.poppins.w800.copyWith(
                    color: const Color(0xFF111827),
                    fontSize: 26,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                // Category Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: statusColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Scale Top Numbers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: scaleLabels
                      .map(
                        (lbl) => Text(
                          lbl,
                          style: AppStyles.text10Px.poppins.w500.copyWith(
                            color: const Color(0xFF6B7280),
                            fontSize: 9,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 6),
                // Gradient Progress Bar & Thumb
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final frac = valueNum != null
                        ? ((valueNum - minScale) / (maxScale - minScale)).clamp(0.0, 1.0)
                        : 0.0;
                    final thumbLeft = (frac * width - 6).clamp(0.0, width - 12);

                    return SizedBox(
                      height: 12,
                      width: width,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 6,
                            width: width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF2E7D32),
                                  Color(0xFF43A047),
                                  Color(0xFFFB8C00),
                                  Color(0xFFE53935),
                                ],
                              ),
                            ),
                          ),
                          if (valueNum != null)
                            Positioned(
                              left: thumbLeft,
                              top: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: statusColor, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Bottom Categories Legends (2x2 Grid for clean spacing without overlapping)
                if (categories.length >= 4) ...[
                  Row(
                    children: [
                      Expanded(child: _buildCategoryLegendItem(categories[0])),
                      const SizedBox(width: 6),
                      Expanded(child: _buildCategoryLegendItem(categories[1])),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(child: _buildCategoryLegendItem(categories[2])),
                      const SizedBox(width: 6),
                      Expanded(child: _buildCategoryLegendItem(categories[3])),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: categories
                        .map((cat) => Expanded(child: _buildCategoryLegendItem(cat)))
                        .toList(),
                  ),
                ],
                if (aboutText != null) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: onAboutTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 13,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'About & Calculation',
                            style: AppStyles.text10Px.poppins.w600.copyWith(
                              color: const Color(0xFF4B5563),
                              fontSize: 9.5,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            aboutExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (aboutExpanded) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            aboutText,
                            style: AppStyles.text10Px.poppins.w400.copyWith(
                              color: const Color(0xFF4B5563),
                              fontSize: 9,
                              height: 1.35,
                            ),
                          ),
                          if (formulaText != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Calculation:',
                              style: AppStyles.text10Px.poppins.w700.copyWith(
                                color: const Color(0xFF111827),
                                fontSize: 8.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formulaText,
                              style: AppStyles.text10Px.poppins.w600.copyWith(
                                color: AppColors.primary,
                                fontSize: 8.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryLegendItem(_RatioCategoryItem cat) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: cat.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  cat.label,
                  style: AppStyles.text10Px.poppins.w600.copyWith(
                    color: cat.color,
                    fontSize: 8.5,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  cat.range,
                  style: AppStyles.text10Px.poppins.w400.copyWith(
                    color: const Color(0xFF9CA3AF),
                    fontSize: 7.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhrCard(CustomerDetailsModel details) {
    final whrVal = _whr;
    final whrStr = whrVal != null ? whrVal.toStringAsFixed(2) : null;
    final gender = (details.gender ?? 'male').toString().toLowerCase();
    final isFemale = gender.startsWith('f');

    Color categoryColor = const Color(0xFF2CB67D);
    String categoryLabel = 'Low Risk (Healthy)';

    if (whrVal != null) {
      if (isFemale) {
        if (whrVal < 0.80) {
          categoryColor = const Color(0xFF2CB67D);
          categoryLabel = 'Low Risk (Healthy)';
        } else if (whrVal <= 0.89) {
          categoryColor = Colors.orange;
          categoryLabel = 'Moderate Risk';
        } else {
          categoryColor = Colors.red;
          categoryLabel = 'High Risk';
        }
      } else {
        if (whrVal < 0.90) {
          categoryColor = const Color(0xFF2CB67D);
          categoryLabel = 'Low Risk (Healthy)';
        } else if (whrVal <= 0.99) {
          categoryColor = Colors.orange;
          categoryLabel = 'Moderate Risk';
        } else {
          categoryColor = Colors.red;
          categoryLabel = 'High Risk';
        }
      }
    }

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
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.straighten_rounded,
                  color: Color(0xFF8E24AA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waist-to-Hip Ratio (WHR)',
                      style: AppStyles.text14Px.poppins.w600
                          .copyWith(color: AppColors.textDark),
                    ),
                    Text(
                      'Body fat distribution indicator',
                      style: AppStyles.text12Px.poppins.w400
                          .copyWith(color: const Color(0xFF868E96)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (whrVal != null) ...[
            Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: whrStr,
                      style: AppStyles.text20Px.poppins.w700.copyWith(
                        fontSize: 48,
                        color: AppColors.textDark,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: '  ratio',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: const Color(0xFF868E96),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: categoryColor, size: 10),
                  const SizedBox(width: 6),
                  Text(
                    categoryLabel,
                    style: AppStyles.text14Px.poppins.w600
                        .copyWith(color: categoryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: categoryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isFemale ? 'Healthy target: < 0.80 ratio' : 'Healthy target: < 0.90 ratio',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: const Color(0xFF868E96),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 56),
            _buildWhrScale(whrVal, categoryColor, isFemale),
            const SizedBox(height: 20),
            _buildWhrLegend(isFemale),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.straighten_outlined,
                    size: 32,
                    color: const Color(0xFF8E24AA).withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waist & Hip Measurements Needed',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add your waist and hip measurements to calculate your Waist-to-Hip Ratio.',
                    textAlign: TextAlign.center,
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: const Color(0xFF868E96),
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () => _showBodyMetricsBottomSheet(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Add Measurements',
                            style: AppStyles.text12Px.poppins.w600.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _buildAboutSection(
            title: 'About Waist-to-Hip Ratio (WHR)',
            body:
                'WHR measures fat distribution around your abdomen and hips. Lower values indicate lower risk of cardiovascular diseases.',
            formulaTitle: 'Formula:',
            formulas: [
              'WHR = Waist Circumference / Hip Circumference',
              isFemale
                  ? 'Women Target: < 0.80 (Healthy), 0.80 - 0.89 (Moderate), ≥ 0.90 (High Risk)'
                  : 'Men Target: < 0.90 (Healthy), 0.90 - 0.99 (Moderate), ≥ 1.00 (High Risk)',
            ],
            expanded: _aboutWhrExpanded,
            onTap: () => setState(() => _aboutWhrExpanded = !_aboutWhrExpanded),
          ),
        ],
      ),
    );
  }

  Widget _buildWhrScale(double? whrVal, Color color, bool isFemale) {
    final minVal = isFemale ? 0.60 : 0.70;
    final maxVal = isFemale ? 1.10 : 1.20;
    final current = whrVal ?? (isFemale ? 0.75 : 0.85);
    final fraction = ((current - minVal) / (maxVal - minVal)).clamp(0.0, 1.0);

    final tick1 = isFemale ? '0.80' : '0.90';
    final tick2 = isFemale ? '0.90' : '1.00';

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bubbleLeft = (fraction * width - 28).clamp(0.0, width - 56);
        final circleLeft = (fraction * width - 7).clamp(0.0, width - 14);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (whrVal != null)
              Positioned(
                top: -48,
                left: bubbleLeft,
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
                        whrVal.toStringAsFixed(2),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 10,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2CB67D),
                      Color(0xFFFFA94D),
                      Color(0xFFFA5252),
                    ],
                    stops: [0.33, 0.66, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -2,
              left: circleLeft,
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
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: SizedBox(
                height: 18,
                child: Stack(
                  children: [
                    Positioned(
                      left: (0.40 * width - 12).clamp(0.0, width),
                      child: _ScaleLabel(tick1),
                    ),
                    Positioned(
                      left: (0.60 * width - 12).clamp(0.0, width),
                      child: _ScaleLabel(tick2),
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

  Widget _buildWhrLegend(bool isFemale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLegendItem(
          icon: Icons.check_circle_outline,
          color: const Color(0xFF2CB67D),
          label: 'Low Risk',
          range: isFemale ? '< 0.80' : '< 0.90',
        ),
        _buildLegendItem(
          icon: Icons.warning_amber_rounded,
          color: Colors.orange,
          label: 'Moderate',
          range: isFemale ? '0.80 - 0.89' : '0.90 - 0.99',
        ),
        _buildLegendItem(
          icon: Icons.error_outline,
          color: Colors.red,
          label: 'High Risk',
          range: isFemale ? '≥ 0.90' : '≥ 1.00',
        ),
      ],
    );
  }

  // ── WHtR Card ──────────────────────────────────────────────────────────────
  Widget _buildWhtrCard(CustomerDetailsModel details) {
    final whtrVal = _whtr;
    final whtrStr = whtrVal != null ? whtrVal.toStringAsFixed(2) : null;

    Color categoryColor = const Color(0xFF2CB67D);
    String categoryLabel = 'Healthy (Normal)';

    if (whtrVal != null) {
      if (whtrVal < 0.40) {
        categoryColor = Colors.blue;
        categoryLabel = 'Slim / Underweight';
      } else if (whtrVal <= 0.49) {
        categoryColor = const Color(0xFF2CB67D);
        categoryLabel = 'Healthy / Low Risk';
      } else if (whtrVal <= 0.59) {
        categoryColor = Colors.orange;
        categoryLabel = 'Overweight / Increased Risk';
      } else {
        categoryColor = Colors.red;
        categoryLabel = 'High Risk / Obese';
      }
    }

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
                  Icons.square_foot_rounded,
                  color: Color(0xFF00796B),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Waist-to-Height Ratio (WHtR)',
                      style: AppStyles.text14Px.poppins.w600
                          .copyWith(color: AppColors.textDark),
                    ),
                    Text(
                      'Central adiposity & health risk scale',
                      style: AppStyles.text12Px.poppins.w400
                          .copyWith(color: const Color(0xFF868E96)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (whtrVal != null) ...[
            Center(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: whtrStr,
                      style: AppStyles.text20Px.poppins.w700.copyWith(
                        fontSize: 48,
                        color: AppColors.textDark,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: '  ratio',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: const Color(0xFF868E96),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: categoryColor, size: 10),
                  const SizedBox(width: 6),
                  Text(
                    categoryLabel,
                    style: AppStyles.text14Px.poppins.w600
                        .copyWith(color: categoryColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: categoryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Healthy target: 0.40 - 0.49 ratio',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: const Color(0xFF868E96),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 56),
            _buildWhtrScale(whtrVal, categoryColor),
            const SizedBox(height: 20),
            _buildWhtrLegend(),
          ] else ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.square_foot_rounded,
                    size: 32,
                    color: const Color(0xFF00796B).withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waist Measurement Needed',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add your waist measurement to calculate your Waist-to-Height Ratio.',
                    textAlign: TextAlign.center,
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      color: const Color(0xFF868E96),
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () => _showBodyMetricsBottomSheet(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Add Waist Measurement',
                            style: AppStyles.text12Px.poppins.w600.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _buildAboutSection(
            title: 'About Waist-to-Height Ratio (WHtR)',
            body:
                'WHtR measures central obesity by comparing your waist size to your height. Keeping your waist to less than half your height helps reduce metabolic risks.',
            formulaTitle: 'Golden Rule:',
            formulas: [
              'WHtR = Waist Circumference / Height',
              'Goal: Keep WHtR < 0.50 (Waist should be less than 50% of height)',
            ],
            expanded: _aboutWhtrExpanded,
            onTap: () => setState(() => _aboutWhtrExpanded = !_aboutWhtrExpanded),
          ),
        ],
      ),
    );
  }

  Widget _buildWhtrScale(double? whtrVal, Color color) {
    final current = whtrVal ?? 0.45;
    final fraction = ((current - 0.30) / (0.70 - 0.30)).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bubbleLeft = (fraction * width - 28).clamp(0.0, width - 56);
        final circleLeft = (fraction * width - 7).clamp(0.0, width - 14);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (whtrVal != null)
              Positioned(
                top: -48,
                left: bubbleLeft,
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
                        whtrVal.toStringAsFixed(2),
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
                    stops: [0.25, 0.50, 0.75, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -2,
              left: circleLeft,
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
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: SizedBox(
                height: 18,
                child: Stack(
                  children: [
                    Positioned(
                      left: (0.25 * width - 12).clamp(0.0, width),
                      child: const _ScaleLabel('0.40'),
                    ),
                    Positioned(
                      left: (0.50 * width - 12).clamp(0.0, width),
                      child: const _ScaleLabel('0.50'),
                    ),
                    Positioned(
                      left: (0.75 * width - 12).clamp(0.0, width),
                      child: const _ScaleLabel('0.60'),
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

  Widget _buildWhtrLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLegendItem(
          icon: Icons.person_outline,
          color: Colors.blue,
          label: 'Slim',
          range: '< 0.40',
        ),
        _buildLegendItem(
          icon: Icons.check_circle_outline,
          color: const Color(0xFF2CB67D),
          label: 'Healthy',
          range: '0.40 - 0.49',
        ),
        _buildLegendItem(
          icon: Icons.warning_amber_rounded,
          color: Colors.orange,
          label: 'Overweight',
          range: '0.50 - 0.59',
        ),
        _buildLegendItem(
          icon: Icons.error_outline,
          color: Colors.red,
          label: 'High Risk',
          range: '≥ 0.60',
        ),
      ],
    );
  }

  // ── Metrics Card ───────────────────────────────────────────────────────────
  Widget _buildMetricsCard() {
    final hVal = _bodyMatrix?.heightCm;
    final wVal = _bodyMatrix?.weightKg;
    final nVal = _bodyMatrix?.neckCm;
    final waistVal = _bodyMatrix?.waistCm;
    final hipVal = _bodyMatrix?.hipCm;

    final hStr = hVal != null ? _formatNum(hVal) : '-';
    final wStr = wVal != null ? _formatNum(wVal) : '-';
    final nStr = nVal != null ? _formatNum(nVal) : '-';
    final waistStr = waistVal != null ? _formatNum(waistVal) : '-';
    final hipStr = hipVal != null ? _formatNum(hipVal) : '-';

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
                  value: hStr,
                  suffix: 'cm',
                  onTap: () => _showBodyMetricsBottomSheet(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMeasurementTile(
                  icon: Icons.monitor_weight_outlined,
                  iconColor: const Color(0xFFFA5252),
                  label: 'Weight',
                  value: wStr,
                  suffix: 'kg',
                  onTap: () => _showBodyMetricsBottomSheet(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMeasurementTile(
                  icon: Icons.format_line_spacing_rounded,
                  iconColor: const Color(0xFF4C6EF5),
                  label: 'Neck',
                  value: nStr,
                  suffix: 'cm',
                  onTap: () => _showBodyMetricsBottomSheet(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMeasurementTile(
                  icon: Icons.straighten_rounded,
                  iconColor: const Color(0xFF8E24AA),
                  label: 'Waist',
                  value: waistStr,
                  suffix: 'cm',
                  onTap: () => _showBodyMetricsBottomSheet(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMeasurementTile(
                  icon: Icons.accessibility_new_rounded,
                  iconColor: const Color(0xFF00796B),
                  label: 'Hip',
                  value: hipStr,
                  suffix: 'cm',
                  onTap: () => _showBodyMetricsBottomSheet(context),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
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
    required String value,
    required String suffix,
    required VoidCallback onTap,
  }) {
    final isDash = value == '-';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                        Text(
                          value,
                          style: AppStyles.text14Px.poppins.w700
                              .copyWith(color: AppColors.textDark),
                        ),
                        if (!isDash) ...[
                          const SizedBox(width: 4),
                          Text(
                            suffix,
                            style: AppStyles.text12Px.poppins.w500
                                .copyWith(color: const Color(0xFF868E96)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBodyMetricsBottomSheet(BuildContext context) {
    final existingHeight = _bodyMatrix?.heightCm ?? double.tryParse(widget.customerDetails.height ?? '');
    final existingWeight = _bodyMatrix?.weightKg ?? double.tryParse(widget.customerDetails.weight ?? '');
    DateTime? selectedDob = widget.customerDetails.dateOfBirth;
    final existingGender = _bodyMatrix?.gender ?? widget.customerDetails.gender?.toString() ?? 'Male';
    final heightController = TextEditingController(
      text: existingHeight != null
          ? (existingHeight == existingHeight.toInt().toDouble()
              ? '${existingHeight.toInt()}'
              : existingHeight.toStringAsFixed(1))
          : '',
    );
    final weightController = TextEditingController(
      text: existingWeight != null
          ? (existingWeight == existingWeight.toInt().toDouble()
              ? '${existingWeight.toInt()}'
              : existingWeight.toStringAsFixed(1))
          : '',
    );
    final neckController = TextEditingController(
      text: _bodyMatrix?.neckCm != null
          ? _formatNum(_bodyMatrix!.neckCm!)
          : '',
    );
    final waistController = TextEditingController(
      text: _bodyMatrix?.waistCm != null
          ? _formatNum(_bodyMatrix!.waistCm!)
          : '',
    );
    final hipController = TextEditingController(
      text: _bodyMatrix?.hipCm != null
          ? _formatNum(_bodyMatrix!.hipCm!)
          : '',
    );

    String heightUnit = 'cm';
    String weightUnit = 'kg';
    String neckUnit = 'cm';
    String waistUnit = 'cm';
    String hipUnit = 'cm';
    String gender = existingGender.toLowerCase().startsWith('f') ? 'Female' : 'Male';

    final profileCubit = BlocProvider.of<ProfileCubit>(context);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: profileCubit,
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDEE2E6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Title row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Update Body Metrics',
                              style: AppStyles.text18Px.poppins.w600.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(sheetContext).pop(),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF1F3F5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: Color(0xFF495057),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Row 1: Height & Weight
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Height',
                                    style: AppStyles.text13Px.poppins.w600.copyWith(
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildMetricInputField(
                                    controller: heightController,
                                    hint: 'e.g. 170',
                                    selectedUnit: heightUnit,
                                    units: const ['cm', 'ft'],
                                    onUnitChanged: (val) {
                                      setSheetState(() => heightUnit = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Weight',
                                    style: AppStyles.text13Px.poppins.w600.copyWith(
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildMetricInputField(
                                    controller: weightController,
                                    hint: 'e.g. 65',
                                    selectedUnit: weightUnit,
                                    units: const ['kg', 'lbs'],
                                    onUnitChanged: (val) {
                                      setSheetState(() => weightUnit = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 2: Date of Birth & Gender
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date of Birth',
                                    style: AppStyles.text13Px.poppins.w600.copyWith(
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDateField(
                                    context: ctx,
                                    selectedDate: selectedDob,
                                    onDateSelected: (newDate) {
                                      setSheetState(() => selectedDob = newDate);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gender',
                                    style: AppStyles.text13Px.poppins.w600.copyWith(
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildGenderDropdown(
                                    selectedGender: gender,
                                    onChanged: (val) {
                                      setSheetState(() => gender = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 3: Neck & Waist
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Neck',
                                    style: AppStyles.text13Px.poppins.w600.copyWith(
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildMetricInputField(
                                    controller: neckController,
                                    hint: 'e.g. 38',
                                    selectedUnit: neckUnit,
                                    units: const ['cm', 'in'],
                                    onUnitChanged: (val) {
                                      setSheetState(() => neckUnit = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Waist',
                                    style: AppStyles.text13Px.poppins.w600.copyWith(
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildMetricInputField(
                                    controller: waistController,
                                    hint: 'e.g. 80',
                                    selectedUnit: waistUnit,
                                    units: const ['cm', 'in'],
                                    onUnitChanged: (val) {
                                      setSheetState(() => waistUnit = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Row 4: Hip & Placeholder
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hip',
                                    style: AppStyles.text13Px.poppins.w600.copyWith(
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildMetricInputField(
                                    controller: hipController,
                                    hint: 'e.g. 95',
                                    selectedUnit: hipUnit,
                                    units: const ['cm', 'in'],
                                    onUnitChanged: (val) {
                                      setSheetState(() => hipUnit = val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Save button
                        BlocConsumer<ProfileCubit, ProfileState>(
                          listener: (ctx, state) {
                            state.updateProfileDetails?.fold(
                              () => null,
                              (either) => either.fold(
                                (error) {
                                  Navigator.of(sheetContext).pop();
                                  Dialogs.showSnack(
                                    msg: AppErrorHandler.formatUserFriendlyMessage(error.msg, fallback: 'Failed to update metrics. Please try again.'),
                                  );
                                },
                                (_) {
                                  Navigator.of(sheetContext).pop();
                                  Dialogs.showSnack(
                                    msg: 'Body metrics updated successfully!',
                                  );
                                  _fetchBodyMatrix();
                                },
                              ),
                            );
                          },
                          builder: (ctx, state) {
                            final isLoading = false;
                            return SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        final heightText =
                                            heightController.text.trim();
                                        final weightText =
                                            weightController.text.trim();
                                        final neckText =
                                            neckController.text.trim();
                                        final waistText =
                                            waistController.text.trim();
                                        final hipText =
                                            hipController.text.trim();

                                        if (heightText.isEmpty ||
                                            weightText.isEmpty ||
                                            selectedDob == null) {
                                          Dialogs.showSnack(
                                            msg: 'Please enter height, weight, and date of birth.',
                                          );
                                          return;
                                        }
                                        double? heightVal =
                                            double.tryParse(heightText);
                                        double? weightVal =
                                            double.tryParse(weightText);
                                        if (heightVal == null ||
                                            weightVal == null) {
                                          Dialogs.showSnack(
                                            msg: 'Please enter valid numbers.',
                                          );
                                          return;
                                        }
                                        final ageVal = DateTime.now().year - selectedDob!.year;
                                        // Convert to cm if needed
                                        if (heightUnit == 'ft') {
                                          heightVal = heightVal * 30.48;
                                        }
                                        // Convert to kg if needed
                                        if (weightUnit == 'lbs') {
                                          weightVal = weightVal * 0.453592;
                                        }

                                        double? neckVal =
                                            double.tryParse(neckText);
                                        double? waistVal =
                                            double.tryParse(waistText);
                                        double? hipVal =
                                            double.tryParse(hipText);

                                        // Calculate body fat percentage
                                        double bfPercentageVal;
                                        final bmiVal = weightVal / pow(heightVal / 100, 2);
                                        if (neckVal != null && waistVal != null && (gender.toLowerCase().startsWith('m') || hipVal != null)) {
                                          // Convert neck, waist, hip to cm
                                          double neckCm = neckVal;
                                          if (neckUnit == 'in') neckCm = neckVal * 2.54;
                                          double waistCm = waistVal;
                                          if (waistUnit == 'in') waistCm = waistVal * 2.54;
                                          
                                          if (gender.toLowerCase().startsWith('f')) {
                                            double hipCm = hipVal ?? 0.0;
                                            if (hipUnit == 'in') hipCm = hipVal! * 2.54;
                                            
                                            final val = 1.29579 - 0.35004 * (log(waistCm + hipCm - neckCm) / ln10) + 0.22100 * (log(heightVal) / ln10);
                                            bfPercentageVal = val > 0 ? (495 / val) - 450 : ((1.20 * bmiVal) + (0.23 * ageVal) - 5.4);
                                          } else {
                                            final val = 1.0324 - 0.19077 * (log(waistCm - neckCm) / ln10) + 0.15456 * (log(heightVal) / ln10);
                                            bfPercentageVal = val > 0 ? (495 / val) - 450 : ((1.20 * bmiVal) + (0.23 * ageVal) - 16.2);
                                          }
                                        } else {
                                          // Fallback to BMI-based body fat calculation
                                          if (gender.toLowerCase().startsWith('f')) {
                                            bfPercentageVal = (1.20 * bmiVal) + (0.23 * ageVal) - 5.4;
                                          } else {
                                            bfPercentageVal = (1.20 * bmiVal) + (0.23 * ageVal) - 16.2;
                                          }
                                        }

                                        // Clamp body fat percentage between 2% and 60% for safety
                                        bfPercentageVal = bfPercentageVal.clamp(2.0, 60.0);

                                        final heightStr = heightVal.toStringAsFixed(2);
                                        final weightStr = weightVal.toStringAsFixed(2);
                                        
                                        final dobStr = '${selectedDob!.year}-${selectedDob!.month.toString().padLeft(2, '0')}-${selectedDob!.day.toString().padLeft(2, '0')}';
                                        
                                        final Map<String, dynamic> extraPayload = {
                                          'height': heightStr,
                                          'weight': weightStr,
                                          'gender': gender.toLowerCase(),
                                          'date_of_birth': dobStr,
                                          'bf_percentage': bfPercentageVal.toStringAsFixed(1),
                                        };
                                        final bg = widget.customerDetails.bloodGroup;
                                        if (bg != null && bg.trim().isNotEmpty) {
                                          extraPayload['blood_group'] = bg.trim();
                                        }

                                        String? calculatedNeckStr;
                                        String? calculatedWaistStr;
                                        String? calculatedHipStr;

                                        if (neckVal != null) {
                                          double neckCm = neckVal;
                                          if (neckUnit == 'in') neckCm = neckVal * 2.54;
                                          calculatedNeckStr = neckCm.toStringAsFixed(1);
                                          extraPayload['neck'] = calculatedNeckStr;
                                        }
                                        if (waistVal != null) {
                                          double waistCm = waistVal;
                                          if (waistUnit == 'in') waistCm = waistVal * 2.54;
                                          calculatedWaistStr = waistCm.toStringAsFixed(1);
                                          extraPayload['waist'] = calculatedWaistStr;
                                        }
                                        if (hipVal != null) {
                                          double hipCm = hipVal;
                                          if (hipUnit == 'in') hipCm = hipVal * 2.54;
                                          calculatedHipStr = hipCm.toStringAsFixed(1);
                                          extraPayload['hip'] = calculatedHipStr;
                                        }

                                        await profileCubit.updateHealthProfile(
                                          bloodGroup: bg ?? '',
                                          height: heightStr,
                                          weight: weightStr,
                                          extraBody: extraPayload,
                                        );

                                        if (neckVal != null || waistVal != null || hipVal != null) {
                                            double? finalNeckCm;
                                            double? finalWaistCm;
                                            double? finalHipCm;
                                            if (neckVal != null) {
                                              finalNeckCm = neckUnit == 'in' ? neckVal * 2.54 : neckVal;
                                            }
                                            if (waistVal != null) {
                                              finalWaistCm = waistUnit == 'in' ? waistVal * 2.54 : waistVal;
                                           }
                                           if (hipVal != null) {
                                             finalHipCm = hipUnit == 'in' ? hipVal * 2.54 : hipVal;
                                           }
                                           await profileCubit.logBodyMeasurements(
                                             neck: finalNeckCm,
                                             waist: finalWaistCm,
                                             hip: finalHipCm,
                                           );
                                         }
                                      },
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Save Changes',
                                        style: AppStyles.text16Px.poppins.w600
                                            .copyWith(color: Colors.white),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Cancel
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(sheetContext).pop(),
                            child: Text(
                              'Cancel',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMetricInputField({
    required TextEditingController controller,
    required String hint,
    required String selectedUnit,
    required List<String> units,
    required void Function(String) onUnitChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEE2E6), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppStyles.text16Px.poppins.w500.copyWith(
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                  color: const Color(0xFFADB5BD),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: const Color(0xFFDEE2E6),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedUnit,
                onChanged: (v) => onUnitChanged(v!),
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: AppColors.textDark,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF868E96),
                ),
                items: units
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(u),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildSimpleInputField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEE2E6), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppStyles.text16Px.poppins.w500.copyWith(
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
            color: const Color(0xFFADB5BD),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown({
    required String selectedGender,
    required void Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEE2E6), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          isExpanded: true,
          onChanged: (v) => onChanged(v!),
          style: AppStyles.text16Px.poppins.w500.copyWith(
            color: AppColors.textDark,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 24,
            color: Color(0xFF868E96),
          ),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required DateTime? selectedDate,
    required void Function(DateTime) onDateSelected,
  }) {
    final text = selectedDate != null
        ? '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'
        : 'DD/MM/YYYY';

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime(2000, 1, 1),
          firstDate: DateTime(1900),
          lastDate: now,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: AppColors.primary),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDEE2E6), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: AppStyles.text14Px.poppins.w500.copyWith(
                color: selectedDate != null
                    ? AppColors.textDark
                    : const Color(0xFFADB5BD),
              ),
            ),
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: Color(0xFF868E96),
            ),
          ],
        ),
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
    String? formulaTitle,
    List<String>? formulas,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1FAF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: expanded
                ? const Color(0xFF2CB67D).withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
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
              if (formulas != null && formulas.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2CB67D).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.functions,
                            size: 14,
                            color: Color(0xFF2CB67D),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formulaTitle ?? 'Calculation Formula:',
                            style: AppStyles.text12Px.poppins.w600.copyWith(
                              color: const Color(0xFF2CB67D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...formulas.map(
                        (formulaText) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              formulaText,
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: const Color(0xFF212529),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

class _RatioCategoryItem {
  final String label;
  final String range;
  final Color color;

  const _RatioCategoryItem({
    required this.label,
    required this.range,
    required this.color,
  });
}
