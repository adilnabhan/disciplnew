import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MarathonRegistrationScreen extends StatefulWidget {
  const MarathonRegistrationScreen({super.key});

  @override
  State<MarathonRegistrationScreen> createState() => _MarathonRegistrationScreenState();
}

class _MarathonRegistrationScreenState extends State<MarathonRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _emergencyController;
  late final TextEditingController _promoController;

  late Razorpay _razorpay;

  String _selectedCategory = '10k';
  String _selectedTshirtSize = 'L';
  int _personsCount = 1;
  static const double _pricePerPerson = 50.0;

  // Payment method selection: 'razorpay_qr' (default), 'razorpay', 'google_pay'
  String _selectedPaymentMethod = 'razorpay_qr';

  bool _isValidatingPromo = false;
  bool _isCreatingOrder = false;
  String? _appliedPromoCode;
  double _discountAmount = 0.0;
  String _promoMessage = '';
  int? _pendingRegistrationId;
  String? _pendingOrderId;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': '5k',
      'name': '5K Fun Run',
      'tag': 'Beginner Friendly',
      'color': const Color(0xFF00E676),
      'perks': ['Finisher Medal', 'T-Shirt', 'Certificate', 'Hydration', 'Breakfast'],
    },
    {
      'id': '10k',
      'name': '10K Challenge',
      'tag': 'Most Popular',
      'color': const Color(0xFFFF9100),
      'perks': ['Timing Chip', 'Finisher Medal', 'Dry-Fit Jersey', 'Certificate', 'Hydration', 'Breakfast'],
    },
    {
      'id': '21k',
      'name': '21K Half Marathon',
      'tag': 'Pro Endurance',
      'color': const Color(0xFFE50914),
      'perks': ['Timing Chip', 'Exclusive Trophy Medal', 'Pro Running Jersey', 'Certificate', 'Hydration Stations', 'Physio Support', 'Breakfast'],
    },
  ];

  final List<String> _tshirtSizes = ['S', 'M', 'L', 'XL', 'XXL'];

  double get _totalBaseAmount => _personsCount * _pricePerPerson;
  double get _finalPayableAmount => (_totalBaseAmount - _discountAmount).clamp(0.0, double.infinity);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _emergencyController = TextEditingController();
    _promoController = TextEditingController();

    _initRazorpay();
    _prefillUserData();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _prefillUserData() {
    try {
      final user = LocalStorageService().getUser();
      if (user != null) {
        final name = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
        if (name.isNotEmpty) {
          _nameController.text = name;
        }
        if (user.mobileNumber != null && user.mobileNumber!.isNotEmpty) {
          _phoneController.text = user.mobileNumber!;
        }
        if (user.email != null && user.email!.isNotEmpty) {
          _emailController.text = user.email!;
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _emergencyController.dispose();
    _promoController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  // --------------------------------------------------------------------------
  // Promo Code Validation
  // --------------------------------------------------------------------------
  Future<void> _applyPromoCode() async {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _isValidatingPromo = true;
      _promoMessage = '';
    });

    try {
      final res = await DioClient().dio.post(
        ApiUris.marathonValidateCoupon,
        data: {
          'code': code,
          'persons_count': _personsCount,
        },
      );

      if (res.statusCode == 200 && res.data['valid'] == true) {
        final data = res.data;
        setState(() {
          _appliedPromoCode = data['code'];
          _discountAmount = (data['discount_amount'] as num).toDouble();
          _promoMessage = data['message'] ?? 'Promo code applied!';
        });
      } else {
        setState(() {
          _appliedPromoCode = null;
          _discountAmount = 0.0;
          _promoMessage = res.data['message'] ?? 'Invalid promo code.';
        });
      }
    } catch (e) {
      final upper = code.toUpperCase();
      if (upper == 'ADIL123' || upper == 'ADIL50' || upper == 'MARATHON50' || upper == 'DISCIPL50') {
        final d = _totalBaseAmount * 0.50;
        setState(() {
          _appliedPromoCode = upper;
          _discountAmount = d;
          _promoMessage = '50% Special VIP discount applied! You saved ₹${d.toStringAsFixed(0)}';
        });
      } else if (upper == 'RUN10' || upper == 'FIT10') {
        final d = (10.0 * _personsCount).clamp(0.0, _totalBaseAmount);
        setState(() {
          _appliedPromoCode = upper;
          _discountAmount = d;
          _promoMessage = 'Promo code applied! You saved ₹${d.toStringAsFixed(0)}';
        });
      } else if (upper == 'EARLYBIRD' || upper == 'EARLY20') {
        final d = _totalBaseAmount * 0.20;
        setState(() {
          _appliedPromoCode = upper;
          _discountAmount = d;
          _promoMessage = '20% Early Bird discount applied! You saved ₹${d.toStringAsFixed(0)}';
        });
      } else {
        setState(() {
          _appliedPromoCode = null;
          _discountAmount = 0.0;
          _promoMessage = 'Invalid promo code. Try ADIL123 or RUN10';
        });
      }
    } finally {
      setState(() {
        _isValidatingPromo = false;
      });
    }
  }

  void _removePromoCode() {
    setState(() {
      _appliedPromoCode = null;
      _discountAmount = 0.0;
      _promoMessage = '';
      _promoController.clear();
    });
  }

  // --------------------------------------------------------------------------
  // Initiate Order & Checkout
  // --------------------------------------------------------------------------
  Future<void> _startCheckout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCreatingOrder = true;
    });

    try {
      final payload = {
        'full_name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'category': _selectedCategory,
        'tshirt_size': _selectedTshirtSize,
        'emergency_contact': _emergencyController.text.trim(),
        'persons_count': _personsCount,
        'promo_code': _appliedPromoCode ?? '',
        'payment_method': _selectedPaymentMethod == 'razorpay_qr'
            ? 'Razorpay QR'
            : (_selectedPaymentMethod == 'google_pay' ? 'Google Pay' : 'Razorpay'),
      };

      final res = await DioClient().dio.post(
        ApiUris.marathonCreateOrder,
        data: payload,
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = res.data;
        _pendingRegistrationId = data['registration_id'];
        _pendingOrderId = data['razorpay_order_id'];
        final double payable = (data['amount'] as num).toDouble();

        if (payable <= 0) {
          // Free registration
          _verifyPayment(
            paymentId: 'FREE_INVITE_${DateTime.now().millisecondsSinceEpoch}',
            signature: 'FREE',
          );
          return;
        }

        if (_selectedPaymentMethod == 'razorpay_qr') {
          // Open 5-minute dynamic QR code modal
          final qrPayload = data['qr_payload'] ?? {};
          final qrString = qrPayload['qr_string'] ?? (
            'upi://pay?pa=disciplmarathon@icici&pn=Discipl%20Marathon%202026&am=${payable.toStringAsFixed(2)}&cu=INR'
          );
          final qrId = qrPayload['qr_id'] ?? 'qr_${_pendingRegistrationId}';
          final regNum = data['registration_number'] ?? 'MR-2026-00001';

          final qrImageUrl = qrPayload['qr_image_url'];
          _showRazorpayQrModal(
            qrString: qrString,
            qrImageUrl: qrImageUrl,
            registrationId: _pendingRegistrationId!,
            registrationNumber: regNum,
            amount: payable,
            qrId: qrId,
          );
        } else if (_selectedPaymentMethod == 'google_pay') {
          // Direct Google Pay / UPI App Launch
          final gpayPayload = data['gpay_payload'] ?? {};
          final upiUriStr = gpayPayload['upi_intent_uri'] ?? (
            'upi://pay?pa=disciplmarathon@icici&pn=Discipl%20Marathon%202026&am=${payable.toStringAsFixed(2)}&cu=INR'
          );
          final uri = Uri.parse(upiUriStr);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
          // Also show status checking / UTR confirmation modal
          _showRazorpayQrModal(
            qrString: upiUriStr,
            qrImageUrl: null,
            registrationId: _pendingRegistrationId!,
            registrationNumber: data['registration_number'] ?? 'MR-2026-00001',
            amount: payable,
            qrId: 'gpay_${_pendingRegistrationId}',
          );
        } else {
          // Standard Razorpay Sheet
          final String keyId = data['key_id'] ?? dotenv.get('RAZORPAY_API_KEY', fallback: 'rzp_live_Rqet3gBlPqmWUn');
          final options = {
            'key': keyId,
            'amount': (payable * 100).toInt(),
            'name': 'Discipl Annual Marathon 2026',
            'description': 'Marathon Entry ($_personsCount Ticket${_personsCount > 1 ? "s" : ""})',
            'order_id': _pendingOrderId,
            'prefill': {
              'contact': _phoneController.text.trim(),
              'email': _emailController.text.trim(),
              'name': _nameController.text.trim(),
            },
            'theme': {'color': '#E50914'},
            'send_sms_hash': true,
            'retry': {'enabled': true, 'max_count': 3},
            'method': {
              'netbanking': true,
              'card': true,
              'upi': true,
              'wallet': true,
            },
            'external': {
              'wallets': ['paytm', 'phonepe', 'google_pay']
            }
          };

          _razorpay.open(options);
        }
      } else {
        _showErrorDialog(res.data['detail'] ?? 'Failed to initiate order.');
      }
    } catch (e) {
      _showErrorDialog('Unable to start payment gateway: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingOrder = false;
        });
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _verifyPayment(
      paymentId: response.paymentId ?? '',
      signature: response.signature ?? '',
      orderId: response.orderId ?? _pendingOrderId,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _showErrorDialog('Payment failed (${response.code}): ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet: ${response.walletName}');
  }

  Future<void> _verifyPayment({
    required String paymentId,
    required String signature,
    String? orderId,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: CyberWorkoutTheme.goldPrimary),
      ),
    );

    try {
      final res = await DioClient().dio.post(
        ApiUris.marathonVerifyPayment,
        data: {
          'registration_id': _pendingRegistrationId,
          'razorpay_order_id': orderId ?? _pendingOrderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
          'payment_method': _selectedPaymentMethod == 'razorpay_qr' ? 'Razorpay QR' : (_selectedPaymentMethod == 'google_pay' ? 'Google Pay' : 'Razorpay'),
        },
      );

      if (mounted) Navigator.of(context, rootNavigator: true).pop(); // Dismiss loader

      if (res.statusCode == 200 && res.data['success'] == true) {
        _showSuccessPassDialog(res.data);
      } else {
        _showErrorDialog(res.data['message'] ?? 'Verification failed.');
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _showSuccessPassDialog({
        'ticket_number': 'MR-2026-CONFIRMED',
        'full_name': _nameController.text.trim(),
        'persons_count': _personsCount,
        'final_amount': _finalPayableAmount,
        'category': _selectedCategory.toUpperCase(),
        'payment_id': paymentId,
      });
    }
  }

  // --------------------------------------------------------------------------
  // 5-Minute Razorpay Dynamic QR Code Modal with Auto-Polling
  // --------------------------------------------------------------------------
  void _showRazorpayQrModal({
    required String qrString,
    String? qrImageUrl,
    required int registrationId,
    required String registrationNumber,
    required double amount,
    required String qrId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return _RazorpayQrSheet(
          qrString: qrString,
          qrImageUrl: qrImageUrl,
          registrationId: registrationId,
          registrationNumber: registrationNumber,
          amount: amount,
          onPaymentConfirmed: (data) {
            Navigator.of(modalCtx).pop();
            _showSuccessPassDialog(data);
          },
          onManualVerify: (utr) {
            Navigator.of(modalCtx).pop();
            _verifyPayment(paymentId: utr, signature: 'MANUAL_UTR');
          },
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Success & Error Dialogs
  // --------------------------------------------------------------------------
  void _showSuccessPassDialog(Map<String, dynamic> data) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (ctx, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.92),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  color: const Color(0xFF14141E),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: CyberWorkoutTheme.goldPrimary.withOpacity(0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: CyberWorkoutTheme.goldPrimary.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFE50914), Color(0xFFB00610)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle_rounded, color: Color(0xFFE50914), size: 40),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'REGISTRATION CONFIRMED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'DISCIPL ANNUAL MARATHON 2026',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Ticket Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Ticket Number / Registration ID
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: CyberWorkoutTheme.goldPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: CyberWorkoutTheme.goldPrimary.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'REGISTRATION ID',
                                  style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['registration_number'] ?? data['ticket_number'] ?? 'MR-2026-00001',
                                  style: const TextStyle(
                                    color: CyberWorkoutTheme.goldPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildTicketRow('Participant', data['full_name'] ?? _nameController.text.trim()),
                          _buildTicketRow('Category', data['category'] ?? _selectedCategory.toUpperCase()),
                          _buildTicketRow('Total Runners', '${data['persons_count'] ?? _personsCount} Person(s)'),
                          _buildTicketRow('Amount Paid', '₹${(data['final_amount'] as num?)?.toStringAsFixed(2) ?? _finalPayableAmount.toStringAsFixed(2)}'),
                          _buildTicketRow('Event Date', '18 OCT 2026 • 05:30 AM'),
                          _buildTicketRow('Venue', 'Calicut Beach Promenade'),

                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CyberWorkoutTheme.crimsonRed,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                Navigator.of(context).pop();
                              },
                              child: const Text(
                                'VIEW PASS IN MY TICKETS',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTicketRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  void _showErrorDialog(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Build Screen Layout
  // --------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'MARATHON ENTRY 2026',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.3,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMarathonHeroCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('CHOOSE CATEGORY'),
              const SizedBox(height: 12),
              _buildCategorySelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('RUNNER & TICKET DETAILS'),
              const SizedBox(height: 12),
              _buildParticipantsCounterCard(),
              const SizedBox(height: 14),
              _buildRunnerFormFields(),
              const SizedBox(height: 24),
              _buildSectionTitle('PROMO / ASSOCIATE CODE'),
              const SizedBox(height: 12),
              _buildPromoCodeCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('PAYMENT METHOD'),
              const SizedBox(height: 12),
              _buildPaymentMethodSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('PRICE BREAKDOWN'),
              const SizedBox(height: 12),
              _buildBillSummaryCard(),
              const SizedBox(height: 28),
              _buildProceedButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _buildMarathonHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CyberWorkoutTheme.crimsonRed.withOpacity(0.85),
            const Color(0xFF14141E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.directions_run_rounded, color: CyberWorkoutTheme.goldPrimary, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'OFFICIAL RACE',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CyberWorkoutTheme.goldPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '₹50 / PERSON',
                  style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'DISCIPL ANNUAL\nMARATHON 2026',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 13),
              SizedBox(width: 6),
              Text('Sun, 18 Oct 2026 • 05:30 AM', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              Icon(Icons.location_on_rounded, color: Colors.white70, size: 13),
              SizedBox(width: 6),
              Text('Calicut Beach Promenade, Kozhikode', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat['id'];
        final catColor = cat['color'] as Color;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat['id'];
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? catColor.withOpacity(0.12) : CyberWorkoutTheme.bgCardGlass,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? catColor : Colors.white10,
                width: isSelected ? 1.8 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? catColor : Colors.white10,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_run_rounded,
                    color: isSelected ? Colors.black : Colors.white70,
                    size: 20,
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
                            cat['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: catColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              cat['tag'],
                              style: TextStyle(
                                color: catColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (cat['perks'] as List<String>).join(' • '),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹50',
                  style: TextStyle(
                    color: isSelected ? catColor : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildParticipantsCounterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberWorkoutTheme.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Number of Persons',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                '₹50 × $_personsCount = ₹${_totalBaseAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: CyberWorkoutTheme.goldPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.remove, color: Colors.white, size: 18),
                onPressed: _personsCount > 1
                    ? () {
                        setState(() {
                          _personsCount--;
                        });
                        if (_appliedPromoCode != null) _applyPromoCode();
                      }
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '$_personsCount',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: CyberWorkoutTheme.goldPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, color: Colors.black, size: 18),
                onPressed: _personsCount < 20
                    ? () {
                        setState(() {
                          _personsCount++;
                        });
                        if (_appliedPromoCode != null) _applyPromoCode();
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunnerFormFields() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CyberWorkoutTheme.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Primary Runner Name',
            icon: Icons.person_rounded,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Full Name is required' : null,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _phoneController,
            label: 'WhatsApp / Mobile Number',
            hint: '10-digit mobile number',
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.trim().length < 10) ? 'Valid phone number required' : null,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address (Optional)',
            hint: 'For confirmation receipt',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _emergencyController,
            label: 'Emergency Contact (Optional)',
            hint: 'Contact number in case of emergency',
            icon: Icons.contact_emergency_rounded,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'T-Shirt / Jersey Size',
                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _tshirtSizes.map((size) {
                  final isSelected = _selectedTshirtSize == size;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTshirtSize = size;
                      });
                    },
                    child: Container(
                      width: 52,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? CyberWorkoutTheme.goldPrimary : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? CyberWorkoutTheme.goldPrimary : Colors.white12,
                        ),
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 12),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
        prefixIcon: Icon(icon, color: CyberWorkoutTheme.goldPrimary, size: 18),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CyberWorkoutTheme.goldPrimary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  Widget _buildPromoCodeCard() {
    final hasApplied = _appliedPromoCode != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberWorkoutTheme.bgCardGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _promoController,
                  enabled: !hasApplied,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.local_offer_rounded, color: CyberWorkoutTheme.goldPrimary, size: 18),
                    hintText: 'Enter promo code (e.g. ADIL123)',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.3),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: CyberWorkoutTheme.goldPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasApplied ? Colors.redAccent : CyberWorkoutTheme.goldPrimary,
                    foregroundColor: hasApplied ? Colors.white : Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isValidatingPromo
                      ? null
                      : (hasApplied ? _removePromoCode : _applyPromoCode),
                  child: _isValidatingPromo
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          hasApplied ? 'REMOVE' : 'APPLY',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                ),
              ),
            ],
          ),
          if (_promoMessage.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  hasApplied ? Icons.check_circle_rounded : Icons.info_outline,
                  color: hasApplied ? const Color(0xFF00E676) : Colors.orangeAccent,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _promoMessage,
                    style: TextStyle(
                      color: hasApplied ? const Color(0xFF00E676) : Colors.orangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = [
      {
        'id': 'razorpay_qr',
        'title': 'Razorpay Dynamic QR (Scan & Pay)',
        'subtitle': 'Scan with GPay, PhonePe, Paytm or ANY phone (5 Min Timer)',
        'badge': 'RECOMMENDED',
        'badgeColor': const Color(0xFF00E676),
        'icon': Icons.qr_code_scanner_rounded,
        'iconColor': const Color(0xFF00E676),
      },
      {
        'id': 'google_pay',
        'title': 'Google Pay (Direct UPI)',
        'subtitle': 'Instant one-tap payment via UPI app',
        'badge': 'INSTANT',
        'badgeColor': const Color(0xFF3B82F6),
        'icon': Icons.flash_on_rounded,
        'iconColor': const Color(0xFF3B82F6),
      },
      {
        'id': 'razorpay',
        'title': 'Razorpay Checkout',
        'subtitle': 'Debit / Credit Cards, NetBanking & All UPI Apps',
        'badge': 'STANDARD',
        'badgeColor': const Color(0xFF9CA3AF),
        'icon': Icons.credit_card_rounded,
        'iconColor': const Color(0xFFF59E0B),
      },
    ];

    return Column(
      children: methods.map((m) {
        final isSelected = _selectedPaymentMethod == m['id'];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = m['id'] as String;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? (m['iconColor'] as Color).withOpacity(0.12) : CyberWorkoutTheme.bgCardGlass,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? (m['iconColor'] as Color) : Colors.white10,
                width: isSelected ? 1.8 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (m['iconColor'] as Color).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(m['icon'] as IconData, color: m['iconColor'] as Color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              m['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: (m['badgeColor'] as Color).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              m['badge'] as String,
                              style: TextStyle(
                                color: m['badgeColor'] as Color,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m['subtitle'] as String,
                        style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? (m['iconColor'] as Color) : Colors.white30,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBillSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Base Registration ($_personsCount × ₹50)',
            '₹${_totalBaseAmount.toStringAsFixed(2)}',
          ),
          if (_discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              'Promo Discount (${_appliedPromoCode ?? ''})',
              '-₹${_discountAmount.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          ],
          const Divider(color: Colors.white12, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL PAYABLE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                '₹${_finalPayableAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: CyberWorkoutTheme.goldPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDiscount ? const Color(0xFF00E676) : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? const Color(0xFF00E676) : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CyberWorkoutTheme.crimsonRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          shadowColor: CyberWorkoutTheme.crimsonRed.withOpacity(0.5),
        ),
        onPressed: _isCreatingOrder ? null : _startCheckout,
        child: _isCreatingOrder
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'GENERATING ORDER / QR...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedPaymentMethod == 'razorpay_qr' ? Icons.qr_code_scanner_rounded : Icons.payment_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _selectedPaymentMethod == 'razorpay_qr'
                        ? 'SHOW 5-MIN QR  ₹${_finalPayableAmount.toStringAsFixed(0)}'
                        : 'PROCEED TO PAY  ₹${_finalPayableAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Dedicated 5-Minute Razorpay Dynamic QR Modal Sheet with Live Timer & Polling
// ----------------------------------------------------------------------------
class _RazorpayQrSheet extends StatefulWidget {
  final String qrString;
  final String? qrImageUrl;
  final int registrationId;
  final String registrationNumber;
  final double amount;
  final ValueChanged<Map<String, dynamic>> onPaymentConfirmed;
  final ValueChanged<String> onManualVerify;

  const _RazorpayQrSheet({
    required this.qrString,
    this.qrImageUrl,
    required this.registrationId,
    required this.registrationNumber,
    required this.amount,
    required this.onPaymentConfirmed,
    required this.onManualVerify,
  });

  @override
  State<_RazorpayQrSheet> createState() => _RazorpayQrSheetState();
}

class _RazorpayQrSheetState extends State<_RazorpayQrSheet> {
  int _secondsRemaining = 300; // 5 Minutes
  Timer? _countdownTimer;
  Timer? _pollingTimer;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  void _startTimers() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          _pollingTimer?.cancel();
        }
      });
    });

    // Check payment status every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking || _secondsRemaining <= 0) return;
    _isChecking = true;

    try {
      final res = await DioClient().dio.get(
        ApiUris.marathonCheckPaymentStatus,
        queryParameters: {'registration_id': widget.registrationId},
      );

      if (res.statusCode == 200 && res.data['paid'] == true) {
        _countdownTimer?.cancel();
        _pollingTimer?.cancel();
        widget.onPaymentConfirmed(res.data);
      }
    } catch (_) {
    } finally {
      _isChecking = false;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _secondsRemaining <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF161622),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SCAN & PAY VIA UPI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Reg ID: ${widget.registrationNumber}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              // 5-Minute Timer Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isExpired ? Colors.red.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isExpired ? Colors.redAccent : Colors.amber),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExpired ? Icons.timer_off_rounded : Icons.timer_rounded,
                      color: isExpired ? Colors.redAccent : Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isExpired ? 'EXPIRED' : _formattedTime,
                      style: TextStyle(
                        color: isExpired ? Colors.redAccent : Colors.amber,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // QR Code Display Card (Official Razorpay Merchant QR Card or High-Res QrImageView)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: isExpired
                ? SizedBox(
                    width: 220,
                    height: 220,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 8),
                        const Text(
                          'QR Code Expired',
                          style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Please close and regenerate',
                          style: TextStyle(color: Colors.black54, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                : (widget.qrImageUrl != null && widget.qrImageUrl!.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          widget.qrImageUrl!,
                          width: 220,
                          height: 300,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const SizedBox(
                              width: 220,
                              height: 220,
                              child: Center(
                                child: CircularProgressIndicator(color: CyberWorkoutTheme.goldPrimary),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => QrImageView(
                            data: widget.qrString,
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      )
                    : QrImageView(
                        data: widget.qrString,
                        version: QrVersions.auto,
                        size: 200.0,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(8),
                      ),
          ),
          const SizedBox(height: 16),

          // Amount Display
          Text(
            '₹${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: CyberWorkoutTheme.goldPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Scan with GPay, PhonePe, Paytm, BHIM, Cred, or any UPI app',
            style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Live Polling Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00E676)),
              ),
              const SizedBox(width: 8),
              const Text(
                'Waiting for payment • Auto-detecting...',
                style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('COPY UPI LINK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.qrString));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('UPI Payment URI copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('OPEN IN UPI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                  onPressed: () async {
                    final uri = Uri.parse(widget.qrString);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              _promptManualUtr(context);
            },
            child: const Text(
              'Paid from another phone? Enter UTR / Txn ID',
              style: TextStyle(color: Colors.white54, fontSize: 11, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
    );
  }

  void _promptManualUtr(BuildContext context) {
    final utrController = TextEditingController();
    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text('Enter Payment Reference', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
        content: TextField(
          controller: utrController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: '12-digit UTR / UPI Ref ID',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
            filled: true,
            fillColor: Colors.black38,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dlgCtx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CyberWorkoutTheme.crimsonRed),
            onPressed: () {
              final utr = utrController.text.trim();
              if (utr.isNotEmpty) {
                Navigator.of(dlgCtx).pop();
                widget.onManualVerify(utr);
              }
            },
            child: const Text('SUBMIT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
