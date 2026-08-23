import 'package:customer_mobile_app/imports_bindings.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen>
    with SingleTickerProviderStateMixin {
  late final MyReviewsCubit _cubit;
  late final ScrollController _scrollController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _cubit = MyReviewsCubit();
    _tabController = TabController(length: 2, vsync: this);
    _fetch();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _cubit.fetchMyReviews(isPagination: true);
      }
    });
  }

  @override
  void dispose() {
    _cubit.close();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    await _cubit.fetchMyReviews();
    await _cubit.fetchActiveMembership();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          leading: const PopButton().center,
          title: Text('Reviews', style: AppStyles.text16Px.poppins.w500),
          centerTitle: true,
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            _buildCustomTabBar(),
            const SizedBox(height: 24),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildCurrentGymTab(), _buildPreviousGymsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: AppColors.primary,
      indicatorWeight: 1,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: AppColors.primary,
      unselectedLabelColor: Colors.grey,
      labelStyle: AppStyles.text16Px.poppins.w600,
      unselectedLabelStyle: AppStyles.text16Px.poppins.w400,
      tabs: const [Tab(text: 'Current Gym'), Tab(text: 'Previous Gyms')],
    );
  }

  Widget _buildCurrentGymTab() {
    return BlocBuilder<MyReviewsCubit, MyReviewsState>(
      builder: (context, state) {
        return state.activeMembershipData.fold(
          () => const Center(child: CircularProgressIndicator()),
          (either) => either.fold(
            (error) {
              return Center(
                child: error.maybeWhen(
                  network: (e) => ErrorUi.network(onTap: _fetch),
                  notFound: (e) => const Text('No active membership found'),
                  orElse: () => ErrorUi.server(onTap: _fetch),
                ),
              );
            },
            (membership) {
              if (membership == null) {
                return const Center(child: Text('No active membership'));
              }
              return ListView(
                padding: EdgeInsets.zero,
                children: [CurrentGymCard(membership: membership)],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPreviousGymsTab() {
    return BlocBuilder<MyReviewsCubit, MyReviewsState>(
      builder: (context, state) {
        return state.myReviews.data.fold(
          () => const Center(child: CircularProgressIndicator()),
          (either) => either.fold(
            (error) => Center(
              child: error.maybeWhen(
                network: (e) => ErrorUi.network(onTap: _fetch),
                notFound: (e) => const Text('No reviews found'),
                orElse: () => ErrorUi.server(onTap: _fetch),
              ),
            ),
            _buildPreviousGymsList,
          ),
        );
      },
    );
  }

  Widget _buildPreviousGymsList(CustomerPostedReviewsModel reviews) {
    if (reviews.results?.isEmpty ?? true) {
      return const Center(child: Text('No reviews found'));
    }
    final isPagination = _cubit.state.myReviews.isPagination;
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: (reviews.results?.length ?? 0) + (isPagination ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == (reviews.results?.length ?? 0)) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return PreviousGymReviewTile(review: reviews.results![index]);
      },
    );
  }
}

class CurrentGymCard extends StatelessWidget {
  const CurrentGymCard({required this.membership, super.key});

  final ActiveMembershipModel membership;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Builder(
        builder: (context) {
          if (membership.organization?.review?.hasReviewed ?? false) {
            return _review(context);
          }
          return _addReview(context);
        },
      ),
    );
  }

  Widget _review(BuildContext context) {
    final myReview = membership.organization?.review?.myReview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageNetwork(
                membership.organization?.logo ?? '',
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    membership.organization?.name ?? '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (membership.organization?.category?.isNotEmpty ?? false)
                          ? membership.organization!.category!.first
                          : 'Gym',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 1,
          child: Divider(color: Colors.grey.shade300),
        ).pOnly(top: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Rating & Review',
              style: AppStyles.text16Px.poppins.w600.textGrey,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${membership.organization?.review?.rating ?? 4.5}',
                    style: AppStyles.text14Px.poppins.w600,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (myReview is Map && myReview.containsKey('comment'))
          Text(
            (myReview as Map<String, dynamic>)['comment'] as String,
            style: AppStyles.text14Px.poppins.w400,
          ),
      ],
    );
  }

  Widget _addReview(BuildContext context) {
    return Column(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ImageNetwork(membership.organization?.logo ?? ''),
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Active Gym',
                      style: AppStyles.text14Px.poppins.w400.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    membership.organization?.name ?? 'N/A',
                    style: AppStyles.text20Px.poppins.w500,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Gym',
                      style: AppStyles.text14Px.poppins.w400.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Joined',
                  style: AppStyles.text14Px.poppins.w400.copyWith(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  membership.startDate?.format('dd MMM yyyy') ?? '23 May 2025',
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              final gymId = membership.id;
              if (gymId != null) {
                context.push(AaddReviewScreen(membership: membership));
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              backgroundColor: AppColors.lightPrimary.withAlpha(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Add Review',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PreviousGymReviewTile extends StatelessWidget {
  const PreviousGymReviewTile({required this.review, super.key});

  final SingleReviewModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: ImageNetwork(
                  review.organizationLogo ?? '',
                  width: 72,
                  height: 72,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.organizationName ?? '',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (review.organizationCategory?.isNotEmpty ?? false)
                            ? review.organizationCategory!.first
                            : 'Gym',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 1,
            child: Divider(color: Colors.grey.shade300),
          ).pxy(y: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Rating & Review',
                style: AppStyles.text16Px.poppins.w600.textGrey,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${review.rating ?? 4.5}',
                      style: AppStyles.text14Px.poppins.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty)
            Text(review.comment!, style: AppStyles.text14Px.poppins.w400),
        ],
      ),
    );
  }
}
