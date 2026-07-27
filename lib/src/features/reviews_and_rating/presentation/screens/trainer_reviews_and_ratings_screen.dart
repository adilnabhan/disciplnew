import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:customer_mobile_app/src/features/reviews_and_rating/domain/models/trainer_reviews_model.dart';

class TrainerReviewsAndRatingsScreen extends StatefulWidget {
  const TrainerReviewsAndRatingsScreen({required this.trainer, super.key});

  final GymTrainer trainer;

  @override
  State<TrainerReviewsAndRatingsScreen> createState() =>
      _TrainerReviewsAndRatingsScreenState();
}

class _TrainerReviewsAndRatingsScreenState
    extends State<TrainerReviewsAndRatingsScreen> {
  final List<SingleTrainerReview> _reviewsList = [];
  bool _isLoading = true;
  bool _isPaginationLoading = false;
  String? _nextUrl;
  late final ScrollController _scrollController;
  double _avgRating = 0.0;
  int _reviewCount = 0;

  @override
  void initState() {
    super.initState();
    _avgRating = (widget.trainer.averageRating as num?)?.toDouble() ?? 4.5;
    _reviewCount = widget.trainer.reviewCount ?? 0;
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchReviews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isPaginationLoading &&
        _nextUrl != null) {
      _fetchReviews(isPagination: true);
    }
  }

  Future<void> _fetchReviews({bool isPagination = false}) async {
    if (widget.trainer.id == null) return;

    setState(() {
      if (isPagination) {
        _isPaginationLoading = true;
      } else {
        _isLoading = true;
      }
    });

    Map<String, dynamic> queryParams = {'page': 1};
    if (isPagination && _nextUrl != null) {
      final uri = Uri.parse(_nextUrl!);
      final pageStr = uri.queryParameters['page'];
      if (pageStr != null) {
        queryParams['page'] = int.parse(pageStr);
      }
    }

    final res = await ReviewsAndReatingRepository().getTrainerReviewsAll(
      trainerId: widget.trainer.id!,
      queryParameters: queryParams,
    );

    if (mounted) {
      setState(() {
        res.fold(
          (error) {
            Dialogs.showSnack(msg: error.msg);
          },
          (data) {
            if (isPagination) {
              _reviewsList.addAll(data.results);
            } else {
              _reviewsList.clear();
              _reviewsList.addAll(data.results);
              _reviewCount = data.count;
            }
            _nextUrl = data.next;
          },
        );
        _isLoading = false;
        _isPaginationLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(true);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(true),
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
        centerTitle: true,
        title: Text(
          'Reviews and Ratings',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: AppColors.textDark,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviewsList.isEmpty
              ? const Center(child: Text('No reviews found!'))
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: 1 + _reviewsList.length + (_isPaginationLoading ? 1 : 0),
                  separatorBuilder: (context, index) {
                    if (index == 0) return const SizedBox(height: 24);
                    return const SizedBox(height: 16);
                  },
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Row(
                        children: [
                          Text(
                            _avgRating.toStringAsFixed(1),
                            style: AppStyles.text32Px.poppins.w600.dark,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (idx) {
                                  final starValue = idx + 1;
                                  if (_avgRating >= starValue) {
                                    return const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  } else if (_avgRating >= starValue - 0.5) {
                                    return const Icon(
                                      Icons.star_half,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  } else {
                                    return const Icon(
                                      Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    );
                                  }
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_reviewCount ${_reviewCount == 1 ? 'Review' : 'Reviews'}',
                                style: AppStyles.text12Px.poppins.w400.textGrey,
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    final reviewIndex = index - 1;
                    if (reviewIndex < _reviewsList.length) {
                      return _buildReviewItem(_reviewsList[reviewIndex]);
                    }

                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
      ),
    );
  }

  Widget _buildReviewItem(SingleTrainerReview review) {
    final currentUser = context.read<AppCubit>().state.currentUser;
    final currentUserName =
        '${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}'.trim();
    final isOwnReview = currentUserName.isNotEmpty &&
        review.customerName.trim().toLowerCase() ==
            currentUserName.toLowerCase();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AbsorbPointer(
          child: ProfileImage(
            isEdit: false,
            radius: 20,
            url: review.profilePicture ?? '',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    review.customerName,
                    style: AppStyles.text14Px.poppins.w600.dark,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${review.rating}',
                        style: AppStyles.text12Px.poppins.w500.dark,
                      ),
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
                                content: const Text(
                                  'Are you sure you want to delete this review?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && mounted) {
                              final res =
                                  await ReviewsAndReatingRepository()
                                      .deleteTrainerReview(
                                trainerId: widget.trainer.id!,
                              );
                              res.fold(
                                (error) => Dialogs.showSnack(msg: error.msg),
                                (_) {
                                  Dialogs.showSnack(
                                    msg: 'Review deleted successfully',
                                  );
                                  _fetchReviews();
                                },
                              );
                            }
                          } else if (value == 'report') {
                            Dialogs.showSnack(
                              msg: 'Review reported successfully',
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          if (isOwnReview) ...[
                            PopupMenuItem(
                              value: 'edit',
                              height: 32,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.black87,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Edit Review',
                                    style: AppStyles.text14Px.poppins.w500
                                        .copyWith(color: Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              height: 32,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.error,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Delete Review',
                                    style: AppStyles.text14Px.poppins.w500
                                        .copyWith(color: AppColors.error),
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
                                  const Icon(
                                    Icons.report_gmailerrorred,
                                    color: Colors.black87,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Report Review',
                                    style: AppStyles.text14Px.poppins.w500
                                        .copyWith(color: Colors.black87),
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
              Text(
                review.createdAt.toLocal().format('dd MMM yyyy'),
                style: AppStyles.text12Px.poppins.w400.textGrey,
              ),
              const SizedBox(height: 8),
              Text(
                review.comment,
                style: AppStyles.text14Px.poppins.w400.dark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showEditReviewDialog(SingleTrainerReview review) async {
    double currentRating = review.rating.toDouble();
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
                    final res = await ReviewsAndReatingRepository().updateTrainerReview(
                      trainerId: widget.trainer.id!,
                      rating: currentRating.toInt(),
                      comment: commentController.text.trim(),
                    );
                    res.fold(
                      (error) => Dialogs.showSnack(msg: error.msg),
                      (_) {
                        Dialogs.showSnack(msg: 'Review updated successfully');
                        Navigator.pop(dialogContext);
                        _fetchReviews();
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
