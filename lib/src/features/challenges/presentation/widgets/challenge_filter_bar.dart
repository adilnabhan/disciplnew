import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_cubit.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_state.dart';

class ChallengeFilterBar extends StatelessWidget {
  const ChallengeFilterBar({super.key});

  static const List<Map<String, dynamic>> _typeOptions = [
    {
      'label': 'All',
      'value': null,
      'icon': Icons.grid_view_rounded,
    },
    {
      'label': 'Lucky Draw',
      'value': 'lucky_draw',
      'icon': Icons.card_giftcard_rounded,
    },
    {
      'label': 'Performance',
      'value': 'performance',
      'icon': Icons.show_chart_rounded,
    },
    {
      'label': 'Community',
      'value': 'community',
      'icon': Icons.people_outline_rounded,
    },
  ];

  static const List<Map<String, dynamic>> _statusOptions = [
    {
      'label': 'Ongoing',
      'value': 'ongoing',
      'icon': Icons.play_circle_fill_rounded,
    },
    {
      'label': 'Ending Soon',
      'value': 'ending_soon',
      'icon': Icons.hourglass_empty_rounded,
    },
    {
      'label': 'Upcoming',
      'value': 'upcoming',
      'icon': Icons.calendar_month_outlined,
    },
    {
      'label': 'Completed',
      'value': 'completed',
      'icon': Icons.check_circle_outline_rounded,
    },
  ];

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFE51D24),
                    Color(0xFFC60000),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFD71920) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFD71920).withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppStyles.text14Px.poppins.w600.copyWith(
                color: isSelected ? Colors.white : const Color(0xFF334155),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeColor = const Color(0xFFD71920);
    final inactiveColor = const Color(0xFF475569);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: isSelected ? activeColor : inactiveColor,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Active Tab Red Indicator Bar
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 32 : 0,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
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
            // Row 1: Category Filter Chips (All, Lucky Draw, Performance, Community)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _typeOptions.map((opt) {
                  final isSelected = (state.selectedChallengeType == opt['value']) ||
                      (opt['value'] == null &&
                          (state.selectedChallengeType == null ||
                              state.selectedChallengeType!.isEmpty));
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildCategoryChip(
                      label: opt['label'] as String,
                      icon: opt['icon'] as IconData,
                      isSelected: isSelected,
                      onTap: () {
                        cubit.filterByChallengeType(opt['value'] as String?);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Row 2: Status Tab Bar Container (Ongoing, Ending Soon, Upcoming, Completed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: _statusOptions.map((opt) {
                    final isSelected = state.selectedStatus == opt['value'];
                    return _buildStatusTab(
                      label: opt['label'] as String,
                      icon: opt['icon'] as IconData,
                      isSelected: isSelected,
                      onTap: () {
                        cubit.filterByStatus(opt['value'] as String);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
