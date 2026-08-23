import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PartnerQrPassScreen extends StatefulWidget {
  const PartnerQrPassScreen({super.key});

  @override
  State<PartnerQrPassScreen> createState() => _PartnerQrPassScreenState();
}

class _PartnerQrPassScreenState extends State<PartnerQrPassScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // QR Data
  bool _isLoadingQr = true;
  String? _qrToken;
  String _memberCode = 'DISC-MEMBER';
  String _customerName = 'Discipl VIP Member';
  String _gymName = 'Discipl Fitness Center';
  bool _isActiveMember = true;
  int _secondsRemaining = 600;
  Timer? _countdownTimer;

  // Partner Merchants & Discounts
  bool _isLoadingMerchants = true;
  List<Map<String, dynamic>> _merchants = [];

  // My Savings & Vouchers
  double _totalSaved = 0;
  int _totalPointsEarned = 0;
  List<Map<String, dynamic>> _vouchers = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMyQrData();
    _fetchPartnerMerchants();
    _fetchMySavingsAndVouchers();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  // 1. Fetch Dynamic QR Token from Backend
  Future<void> _fetchMyQrData() async {
    setState(() => _isLoadingQr = true);
    try {
      final res = await DioClient().dio.get<Map<String, dynamic>>(ApiUris.partnerMyQr);
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data!;
        if (mounted) {
          setState(() {
            _qrToken = (data['qr_token'] ?? data['member_code'] ?? 'DISCIPL-PASS').toString();
            _memberCode = (data['member_code'] ?? 'DISC-000001').toString();
            _customerName = (data['customer_name'] ?? 'Discipl Member').toString();
            _gymName = (data['gym_name'] ?? 'Discipl Partner Gym').toString();
            _isActiveMember = data['is_active_member'] == true;
            _secondsRemaining = (data['expires_in_seconds'] as num?)?.toInt() ?? 600;
            _isLoadingQr = false;
          });
          _startCountdown();
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingQr = false;
          _qrToken = _memberCode;
        });
      }
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _fetchMyQrData(); // Auto refresh on expiry
      }
    });
  }

  // 2. Fetch Partner Merchant Directory
  Future<void> _fetchPartnerMerchants() async {
    try {
      final res = await DioClient().dio.get<dynamic>(ApiUris.partnerMerchants);
      if (res.statusCode == 200 && res.data != null) {
        final dynamic raw = res.data;
        var list = <dynamic>[];
        if (raw is Map && raw['results'] is List) {
          list = raw['results'] as List<dynamic>;
        } else if (raw is List) {
          list = raw;
        }

        if (mounted) {
          setState(() {
            _merchants = list
                .whereType<Map<dynamic, dynamic>>()
                .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
                .toList();
            _isLoadingMerchants = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMerchants = false);
    }
  }

  // 3. Fetch My Savings & Vouchers
  Future<void> _fetchMySavingsAndVouchers() async {
    try {
      final txRes = await DioClient().dio.get<Map<String, dynamic>>(ApiUris.partnerMyTransactions);
      if (txRes.statusCode == 200 && txRes.data != null) {
        final dynamic rawSummary = txRes.data!['summary'];
        if (rawSummary is Map) {
          setState(() {
            _totalSaved = (rawSummary['total_savings_inr'] as num?)?.toDouble() ?? 0.0;
            _totalPointsEarned = (rawSummary['total_points_earned'] as num?)?.toInt() ?? 0;
          });
        }
      }

      final vchRes = await DioClient().dio.get<Map<String, dynamic>>(ApiUris.partnerMyVouchers);
      if (vchRes.statusCode == 200 && vchRes.data != null) {
        final dynamic rawActive = vchRes.data!['active_vouchers'];
        if (rawActive is List) {
          setState(() {
            _vouchers = rawActive
                .whereType<Map<dynamic, dynamic>>()
                .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
                .toList();
          });
        }
      }
    } catch (_) {
      // Ignored
    }
  }

  // Redeem XP Points Modal
  void _showRedeemPointsDialog() {
    var selectedPoints = 50;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF15191E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Redeem Discipl Points',
                        style: AppStyles.text18Px.poppins.w700.copyWith(color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Convert your workout XP into instant partner discounts & restaurant vouchers!',
                    style: AppStyles.text13Px.poppins.w400.copyWith(color: Colors.white60),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildPointsOption(50, 50, selectedPoints == 50, () {
                        setSheetState(() => selectedPoints = 50);
                      }),
                      const SizedBox(width: 12),
                      _buildPointsOption(100, 100, selectedPoints == 100, () {
                        setSheetState(() => selectedPoints = 100);
                      }),
                      const SizedBox(width: 12),
                      _buildPointsOption(200, 200, selectedPoints == 200, () {
                        setSheetState(() => selectedPoints = 200);
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _redeemVoucher(selectedPoints);
                      },
                      child: Text(
                        'Confirm Redemption (₹$selectedPoints OFF)',
                        style: AppStyles.text15Px.poppins.w700.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPointsOption(int points, int rupees, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x33E50914) : const Color(0xFF1B2027),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFFE50914) : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text('$points XP', style: AppStyles.text14Px.poppins.w700.copyWith(color: const Color(0xFFFFB300))),
              const SizedBox(height: 4),
              Text('₹$rupees OFF', style: AppStyles.text12Px.poppins.w600.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _redeemVoucher(int points) async {
    try {
      final res = await DioClient().dio.post<Map<String, dynamic>>(
        ApiUris.partnerRedeemPoints,
        data: {
          'points': points,
          'title': '₹$points Partner Voucher',
        },
      );
      if (res.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 Successfully redeemed ₹$points Partner Voucher!'),
              backgroundColor: const Color(0xFF00E676),
            ),
          );
          await _fetchMySavingsAndVouchers();
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to redeem voucher. Check your XP balance.'),
            backgroundColor: Color(0xFFE50914),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
    final timerFormatted =
        '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0D10),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'DISCIPL ',
              style: AppStyles.text18Px.poppins.w800.copyWith(
                color: const Color(0xFFE50914),
                letterSpacing: 1.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0x33E50914),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x66E50914)),
              ),
              child: Text(
                'PARTNER PASS',
                style: AppStyles.text10Px.poppins.w700.copyWith(color: const Color(0xFFFF4D4F)),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE50914),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: AppStyles.text13Px.poppins.w600,
          tabs: const [
            Tab(text: 'My QR Pass'),
            Tab(text: 'Partner Perks'),
            Tab(text: 'My Savings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyQrPassTab(timerFormatted),
          _buildPartnerPerksTab(),
          _buildMySavingsTab(),
        ],
      ),
    );
  }

  // TAB 1: VIP QR PASS
  Widget _buildMyQrPassTab(String timerFormatted) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // VIP Pass Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E242C), Color(0xFF15191E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x44E50914), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4D000000),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Top Member Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE50914), width: 2),
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Color(0xFF2C3440),
                          child: Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _customerName,
                              style: AppStyles.text16Px.poppins.w700.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _gymName,
                              style: AppStyles.text12Px.poppins.w400.copyWith(color: Colors.white60),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isActiveMember ? const Color(0x2200E676) : const Color(0x22E50914),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _isActiveMember ? const Color(0xFF00E676) : const Color(0xFFE50914),
                          ),
                        ),
                        child: Text(
                          _isActiveMember ? 'ACTIVE' : 'EXPIRED',
                          style: AppStyles.text10Px.poppins.w800.copyWith(
                            color: _isActiveMember ? const Color(0xFF00E676) : const Color(0xFFE50914),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white12, height: 1),

                // QR Code Container
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22FFFFFF),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: _isLoadingQr
                        ? const SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(color: Color(0xFFE50914)),
                            ),
                          )
                        : QrImageView(
                            data: _qrToken ?? _memberCode,
                            size: 200,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Color(0xFF0B0D10),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Color(0xFF0B0D10),
                            ),
                          ),
                  ),
                ),

                // Member Code & Refresh Timer
                Text(
                  _memberCode,
                  style: AppStyles.text16Px.poppins.w800.copyWith(
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, color: Color(0xFFFFB300), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Auto-refreshes in $timerFormatted',
                      style: AppStyles.text12Px.poppins.w500.copyWith(color: const Color(0xFFFFB300)),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _fetchMyQrData,
                      child: const Icon(Icons.refresh, color: Colors.white70, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Scan Instruction Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF15191E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Show this QR code to the cashier at any partner restaurant, hotel, or wellness spa to claim instant discounts and earn XP points.',
                    style: AppStyles.text12Px.poppins.w400.copyWith(color: Colors.white70, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: PARTNER MERCHANTS PERKS
  Widget _buildPartnerPerksTab() {
    if (_isLoadingMerchants) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
    }

    if (_merchants.isEmpty) {
      return Center(
        child: Text(
          'No partner merchants available in your area yet.',
          style: AppStyles.text14Px.poppins.w500.copyWith(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _merchants.length,
      itemBuilder: (context, index) {
        final m = _merchants[index];
        final nameStr = (m['name'] ?? 'Partner Venue').toString();
        final categoryStr = (m['category_display'] ?? 'Dining').toString();
        final cityStr = (m['city'] ?? 'Kozhikode').toString();
        final discountStr = '${m['discount_percentage'] ?? 10}% OFF';

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF15191E),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E242C),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(child: Text('🍽️', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nameStr,
                      style: AppStyles.text15Px.poppins.w700.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$categoryStr • $cityStr',
                      style: AppStyles.text12Px.poppins.w400.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x2200E676),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00E676)),
                ),
                child: Text(
                  discountStr,
                  style: AppStyles.text12Px.poppins.w800.copyWith(color: const Color(0xFF00E676)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // TAB 3: MY SAVINGS & VOUCHERS
  Widget _buildMySavingsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Savings Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E676), Color(0xFF00B359)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x3300E676), blurRadius: 15, offset: Offset(0, 6)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TOTAL MONEY SAVED', style: AppStyles.text10Px.poppins.w800.copyWith(color: const Color(0xFF0B0D10))),
                    const SizedBox(height: 4),
                    Text('₹${_totalSaved.toStringAsFixed(2)}', style: AppStyles.text24Px.poppins.w800.copyWith(color: const Color(0xFF0B0D10))),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('AFFILIATE XP', style: AppStyles.text10Px.poppins.w800.copyWith(color: const Color(0xFF0B0D10))),
                    const SizedBox(height: 4),
                    Text('+$_totalPointsEarned XP', style: AppStyles.text18Px.poppins.w800.copyWith(color: const Color(0xFF0B0D10))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Redeem Points Action Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF15191E),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x44FFB300)),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Redeem Points for Vouchers', style: AppStyles.text14Px.poppins.w700.copyWith(color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Get ₹50, ₹100 instant coupons', style: AppStyles.text12Px.poppins.w400.copyWith(color: Colors.white60)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _showRedeemPointsDialog,
                  child: Text('Redeem', style: AppStyles.text12Px.poppins.w800.copyWith(color: Colors.black)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Active Vouchers List
          Text('My Active Vouchers', style: AppStyles.text16Px.poppins.w700.copyWith(color: Colors.white)),
          const SizedBox(height: 12),

          if (_vouchers.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF15191E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'No active vouchers yet. Redeem your XP points above!',
                  style: AppStyles.text13Px.poppins.w400.copyWith(color: Colors.white54),
                ),
              ),
            )
          else
            ..._vouchers.map((v) {
              final titleStr = (v['title'] ?? '₹50 Voucher').toString();
              final codeStr = (v['voucher_code'] ?? '').toString();
              final discStr = '₹${v['discount_amount'] ?? 50} OFF';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF15191E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x4400E676)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(titleStr, style: AppStyles.text14Px.poppins.w700.copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(codeStr, style: AppStyles.text12Px.poppins.w600.copyWith(color: const Color(0xFF00E676), letterSpacing: 1.2)),
                      ],
                    ),
                    Text(discStr, style: AppStyles.text16Px.poppins.w800.copyWith(color: const Color(0xFF00E676))),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
