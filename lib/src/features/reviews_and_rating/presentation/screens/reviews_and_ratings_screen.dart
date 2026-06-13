import 'package:customer_mobile_app/imports_bindings.dart';

class ReviewsAndRatingsScreen extends StatefulWidget {
  const ReviewsAndRatingsScreen({required this.fitnessCenterId, super.key});

  final int fitnessCenterId;

  @override
  State<ReviewsAndRatingsScreen> createState() => _ReviewsAndRatingsScreenState();
}

class _ReviewsAndRatingsScreenState extends State<ReviewsAndRatingsScreen> {
  late final ReviewsAndRatingCubit _cubit;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _cubit = ReviewsAndRatingCubit();
    _fetch();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _cubit.fetchFitnessCenterReviews(widget.fitnessCenterId, isPagination: true);
      }
    });
  }

  @override
  void dispose() {
    _cubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    await _cubit.fetchFitnessCenterReviews(widget.fitnessCenterId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(title: const Text('Reviews and Ratings')),
        body: BlocBuilder<ReviewsAndRatingCubit, ReviewsAndRatingState>(
          builder: (context, state) {
            return state.fitnessCenterReviews.data.fold(
              () => const Center(child: CircularProgressIndicator()),
              (either) => either.fold((error) {
                return error.maybeWhen(network: (e) => ErrorUi.network(onTap: _fetch), notFound: (e) => ErrorUi.notFound(onTap: _fetch), orElse: () => ErrorUi.server(onTap: _fetch)).center;
              }, _buildReviewsAndRatings),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewsAndRatings(FitnessCenterReviewsModel reviews) {
    if (reviews.results?.reviews?.isEmpty ?? true) {
      return const Center(child: Text('No reviews found!'));
    }
    final isPagination = _cubit.state.fitnessCenterReviews.isPagination;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Text('${reviews.results?.avgRating ?? 4.5}', style: AppStyles.text32Px.poppins.w600.dark),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final avgRating = reviews.results?.avgRating ?? 4.5;
                    return Icon(
                      index < avgRating.floor()
                          ? Icons.star
                          : index == avgRating.floor() && avgRating % 1 >= 0.5
                          ? Icons.star_half
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(height: 4),
                Text('${reviews.results?.reviewCount ?? 0} Reviews', style: AppStyles.text12Px.poppins.w400.textGrey),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            if (index == (reviews.results?.reviews?.length ?? 0)) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _buildReviewItem(reviews.results?.reviews?[index]);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemCount: (reviews.results?.reviews?.length ?? 0) + (isPagination ? 1 : 0),
        ),
      ],
    );
  }

  Widget _buildReviewItem(SingleFitnessCenterReviewModel? review) {
    if (review == null) return const SizedBox.shrink();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AbsorbPointer(child: ProfileImage(isEdit: false, radius: 20, url: '${review.profilePicture}')),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(review.customerName ?? 'N/A', style: AppStyles.text14Px.poppins.w600.dark),
                  Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), const SizedBox(width: 4), Text('${review.rating}', style: AppStyles.text12Px.poppins.w500.dark)]),
                ],
              ),
              const SizedBox(height: 4),
              Text(review.created?.toLocal().format('dd MMM yyyy') ?? 'N/A', style: AppStyles.text12Px.poppins.w400.textGrey),
              const SizedBox(height: 8),
              Text(review.comment ?? 'N/A', style: AppStyles.text14Px.poppins.w400.dark),
            ],
          ),
        ),
      ],
    );
  }
}
