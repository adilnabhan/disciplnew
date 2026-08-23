import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/components/logout_sheet.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/pages/contact_support_screen.dart';
import 'package:customer_mobile_app/src/features/home/persentation/screens/partner_qr_pass_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit();
    final bool isCustomer = Feggy.read<AppCubit>()?.state.currentUser != null;

    if (isCustomer) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    await _cubit.fetchCustomerDetails();
    await _cubit.fetchConstChoices();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listenWhen: (previous, current) {
        return previous.currentUser?.access != current.currentUser?.access;
      },
      listener: (context, appState) {
        if (appState.currentUser != null) {
          _fetch();
        }
      },
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, appState) {
          final bool isCustomer = Feggy.read<AppCubit>()?.state.currentUser != null;
          final user = appState.currentUser;
          final firstName = user?.firstName ?? '';
          final lastName = user?.lastName ?? '';
          final fullName = '$firstName $lastName'.trim();
          final userName = fullName.isNotEmpty ? fullName : 'John D';
          final profilePic = user?.profilePicture as String?;

          return BlocProvider.value(
            value: _cubit,
            child: Scaffold(
              backgroundColor: const Color(0xFFFDFBF7),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                title: Text('Profile', style: AppStyles.text18Px.poppins.w600.copyWith(color: const Color(0xFF0F172A))),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B)),
                    onPressed: () => context.push(const SettingsScreen()),
                  ),
                ],
              ),
              body: !isCustomer
                  ? _GuestProfileView(
                      onLoginTap: () => context.push(const SentOtpScreen()),
                    )
                  : SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Marigold Floral Garland Banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [
                                Text('🌼 🌸 🌿 🌼 🌸 🌿 🌼 🌸 🌿 🌼', style: TextStyle(fontSize: 10)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // User Info Card (1:1 with Reference Photo Screen 5)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1F000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Avatar with Level Badge
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(40),
                                      child: Container(
                                        width: 64,
                                        height: 64,
                                        color: const Color(0xFF0D3B2E),
                                        child: profilePic != null && profilePic.isNotEmpty
                                            ? ImageNetwork(profilePic, fit: BoxFit.cover)
                                            : const Center(
                                                child: Text('D', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              userName,
                                              style: AppStyles.text16Px.poppins.w700.copyWith(color: const Color(0xFF0F172A)),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0D3B2E),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'Level 12',
                                              style: AppStyles.text10Px.poppins.w600.copyWith(color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Fitness Enthusiast',
                                        style: AppStyles.text12Px.poppins.w500.copyWith(color: const Color(0xFF64748B)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Discipl Member Since Jan 2024',
                                        style: AppStyles.text10Px.poppins.w400.copyWith(color: const Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // VIP Partner QR Pass Banner Card (Prominent & Eye-Catching)
                          GestureDetector(
                            onTap: () => context.push(const PartnerQrPassScreen()),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF1E242C), Color(0xFF15191E)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0x66E50914), width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x22000000),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0x22E50914),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: const Color(0xFFE50914)),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.qr_code_2, color: Color(0xFFFF4D4F), size: 28),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'My VIP Partner Pass',
                                              style: AppStyles.text15Px.poppins.w700.copyWith(color: Colors.white),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0x2200E676),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '10-20% OFF',
                                                style: AppStyles.text10Px.poppins.w800.copyWith(color: const Color(0xFF00E676)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Tap to view your QR code for partner discounts & XP',
                                          style: AppStyles.text12Px.poppins.w400.copyWith(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Profile Menu Items List (1:1 Match with Reference Photo)
                          _buildProfileMenuItem(
                            icon: Icons.qr_code_scanner,
                            title: 'My VIP Partner Pass & QR Code',
                            onTap: () => context.push(const PartnerQrPassScreen()),
                          ),
                          _buildProfileMenuItem(
                            icon: Icons.track_changes_outlined,
                            title: 'My Goals',
                            onTap: () {},
                          ),
                          _buildProfileMenuItem(
                            icon: Icons.show_chart,
                            title: 'My Progress',
                            onTap: () => context.read<DashboardCubit>().changeNav(index: 3),
                          ),
                          _buildProfileMenuItem(
                            icon: Icons.fitness_center,
                            title: 'My Workouts',
                            onTap: () => context.read<DashboardCubit>().changeNav(index: 1),
                          ),
                          _buildProfileMenuItem(
                            icon: Icons.restaurant_menu,
                            title: 'My Nutrition',
                            onTap: () => context.read<DashboardCubit>().changeNav(index: 2),
                          ),
                          _buildProfileMenuItem(
                            icon: Icons.emoji_events_outlined,
                            title: 'My Achievements',
                            onTap: () => context.read<DashboardCubit>().changeNav(index: 3),
                          ),
                          _buildProfileMenuItem(
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            onTap: () => context.push(const SettingsScreen()),
                          ),
                          _buildProfileMenuItem(
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            onTap: () => context.push(const ContactSupportScreen()),
                          ),
                          _buildProfileMenuItem(
                            icon: Icons.logout,
                            title: 'Logout',
                            isDestructive: true,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (_) => const LogoutSheet(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF0F172A), size: 20),
        title: Text(
          title,
          style: AppStyles.text14Px.poppins.w500.copyWith(
            color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 18),
      ),
    );
  }
}

class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView({required this.onLoginTap});
  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle, size: 80, color: Color(0xFF0D3B2E)),
            const SizedBox(height: 16),
            Text(
              'Sign in to view your profile',
              style: AppStyles.text16Px.poppins.w600.copyWith(color: const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B2E),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onLoginTap,
              child: const Text('Log In', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
