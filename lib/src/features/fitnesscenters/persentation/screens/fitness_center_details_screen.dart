import 'dart:ui';
import 'dart:async';

import 'package:customer_mobile_app/imports_bindings.dart';

class FitnessCenterDetailsScreen extends StatefulWidget {
  const FitnessCenterDetailsScreen({required this.fitnessCenterId, this.activeMembership, super.key});

  final int fitnessCenterId;
  final ActiveMembershipModel? activeMembership;

  @override
  State<FitnessCenterDetailsScreen> createState() => _FitnessCenterDetailsScreenState();
}

class _FitnessCenterDetailsScreenState extends State<FitnessCenterDetailsScreen> {
  late final FitnessCenterDetailsCubit _cubit;
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentImageIndexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _selectedTabNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> _selectedDayNotifier = ValueNotifier<String>('mon');
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _cubit = FitnessCenterDetailsCubit(id: widget.fitnessCenterId);
    _fetch();
  }

  @override
  void dispose() {
    _cubit.close();
    _pageController.dispose();
    _currentImageIndexNotifier.dispose();
    _selectedTabNotifier.dispose();
    _selectedDayNotifier.dispose();
    _carouselTimer?.cancel();
    super.dispose();
  }

  void _startCarouselTimer(int itemCount) {
    if (itemCount <= 1) return;
    if (_carouselTimer != null) return;
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_pageController.page?.toInt() ?? 0) + 1;
        if (nextPage >= itemCount) {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _openGalleryViewer(BuildContext context, List<String> images, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      barrierLabel: 'Gallery',
      pageBuilder: (context, animation, secondaryAnimation) {
        return GymGalleryViewerDialog(
          images: images,
          initialIndex: initialIndex,
        );
      },
    );
  }

  Future<void> _fetch() async {
    await _cubit.fetch();
  }

  Future<void> _fetchReviews() async {
    await _cubit.fetchFitnessCenterReviews(widget.fitnessCenterId);
  }

  Future<void> _fetchDetails() async {
    await _cubit.fetchFitnessCenterDetails(widget.fitnessCenterId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        extendBody: true,
        backgroundColor: AppColors.lightGrey,
        body: BlocBuilder<FitnessCenterDetailsCubit, FitnessCenterDetailsState>(
          builder: (context, state) {
            return state.fitnessCenterDetails.fold(
              () => const Center(child: CircularProgressIndicator()),
              (either) => either.fold(
                (error) {
                  return error
                      .maybeWhen(network: (e) => ErrorUi.network(onTap: _fetchDetails), notFound: (e) => ErrorUi.notFound(onTap: _fetchDetails), orElse: () => ErrorUi.server(onTap: _fetchDetails))
                      .center;
                },
                (details) => state.fitnessCenterReviews.fold(
                  () => const Center(child: CircularProgressIndicator()),
                  (either) => either.fold(
                    (error) {
                      return error
                          .maybeWhen(network: (e) => ErrorUi.network(onTap: _fetchReviews), notFound: (e) => ErrorUi.notFound(onTap: _fetchReviews), orElse: () => ErrorUi.server(onTap: _fetchReviews))
                          .center;
                    },
                    (reviews) {
                      return _buildDetailsView(details, reviews);
                    },
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: BlocBuilder<FitnessCenterDetailsCubit, FitnessCenterDetailsState>(
          buildWhen: (p, c) => p.fitnessCenterDetails != c.fitnessCenterDetails,
          builder: (context, state) {
            return state.fitnessCenterDetails.fold(
              () => const SizedBox.shrink(),
              (either) => either.fold(
                (error) => const SizedBox.shrink(),
                (details) {
                  if (widget.activeMembership == null) {
                    return _buildJoinNowButton(details);
                  }
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailsView(FitnesscenterDetailsModel details, FitnessCenterReviewsModel reviews) {
    final photos = details.photos?.where((photo) => photo.image != null).toList() ?? [];
    final hasPhotos = photos.isNotEmpty;

    if (hasPhotos) {
      final images = photos.map((p) => p.image!).toList();
      _startCarouselTimer(images.length);

      return SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Image Carousel
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      _currentImageIndexNotifier.value = index;
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _openGalleryViewer(context, images, index),
                        child: ImageNetwork(
                          images[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                IgnorePointer(
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
                // Top Custom Header Row
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1.0,
                                  ),
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
                      ],
                    ),
                  ),
                ),
                // Carousel Indicator Dots
                if (images.length > 1)
                  Positioned(
                    bottom: 40, // Slightly above the profile card
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ValueListenableBuilder<int>(
                          valueListenable: _currentImageIndexNotifier,
                          builder: (context, currentIdx, _) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(images.length, (index) {
                                final isActive = index == currentIdx;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                  width: isActive ? 14 : 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                // Profile Card
                Positioned(
                  bottom: -90,
                  left: 16,
                  right: 16,
                  child: _buildProfileCard(details, reviews),
                ),
              ],
            ),
            const SizedBox(height: 106), // 90 for overlap + 16 spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildTagsAndLocationCard(details),
                  const SizedBox(height: 16),
                  _buildTabsCard(details),
                  const SizedBox(height: 120), // extra padding for bottom button
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // No photos included: remove the carousel and top stack entirely
      return SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildProfileCard(details, reviews),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildTagsAndLocationCard(details),
                  const SizedBox(height: 16),
                  _buildTabsCard(details),
                  const SizedBox(height: 120), // extra padding for bottom button
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProfileCard(FitnesscenterDetailsModel details, FitnessCenterReviewsModel reviews) {
    final logoUrl = details.logo;
    final avgRating = (reviews.results?.avgRating as num?)?.toDouble() ?? 4.5;
    final reviewCount = reviews.results?.reviewCount ?? 0;
    final packagesCount = details.packages?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.black,
                  child: logoUrl != null && logoUrl.isNotEmpty
                      ? ImageNetwork(
                          logoUrl,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/mascot_Image.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[100],
                            child: const Icon(Icons.fitness_center, color: Colors.grey),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.name ?? 'Fitness Center',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      details.categories?.isNotEmpty == true
                          ? details.categories!.first.name ?? 'Fitness Center'
                          : 'Fitness Center',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem('$packagesCount', 'Packages'),
                        _buildRatingItem(
                          avgRating.toStringAsFixed(1),
                          '($reviewCount)',
                        ),
                        _buildDirectionItem(details),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRatingItem(String rating, String count) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 16),
            const SizedBox(width: 4),
            Text(
              '$rating$count',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Text(
          'Rating',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDirectionItem(FitnesscenterDetailsModel details) {
    return InkWell(
      onTap: () async {
        final loc = details.location;
        if (loc != null) {
          final lat = loc.latitude;
          final lng = loc.longitude;
          Uri mapUri;
          if (lat != null && lng != null) {
            mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
          } else {
            final address = [loc.buildingName, loc.street, loc.city, loc.state]
                .where((e) => e != null && e.isNotEmpty)
                .join(', ');
            mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
          }
          if (await canLaunchUrl(mapUri)) {
            await launchUrl(mapUri);
          } else {
            await Dialogs.showSnack(msg: 'Could not open maps');
          }
        } else {
          await Dialogs.showSnack(msg: 'Location not available');
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions,
              color: Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Direction',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsAndLocationCard(FitnesscenterDetailsModel details) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${_buildLocationString(details.location) ?? 'Location N/A'}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            details.description ?? 'No description available.',
            style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.4),
          ),
          const SizedBox(height: 16),
          if (details.socialMedia?.isNotEmpty ?? false)
            Row(
              children: details.socialMedia!.map((e) {
                final platform = (e.platform ?? '').toLowerCase();
                String assetPath;
                switch (platform) {
                  case 'facebook':
                    assetPath = 'assets/images/svg/icons/facebook.svg';
                    break;
                  case 'instagram':
                    assetPath = 'assets/images/svg/icons/instagram.svg';
                    break;
                  case 'whatsapp':
                    assetPath = 'assets/images/svg/icons/whatsapp.svg';
                    break;
                  case 'youtube':
                    assetPath = 'assets/images/svg/icons/youtube.svg';
                    break;
                  default:
                    assetPath = 'assets/images/svg/icons/website.svg';
                }

                final iconColor = AppColors.primary;
                final bgColor = AppColors.primary.withOpacity(0.05);

                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(99),
                    onTap: () async {
                      final url = e.url ?? '';
                      if (platform == 'whatsapp') {
                        final phone = url.replaceAll(RegExp('[^0-9+]'), '');
                        if (phone.isNotEmpty) {
                          final waUrl = Uri.parse('https://wa.me/$phone');
                          if (await canLaunchUrl(waUrl)) {
                            await launchUrl(waUrl);
                          } else {
                            await Dialogs.showSnack(msg: 'Invalid WhatsApp number');
                          }
                        } else {
                          await Dialogs.showSnack(msg: 'Invalid WhatsApp number');
                        }
                      } else {
                        final uri = url.startsWith('http://') || url.startsWith('https://') 
                            ? Uri.parse(url) 
                            : Uri.parse('https://$url');
                        if (url.isNotEmpty && await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          await Dialogs.showSnack(msg: 'Invalid URL');
                        }
                      }
                    },
                    child: _buildSocialIcon(assetPath, iconColor, bgColor),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSocialIcon(String assetPath, Color iconColor, Color bgColor) {
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        assetPath,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    );
  }

  IconData _getAmenityIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('wifi')) return Icons.wifi;
    if (lower.contains('elevator') || lower.contains('lift')) return Icons.elevator;
    if (lower.contains('locker')) return Icons.lock_outline;
    if (lower.contains('ac') || lower.contains('air condition')) return Icons.ac_unit;
    if (lower.contains('cctv') || lower.contains('camera')) return Icons.videocam_outlined;
    if (lower.contains('parking')) return Icons.local_parking;
    if (lower.contains('water') || lower.contains('drinking')) return Icons.local_drink;
    if (lower.contains('changing') || lower.contains('shower')) return Icons.shower_outlined;
    return Icons.star_border; // fallback
  }

  Widget _buildTabsCard(FitnesscenterDetailsModel details) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              height: 56,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: _selectedTabNotifier,
                builder: (context, activeTab, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectedTabNotifier.value = 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: activeTab == 0 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: activeTab == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Amenities',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: activeTab == 0 ? FontWeight.w500 : FontWeight.w400,
                                fontSize: 14,
                                height: 1.5,
                                letterSpacing: -0.41,
                                color: activeTab == 0 ? AppColors.primary : const Color(0xFF444444),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectedTabNotifier.value = 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: activeTab == 1 ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: activeTab == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Schedule',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: activeTab == 1 ? FontWeight.w500 : FontWeight.w400,
                                fontSize: 14,
                                height: 1.5,
                                letterSpacing: -0.41,
                                color: activeTab == 1 ? AppColors.primary : const Color(0xFF444444),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _selectedTabNotifier,
            builder: (context, activeTab, _) {
              if (activeTab == 0) {
                return _buildAmenitiesTab(details);
              } else {
                return _buildScheduleTab(details);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesTab(FitnesscenterDetailsModel details) {
    final amenitiesList = details.amenities ?? [];
    if (amenitiesList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'No amenities specified',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.start,
        children: amenitiesList.map((amenity) {
          final name = amenity.name ?? 'Amenity';
          final icon = _getAmenityIcon(name);
          return SizedBox(
            width: 72,
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScheduleTab(FitnesscenterDetailsModel details) {
    final daysOfWeek = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final dayLabels = {
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
    };

    return ValueListenableBuilder<String>(
      valueListenable: _selectedDayNotifier,
      builder: (context, selectedDay, _) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: daysOfWeek.map((day) {
                    final isSelected = selectedDay == day;
                    final workingDay = details.workingDays?.firstWhere(
                      (d) => (d.day ?? '').toLowerCase() == day,
                      orElse: () => WorkingDay(day: day, isOpen: day != 'sun'),
                    );
                    final isOpen = workingDay?.isOpen ?? (day != 'sun');

                    final chipBgColor = isOpen ? const Color(0xFFE2F9EC) : const Color(0xFFF2F2F2);
                    final textColor = isOpen ? const Color(0xFF1EA864) : Colors.grey;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          _selectedDayNotifier.value = day;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: chipBgColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dayLabels[day] ?? day,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              Builder(
                builder: (context) {
                  final workingDay = details.workingDays?.firstWhere(
                    (d) => (d.day ?? '').toLowerCase() == selectedDay,
                    orElse: () => WorkingDay(
                      day: selectedDay,
                      isOpen: selectedDay != 'sun',
                      morningOpeningTime: '05:30:00',
                      morningClosingTime: '09:30:00',
                      eveningOpeningTime: '16:00:00',
                      eveningClosingTime: '22:30:00',
                    ),
                  );

                  final isOpen = workingDay?.isOpen ?? (selectedDay != 'sun');

                  if (!isOpen) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.event_busy, color: Colors.grey, size: 40),
                          const SizedBox(height: 12),
                          const Text(
                            'Gym is closed on this day',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final morningStart = _formatTimeString(workingDay?.morningOpeningTime ?? '05:30:00');
                  final morningEnd = _formatTimeString(workingDay?.morningClosingTime ?? '09:30:00');
                  final eveningStart = _formatTimeString(workingDay?.eveningOpeningTime ?? '16:00:00');
                  final eveningEnd = _formatTimeString(workingDay?.eveningClosingTime ?? '22:30:00');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeSlotSection('Morning', morningStart, morningEnd),
                      const SizedBox(height: 16),
                      _buildTimeSlotSection('Evening', eveningStart, eveningEnd),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotSection(String title, String start, String end) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTimeBox(start)),
            const SizedBox(width: 12),
            Expanded(child: _buildTimeBox(end)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeBox(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SvgPicture.asset(
            'assets/images/svg/icons/clock.svg',
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
        ],
      ),
    );
  }

  String _formatTimeString(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '--:--';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        final minute = parts[1];
        final ampm = hour >= 12 ? 'PM' : 'AM';
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        final hourStr = hour.toString().padLeft(2, '0');
        return '$hourStr:$minute $ampm';
      }
    } catch (_) {}
    return timeStr;
  }

  Widget _buildCertificatesCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'View Certificates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildReviewsCard(FitnesscenterDetailsModel details, FitnessCenterReviewsModel reviews) {
    final list = reviews.results?.reviews ?? [];
    final avgRating = (reviews.results?.avgRating as num?)?.toDouble() ?? 4.5;
    final reviewCount = reviews.results?.reviewCount ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating & Reviews',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: List.generate(
                  5,
                  (index) {
                    final starValue = index + 1;
                    if (avgRating >= starValue) {
                      return const Icon(Icons.star, color: Colors.orange, size: 24);
                    } else if (avgRating >= starValue - 0.5) {
                      return const Icon(Icons.star_half, color: Colors.orange, size: 24);
                    } else {
                      return const Icon(Icons.star_border, color: Colors.orange, size: 24);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "$reviewCount ${reviewCount == 1 ? 'Review' : 'Reviews'}",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'No reviews yet',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            )
          else ...[
            ...list.take(3).map((review) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildReviewItem(review),
            )),
          ],
          const SizedBox(height: 16),
          if (reviews.next?.isNotEmpty ?? false)
            InkWell(
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              onTap: () {
                context.push(ReviewsAndRatingsScreen(fitnessCenterId: widget.fitnessCenterId));
              },
              child: Row(
                children: [
                  Text('View All Reviews', style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.primary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(SingleFitnessCenterReviewModel review) {
    final rating = (review.rating as num?)?.toDouble() ?? 0.0;
    final comment = review.comment ?? '';
    final createdAt = review.created != null ? review.created!.toLocal().format('dd MMM yyyy') : '';
    final customerName = review.customerName ?? 'Anonymous';
    final customerImage = review.profilePicture;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: customerImage != null && customerImage.toString().isNotEmpty
                      ? ImageNetwork(
                          customerImage.toString(),
                          height: 32,
                          width: 32,
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.person, size: 16, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    if (createdAt.isNotEmpty)
                      Text(
                        createdAt,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }

  String? _buildLocationString(Location? location) {
    if (location == null) return null;

    final parts = <String>[];
    if (location.city?.isNotEmpty ?? false) parts.add(location.city!);
    if (location.state?.isNotEmpty ?? false) parts.add(location.state!);

    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  Widget _buildJoinNowButton(FitnesscenterDetailsModel details) {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: GestureDetector(
          onTap: () async {
            final phone = details.phoneNumber?.replaceAll(RegExp('[^0-9+]'), '') ?? '';
            if (phone.isNotEmpty) {
              final message = Uri.encodeComponent(
                'Hi,\n\n'
                'I would like to know more about your membership plans, facilities, timings, and current offers.\n\n'
                'Thank you.\n\n'
                '—\n'
                'This enquiry was initiated through the Discipl App.',
              );
              final waUrl = Uri.parse('https://wa.me/$phone?text=$message');
              if (await canLaunchUrl(waUrl)) {
                await launchUrl(waUrl);
              } else {
                await Dialogs.showSnack(msg: 'Invalid WhatsApp number');
              }
            } else {
              await Dialogs.showSnack(msg: 'WhatsApp number not available');
            }
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/images/svg/icons/whatsapp_logo.svg',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Enquire',
                  style: AppStyles.text16Px.poppins.w600.light,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GymGalleryViewerDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const GymGalleryViewerDialog({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<GymGalleryViewerDialog> createState() => _GymGalleryViewerDialogState();
}

class _GymGalleryViewerDialogState extends State<GymGalleryViewerDialog> {
  late int _currentIndex;
  late PageController _viewerPageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _viewerPageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _viewerPageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < widget.images.length - 1) {
      _currentIndex++;
      _viewerPageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {});
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _viewerPageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {});
    }
  }

  void _onThumbnailTap(int index) {
    _currentIndex = index;
    _viewerPageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Solid dark background to prevent any shader/color banding issues
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black.withOpacity(0.92),
              ),
            ),
          ),
          
          // Back Button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Large image in the center with left/right arrows
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Image Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: PageView.builder(
                          controller: _viewerPageController,
                          itemCount: widget.images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return ImageNetwork(
                              widget.images[index],
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                    // Left Arrow
                    if (_currentIndex > 0)
                      Positioned(
                        left: 16,
                        child: GestureDetector(
                          onTap: _prev,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    // Right Arrow
                    if (_currentIndex < widget.images.length - 1)
                      Positioned(
                        right: 16,
                        child: GestureDetector(
                          onTap: _next,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Thumbnail list
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.images.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentIndex;
                    return GestureDetector(
                      onTap: () => _onThumbnailTap(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ImageNetwork(
                            widget.images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
