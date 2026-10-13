import 'package:customer_mobile_app/imports_bindings.dart';

/// Live API-connected Body Matrix History View with a single big graph
/// and a dropdown metric selector at the top.
class BodyMatrixHistoryView extends StatefulWidget {
  const BodyMatrixHistoryView({
    required this.customerDetails,
    super.key,
  });

  final CustomerDetailsModel customerDetails;

  @override
  State<BodyMatrixHistoryView> createState() => BodyMatrixHistoryViewState();
}

class BodyMatrixHistoryViewState extends State<BodyMatrixHistoryView> {
  bool _isLoading = true;
  String? _errorMessage;
  BodyMetricsHistoryData? _historyData;
  String _selectedMetricKey = 'bmi';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await CustomerDetailsRepository().fetchBodyMetricsHistory(
      userId: widget.customerDetails.id,
    );

    if (!mounted) return;

    res.fold(
      (error) {
        setState(() {
          _isLoading = false;
          _errorMessage = error.msg;
        });
      },
      (data) {
        var finalData = data;
        final custHeight = double.tryParse(widget.customerDetails.height ?? '');
        final custWeight = double.tryParse(widget.customerDetails.weight ?? '');

        var heightMetric = data.metrics.height;
        if (heightMetric == null && custHeight != null && custHeight > 0) {
          heightMetric = BodyMetricItem(
            metricKey: 'height',
            title: 'Height',
            subtitle: 'Stature history',
            currentValue: custHeight,
            unit: 'cm',
            history: [
              BodyMetricHistoryPoint(date: 'Current', value: custHeight),
            ],
          );
        }

        var weightMetric = data.metrics.weight;
        if (weightMetric == null && custWeight != null && custWeight > 0) {
          weightMetric = BodyMetricItem(
            metricKey: 'weight',
            title: 'Weight',
            subtitle: 'Body weight history',
            currentValue: custWeight,
            unit: 'kg',
            history: [
              BodyMetricHistoryPoint(date: 'Current', value: custWeight),
            ],
          );
        }

        if (heightMetric != data.metrics.height ||
            weightMetric != data.metrics.weight) {
          finalData = BodyMetricsHistoryData(
            userId: data.userId,
            customerId: data.customerId,
            userName: data.userName,
            gender: data.gender,
            age: data.age,
            heightCm: data.heightCm ?? custHeight,
            currentWeightKg: data.currentWeightKg ?? custWeight,
            timeframe: data.timeframe,
            metrics: BodyMetricsMap(
              bmi: data.metrics.bmi,
              bmr: data.metrics.bmr,
              bodyFat: data.metrics.bodyFat,
              waistHipRatio: data.metrics.waistHipRatio,
              waistHeightRatio: data.metrics.waistHeightRatio,
              height: heightMetric,
              weight: weightMetric,
            ),
          );
        }

        setState(() {
          _isLoading = false;
          _historyData = finalData;
          final available = finalData.orderedMetrics;
          if (available.isNotEmpty) {
            final exists = available.any((m) =>
                _normalizeMetricKey(m.metricKey) ==
                _normalizeMetricKey(_selectedMetricKey));
            if (!exists) {
              _selectedMetricKey =
                  _normalizeMetricKey(available.first.metricKey);
            }
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    if (_errorMessage != null) {
      return _buildErrorView(_errorMessage!);
    }

    final data = _historyData;
    if (data == null || !data.hasAnyData || data.orderedMetrics.isEmpty) {
      return _buildEmptyView();
    }

    final metrics = data.orderedMetrics;
    final activeKey = _normalizeMetricKey(_selectedMetricKey);
    final selectedMetric = metrics.firstWhere(
      (m) => _normalizeMetricKey(m.metricKey) == activeKey,
      orElse: () => metrics.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricSelectorDropdown(metrics),
        const SizedBox(height: 16),
        _buildMetricCard(selectedMetric),
      ],
    );
  }

  Widget _buildMetricSelectorDropdown(List<BodyMetricItem> metrics) {
    final activeKey = _normalizeMetricKey(_selectedMetricKey);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: metrics.any((m) => _normalizeMetricKey(m.metricKey) == activeKey)
              ? activeKey
              : _normalizeMetricKey(metrics.first.metricKey),
          isExpanded: true,
          itemHeight: 56,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF4B5563),
            size: 24,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(18),
          elevation: 6,
          items: metrics.map((item) {
            final (color, bgColor, icon) = _resolveMetricStyle(item.metricKey);
            final title = item.title.isNotEmpty
                ? item.title
                : _resolveDefaultTitle(item.metricKey);
            final subtitle = item.subtitle.isNotEmpty
                ? item.subtitle
                : _resolveDefaultSubtitle(item.metricKey);
            final itemKey = _normalizeMetricKey(item.metricKey);
            final isSelected = itemKey == activeKey;

            return DropdownMenuItem<String>(
              value: itemKey,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(icon, color: color, size: 19),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: isSelected
                                ? color
                                : const Color(0xFF111827),
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: AppStyles.text11Px.poppins.w400.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle_rounded, color: color, size: 20),
                ],
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) {
            return metrics.map((item) {
              final (color, bgColor, icon) =
                  _resolveMetricStyle(item.metricKey);
              final title = item.title.isNotEmpty
                  ? item.title
                  : _resolveDefaultTitle(item.metricKey);
              final subtitle = item.subtitle.isNotEmpty
                  ? item.subtitle
                  : _resolveDefaultSubtitle(item.metricKey);

              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Icon(icon, color: color, size: 19),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppStyles.text15Px.poppins.w700.copyWith(
                            color: const Color(0xFF111827),
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            style: AppStyles.text11Px.poppins.w400.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList();
          },
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedMetricKey = val;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildMetricCard(BodyMetricItem metric) {
    final (themeColor, themeBgColor, icon) =
        _resolveMetricStyle(metric.metricKey);
    final (minY, maxY, yLabels, decimals, isInt) =
        _resolveChartLimits(metric.metricKey, metric);

    final isIncrease = metric.isIncrease;
    final isFavorable = metric.metricKey == 'bmr' ? isIncrease : !isIncrease;
    final trendColor =
        isFavorable ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    final badgeColor = _parseHexColor(metric.statusColor, trendColor);
    final badgeBgColor = badgeColor.withValues(alpha: 0.12);

    final (rangeLabel, rangeValue) = _parseRangeInfo(metric.rangeText);

    final chartPoints = metric.history.map((e) => e.value).toList();
    final chartDates = metric.history.map((e) => e.date).toList();

    final defaultUnit = _resolveDefaultUnit(metric.metricKey);
    final unit = metric.unit.isNotEmpty
        ? metric.unit
        : (defaultUnit.isNotEmpty ? defaultUnit : null);

    return BodyMatrixHistoryCard(
      title: metric.title.isNotEmpty
          ? metric.title
          : _resolveDefaultTitle(metric.metricKey),
      subtitle: metric.subtitle.isNotEmpty
          ? metric.subtitle
          : _resolveDefaultSubtitle(metric.metricKey),
      icon: icon,
      themeColor: themeColor,
      themeBgColor: themeBgColor,
      currentValue:
          _formatCurrentValue(metric.metricKey, metric.currentValue),
      unit: unit,
      deltaValue: metric.deltaFormatted ??
          (metric.delta != null
              ? '${metric.delta! > 0 ? "↑ " : "↓ "}${metric.delta!.abs().toStringAsFixed(decimals)}'
              : ''),
      isIncrease: isIncrease,
      isFavorable: isFavorable,
      badgeLabel: metric.statusBadge ?? metric.status ?? 'Normal',
      badgeColor: badgeColor,
      badgeBgColor: badgeBgColor,
      rangeLabel: rangeLabel,
      rangeValue: rangeValue,
      sinceText: metric.sinceText ??
          (metric.sinceDate != null ? 'since ${metric.sinceDate}' : ''),
      chartPoints: chartPoints,
      chartDates: chartDates,
      yAxisLabels: yLabels,
      minY: minY,
      maxY: maxY,
      decimalPlaces: decimals,
      formatYAsInt: isInt,
      insightText: metric.insight,
    );
  }

  String _normalizeMetricKey(String key) {
    final k = key.toLowerCase().trim().replaceAll('-', '_');
    if (k == 'bodyfat') return 'body_fat';
    if (k == 'whr') return 'waist_hip_ratio';
    if (k == 'whtr' || k == 'waist_hip_height') return 'waist_height_ratio';
    if (k == 'weight_kg' || k == 'body_weight') return 'weight';
    if (k == 'height_cm') return 'height';
    return k;
  }

  (Color, Color, IconData) _resolveMetricStyle(String key) {
    final normalized = _normalizeMetricKey(key);
    switch (normalized) {
      case 'bmi':
        return (
          const Color(0xFF4C6EF5), // Royal blue matching Present Condition
          const Color(0xFFEEF2FF),
          Icons.monitor_weight_outlined,
        );
      case 'bmr':
        return (
          const Color(0xFFFF9800), // Vibrant orange matching Present Condition
          const Color(0xFFFFF3E0),
          Icons.local_fire_department_rounded,
        );
      case 'body_fat':
        return (
          const Color(0xFF00A896), // Teal matching Present Condition
          const Color(0xFFE0F2F1),
          Icons.percent_rounded,
        );
      case 'weight':
        return (
          const Color(0xFF0284C7), // Sky/Azure blue matching weight
          const Color(0xFFE0F2FE),
          Icons.scale_rounded,
        );
      case 'height':
        return (
          const Color(0xFF10B981), // Emerald green matching stature
          const Color(0xFFECFDF5),
          Icons.height_rounded,
        );
      case 'waist_hip_ratio':
        return (
          const Color(0xFFFF5252), // Coral red matching Present Condition
          const Color(0xFFFFF0F2),
          Icons.accessibility_new_rounded,
        );
      case 'waist_height_ratio':
        return (
          const Color(0xFF7C3AED), // Purple/violet palette matching ratios
          const Color(0xFFF5F3FF),
          Icons.square_foot_rounded,
        );
      default:
        return (
          AppColors.primary,
          const Color(0xFFFFEEEE),
          Icons.fitness_center_rounded,
        );
    }
  }

  String _resolveDefaultTitle(String key) {
    final normalized = _normalizeMetricKey(key);
    switch (normalized) {
      case 'bmi':
        return 'BMI';
      case 'bmr':
        return 'BMR';
      case 'body_fat':
        return 'Body Fat';
      case 'weight':
        return 'Weight';
      case 'height':
        return 'Height';
      case 'waist_hip_ratio':
        return 'Waist-to-Hip Ratio';
      case 'waist_height_ratio':
        return 'Waist-to-Height Ratio';
      default:
        return key;
    }
  }

  String _resolveDefaultSubtitle(String key) {
    final normalized = _normalizeMetricKey(key);
    switch (normalized) {
      case 'bmi':
        return 'Body Mass Index';
      case 'bmr':
        return 'Basal Metabolic Rate';
      case 'body_fat':
        return 'Body Fat Percentage';
      case 'weight':
        return 'Body Weight History';
      case 'height':
        return 'Stature History';
      case 'waist_hip_ratio':
        return 'Fat distribution indicator';
      case 'waist_height_ratio':
        return 'Central obesity indicator';
      default:
        return '';
    }
  }

  String _resolveDefaultUnit(String key) {
    final normalized = _normalizeMetricKey(key);
    switch (normalized) {
      case 'bmr':
        return 'kcal/day';
      case 'body_fat':
        return '%';
      case 'weight':
        return 'kg';
      case 'height':
        return 'cm';
      default:
        return '';
    }
  }

  String _formatCurrentValue(String metricKey, double value) {
    final normalized = _normalizeMetricKey(metricKey);
    if (normalized == 'bmr') {
      return NumberFormat('#,###').format(value.round());
    } else if (normalized == 'waist_hip_ratio' ||
        normalized == 'waist_height_ratio') {
      return value.toStringAsFixed(2);
    } else if (normalized == 'height') {
      return value == value.roundToDouble()
          ? value.toInt().toString()
          : value.toStringAsFixed(1);
    } else {
      return value.toStringAsFixed(1);
    }
  }

  (String, String) _parseRangeInfo(String? rangeText) {
    if (rangeText == null || rangeText.isEmpty) {
      return ('', '');
    }
    final trimmed = rangeText.trim();
    if (trimmed.toLowerCase().startsWith('healthy range')) {
      return (
        'Healthy range',
        trimmed.substring('healthy range'.length).trim(),
      );
    }
    if (trimmed.toLowerCase().startsWith('optimal burn')) {
      return (
        'Target calories',
        trimmed.substring('optimal burn'.length).trim(),
      );
    }
    return ('Healthy range', trimmed);
  }

  Color _parseHexColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    try {
      final hex = hexString.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      } else if (hex.length == 8) {
        return Color(int.parse('0x$hex'));
      }
    } catch (_) {}
    return fallback;
  }

  (double, double, List<double>, int, bool) _resolveChartLimits(
    String metricKey,
    BodyMetricItem metric,
  ) {
    final normalized = _normalizeMetricKey(metricKey);
    if (metric.history.isEmpty) {
      return (0, 100, const [0, 25, 50, 75, 100], 0, true);
    }

    final values = metric.history.map((e) => e.value).toList();
    var minVal = values.reduce(min);
    var maxVal = values.reduce(max);

    if (metric.chartMeta?.minValue != null) {
      minVal = metric.chartMeta!.minValue!;
    }
    if (metric.chartMeta?.maxValue != null) {
      maxVal = metric.chartMeta!.maxValue!;
    }

    if (minVal == maxVal) {
      if (minVal == 0) {
        minVal = 0;
        maxVal = 10;
      } else {
        minVal = (minVal * 0.9).floorToDouble();
        maxVal = (maxVal * 1.1).ceilToDouble();
      }
    }

    int decimals;
    bool isInt;
    if (normalized == 'bmr') {
      decimals = 0;
      isInt = true;
      minVal = (minVal / 100).floor() * 100.0;
      maxVal = (maxVal / 100).ceil() * 100.0;
    } else if (normalized == 'bmi' ||
        normalized == 'body_fat' ||
        normalized == 'weight') {
      decimals = 1;
      isInt = minVal == minVal.toInt() && maxVal == maxVal.toInt();
      minVal = (minVal - 1).floorToDouble();
      maxVal = (maxVal + 1).ceilToDouble();
    } else if (normalized == 'height') {
      decimals = 0;
      isInt = true;
      minVal = (minVal - 5).floorToDouble();
      maxVal = (maxVal + 5).ceilToDouble();
    } else {
      decimals = 2;
      isInt = false;
      minVal = double.parse(
          (minVal - 0.05).clamp(0, double.infinity).toStringAsFixed(2));
      maxVal = double.parse((maxVal + 0.05).toStringAsFixed(2));
    }

    final step = (maxVal - minVal) / 4;
    final yLabels = <double>[];
    for (var i = 0; i <= 4; i++) {
      final val = minVal + (step * i);
      yLabels.add(double.parse(val.toStringAsFixed(decimals)));
    }

    return (minVal, maxVal, yLabels, decimals, isInt);
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF3F4F6),
      child: Column(
        children: [
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ],
      ),
    );
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
            'Failed to Load History',
            style: AppStyles.text18Px.poppins.w700.copyWith(
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message.isNotEmpty
                ? message
                : 'Unable to retrieve your body metrics history. Please try again.',
            textAlign: TextAlign.center,
            style: AppStyles.text13Px.poppins.w400.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchHistory,
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

  Widget _buildEmptyView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F3F5),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.monitor_weight_outlined,
                color: Color(0xFF9CA3AF),
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No History Recorded Yet',
            textAlign: TextAlign.center,
            style: AppStyles.text18Px.poppins.w700.copyWith(
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log your body weight and measurements regularly to start tracking your progress trends and milestones over time.',
            textAlign: TextAlign.center,
            style: AppStyles.text13Px.poppins.w400.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchHistory,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              'Refresh',
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
}

/// Single Big Card Widget for History Metric
class BodyMatrixHistoryCard extends StatelessWidget {
  const BodyMatrixHistoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.themeColor,
    required this.themeBgColor,
    required this.currentValue,
    required this.deltaValue,
    required this.isIncrease,
    required this.isFavorable,
    required this.badgeLabel,
    required this.badgeColor,
    required this.badgeBgColor,
    required this.rangeLabel,
    required this.rangeValue,
    required this.chartPoints,
    required this.chartDates,
    required this.yAxisLabels,
    required this.minY,
    required this.maxY,
    this.unit,
    this.sinceText = '',
    this.decimalPlaces = 1,
    this.formatYAsInt = true,
    this.insightText,
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color themeColor;
  final Color themeBgColor;
  final String currentValue;
  final String? unit;
  final String deltaValue;
  final bool isIncrease;
  final bool isFavorable;
  final String badgeLabel;
  final Color badgeColor;
  final Color badgeBgColor;
  final String rangeLabel;
  final String rangeValue;
  final String sinceText;
  final List<double> chartPoints;
  final List<String> chartDates;
  final List<double> yAxisLabels;
  final double minY;
  final double maxY;
  final int decimalPlaces;
  final bool formatYAsInt;
  final String? insightText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final trendColor =
        isFavorable ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: themeBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(icon, color: themeColor, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyles.text18Px.poppins.w700.copyWith(
                        color: const Color(0xFF111827),
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (badgeLabel.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: badgeBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeLabel,
                    style: AppStyles.text11Px.poppins.w600.copyWith(
                      color: badgeColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Main Stats Row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Value & Trend
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        currentValue,
                        style: AppStyles.text32Px.poppins.w800.copyWith(
                          color: const Color(0xFF111827),
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      if (unit != null && unit!.isNotEmpty) ...[
                        const SizedBox(width: 5),
                        Text(
                          unit!,
                          style: AppStyles.text13Px.poppins.w500.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (deltaValue.isNotEmpty || sinceText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (deltaValue.isNotEmpty) ...[
                          Icon(
                            isIncrease
                                ? Icons.arrow_upward_rounded
                                : Icons.arrow_downward_rounded,
                            size: 14,
                            color: trendColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            deltaValue,
                            style: AppStyles.text12Px.poppins.w700.copyWith(
                              color: trendColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (sinceText.isNotEmpty)
                          Text(
                            sinceText,
                            style: AppStyles.text11Px.poppins.w400.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              // Range Info
              if (rangeLabel.isNotEmpty && rangeValue.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      rangeLabel,
                      style: AppStyles.text11Px.poppins.w400.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      rangeValue,
                      style: AppStyles.text13Px.poppins.w600.copyWith(
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Divider ──
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 14),

          // ── The Big Line Chart ──
          SizedBox(
            height: 220,
            width: double.infinity,
            child: chartPoints.isNotEmpty
                ? CustomPaint(
                    size: const Size(double.infinity, 220),
                    painter: _HistoryMetricChartPainter(
                      points: chartPoints,
                      dates: chartDates,
                      yLabels: yAxisLabels,
                      minY: minY,
                      maxY: maxY,
                      themeColor: themeColor,
                      decimalPlaces: decimalPlaces,
                      formatYAsInt: formatYAsInt,
                    ),
                  )
                : Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          size: 32,
                          color:
                              const Color(0xFF9CA3AF).withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No timeline entries yet for $title',
                          style: AppStyles.text12Px.poppins.w500.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // ── Insight / Tip Box (if available) ──
          if (insightText != null && insightText!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: themeBgColor.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: themeColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 18,
                    color: themeColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insightText!,
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: const Color(0xFF374151),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom line chart painter matching the big chart design specifications
class _HistoryMetricChartPainter extends CustomPainter {
  _HistoryMetricChartPainter({
    required this.points,
    required this.dates,
    required this.yLabels,
    required this.minY,
    required this.maxY,
    required this.themeColor,
    required this.decimalPlaces,
    required this.formatYAsInt,
  });

  final List<double> points;
  final List<String> dates;
  final List<double> yLabels;
  final double minY;
  final double maxY;
  final Color themeColor;
  final int decimalPlaces;
  final bool formatYAsInt;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // Compute dynamic width for Y-axis labels
    var maxYLabelWidth = 0.0;
    for (final yVal in yLabels) {
      final text = _formatYLabel(yVal);
      final p = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (p.width > maxYLabelWidth) {
        maxYLabelWidth = p.width;
      }
    }

    final leftPadding = maxYLabelWidth + 10;
    const rightPadding = 16.0;
    const topPadding = 20.0;
    const bottomPadding = 26.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    final range = (maxY - minY) == 0 ? 1.0 : (maxY - minY);

    // ── 1. Draw Grid Lines & Y-Axis Labels ──
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;

    final axisLinePaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1;

    // Draw vertical Y-axis line
    canvas.drawLine(
      Offset(leftPadding, topPadding - 4),
      Offset(leftPadding, size.height - bottomPadding),
      axisLinePaint,
    );

    for (final yVal in yLabels) {
      final norm = (yVal - minY) / range;
      final y = topPadding + (1 - norm) * chartHeight;

      // Horizontal gridline
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding + 4, y),
        gridPaint,
      );

      // Y-axis label text
      final text = _formatYLabel(yVal);
      final yPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 9.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      yPainter.paint(
        canvas,
        Offset(leftPadding - yPainter.width - 5, y - (yPainter.height / 2)),
      );
    }

    // ── 2. Calculate Point Coordinates ──
    final pointOffsets = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final x = points.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + (i * (chartWidth / (points.length - 1)));
      final norm = (points[i] - minY) / range;
      final y = topPadding + (1 - norm) * chartHeight;
      pointOffsets.add(Offset(x, y));
    }

    // ── 3. Draw Area Gradient & Trend Line (if > 1 point) ──
    if (pointOffsets.length > 1) {
      final path = Path()
        ..moveTo(pointOffsets.first.dx, pointOffsets.first.dy);
      for (var i = 0; i < pointOffsets.length - 1; i++) {
        path.lineTo(pointOffsets[i + 1].dx, pointOffsets[i + 1].dy);
      }

      final fillPath = Path.from(path)
        ..lineTo(pointOffsets.last.dx, size.height - bottomPadding)
        ..lineTo(pointOffsets.first.dx, size.height - bottomPadding)
        ..close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            themeColor.withValues(alpha: 0.18),
            themeColor.withValues(alpha: 0),
          ],
        ).createShader(
            Rect.fromLTWH(0, topPadding, size.width, chartHeight));

      canvas.drawPath(fillPath, fillPaint);

      final linePaint = Paint()
        ..color = themeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, linePaint);
    }

    // ── 4. Draw Point Dots, Value Labels, and X Dates ──
    for (var i = 0; i < pointOffsets.length; i++) {
      final pt = pointOffsets[i];

      // Draw outer point dot & inner white center
      canvas
        ..drawCircle(pt, 4.2, Paint()..color = themeColor)
        ..drawCircle(pt, 1.8, Paint()..color = Colors.white);

      // Data point value text directly above dot
      final valText = formatYAsInt && points[i] >= 1000
          ? NumberFormat('#,###').format(points[i])
          : (decimalPlaces == 0
              ? points[i].round().toString()
              : points[i].toStringAsFixed(decimalPlaces));

      final valPainter = TextPainter(
        text: TextSpan(
          text: valText,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final xValOffset = (pt.dx - valPainter.width / 2)
          .clamp(leftPadding, size.width - valPainter.width - 2);
      valPainter.paint(
        canvas,
        Offset(xValOffset, pt.dy - valPainter.height - 4),
      );

      // Date label below chart
      if (i < dates.length) {
        final datePainter = TextPainter(
          text: TextSpan(
            text: dates[i],
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final xDateOffset = (pt.dx - datePainter.width / 2)
            .clamp(leftPadding - 8, size.width - datePainter.width);
        datePainter.paint(
          canvas,
          Offset(xDateOffset, size.height - bottomPadding + 6),
        );
      }
    }
  }

  String _formatYLabel(double val) {
    if (formatYAsInt) {
      if (val >= 1000) {
        return NumberFormat('#,###').format(val);
      }
      return val.toInt().toString();
    }
    return val.toStringAsFixed(decimalPlaces);
  }

  @override
  bool shouldRepaint(covariant _HistoryMetricChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.dates != dates ||
        oldDelegate.themeColor != themeColor ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY;
  }
}
