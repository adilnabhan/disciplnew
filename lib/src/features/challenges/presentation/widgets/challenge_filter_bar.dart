import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_cubit.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_state.dart';

class ChallengeFilterBar extends StatelessWidget {
  const ChallengeFilterBar({super.key});

  static const List<Map<String, dynamic>> _typeOptions = [
    {
      'label': 'All Challenges',
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
      'label': 'All',
      'value': 'all',
      'icon': Icons.grid_view_rounded,
    },
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

  String _getTypeLabel(String? selectedType) {
    if (selectedType == null || selectedType.isEmpty) {
      return 'All Challenges';
    }
    for (final opt in _typeOptions) {
      if (opt['value'] == selectedType) {
        return opt['label'] as String;
      }
    }
    return 'All Challenges';
  }

  void _showFilterBottomSheet(
    BuildContext context,
    ChallengeListCubit cubit,
    ChallengeListState state,
  ) {
    var tempStatus = state.selectedStatus;
    var tempType = state.selectedChallengeType;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Challenges',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempStatus = 'all';
                              tempType = null;
                            });
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD71920),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 1: Status
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _statusOptions.map((opt) {
                        final isSelected = tempStatus == opt['value'];
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              tempStatus = opt['value'] as String;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFECEE)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFD71920)
                                    : const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  opt['icon'] as IconData,
                                  size: 14,
                                  color: isSelected
                                      ? const Color(0xFFD71920)
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  opt['label'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFFD71920)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Section 2: Challenge Type
                    const Text(
                      'Challenge Type',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _typeOptions.map((opt) {
                        final isSelected = (tempType == opt['value']) ||
                            (opt['value'] == null &&
                                (tempType == null || tempType!.isEmpty));
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              tempType = opt['value'] as String?;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFFECEE)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFD71920)
                                    : const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  opt['icon'] as IconData,
                                  size: 14,
                                  color: isSelected
                                      ? const Color(0xFFD71920)
                                      : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  opt['label'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12.5,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? const Color(0xFFD71920)
                                        : const Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 26),

                    // Apply Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        if (tempStatus != state.selectedStatus) {
                          cubit.filterByStatus(tempStatus);
                        }
                        if (tempType != state.selectedChallengeType) {
                          cubit.filterByChallengeType(tempType);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD71920),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD71920).withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChallengeListCubit, ChallengeListState>(
      builder: (context, state) {
        final cubit = context.read<ChallengeListCubit>();
        final currentTypeLabel = _getTypeLabel(state.selectedChallengeType);
        final hasActiveStatus = state.selectedStatus != 'all';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // All Challenges Dropdown Pill (Left)
              PopupMenuButton<String?>(
                onSelected: cubit.filterByChallengeType,
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                elevation: 6,
                itemBuilder: (context) {
                  return _typeOptions.map((opt) {
                    final isSelected =
                        (state.selectedChallengeType == opt['value']) ||
                            (opt['value'] == null &&
                                (state.selectedChallengeType == null ||
                                    state.selectedChallengeType!.isEmpty));
                    return PopupMenuItem<String?>(
                      value: opt['value'] as String?,
                      child: Row(
                        children: [
                          Icon(
                            opt['icon'] as IconData,
                            size: 18,
                            color: isSelected
                                ? const Color(0xFFD71920)
                                : const Color(0xFF475569),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              opt['label'] as String,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected
                                    ? const Color(0xFFD71920)
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Color(0xFFD71920),
                            ),
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9.5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentTypeLabel,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: Color(0xFF0F172A),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Button (Right)
              GestureDetector(
                onTap: () {
                  _showFilterBottomSheet(context, cubit, state);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECEE),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.filter_alt_outlined,
                        size: 18,
                        color: Color(0xFF8B1D2C),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Filter',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B1D2C),
                        ),
                      ),
                      if (hasActiveStatus) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD71920),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
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
