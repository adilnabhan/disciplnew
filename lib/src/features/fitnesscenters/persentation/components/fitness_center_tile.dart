import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:url_launcher/url_launcher.dart';

class FitnessCenterTile extends StatelessWidget {
  const FitnessCenterTile({required this.fitnessCenter, this.activeMembership, super.key});

  final SingleFItnessCenterModel fitnessCenter;
  final ActiveMembershipModel? activeMembership;

  @override
  Widget build(BuildContext context) {
    // Build location string
    String locationText = 'Location N/A';
    if (fitnessCenter.location != null) {
      final loc = fitnessCenter.location!;
      final parts = [loc.street, loc.city];
      final validParts = parts.where((e) => e != null && e.toString().isNotEmpty).toList();
      if (validParts.isNotEmpty) {
        locationText = validParts.join(', ');
      }
    }

    return InkWell(
      onTap: () {
        if (fitnessCenter.id != null) {
          context.push(FitnessCenterDetailsScreen(fitnessCenterId: fitnessCenter.id ?? 0, activeMembership: activeMembership));
        } else {
          Dialogs.showSnack(msg: 'Fitness center not found');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fitness center logo/image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ImageNetwork(
                fitnessCenter.logo ?? '',
                height: 126,
                width: 126,
                errorWidget: Container(
                  width: 126,
                  height: 126,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, color: Colors.white, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Content Column
            Expanded(
              child: SizedBox(
                height: 126,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          fitnessCenter.name ?? 'N/A',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                            color: Color(0xFF222222),
                          ),
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Categories
                        _buildCategoryTags(),
                        const SizedBox(height: 4),
                        // Location Row
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: Color(0xFF789081),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                locationText,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF666666),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Enquire via WhatsApp
                    GestureDetector(
                      onTap: () async {
                        final phone = fitnessCenter.phoneNumber?.replaceAll(RegExp('[^0-9+]'), '') ?? '';
                        if (phone.isNotEmpty) {
                          final message = Uri.encodeComponent("Hi, I want to enquire about ${fitnessCenter.name ?? 'the fitness center'}.");
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/images/svg/icons/whatsapp_logo.svg',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Enquire',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTags() {
    final categories = fitnessCenter.categories ?? [];
    if (categories.isEmpty) return const SizedBox.shrink();

    final visibleCategories = categories.take(2).toList();
    final remainingCount = categories.length - visibleCategories.length;

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ...visibleCategories.map((cat) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            cat.name ?? '',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
        )),
        if (remainingCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$remainingCount',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
            ),
          ),
      ],
    );
  }
}
