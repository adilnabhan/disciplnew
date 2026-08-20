import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'certificate_viewer_screen.dart';
import 'package:customer_mobile_app/src/features/reviews_and_rating/domain/models/trainer_reviews_model.dart';
import 'package:customer_mobile_app/src/features/reviews_and_rating/presentation/screens/trainer_reviews_and_ratings_screen.dart';

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
  TrainerReviewsModel? _allReviews;
  bool _isLoadingReviewsAll = true;
  CustomerDetailsModel? _customerDetails;

  final PageController _headerPageController = PageController();
  int _currentHeaderIndex = 0;

  final PageController _transPageController = PageController();
  int _currentTransIndex = 0;
  String _selectedTransTab = 'Before';

  @override
  void initState() {
    super.initState();
    _trainerRating = (widget.trainer.averageRating as num?)?.toDouble() ?? 4.5;
    _trainerReviewCount = widget.trainer.reviewCount ?? 19;
    _fetchReview();
    _fetchReviewsAll();
    _fetchCustomerDetails();
  }

  @override
  void dispose() {
    _headerPageController.dispose();
    _transPageController.dispose();
    super.dispose();
  }

  Future<void> _fetchCustomerDetails() async {
    final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
    final customerId = currentUser?.customer?.id;
    if (customerId != null && _customerDetails == null) {
      final res = await CustomerDetailsRepository().customerDetails(id: customerId);
      if (mounted) {
        res.fold(
          (_) {},
          (details) {
            setState(() {
              _customerDetails = details;
            });
          },
        );
      }
    }
  }

  bool _isTrainerAssigned() {
    if (_customerDetails == null) return false;
    final assigned = _customerDetails!.assignedTrainer;
    if (assigned == null) return false;

    final trainerId = widget.trainer.id;
    final assignedId = int.tryParse(assigned['id']?.toString() ?? '') ??
        int.tryParse(assigned['trainer_id']?.toString() ?? '') ??
        int.tryParse(assigned['trainer']?.toString() ?? '') ??
        int.tryParse(assigned['pk']?.toString() ?? '');

    if (trainerId != null && assignedId != null && assignedId == trainerId) {
      return true;
    }

    final assignedName = assigned['name']?.toString()?.trim().toLowerCase() ??
        assigned['full_name']?.toString()?.trim().toLowerCase();
    final trainerName = widget.trainer.fullName?.trim().toLowerCase() ??
        widget.trainer.userType?.trim().toLowerCase();

    if (assignedName != null && trainerName != null && assignedName.isNotEmpty) {
      if (assignedName == trainerName) {
        return true;
      }
    }

    return false;
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

  Future<void> _fetchReviewsAll() async {
    if (widget.trainer.id == null) return;
    setState(() {
      _isLoadingReviewsAll = true;
    });
    final res = await ReviewsAndReatingRepository().getTrainerReviewsAll(
      trainerId: widget.trainer.id!,
      queryParameters: {'page': 1},
    );
    if (mounted) {
      setState(() {
        res.fold(
          (error) {
            _allReviews = null;
          },
          (reviews) {
            _allReviews = reviews;
            _trainerReviewCount = reviews.count;
          },
        );
        _isLoadingReviewsAll = false;
      });
    }
  }

  List<String> _getHeaderImages() {
    final List<String> images = [];
    if (widget.trainer.bannerImage != null && widget.trainer.bannerImage!.isNotEmpty) {
      images.add(widget.trainer.bannerImage!);
    } else {
      if (widget.trainer.profileImage != null && widget.trainer.profileImage!.isNotEmpty) {
        images.add(widget.trainer.profileImage!);
      } else if (widget.trainer.transformations != null) {
        for (final trans in widget.trainer.transformations!) {
          if (trans.beforeImage != null && trans.beforeImage!.isNotEmpty) {
            images.add(trans.beforeImage!);
            break;
          } else if (trans.afterImage != null && trans.afterImage!.isNotEmpty) {
            images.add(trans.afterImage!);
            break;
          }
        }
      }
    }
    return images;
  }

  void _onViewCertificates() {
    final certs = (widget.trainer.certifications ?? [])
        .where((c) => c.fileUrl != null && c.fileUrl!.trim().isNotEmpty)
        .toList();
    if (certs.isEmpty) {
      Dialogs.showSnack(msg: 'No certificates available');
      return;
    }
    if (certs.length == 1) {
      final cert = certs.first;
      final fileUrl = cert.fileUrl!;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CertificateViewerScreen(
            fileUrl: fileUrl,
            certificateName: cert.name ?? 'Certificate',
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Certifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: certs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  itemBuilder: (context, index) {
                    final cert = certs[index];
                    final fileUrl = cert.fileUrl;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFECEF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFFE53935),
                          size: 18,
                        ),
                      ),
                      title: Text(
                        cert.name ?? 'Certification',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      subtitle: cert.issuedBy != null
                          ? Text(
                              cert.issuedBy!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Poppins',
                                color: Color(0xFF757575),
                              ),
                            )
                          : null,
                      trailing: const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Color(0xFF9E9E9E),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        if (fileUrl != null && fileUrl.isNotEmpty) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CertificateViewerScreen(
                                fileUrl: fileUrl,
                                certificateName: cert.name ?? 'Certificate',
                              ),
                            ),
                          );
                        }
                      },
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
                        _fetchReviewsAll();
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
                        _fetchReviewsAll();
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
    final headerImages = _getHeaderImages();
    final specs = trainer.specializations ?? [];
    final transformations = (trainer.transformations ?? [])
        .where((t) =>
            (t.beforeImage != null && t.beforeImage!.trim().isNotEmpty) ||
            (t.afterImage != null && t.afterImage!.trim().isNotEmpty))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Top Header Image Banner Carousel (Only rendered if bannerImage is present)
                if (headerImages.isNotEmpty) ...[
                  Stack(
                    children: [
                      SizedBox(
                        height: 280,
                        width: double.infinity,
                        child: PageView.builder(
                          controller: _headerPageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentHeaderIndex = index;
                            });
                          },
                          itemCount: headerImages.length,
                          itemBuilder: (context, index) {
                            return ImageNetwork(
                              headerImages[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 280,
                            );
                          },
                        ),
                      ),
                      // Dark Gradient Overlay at Bottom of Banner
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 70,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.45),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Carousel Dot Indicator
                      if (headerImages.length > 1)
                        Positioned(
                          bottom: 38,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              headerImages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: _currentHeaderIndex == index ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentHeaderIndex == index
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ] else ...[
                  SizedBox(height: MediaQuery.of(context).padding.top + 50),
                ],

                // Cards Section
                Transform.translate(
                  offset: headerImages.isNotEmpty
                      ? const Offset(0, -24)
                      : Offset.zero,
                  child: Column(
                    children: [
                      // CARD 1: Profile Info Card
                      _buildMainProfileCard(),
                      const SizedBox(height: 14),

                      // CARD 2: Tags, Location, Description & Social Icons Card
                      if (specs.isNotEmpty ||
                          (trainer.bio != null && trainer.bio!.isNotEmpty) ||
                          trainer.place != null ||
                          trainer.location != null ||
                          (trainer.socialMedia != null && trainer.socialMedia!.isNotEmpty)) ...[
                        _buildDetailsCard(specs),
                        const SizedBox(height: 14),
                      ],

                      // CARD 3: Transformations (Before / After Card)
                      if (transformations.isNotEmpty) ...[
                        _buildTransformationsCard(transformations),
                        const SizedBox(height: 14),
                      ],

                      // CARD 4: View Certificates Tile
                      if ((trainer.certifications ?? []).any((c) => c.fileUrl != null && c.fileUrl!.trim().isNotEmpty)) ...[
                        _buildViewCertificatesTile(),
                        const SizedBox(height: 14),
                      ],

                      // CARD 5: Rating & Reviews Card
                      if (_isLoadingReview || _isLoadingReviewsAll)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        _buildReviewsCard(),
                        if (_isTrainerAssigned() && _myReview == null) ...[
                          const SizedBox(height: 12),
                          _buildAddReviewPromptCard(),
                        ],
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Floating Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFF333333),
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainProfileCard() {
    final trainer = widget.trainer;
    final clients = trainer.clientsCount ?? 0;
    final workouts = trainer.verifiedWorkoutsCount ?? 0;
    final rating = _trainerRating;
    final reviewCount = _trainerReviewCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Profile Image
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: SizedBox(
              width: 80,
              height: 80,
              child: trainer.profileImage != null && trainer.profileImage!.isNotEmpty
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
          const SizedBox(width: 16),

          // Right Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Name and User Type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trainer.fullName ?? 'Trainer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    if (trainer.userType != null && trainer.userType!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        trainer.userType!,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),

                // Stats Row: Clients | Verified Workouts | Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Clients Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$clients',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Clients',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),

                    // Verified Workouts Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$workouts',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Verified\nWorkouts',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF757575),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),

                    // Rating Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFB800),
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E1E1E),
                                    ),
                                  ),
                                  TextSpan(
                                    text: '($reviewCount)',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Rating',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF757575),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(List<String> specs) {
    final trainer = widget.trainer;
    final bio = trainer.bio;
    final locationName = trainer.place ??
        trainer.location?.place ??
        trainer.location?.area ??
        trainer.location?.city;
    final socialMedia = trainer.socialMedia ?? [];

    final hasSpecs = specs.isNotEmpty;
    final hasLocation = locationName != null && locationName.isNotEmpty;
    final hasBio = bio != null && bio.isNotEmpty;
    final hasSocial = socialMedia.isNotEmpty;

    if (!hasSpecs && !hasLocation && !hasBio && !hasSocial) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Specialization Badges
          if (hasSpecs) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: specs
                  .map(
                    (spec) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        spec,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (hasLocation || hasBio || hasSocial) const SizedBox(height: 16),
          ],

          // Location Row
          if (hasLocation) ...[
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFF5B9E77),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    locationName!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A4A4A),
                    ),
                  ),
                ),
              ],
            ),
            if (hasBio || hasSocial) const SizedBox(height: 12),
          ],

          // Bio / Description
          if (hasBio) ...[
            Text(
              bio!,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF4A4A4A),
              ),
            ),
            if (hasSocial) const SizedBox(height: 16),
          ],

          // Social Icons Row
          if (hasSocial)
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: socialMedia.map((sm) {
                return _buildSocialButton(
                  platform: sm.platform ?? '',
                  url: sm.url,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String platform,
    String? url,
  }) {
    final p = platform.toLowerCase();
    IconData iconData;
    const Color iconColor = Color(0xFFE53935);

    if (p.contains('instagram')) {
      iconData = Icons.camera_alt_outlined;
    } else if (p.contains('facebook')) {
      iconData = Icons.facebook;
    } else if (p.contains('youtube')) {
      iconData = Icons.play_arrow_rounded;
    } else if (p.contains('whatsapp')) {
      iconData = Icons.chat_bubble_outline_rounded;
    } else {
      iconData = Icons.link_rounded;
    }

    return InkWell(
      onTap: () async {
        if (url != null && url.isNotEmpty) {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          }
        }
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFFFECEF),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            iconData,
            color: iconColor,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildTransformationsCard(List<GymTransformation> transformations) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Tab Switches (Before / After)
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTransTab = 'Before';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Before',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTransTab = 'After';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'After',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Transformation Images Row
          SizedBox(
            height: 170,
            child: PageView.builder(
              controller: _transPageController,
              onPageChanged: (index) {
                setState(() {
                  _currentTransIndex = index;
                });
              },
              itemCount: transformations.length,
              itemBuilder: (context, index) {
                final trans = transformations[index];
                return Row(
                  children: [
                    // Before Box
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6D6DA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: trans.beforeImage != null && trans.beforeImage!.isNotEmpty
                                  ? ImageNetwork(
                                      trans.beforeImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Transformation\nBefore Pic',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF333333),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // After Box
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFD6D6DA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: trans.afterImage != null && trans.afterImage!.isNotEmpty
                                  ? ImageNetwork(
                                      trans.afterImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Transformation\nAfter Pic',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF333333),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          if (transformations.length > 1) ...[
            const SizedBox(height: 14),
            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                transformations.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentTransIndex
                        ? Colors.red
                        : Colors.grey.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewCertificatesTile() {
    return GestureDetector(
      onTap: _onViewCertificates,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECEF),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.description_outlined,
                  color: Color(0xFFE53935),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Text(
              'View Certificates',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9E9E9E),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsCard() {
    final list = _allReviews?.results ?? [];
    final avgRating = _trainerRating > 0 ? _trainerRating : 4.5;
    final reviewCount = _trainerReviewCount > 0 ? _trainerReviewCount : 128;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating & Reviews',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(width: 14),
              Row(
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  if (avgRating >= starValue) {
                    return const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFB800),
                      size: 24,
                    );
                  } else if (avgRating >= starValue - 0.5) {
                    return const Icon(
                      Icons.star_half_rounded,
                      color: Color(0xFFFFB800),
                      size: 24,
                    );
                  } else {
                    return const Icon(
                      Icons.star_outline_rounded,
                      color: Color(0xFFFFB800),
                      size: 24,
                    );
                  }
                }),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '$reviewCount Reviews',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Text(
                  'No reviews available',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF757575),
                  ),
                ),
              ),
            )
          else ...[
            ...list
                .take(3)
                .map(
                  (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildReviewItem(review),
                  ),
                ),
          ],
          if (list.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                onTap: () async {
                  final needRefresh = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TrainerReviewsAndRatingsScreen(
                        trainer: widget.trainer,
                      ),
                    ),
                  );
                  if (needRefresh == true) {
                    _fetchReview();
                    _fetchReviewsAll();
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all Reviews',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(SingleTrainerReview review) {
    final rating = review.rating.toDouble();
    final comment = review.comment;
    final customerName = review.customerName.isNotEmpty ? review.customerName : 'David James';
    final customerImage = review.profilePicture;

    final currentUser = context.read<AppCubit>().state.currentUser;
    final currentUserName = '${currentUser?.firstName ?? ''} ${currentUser?.lastName ?? ''}'.trim();
    final isOwnReview = currentUserName.isNotEmpty &&
        customerName.trim().toLowerCase() == currentUserName.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFEEEEEE)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: customerImage != null && customerImage.isNotEmpty
                      ? ImageNetwork(
                          customerImage,
                          height: 36,
                          width: 36,
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  customerName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwnReview) ...[
                const SizedBox(width: 4),
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
                          content: const Text('Are you sure you want to delete your review?'),
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
                      if (confirm == true && mounted) {
                        final res = await ReviewsAndReatingRepository().deleteTrainerReview(
                          trainerId: widget.trainer.id!,
                        );
                        res.fold(
                          (error) => Dialogs.showSnack(msg: error.msg),
                          (_) {
                            Dialogs.showSnack(msg: 'Review deleted successfully');
                            setState(() {
                              _myReview = null;
                              _trainerReviewCount = (_trainerReviewCount - 1).clamp(0, 999999);
                            });
                            _fetchReview();
                            _fetchReviewsAll();
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
                  ],
                ),
              ],
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              comment,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Color(0xFF555555),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddReviewPromptCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
    );
  }
}
