import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_cubit.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_state.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/challenge_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChallengeFilterBar extends StatelessWidget {
  const ChallengeFilterBar({super.key});

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

  static const List<Map<String, dynamic>> _typeDropdownOptions = [
    {
      'label': 'All Challenges',
      'value': 'all',
      'icon': Icons.grid_view_rounded,
    },
    {
      'label': 'Performance',
      'value': 'performance',
      'icon': Icons.trending_up_rounded,
    },
    {
      'label': 'Lucky Draw',
      'value': 'lucky_draw',
      'icon': Icons.card_giftcard_rounded,
    },
    {
      'label': 'Community',
      'value': 'community',
      'icon': Icons.groups_rounded,
    },
  ];

  static Widget _buildCheckbox(bool isChecked) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isChecked ? const Color(0xFFD71920) : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isChecked ? const Color(0xFFD71920) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: isChecked
          ? const Icon(
              Icons.check_rounded,
              size: 16,
              color: Colors.white,
            )
          : null,
    );
  }

  static Widget _buildPartnerLogo(ChallengePartner partner) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: partner.logo != null && partner.logo!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: partner.logo!,
                fit: BoxFit.cover,
                memCacheWidth: 80,
                memCacheHeight: 80,
                placeholder: (_, __) => Container(
                  color: const Color(0xFFF1F5F9),
                  alignment: Alignment.center,
                  child: Text(
                    partner.name.isNotEmpty
                        ? partner.name[0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFFF1F5F9),
                  alignment: Alignment.center,
                  child: Text(
                    partner.name.isNotEmpty
                        ? partner.name[0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              )
            : Container(
                color: const Color(0xFFF1F5F9),
                alignment: Alignment.center,
                child: Text(
                  partner.name.isNotEmpty
                      ? partner.name[0].toUpperCase()
                      : 'P',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    ChallengeListCubit cubit,
    ChallengeListState state,
  ) {
    var tempStatus = state.selectedStatus;
    var tempPartnerIds = List<int>.from(state.selectedPartnerIds);
    final searchController = TextEditingController();

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
            final query = searchController.text.trim().toLowerCase();
            final filteredPartners = state.partners.where((p) {
              if (query.isEmpty) return true;
              return p.name.toLowerCase().contains(query);
            }).toList();

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 12,
                  bottom:
                      MediaQuery.of(bottomSheetContext).viewInsets.bottom + 28,
                ),
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

                    // Header: "Filter Challenges" + "Reset"
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
                              tempPartnerIds.clear();
                              searchController.clear();
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

                    // Section 2: Partner
                    const Text(
                      'Partner',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Search partner bar
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search partner...',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.5,
                                  color: Color(0xFF94A3B8),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.5,
                                color: Color(0xFF1E293B),
                              ),
                              onChanged: (_) => setSheetState(() {}),
                            ),
                          ),
                          if (searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  searchController.clear();
                                });
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Partner List with Checkboxes
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: state.isLoadingPartners
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  color: Color(0xFFD71920),
                                  strokeWidth: 2.5,
                                ),
                              ),
                            )
                          : ListView(
                              shrinkWrap: true,
                              children: [
                                // All Partners Item
                                if (query.isEmpty) ...[
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      setSheetState(() {
                                        tempPartnerIds.clear();
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 7),
                                      child: Row(
                                        children: [
                                          _buildCheckbox(tempPartnerIds.isEmpty),
                                          const SizedBox(width: 14),
                                          const Text(
                                            'All Partners',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],

                                // Individual Partners
                                if (filteredPartners.isEmpty && query.isNotEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: Text(
                                        'No partners found',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 13,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ...filteredPartners.map((partner) {
                                    final isChecked =
                                        tempPartnerIds.contains(partner.id);
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setSheetState(() {
                                          if (tempPartnerIds.contains(partner.id)) {
                                            tempPartnerIds.remove(partner.id);
                                          } else {
                                            tempPartnerIds.add(partner.id);
                                          }
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        child: Row(
                                          children: [
                                            _buildCheckbox(isChecked),
                                            const SizedBox(width: 14),
                                            _buildPartnerLogo(partner),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                partner.name,
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                              ],
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Apply Filters Button
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        if (tempStatus != state.selectedStatus) {
                          cubit.filterByStatus(tempStatus);
                        }
                        cubit.filterByPartners(tempPartnerIds);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD71920),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD71920)
                                  .withValues(alpha: 0.28),
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

        final currentType = state.selectedChallengeType;
        final currentTypeLabel = (currentType == null ||
                currentType.isEmpty ||
                currentType == 'all')
            ? 'All Challenges'
            : currentType == 'performance'
                ? 'Performance'
                : currentType == 'lucky_draw'
                    ? 'Lucky Draw'
                    : currentType == 'community'
                        ? 'Community'
                        : currentType;

        final hasActiveFilter = state.selectedStatus != 'all' ||
            state.selectedPartnerIds.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Challenge Type Dropdown Pill (Left)
              PopupMenuButton<String>(
                onSelected: (val) {
                  cubit.filterByChallengeType(val == 'all' ? null : val);
                },
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
                elevation: 6,
                itemBuilder: (context) {
                  return _typeDropdownOptions.map((opt) {
                    final val = opt['value'] as String;
                    final isSelected = val == 'all'
                        ? (state.selectedChallengeType == null ||
                            state.selectedChallengeType!.isEmpty ||
                            state.selectedChallengeType == 'all')
                        : state.selectedChallengeType == val;

                    return PopupMenuItem<String>(
                      value: val,
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
                      if (hasActiveFilter) ...[
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
