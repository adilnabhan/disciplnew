import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
    final reviewsList = reviews.results?.reviews ?? [];

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: 1 + reviewsList.length + (isPagination ? 1 : 0),
      separatorBuilder: (context, index) {
        if (index == 0) return const SizedBox(height: 24);
        return const SizedBox(height: 16);
      },
      itemBuilder: (context, index) {
        if (index == 0) {
          return Row(
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
          );
        }

        final reviewIndex = index - 1;
        if (reviewIndex < reviewsList.length) {
          return _buildReviewItem(reviewsList[reviewIndex]);
        }

        return const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildReviewItem(SingleFitnessCenterReviewModel? review) {
    if (review == null) return const SizedBox.shrink();

    final currentUser = context.read<AppCubit>().state.currentUser;
    final currentUserName = '${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}'.trim();
    final isOwnReview = currentUserName.isNotEmpty &&
        (review.customerName ?? '').trim().toLowerCase() == currentUserName.toLowerCase();

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
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${review.rating}', style: AppStyles.text12Px.poppins.w500.dark),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.grey,
                          size: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.white,
                        elevation: 4,
                        onSelected: (value) async {
                          if (value == 'edit') {
                            _showEditReviewDialog(review);
                          } else if (value == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Review'),
                                content: const Text('Are you sure you want to delete this review?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              final res = await ReviewsAndReatingRepository().deleteReview(id: review.id ?? 0, body: {});
                              res.fold(
                                (error) => Dialogs.showSnack(msg: error.msg),
                                (_) {
                                  Dialogs.showSnack(msg: 'Review deleted successfully');
                                  _fetch();
                                },
                              );
                            }
                          } else if (value == 'report') {
                            Dialogs.showSnack(msg: 'Review reported successfully');
                          }
                        },
                        itemBuilder: (context) => [
                          if (isOwnReview) ...[
                            PopupMenuItem(
                              value: 'edit',
                              height: 32,
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, color: Colors.black87, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Edit Review',
                                    style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              height: 32,
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delete Review',
                                    style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.error),
                                  ),
                                ],
                              ),
                            ),
                          ] else
                            PopupMenuItem(
                              value: 'report',
                              height: 32,
                              child: Row(
                                children: [
                                  const Icon(Icons.report_gmailerrorred, color: Colors.black87, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Report Review',
                                    style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
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

  Future<void> _showEditReviewDialog(SingleFitnessCenterReviewModel review) async {
    double currentRating = (review.rating as num?)?.toDouble() ?? 0.0;
    final commentController = TextEditingController(text: review.comment);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Edit Review'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Rating', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    RatingBar.builder(
                      initialRating: currentRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setDialogState(() {
                          currentRating = rating;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Comment', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Type your review here',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) {
                      Dialogs.showSnack(msg: 'Please enter your review');
                      return;
                    }
                    final res = await ReviewsAndReatingRepository().updateReview(
                      id: review.id ?? 0,
                      body: {
                        'rating': currentRating.toInt(),
                        'comment': commentController.text,
                      },
                    );
                    res.fold(
                      (error) => Dialogs.showSnack(msg: error.msg),
                      (_) {
                        Dialogs.showSnack(msg: 'Review updated successfully');
                        Navigator.pop(dialogContext);
                        _fetch();
                      },
                    );
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
