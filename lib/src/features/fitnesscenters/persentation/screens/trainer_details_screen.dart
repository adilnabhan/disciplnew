import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'certificate_viewer_screen.dart';

class TrainerDetailsScreen extends StatefulWidget {
  const TrainerDetailsScreen({required this.trainer, super.key});

  final GymTrainer trainer;

  @override
  State<TrainerDetailsScreen> createState() => _TrainerDetailsScreenState();
}

class _TrainerDetailsScreenState extends State<TrainerDetailsScreen> {
  Map<String, dynamic>? _myReview;
  bool _isLoadingReview = true;
  double _trainerRating = 0.0;
  int _trainerReviewCount = 0;

  @override
  void initState() {
    super.initState();
    _trainerRating = (widget.trainer.averageRating as num?)?.toDouble() ?? 0.0;
    _trainerReviewCount = widget.trainer.reviewCount ?? 0;
    _fetchReview();
  }

  Future<void> _fetchReview() async {
    if (widget.trainer.id == null) return;
    setState(() {
      _isLoadingReview = true;
    });
    final res = await ReviewsAndReatingRepository().getTrainerReview(
      trainerId: widget.trainer.id!,
    );
    if (mounted) {
      setState(() {
        res.fold(
          (error) {
            _myReview = null;
          },
          (review) {
            _myReview = review;
          },
        );
        _isLoadingReview = false;
      });
    }
  }

  Future<void> _showAddTrainerReviewDialog({double initialRating = 0}) async {
    double currentRating = initialRating;
    final commentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Add Review'),
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
                    if (currentRating == 0) {
                      Dialogs.showSnack(msg: 'Please select a rating');
                      return;
                    }
                    if (commentController.text.trim().isEmpty) {
                      Dialogs.showSnack(msg: 'Please enter your review');
                      return;
                    }
                    final res = await ReviewsAndReatingRepository().addTrainerReview(
                      trainerId: widget.trainer.id!,
                      rating: currentRating.toInt(),
                      comment: commentController.text.trim(),
                    );
                    res.fold(
                      (error) => Dialogs.showSnack(msg: error.msg),
                      (_) {
                        Dialogs.showSnack(msg: 'Review submitted successfully');
                        Navigator.pop(dialogContext);
                        setState(() {
                          _trainerReviewCount = _trainerReviewCount + 1;
                        });
                        _fetchReview();
                      },
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditTrainerReviewDialog() async {
    if (_myReview == null) return;
    double currentRating = (_myReview!['rating'] as num?)?.toDouble() ?? 0.0;
    final commentController = TextEditingController(text: _myReview!['comment']?.toString() ?? '');

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
                    if (currentRating == 0) {
                      Dialogs.showSnack(msg: 'Please select a rating');
                      return;
                    }
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
                        _fetchReview();
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

  @override
  Widget build(BuildContext context) {
    final trainer = widget.trainer;
    final specs = trainer.specializations ?? [];
    final certifications = trainer.certifications ?? [];
    final transformations = trainer.transformations ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
        centerTitle: true,
        title: Text(
          'Trainer Profile',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Circular Profile Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child:
                              trainer.profileImage != null &&
                                      trainer.profileImage!.isNotEmpty
                                  ? ImageNetwork(
                                    trainer.profileImage!,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Name & Specialty
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    trainer.fullName ?? 'Trainer',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trainer.userType ?? 'Personal Trainer',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary,
                              ),
                            ),
                            if (trainer.experienceYears != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.work_history_outlined,
                                    size: 15,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${trainer.experienceYears} Years Experience',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (specs.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Divider(height: 1, color: Color(0xFFF2F2F2)),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            specs
                                .map(
                                  (spec) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF5F5F5),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.black.withOpacity(0.04),
                                      ),
                                    ),
                                    child: Text(
                                      spec,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF555555),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Metrics/Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      value: '${trainer.clientsCount ?? 0}',
                      label: 'Clients',
                      icon: Icons.people_outline_rounded,
                      color: const Color(0xFF4A90E2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      value: '${trainer.verifiedWorkoutsCount ?? 0}',
                      label: 'Verified Workouts',
                      icon: Icons.verified_rounded,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      value: _trainerRating.toStringAsFixed(1),
                      label: '$_trainerReviewCount Reviews',
                      icon: Icons.star_border_rounded,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bio Section
            if (trainer.bio != null && trainer.bio!.isNotEmpty) ...[
              _buildSectionTitle('About Me'),
              _buildCardContainer(
                child: Text(
                  trainer.bio!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF444444),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Contact Information Section
            if ((trainer.email != null && trainer.email!.isNotEmpty) ||
                (trainer.mobile != null && trainer.mobile!.isNotEmpty) ||
                (trainer.gender != null && trainer.gender!.isNotEmpty)) ...[
              _buildSectionTitle('Contact Information'),
              _buildCardContainer(
                child: Column(
                  children: [
                    if (trainer.mobile != null &&
                        trainer.mobile!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            trainer.mobile!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      if ((trainer.email != null &&
                              trainer.email!.isNotEmpty) ||
                          (trainer.gender != null &&
                              trainer.gender!.isNotEmpty))
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFF2F2F2)),
                        ),
                    ],
                    if (trainer.email != null && trainer.email!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            trainer.email!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      if (trainer.gender != null && trainer.gender!.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFF2F2F2)),
                        ),
                    ],
                    if (trainer.gender != null &&
                        trainer.gender!.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.face_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            trainer.gender!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Certifications Section
            if (certifications.isNotEmpty) ...[
              _buildSectionTitle('Certifications'),
              _buildCardContainer(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: certifications.length,
                  separatorBuilder:
                      (context, index) =>
                          const Divider(height: 24, color: Color(0xFFF2F2F2)),
                  itemBuilder: (context, index) {
                    final cert = certifications[index];
                    final fileUrl = cert.fileUrl;
                    final hasPdf = fileUrl != null && fileUrl.isNotEmpty;
                    return InkWell(
                      onTap: hasPdf
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CertificateViewerScreen(
                                    fileUrl: fileUrl,
                                    certificateName: cert.name ?? 'Certificate',
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.workspace_premium_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cert.name ?? 'Certification',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (cert.issuedBy != null &&
                                    cert.issuedBy!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    cert.issuedBy!,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                                if (cert.issuedDate != null &&
                                    cert.issuedDate!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Issued: ${cert.issuedDate}',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (hasPdf) ...[
                            const SizedBox(width: 8),
                            const Center(
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Transformations Section
            if (transformations.isNotEmpty) ...[
              _buildSectionTitle('Transformations'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children:
                      transformations.map((trans) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child:
                                                trans.beforeImage != null &&
                                                        trans
                                                            .beforeImage!
                                                            .isNotEmpty
                                                    ? ImageNetwork(
                                                      trans.beforeImage!,
                                                      height: 160,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    )
                                                    : Container(
                                                      color: const Color(
                                                        0xFFEAEAEA,
                                                      ),
                                                      height: 160,
                                                      child: const Center(
                                                        child: Text(
                                                          'Before',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                          ),
                                          const SizedBox(height: 6),
                                          const Center(
                                            child: Text(
                                              'BEFORE',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child:
                                                trans.afterImage != null &&
                                                        trans
                                                            .afterImage!
                                                            .isNotEmpty
                                                    ? ImageNetwork(
                                                      trans.afterImage!,
                                                      height: 160,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    )
                                                    : Container(
                                                      color: const Color(
                                                        0xFFEAEAEA,
                                                      ),
                                                      height: 160,
                                                      child: const Center(
                                                        child: Text(
                                                          'After',
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                          ),
                                          const SizedBox(height: 6),
                                          Center(
                                            child: Text(
                                              'AFTER',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (trans.description != null &&
                                  trans.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    16,
                                  ),
                                  child: Text(
                                    trans.description!,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 13,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Ratings & Reviews Section
            _buildSectionTitle('Ratings & Reviews'),
            if (_isLoadingReview)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_myReview != null) ...[
              _buildCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Review',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.grey,
                            size: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          elevation: 4,
                          onSelected: (value) async {
                            if (value == 'edit') {
                              _showEditTrainerReviewDialog();
                            } else if (value == 'delete') {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Review'),
                                  content: const Text(
                                    'Are you sure you want to delete your review?',
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
                                    setState(() {
                                      _myReview = null;
                                      _trainerReviewCount = (_trainerReviewCount - 1).clamp(0, 999999);
                                      _trainerRating = 0.0;
                                    });
                                    _fetchReview();
                                  },
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => [
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
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RatingBarIndicator(
                      rating: (_myReview!['rating'] as num?)?.toDouble() ?? 0.0,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 18.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _myReview!['comment']?.toString() ?? '',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _buildCardContainer(
                child: Column(
                  children: [
                    const Text(
                      'Rate your experience with this trainer',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star_border_rounded,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        _showAddTrainerReviewDialog(initialRating: rating);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _showAddTrainerReviewDialog(),
                      child: Text(
                        'Write a review',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
