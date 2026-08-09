import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_cubit.dart';
import 'package:customer_mobile_app/src/features/challenges/cubit/challenge_list_state.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_details_screen.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/widgets/challenge_filter_bar.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/widgets/challenge_item_card.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/settings_screen.dart';
import 'package:shimmer/shimmer.dart';

class AllChallengesScreen extends StatefulWidget {
  const AllChallengesScreen({super.key});

  @override
  State<AllChallengesScreen> createState() => _AllChallengesScreenState();
}

class _AllChallengesScreenState extends State<AllChallengesScreen> {
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
              height: 180,
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No challenges available.',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Check back later for new fitness challenges!',
              textAlign: TextAlign.center,
              style: AppStyles.text13Px.poppins.w400.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<ChallengeListCubit>().refreshChallenges();
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
                'Refresh',
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
    return BlocProvider(
      create: (context) => ChallengeListCubit()..loadChallenges(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leadingWidth: 56,
          leading: Padding(
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
          title: Text(
            'Challenges',
            style: AppStyles.text20Px.poppins.w500.copyWith(
              color: AppColors.textDark,
            ),
          ),
          centerTitle: false,
          actions: [
            GestureDetector(
              onTap: () {
                context.push(const SettingsScreen());
              },
              child: SvgPicture.asset(
                'assets/images/svg/icons/settings _icon.svg',
                width: 22,
                height: 22,
              ),
            ).pOnly(right: 20),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const ChallengeFilterBar(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Open Challenges',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  fontSize: 15,
                  height: 1.5,
                  letterSpacing: -0.41,
                  color: const Color(0xFF222222),
                ),
              ),
            ),
            const SizedBox(height: 8),
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
                    return _buildEmptyState(context);
                  }

                  return RefreshIndicator(
                    color: const Color(0xFFD71920),
                    onRefresh: () async {
                      await context.read<ChallengeListCubit>().refreshChallenges();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
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
                                  MaterialPageRoute(
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
      ),
    );
  }
}
