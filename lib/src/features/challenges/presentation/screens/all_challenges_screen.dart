import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_cubit.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_state.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_details_screen.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/widgets/challenge_filter_bar.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/widgets/challenge_item_card.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_winners_screen.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/settings_screen.dart';
import 'package:shimmer/shimmer.dart';

class AllChallengesScreen extends StatelessWidget {
  final bool isFromBottomNav;
  const AllChallengesScreen({this.isFromBottomNav = false, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChallengeListCubit()..loadChallenges(),
      child: _AllChallengesScreenContent(isFromBottomNav: isFromBottomNav),
    );
  }
}

class _AllChallengesScreenContent extends StatefulWidget {
  final bool isFromBottomNav;
  const _AllChallengesScreenContent({this.isFromBottomNav = false});

  @override
  State<_AllChallengesScreenContent> createState() =>
      __AllChallengesScreenContentState();
}

class __AllChallengesScreenContentState
    extends State<_AllChallengesScreenContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ChallengeListCubit>().loadMoreChallenges();
    }
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 225,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, ChallengeListState state) {
    final hasActiveFilter = (state.selectedStatus != 'all') ||
        state.selectedPartnerIds.isNotEmpty ||
        (state.selectedChallengeType != null &&
            state.selectedChallengeType!.isNotEmpty) ||
        state.searchQuery.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasActiveFilter
                  ? Icons.filter_alt_off_outlined
                  : Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilter
                  ? 'No matching challenges found'
                  : 'No challenges available.',
              textAlign: TextAlign.center,
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasActiveFilter
                  ? 'Try selecting a different filter or clear all to see available challenges.'
                  : 'Check back later for new fitness challenges!',
              textAlign: TextAlign.center,
              style: AppStyles.text13Px.poppins.w400.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (hasActiveFilter) {
                  context.read<ChallengeListCubit>().clearFilters();
                } else {
                  context.read<ChallengeListCubit>().refreshChallenges();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD71920),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                hasActiveFilter ? 'Clear Filters' : 'Refresh',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load challenges',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: const Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.text13Px.poppins.w400.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ChallengeListCubit>().loadChallenges();
              },
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
              label: Text(
                'Retry',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD71920),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolorgrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: widget.isFromBottomNav ? null : 64,
        leading: widget.isFromBottomNav
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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
        centerTitle: false,
        titleSpacing: widget.isFromBottomNav ? 16 : 8,
        title: Text(
          'Challenges',
          style: AppStyles.text20Px.poppins.w500.copyWith(
            color: AppColors.textDark,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              context.push(const SettingsScreen());
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/images/svg/icons/settings _icon.svg',
                width: 20,
                height: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const ChallengeFilterBar(),
          const SizedBox(height: 14),


          // Challenges Section Header (Dynamic title reflecting current filter)
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocBuilder<ChallengeListCubit, ChallengeListState>(
              buildWhen: (prev, curr) =>
                  prev.selectedStatus != curr.selectedStatus ||
                  prev.selectedChallengeType != curr.selectedChallengeType ||
                  prev.selectedPartnerIds != curr.selectedPartnerIds ||
                  prev.challenges.length != curr.challenges.length,
              builder: (context, state) {
                String title;
                switch (state.selectedStatus) {
                  case 'ongoing':
                    title = 'Ongoing Challenges';
                  case 'ending_soon':
                    title = 'Ending Soon';
                  case 'upcoming':
                    title = 'Upcoming Challenges';
                  case 'completed':
                    title = 'Completed Challenges';
                  default:
                    title = 'All Challenges';
                }

                if (state.selectedPartnerIds.isNotEmpty) {
                  if (state.selectedPartnerIds.length == 1) {
                    String? pName;
                    for (final p in state.partners) {
                      if (p.id == state.selectedPartnerIds.first) {
                        pName = p.name;
                        break;
                      }
                    }
                    if (pName != null && pName.isNotEmpty) {
                      title = '$title • $pName';
                    }
                  } else {
                    title =
                        '$title • ${state.selectedPartnerIds.length} Partners';
                  }
                } else if (state.selectedChallengeType != null &&
                    state.selectedChallengeType!.isNotEmpty) {
                  final typeName = state.selectedChallengeType == 'lucky_draw'
                      ? 'Lucky Draw'
                      : state.selectedChallengeType == 'performance'
                          ? 'Performance'
                          : state.selectedChallengeType == 'community'
                              ? 'Community'
                              : state.selectedChallengeType!;
                  title = '$title • $typeName';
                }

                final hasActiveFilter = (state.selectedStatus != 'all') ||
                    state.selectedPartnerIds.isNotEmpty ||
                    (state.selectedChallengeType != null &&
                        state.selectedChallengeType!.isNotEmpty);

                return Row(
                  children: [
                    Text(
                      title,
                      style: AppStyles.text16Px.poppins.w700.copyWith(
                        fontSize: 17,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                    const Spacer(),
                    if (hasActiveFilter)
                      GestureDetector(
                        onTap: () {
                          context.read<ChallengeListCubit>().clearFilters();
                        },
                        child: Text(
                          'Clear All',
                          style: AppStyles.text13Px.poppins.w600.copyWith(
                            color: const Color(0xFFD71920),
                            fontSize: 12,
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ChallengeWinnersScreen(challengeId: 0),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2), // Light red bg
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.emoji_events, color: Color(0xFFDC2626), size: 14), // Trophy
                              const SizedBox(width: 4),
                              Text(
                                'View All Winners',
                                style: AppStyles.text10Px.poppins.w600.copyWith(
                                  color: const Color(0xFFDC2626),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFFDC2626), size: 14),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: BlocBuilder<ChallengeListCubit, ChallengeListState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return _buildShimmerLoading();
                }

                if (state.errorMessage != null && state.challenges.isEmpty) {
                  return _buildErrorState(context, state.errorMessage!);
                }

                if (state.challenges.isEmpty) {
                  return _buildEmptyState(context, state);
                }

                return RefreshIndicator(
                  color: const Color(0xFFD71920),
                  onRefresh: () async {
                    await context.read<ChallengeListCubit>().refreshChallenges();
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 8.0,
                      bottom: 96.0,
                    ),
                    itemCount: state.challenges.length +
                        (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.challenges.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFD71920),
                              strokeWidth: 2.5,
                            ),
                          ),
                        );
                      }

                      final challenge = state.challenges[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ChallengeItemCard(
                          challenge: challenge,
                          onTapDetails: () {
                            if (challenge.id != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ChallengeDetailsScreen(
                                    challengeId: challenge.id!,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
