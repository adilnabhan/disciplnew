import 'dart:ui';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_cubit.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_state.dart';

class ChallengeFilterBar extends StatefulWidget {
  const ChallengeFilterBar({super.key});

  @override
  State<ChallengeFilterBar> createState() => _ChallengeFilterBarState();
}

class _ChallengeFilterBarState extends State<ChallengeFilterBar> {
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, String?>> _typeOptions = [
    {'label': 'All', 'value': null},
    {'label': 'Lucky Draw', 'value': 'lucky_draw'},
    {'label': 'Performance', 'value': 'performance'},
    {'label': 'Completed', 'value': 'completed'},
  ];

  static const List<Map<String, String>> _statusOptions = [
    {'label': 'Ongoing', 'value': 'ongoing'},
    {'label': 'Ending soon', 'value': 'ongoing'},
    {'label': 'Upcoming', 'value': 'upcoming'},
    {'label': 'Completed', 'value': 'completed'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE52027),
                        Color(0xFFBE1117),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.95),
                        const Color(0xFFEDEFF3).withValues(alpha: 0.85),
                      ],
                    ),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFD71920)
                    : const Color(0xFFCDD2DB),
                width: 1.2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFFD71920).withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.9),
                        blurRadius: 3,
                        offset: const Offset(-1, -1),
                      ),
                    ],
            ),
            child: Text(
              label,
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
                fontSize: 13.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengeListCubit, ChallengeListState>(
      builder: (context, state) {
        final cubit = context.read<ChallengeListCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Type Filters (All, Lucky Draw, Performance, etc.)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: _typeOptions.map((opt) {
                  final isSelected =
                      (state.selectedChallengeType == opt['value']) ||
                          (opt['value'] == null &&
                              (state.selectedChallengeType == null ||
                                  state.selectedChallengeType!.isEmpty));
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: _buildFilterChip(
                      label: opt['label']!,
                      isSelected: isSelected,
                      onTap: () {
                        cubit.filterByChallengeType(opt['value']);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Row 2: Status Filters (Ongoing, Ending soon, Upcoming, Completed)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: _statusOptions.map((opt) {
                  final isSelected = state.selectedStatus == opt['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: _buildFilterChip(
                      label: opt['label']!,
                      isSelected: isSelected,
                      onTap: () {
                        cubit.filterByStatus(opt['value']!);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
