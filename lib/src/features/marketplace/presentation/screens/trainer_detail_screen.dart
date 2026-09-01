import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/marketplace/domain/models/marketplace_trainer_model.dart';

class TrainerDetailScreen extends StatefulWidget {
  final int trainerId;
  final MarketplaceTrainerModel? initialTrainer;

  const TrainerDetailScreen({
    super.key,
    required this.trainerId,
    this.initialTrainer,
  });

  @override
  State<TrainerDetailScreen> createState() => _TrainerDetailScreenState();
}

class _TrainerDetailScreenState extends State<TrainerDetailScreen> {
  MarketplaceTrainerModel? _trainer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _trainer = widget.initialTrainer;
    _fetchTrainerDetail();
  }

  Future<void> _fetchTrainerDetail() async {
    if (_trainer == null) {
      setState(() => _isLoading = true);
    }
    try {
      final response = await DioClient().dio.get(
        ApiUris.marketplaceTrainerDetail(widget.trainerId),
      );
      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _trainer = MarketplaceTrainerModel.fromJson(response.data);
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (_trainer == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load trainer profile. Please try again.';
        });
      }
    }
  }

  Future<void> _openWhatsApp() async {
    final t = _trainer;
    if (t == null) return;

    String? targetUrl = t.whatsappUrl;
    if (targetUrl == null && t.whatsappNumber != null && t.whatsappNumber!.isNotEmpty) {
      final cleanDigits = t.whatsappNumber!.replaceAll(RegExp(r'\D'), '');
      final phone = cleanDigits.length == 10 ? '91$cleanDigits' : cleanDigits;
      final msg = Uri.encodeComponent(
        "Hi ${t.firstName ?? t.name}, I saw your trainer profile on Discipl and I'm interested in personal training!",
      );
      targetUrl = 'https://wa.me/$phone?text=$msg';
    }

    if (targetUrl != null) {
      final uri = Uri.parse(targetUrl);
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open WhatsApp. Phone: ${t.whatsappNumber ?? "N/A"}')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp contact not provided by this trainer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          _trainer?.name ?? 'Trainer Profile',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchTrainerDetail,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _buildProfileContent(),
      bottomNavigationBar: _trainer != null ? _buildWhatsAppBottomBar() : null,
    );
  }

  Widget _buildProfileContent() {
    final t = _trainer!;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card with Avatar & Badges
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: const Color(0xFFE2E8F0),
                      backgroundImage: (t.profileImage != null && t.profileImage!.isNotEmpty)
                          ? NetworkImage(t.profileImage!)
                          : null,
                      child: (t.profileImage == null || t.profileImage!.isEmpty)
                          ? const Icon(Icons.person, size: 54, color: Color(0xFF94A3B8))
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  t.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Verified Marketplace Trainer • ${t.experienceYears} Yrs Exp',
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (t.specialties.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: t.specialties.map((spec) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          spec,
                          style: const TextStyle(
                            color: Color(0xFF4F46E5),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Affiliated Gyms
          if (t.gymAffiliations.isNotEmpty) ...[
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.fitness_center_rounded, color: Color(0xFF0D3B2E), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Gym Affiliations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: t.gymAffiliations.map((gym) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Text(
                          gym,
                          style: const TextStyle(
                            color: Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // About / Bio Section
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF0D3B2E), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'About Trainer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  (t.bio != null && t.bio!.isNotEmpty)
                      ? t.bio!
                      : 'Dedicated fitness professional committed to helping clients reach their health, strength, and transformation goals.',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Experience History
          if (t.experiences.isNotEmpty) ...[
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.work_history_rounded, color: Color(0xFF0D3B2E), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Experience & Background',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...t.experiences.map((exp) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exp.designation,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  exp.organizationName,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                if (exp.description != null && exp.description!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    exp.description!,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          // Information Note
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_clock_rounded, color: Color(0xFF16A34A), size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Direct Personal Training: Connect via WhatsApp to customize your training plan. All session rates and schedules are settled directly with the trainer.',
                      style: TextStyle(color: Color(0xFF15803D), fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatsAppBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _openWhatsApp,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.chat_bubble_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'Contact on WhatsApp',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
