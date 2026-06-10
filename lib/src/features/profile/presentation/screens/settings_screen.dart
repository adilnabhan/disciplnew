import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/screens/pages/profile_details_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final ProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit();
    _fetch();
  }

  Future<void> _fetch() async {
    await _cubit.fetchCustomerDetails();
  }

  void _showComingSoon(String title) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leadingWidth: 56,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Center(
              child: GestureDetector(
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
            ),
          ),
          title: Text(
            'Settings',
            style: AppStyles.text18Px.poppins.w600.copyWith(
              color: const Color(0xFF212121),
            ),
          ),
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return state.customerDetails.fold(
              () => const Center(child: CircularProgressIndicator()),
              (either) => either.fold(
                (error) => ErrorUi.server(onTap: _fetch).center,
                (customerDetails) {
                  final displayName = customerDetails.fullName ??
                      '${customerDetails.firstName ?? ''} ${customerDetails.lastName ?? ''}'.trim();
                  final displayPhone = customerDetails.mobileNumber ?? '+91 123 456 7890';

                  return RefreshIndicator(
                    onRefresh: _fetch,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      children: [
                        // Profile Header Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ProfileImage(
                                isEdit: false,
                                onChanged: (image) {},
                                radius: 80.w,
                                url: customerDetails.profilePicture != null
                                    ? '${customerDetails.profilePicture}'
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      displayName.isNotEmpty ? displayName : 'Marcus Lee',
                                      style: AppStyles.text16Px.poppins.w600.copyWith(
                                        color: const Color(0xFF212121),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      displayPhone,
                                      style: AppStyles.text12Px.poppins.w400.copyWith(
                                        color: const Color(0xFF7A7A7A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Account & Security
                        _buildSectionHeader('Account & Security'),
                        _buildGroupedCard([
                          _buildMenuItem(
                            icon: Icons.account_circle_outlined,
                            title: 'Manage Profile',
                            onTap: () {
                              context.push(BlocProvider.value(
                                value: _cubit,
                                child: ProfileDetailsScreen(customerDetailsModel: customerDetails),
                              ));
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.phone_outlined,
                            title: 'Change Phone number',
                            onTap: () => _showComingSoon('Change Phone number'),
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // Preferences
                        _buildSectionHeader('Preferences'),
                        _buildGroupedCard([
                          _buildMenuItem(
                            icon: 'assets/images/svg/vectors/logo.svg',
                            title: 'About Us',
                            applyColorFilter: false,
                            onTap: () => _showComingSoon('About Us'),
                          ),
                          _buildMenuItem(
                            icon: 'assets/images/svg/icons/notification_icon.svg',
                            title: 'Notifications',
                            onTap: () => _showComingSoon('Notifications'),
                          ),
                          _buildMenuItem(
                            icon: Icons.contrast,
                            title: 'Themes',
                            onTap: () => _showComingSoon('Themes'),
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // Support & Legal
                        _buildSectionHeader('Support & Legal'),
                        _buildGroupedCard([
                          _buildMenuItem(
                            icon: Icons.help_outline_outlined,
                            title: 'Help Center / FAQ',
                            onTap: () => _showComingSoon('Help Center / FAQ'),
                          ),
                          _buildMenuItem(
                            icon: Icons.support_agent_outlined,
                            title: 'Contact Support',
                            onTap: () => _showComingSoon('Contact Support'),
                          ),
                          _buildMenuItem(
                            icon: Icons.article_outlined,
                            title: 'Terms & Conditions',
                            onTap: () => _showComingSoon('Terms & Conditions'),
                          ),
                          _buildMenuItem(
                            icon: Icons.shield_outlined,
                            title: 'Privacy Policy',
                            onTap: () => _showComingSoon('Privacy Policy'),
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // Logout
                        _buildGroupedCard([
                          _buildMenuItem(
                            icon: Icons.logout,
                            title: 'Logout',
                            isDestructive: true,
                            onTap: () => const LogoutSheet().show(context),
                          ),
                        ]),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppStyles.text12Px.poppins.w500.copyWith(
          fontSize: 12,
          color: const Color(0xFF444444),
          height: 1.0,
          letterSpacing: 0,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index < children.length - 1) {
            return Column(
              children: [
                children[index],
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF0F0F0),
                  indent: 16,
                  endIndent: 16,
                ),
              ],
            );
          }
          return children[index];
        }),
      ),
    );
  }

  Widget _buildMenuItem({
    required dynamic icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool applyColorFilter = true,
  }) {
    Widget leadingWidget;
    if (icon is IconData) {
      leadingWidget = Icon(
        icon,
        color: isDestructive ? Colors.red : const Color(0xFF212121),
        size: 22,
      );
    } else if (icon is String) {
      leadingWidget = SvgPicture.asset(
        icon,
        width: 22,
        height: 22,
        colorFilter: applyColorFilter
            ? ColorFilter.mode(
                isDestructive ? Colors.red : const Color(0xFF212121),
                BlendMode.srcIn,
              )
            : null,
      );
    } else {
      leadingWidget = const SizedBox(width: 22, height: 22);
    }

    return ListTile(
      onTap: onTap,
      leading: leadingWidget,
      title: Text(
        title,
        style: AppStyles.text14Px.poppins.w500.copyWith(
          color: isDestructive ? Colors.red : const Color(0xFF212121),
          height: 1.0,
          letterSpacing: 0,
        ),
      ),
      trailing: isDestructive
          ? null
          : const Icon(
              Icons.chevron_right,
              color: Color(0xFFB5B5B5),
              size: 20,
            ),
    );
  }
}
