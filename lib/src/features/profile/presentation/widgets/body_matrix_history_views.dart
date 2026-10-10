import 'package:customer_mobile_app/imports_bindings.dart';

/// Live API-connected Body Matrix History View.
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
        setState(() {
          _isLoading = false;
          _historyData = data;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < metrics.length; i++) ...[
          _buildMetricCard(metrics[i]),
          if (i < metrics.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildMetricCard(BodyMetricItem metric) {
    final (themeColor, themeBgColor, icon) = _resolveMetricStyle(metric.metricKey);
    final (minY, maxY, yLabels, decimals, isInt) =
        _resolveChartLimits(metric.metricKey, metric);

    final isIncrease = metric.isIncrease;
    final isFavorable = metric.metricKey == 'bmr' ? isIncrease : !isIncrease;
    final trendColor = isFavorable ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    final badgeColor = _parseHexColor(metric.statusColor, trendColor);
    final badgeBgColor = badgeColor.withValues(alpha: 0.12);

    final (rangeLabel, rangeValue) = _parseRangeInfo(metric.rangeText);

    final chartPoints = metric.history.map((e) => e.value).toList();
    final chartDates = metric.history.map((e) => e.date).toList();

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
      currentValue: _formatCurrentValue(metric.metricKey, metric.currentValue),
      unit: metric.unit.isNotEmpty ? metric.unit : null,
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
      sinceText: metric.sinceText ?? (metric.sinceDate != null ? 'since ${metric.sinceDate}' : ''),
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

  (Color, Color, IconData) _resolveMetricStyle(String key) {
    final normalized = key.toLowerCase().replaceAll('-', '_');
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
      case 'bodyfat':
        return (
          const Color(0xFF00A896), // Teal matching Present Condition
          const Color(0xFFE0F2F1),
          Icons.percent_rounded,
        );
      case 'waist_hip_ratio':
      case 'whr':
        return (
          const Color(0xFFFF5252), // Coral red matching Present Condition
          const Color(0xFFFFF0F2),
          Icons.accessibility_new_rounded,
        );
      case 'waist_height_ratio':
      case 'whtr':
      case 'waist_hip_height':
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
    final normalized = key.toLowerCase().replaceAll('-', '_');
    switch (normalized) {
      case 'bmi':
        return 'BMI';
      case 'bmr':
        return 'BMR';
      case 'body_fat':
      case 'bodyfat':
        return 'Body Fat';
      case 'waist_hip_ratio':
      case 'whr':
        return 'Waist Hip Ratio';
      case 'waist_height_ratio':
      case 'whtr':
        return 'Waist Height Ratio';
      default:
        return key;
    }
  }

  String _resolveDefaultSubtitle(String key) {
    final normalized = key.toLowerCase().replaceAll('-', '_');
    switch (normalized) {
      case 'bmi':
        return 'Body Mass Index';
      case 'bmr':
        return 'Basal Metabolic Rate';
      case 'body_fat':
      case 'bodyfat':
        return 'Body Fat Percentage';
      case 'waist_hip_ratio':
      case 'whr':
        return 'Fat distribution indicator';
      case 'waist_height_ratio':
      case 'whtr':
        return 'Waist-to-height central obesity ratio';
      default:
        return '';
    }
  }

  String _formatCurrentValue(String metricKey, double value) {
    final normalized = metricKey.toLowerCase().replaceAll('-', '_');
    if (normalized == 'bmr') {
      return NumberFormat('#,###').format(value.round());
    } else if (normalized == 'waist_hip_ratio' ||
        normalized == 'whr' ||
        normalized == 'waist_height_ratio' ||
        normalized == 'whtr') {
      return value.toStringAsFixed(2);
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
    final normalized = metricKey.toLowerCase().replaceAll('-', '_');
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
      minVal = (minVal * 0.9).floorToDouble();
      maxVal = (maxVal * 1.1).ceilToDouble();
    }

    int decimals;
    bool isInt;
    if (normalized == 'bmr') {
      decimals = 0;
      isInt = true;
      minVal = (minVal / 100).floor() * 100.0;
      maxVal = (maxVal / 100).ceil() * 100.0;
    } else if (normalized == 'bmi' || normalized == 'body_fat' || normalized == 'bodyfat') {
      decimals = 1;
      isInt = minVal == minVal.toInt() && maxVal == maxVal.toInt();
      minVal = minVal.floorToDouble();
      maxVal = maxVal.ceilToDouble();
    } else {
      decimals = 2;
      isInt = false;
      minVal = double.parse(minVal.toStringAsFixed(2));
      maxVal = double.parse(maxVal.toStringAsFixed(2));
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
          for (var i = 0; i < 3; i++) ...[
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            if (i < 2) const SizedBox(height: 16),
          ],
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

/// Individual Card Widget for History Metric
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
    final trendColor = isFavorable ? const Color(0xFF10B981) : const Color(0xFFEF4444);

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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: themeBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(icon, color: themeColor, size: 22),
                ),
              ),
              const SizedBox(width: 12),
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
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: AppStyles.text12Px.poppins.w400.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF374151),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Main Content: Stats & Line Chart ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Values & Badge
              SizedBox(
                width: 118,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            currentValue,
                            maxLines: 1,
                            softWrap: false,
                            style: AppStyles.text28Px.poppins.w800.copyWith(
                              color: const Color(0xFF111827),
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                          ),
                          if (unit != null && unit!.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Text(
                              unit!,
                              maxLines: 1,
                              softWrap: false,
                              style: AppStyles.text11Px.poppins.w500.copyWith(
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (deltaValue.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
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
                            maxLines: 1,
                            softWrap: false,
                            style: AppStyles.text13Px.poppins.w700.copyWith(
                              color: trendColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (sinceText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        sinceText,
                        maxLines: 1,
                        softWrap: false,
                        style: AppStyles.text10Px.poppins.w400.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeLabel,
                        maxLines: 1,
                        softWrap: false,
                        style: AppStyles.text11Px.poppins.w600.copyWith(
                          color: badgeColor,
                        ),
                      ),
                    ),
                    if (rangeLabel.isNotEmpty && rangeValue.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        rangeLabel,
                        maxLines: 1,
                        softWrap: false,
                        style: AppStyles.text10Px.poppins.w400.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rangeValue,
                        maxLines: 1,
                        softWrap: false,
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),

              // Right Column: Line Chart
              Expanded(
                child: SizedBox(
                  height: 145,
                  child: chartPoints.isNotEmpty
                      ? CustomPaint(
                          size: const Size(double.infinity, 145),
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
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'No timeline entries yet',
                            style: AppStyles.text11Px.poppins.w400.copyWith(
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),

          // ── Insight / Tip Box (if available) ──
          if (insightText != null && insightText!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

/// Custom line chart painter matching the design specifications
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
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      if (p.width > maxYLabelWidth) {
        maxYLabelWidth = p.width;
      }
    }

    final leftPadding = maxYLabelWidth + 8;
    const rightPadding = 12.0;
    const topPadding = 16.0;
    const bottomPadding = 22.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;
    if (chartWidth <= 0 || chartHeight <= 0) return;

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
      final norm = (yVal - minY) / (maxY - minY);
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
            fontSize: 9,
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
      final norm = (points[i] - minY) / (maxY - minY);
      final y = topPadding + (1 - norm) * chartHeight;
      pointOffsets.add(Offset(x, y));
    }

    // ── 3. Draw Gradient Area Fill ──
    final path = Path()..moveTo(pointOffsets.first.dx, pointOffsets.first.dy);
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
      ).createShader(Rect.fromLTWH(0, topPadding, size.width, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    // ── 4. Draw Trend Line ──
    final linePaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // ── 5. Draw Point Dots, Value Labels, and X Dates ──
    for (var i = 0; i < pointOffsets.length; i++) {
      final pt = pointOffsets[i];

      // Draw outer point dot
      canvas
        ..drawCircle(pt, 3.8, Paint()..color = themeColor)
        ..drawCircle(pt, 1.6, Paint()..color = Colors.white);

      // Data point value text directly above dot
      final valText = formatYAsInt && points[i] >= 1000
          ? NumberFormat('#,###').format(points[i])
          : points[i].toStringAsFixed(decimalPlaces);

      final valPainter = TextPainter(
        text: TextSpan(
          text: valText,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 9.5,
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
              fontSize: 9,
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
        oldDelegate.themeColor != themeColor ||
        oldDelegate.minY != minY ||
        oldDelegate.maxY != maxY;
  }
}
