import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/models/winner_popup_model.dart';
import 'package:customer_mobile_app/src/features/challenges/domain/repositories/challenge_repository.dart';
import 'package:customer_mobile_app/src/features/challenges/presentation/screens/challenge_winners_screen.dart';

class WinnerAnnouncementDialog extends StatefulWidget {
  final WinnerPopupData winner;

  const WinnerAnnouncementDialog({
    super.key,
    required this.winner,
  });

  static bool _isShowing = false;

  static Future<void> show(
    BuildContext context, {
    required WinnerPopupData winner,
  }) async {
    if (_isShowing) return;
    _isShowing = true;

    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.65),
        builder: (dialogContext) => WinnerAnnouncementDialog(winner: winner),
      );
    } finally {
      _isShowing = false;
    }
  }

  @override
  State<WinnerAnnouncementDialog> createState() => _WinnerAnnouncementDialogState();
}

class _WinnerAnnouncementDialogState extends State<WinnerAnnouncementDialog> {
  bool _isMarkingSeen = false;

  Future<void> _handleDismiss({bool navigateToWinners = false}) async {
    if (_isMarkingSeen) return;
    setState(() {
      _isMarkingSeen = true;
    });

    final navigator = Navigator.of(context);
    final challengeId = widget.winner.challengeId;

    // 1. Close dialog
    navigator.pop();

    // 2. Mark as seen in background
    ChallengeRepository().markWinnerPopupSeen(challengeId);

    // 3. Navigate if requested
    if (navigateToWinners && challengeId > 0) {
      navigator.push(
        MaterialPageRoute<void>(
          builder: (context) => ChallengeWinnersScreen(challengeId: challengeId),
        ),
      );
    }
  }

  Color _parseColor(String? hexString, {Color fallback = const Color(0xFF70007C)}) {
    if (hexString == null || hexString.trim().isEmpty) return fallback;
    try {
      var clean = hexString.trim().replaceAll('#', '');
      if (clean.toLowerCase().startsWith('0x')) {
        clean = clean.substring(2);
      }
      if (clean.length == 6) {
        return Color(int.parse('0xFF$clean'));
      } else if (clean.length == 8) {
        return Color(int.parse('0x$clean'));
      }
    } catch (_) {}
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.winner;
    final themeColor = _parseColor(winner.themeColor, fallback: const Color(0xFF70007C));
    final cardBgColor = themeColor.withValues(alpha: 0.12);
    final currentUser = Feggy.read<AppCubit>()?.state.currentUser;
    final firstName = currentUser?.firstName ?? '';
    final lastName = currentUser?.lastName ?? '';
    final winnerName = (firstName.isNotEmpty || lastName.isNotEmpty)
        ? '$firstName $lastName'.trim()
        : 'Lucky Winner';
    final avatarUrl = winner.profileImage ?? currentUser?.profilePicture?.toString();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Main Dialog Card Container
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 350),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFDEDD7),
                  Color(0xFFFEFBF7),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Bottom Background Confetti Graphic
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 130,
                    child: Image.asset(
                      'assets/images/png/vectors/winner_popup_bottom.png',
                      width: double.infinity,
                      height: 130,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Main Content Column
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Full-Width Trophy Graphic Header
                        _buildTrophyHeader(),
                        const SizedBox(height: 6),

                        // Card Content Body
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 2. WINNER Header Text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'You are a',
                                    style: AppStyles.text13Px.poppins.w600.copyWith(
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                                ],
                              ),
                              const SizedBox(height: 2),

                              Text(
                                'WINNER!',
                                style: AppStyles.text28Px.poppins.w800.copyWith(
                                  fontSize: 28,
                                  color: themeColor,
                                  letterSpacing: 1.3,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // — in — divider text
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 24, height: 1.5, color: themeColor.withValues(alpha: 0.6)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      'in',
                                      style: AppStyles.text12Px.poppins.w500.copyWith(
                                        fontSize: 12,
                                        color: const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                  Container(width: 24, height: 1.5, color: themeColor.withValues(alpha: 0.6)),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // 3. Challenge Card Container (Matching Reference Style)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: themeColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.emoji_events_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            winner.challengeName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppStyles.text14Px.poppins.w700.copyWith(
                                              color: const Color(0xFF111827),
                                              fontSize: 14.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            winner.formattedSubtext,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppStyles.text12Px.poppins.w400.copyWith(
                                              color: const Color(0xFF4B5563),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // 4. Compact Customer Avatar & Name
                              if (winnerName.isNotEmpty) ...[
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: themeColor.withValues(alpha: 0.35),
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: avatarUrl != null && avatarUrl.isNotEmpty
                                        ? ImageNetwork(
                                            avatarUrl,
                                            fit: BoxFit.cover,
                                            errorWidget: _buildAvatarPlaceholder(),
                                          )
                                        : _buildAvatarPlaceholder(),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  winnerName,
                                  style: AppStyles.text14Px.poppins.w700.copyWith(
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],

                              // 5. Compact Motivational Text
                              Text(
                                'Your hard work, consistency and\ndedication have paid off.',
                                textAlign: TextAlign.center,
                                style: AppStyles.text13Px.poppins.w400.copyWith(
                                  fontSize: 12.5,
                                  color: const Color(0xFF4B5563),
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Keep Crushing! 💪',
                                textAlign: TextAlign.center,
                                style: AppStyles.text14Px.poppins.w700.copyWith(
                                  color: themeColor,
                                ),
                              ),
                              const SizedBox(height: 10),

                          // 7. Centered Primary CTA Button
                          SizedBox(
                            width: 190,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => _handleDismiss(navigateToWinners: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 3,
                                shadowColor: themeColor.withValues(alpha: 0.35),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 14),
                                  Text(
                                    'View Reward',
                                    style: AppStyles.text15Px.poppins.w700.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_rounded,
                                      color: themeColor,
                                      size: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

          // Top Right Close "X" Button
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => _handleDismiss(navigateToWinners: false),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF4B5563),
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyHeader() {
    return SizedBox(
      width: double.infinity,
      child: Image.asset(
        'assets/images/png/vectors/winner_popup_2.png',
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: const Icon(
        Icons.person,
        color: Color(0xFF9CA3AF),
        size: 24,
      ),
    );
  }
}
