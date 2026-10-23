import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/widgets/personal_record_state_views.dart';

class PersonalRecordsScreen extends StatefulWidget {
  const PersonalRecordsScreen({super.key});

  @override
  State<PersonalRecordsScreen> createState() => _PersonalRecordsScreenState();
}

class _PersonalRecordsScreenState extends State<PersonalRecordsScreen> {
  final PersonalRecordsRepository _repository = PersonalRecordsRepository();

  bool _isLoading = true;
  String? _errorMessage;
  PersonalRecordsData? _prData;

  String _selectedCategory = 'All';
  String _selectedSort = 'Recent';

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords({bool isRefresh = false}) async {
    if (!isRefresh && _prData == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final categoryParam =
        _selectedCategory.toLowerCase() == 'all' ? null : _selectedCategory;

    final result = await _repository.fetchPersonalRecords(
      category: categoryParam,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppErrorHandler.formatUserFriendlyMessage(failure.msg, fallback: 'Unable to fetch personal records. Please try again.');
        });
      },
      (data) {
        setState(() {
          _isLoading = false;
          _errorMessage = null;
          _prData = data;
        });
      },
    );
  }

  List<PersonalRecordItemModel> get _filteredAndSortedRecords {
    if (_prData == null) return [];

    var list = List<PersonalRecordItemModel>.from(_prData!.records);

    // In case the API returns all records and client filters by category
    if (_selectedCategory.toLowerCase() != 'all') {
      list =
          list.where((item) {
            final cat = item.category.toLowerCase();
            final major = (item.majorMuscle ?? '').toLowerCase();
            final selected = _selectedCategory.toLowerCase();
            return cat == selected || major == selected;
          }).toList();
    }

    if (_selectedSort == 'Recent') {
      // Natural order
    } else if (_selectedSort == 'Max Weight') {
      list.sort((a, b) {
        final valA = a.maxWeight?.value ?? 0;
        final valB = b.maxWeight?.value ?? 0;
        return valB.compareTo(valA);
      });
    } else if (_selectedSort == 'Volume') {
      list.sort((a, b) {
        final valA = a.totalVolume?.value ?? 0;
        final valB = b.totalVolume?.value ?? 0;
        return valB.compareTo(valA);
      });
    } else if (_selectedSort == 'Name') {
      list.sort((a, b) => a.name.compareTo(b.name));
    }

    return list;
  }

  void _showInfoDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEEEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events_outlined,
                          color: Color(0xFFE53935),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'About Personal Records',
                        style: AppStyles.text18Px.poppins.w600.copyWith(
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Personal Records (PRs) track your all-time greatest achievements for each lift across three distinct milestones:\n\n'
                    '• Max Weight: The heaviest single load you have completed (1RM or max set).\n'
                    '• Best Rep: Your highest repetitions performed at a given weight load.\n'
                    '• Total Volume: Your highest cumulative training volume achieved in a single session.',
                    style: AppStyles.text14Px.poppins.w400.copyWith(
                      color: const Color(0xFF4B5563),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Got it',
                        style: AppStyles.text14Px.poppins.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort PRs by',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...['Recent', 'Max Weight', 'Volume', 'Name'].map((opt) {
                    final isSelected = _selectedSort == opt;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color:
                            isSelected
                                ? const Color(0xFFE53935)
                                : const Color(0xFF9CA3AF),
                      ),
                      title: Text(
                        opt,
                        style: AppStyles.text15Px.poppins.w500.copyWith(
                          color:
                              isSelected
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF1F2937),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedSort = opt;
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
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
                  Icons.chevron_left_rounded,
                  color: Color(0xFF222222),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Personal Records',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: const Color(0xFF1F2937),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: GestureDetector(
                onTap: () => _showInfoDialog(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF222222),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _prData == null) {
      return const PRListLoadingSkeleton();
    }

    if (_errorMessage != null && _prData == null) {
      return PRErrorView(message: _errorMessage, onRetry: _fetchRecords);
    }

    final data = _prData;
    if (data == null) {
      return PRNoDataView(onRefresh: _fetchRecords);
    }

    final categories = data.categories.isEmpty ? ['All'] : data.categories;
    final records = _filteredAndSortedRecords;

    final thisMonthCount =
        data.thisMonthPrsCount ??
        data.records.where((r) {
          final d = r.maxWeight?.date ?? '';
          final currentYear = DateTime.now().year.toString();
          return d.contains(currentYear);
        }).length;

    return RefreshIndicator(
      onRefresh: () => _fetchRecords(isRefresh: true),
      color: const Color(0xFFE53935),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // ── Header Banner Card ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEEEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.emoji_events_outlined,
                      color: Color(0xFFE53935),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PR Records',
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.userName != null && data.userName!.isNotEmpty
                            ? 'Logged for ${data.userName}'
                            : 'Track your best performance across exercises.',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Stats Summary Row ──
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.emoji_events_outlined,
                        color: Color(0xFFE53935),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${data.totalPrsCount}',
                        style: AppStyles.text24Px.poppins.w700.copyWith(
                          fontSize: 26,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total PRs',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        color: Color(0xFFE53935),
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '+$thisMonthCount',
                        style: AppStyles.text24Px.poppins.w700.copyWith(
                          fontSize: 26,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This month',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Section Title & Sort Dropdown ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your PR Records',
                style: AppStyles.text18Px.poppins.w600.copyWith(
                  color: const Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: _showSortBottomSheet,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sort by: $_selectedSort',
                      style: AppStyles.text13Px.poppins.w600.copyWith(
                        color: const Color(0xFFE53935),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFFE53935),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Filter Chips ──
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected =
                    category.toLowerCase() == _selectedCategory.toLowerCase();
                final count = data.categoryCounts[category];

                return GestureDetector(
                  onTap: () {
                    if (_selectedCategory != category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _fetchRecords();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? const Color(0xFFE53935)
                              : const Color(0xFFE9ECEF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        count != null && count > 0 && category != 'All'
                            ? '$category ($count)'
                            : category,
                        style: AppStyles.text13Px.poppins.w600.copyWith(
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF495057),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── PR Records List ──
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: PRNoDataView(
                title:
                    _selectedCategory.toLowerCase() == 'all'
                        ? 'No Personal Records Yet'
                        : 'No PRs in $_selectedCategory yet',
                message:
                    _selectedCategory.toLowerCase() == 'all'
                        ? 'Log your workout weights to celebrate and track your milestones here.'
                        : 'Start logging workouts in the $_selectedCategory category to see your PRs here.',
                onRefresh: _fetchRecords,
              ),
            )
          else
            ...records.map(_buildPRCard),
        ],
      ),
    );
  }

  Widget _buildPRCard(PersonalRecordItemModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder:
                (_) => PersonalRecordDetailsScreen(
                  workoutId: item.workoutId,
                  initialRecord: item,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: Color(0xFF1F2937),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (item.majorMuscle?.isNotEmpty ?? false)
                            ? item.majorMuscle!
                            : item.category,
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFCED4DA),
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F5)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricColumn(
                    label: 'Max Weight',
                    icon: Icons.fitness_center_rounded,
                    iconColor: const Color(0xFFE53935),
                    value:
                        item.maxWeight?.displayText ??
                        item.maxWeight?.formatted ??
                        '-',
                    date: item.maxWeight?.date ?? '',
                  ),
                ),
                Expanded(
                  child: _buildMetricColumn(
                    label: 'Best Rep',
                    icon: Icons.repeat_rounded,
                    iconColor: const Color(0xFF10B981),
                    value:
                        item.bestReps?.displayText ??
                        item.bestReps?.formatted ??
                        '-',
                    date: item.bestReps?.date ?? '',
                  ),
                ),
                Expanded(
                  child: _buildMetricColumn(
                    label: 'Total Volume',
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFF2563EB),
                    value:
                        item.totalVolume?.displayText ??
                        item.totalVolume?.formatted ??
                        '-',
                    date: item.totalVolume?.date ?? '',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricColumn({
    required String label,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String date,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.text11Px.poppins.w500.copyWith(
            color: const Color(0xFF868E96),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 13),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.text12Px.poppins.w700.copyWith(
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
          ],
        ),
        if (date.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            date,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.text10Px.poppins.w400.copyWith(
              color: const Color(0xFFADB5BD),
            ),
          ),
        ],
      ],
    );
  }
}
