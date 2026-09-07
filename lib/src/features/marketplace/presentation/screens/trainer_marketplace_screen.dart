import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/marketplace/domain/models/marketplace_trainer_model.dart';
import 'package:customer_mobile_app/src/features/marketplace/presentation/screens/trainer_detail_screen.dart';
import 'package:customer_mobile_app/src/features/chat/presentation/screens/customer_chat_screen.dart';

class TrainerMarketplaceScreen extends StatefulWidget {
  const TrainerMarketplaceScreen({super.key});

  @override
  State<TrainerMarketplaceScreen> createState() => _TrainerMarketplaceScreenState();
}

class _TrainerMarketplaceScreenState extends State<TrainerMarketplaceScreen> {
  List<MarketplaceTrainerModel> _trainers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedSpecialty = 'All';

  final List<String> _specialties = [
    'All',
    'Strength Training',
    'Weight Loss',
    'Bodybuilding',
    'Functional Training',
    'Yoga',
    'CrossFit',
    'Endurance',
  ];

  @override
  void initState() {
    super.initState();
    _fetchMarketplaceTrainers();
  }

  Future<void> _fetchMarketplaceTrainers() async {
    setState(() => _isLoading = true);
    try {
      final queryParams = <String, dynamic>{};
      if (_searchQuery.isNotEmpty) {
        queryParams['search'] = _searchQuery;
      }
      if (_selectedSpecialty != 'All') {
        queryParams['specialty'] = _selectedSpecialty;
      }

      final response = await DioClient().dio.get(
        ApiUris.marketplaceTrainers,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawList = response.data is Map
            ? (response.data['results'] ?? response.data['trainers'] ?? [])
            : (response.data is List ? response.data : []);

        final parsed = (rawList as List)
            .map((item) => MarketplaceTrainerModel.fromJson(item as Map<String, dynamic>))
            .toList();

        setState(() {
          _trainers = parsed;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openWhatsApp(MarketplaceTrainerModel trainer) async {
    String? targetUrl = trainer.whatsappUrl;
    if (targetUrl == null && trainer.whatsappNumber != null && trainer.whatsappNumber!.isNotEmpty) {
      final cleanDigits = trainer.whatsappNumber!.replaceAll(RegExp(r'\D'), '');
      final phone = cleanDigits.length == 10 ? '91$cleanDigits' : cleanDigits;
      final msg = Uri.encodeComponent(
        "Hi ${trainer.firstName ?? trainer.name}, I saw your trainer profile on Discipl and I'm interested in personal training!",
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
            SnackBar(content: Text('Could not open WhatsApp: ${trainer.whatsappNumber}')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp contact not available for this trainer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Trainer Marketplace',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Color(0xFF0F172A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search TextField
                TextField(
                  onChanged: (val) {
                    _searchQuery = val;
                    _fetchMarketplaceTrainers();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search trainers, specialties, gyms...',
                    hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Specialty Filter Chips
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _specialties.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final spec = _specialties[index];
                      final isSelected = _selectedSpecialty == spec;
                      return ChoiceChip(
                        label: Text(spec),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedSpecialty = spec);
                          _fetchMarketplaceTrainers();
                        },
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                        selectedColor: const Color(0xFF0D3B2E),
                        backgroundColor: const Color(0xFFF1F5F9),
                        side: BorderSide.none,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Trainers List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchMarketplaceTrainers,
                    child: _trainers.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _trainers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final trainer = _trainers[index];
                              return _buildTrainerCard(trainer);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerCard(MarketplaceTrainerModel trainer) {
    return GestureDetector(
      onTap: () {
        context.push(TrainerDetailScreen(
          trainerId: trainer.id,
          initialTrainer: trainer,
        ));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFE2E8F0),
                      backgroundImage: (trainer.profileImage != null && trainer.profileImage!.isNotEmpty)
                          ? NetworkImage(trainer.profileImage!)
                          : null,
                      child: (trainer.profileImage == null || trainer.profileImage!.isEmpty)
                          ? const Icon(Icons.person, size: 30, color: Color(0xFF94A3B8))
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Name & Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              trainer.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PREMIUM',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${trainer.experienceYears} Years Experience',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      if (trainer.gymAffiliations.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                trainer.gymAffiliations.join(', '),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

            if (trainer.bioSnippet != null && trainer.bioSnippet!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                trainer.bioSnippet!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (trainer.specialties.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: trainer.specialties.take(3).map((spec) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      spec,
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 10),

            // Action Row
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: OutlinedButton(
                    onPressed: () {
                      context.push(TrainerDetailScreen(
                        trainerId: trainer.id,
                        initialTrainer: trainer,
                      ));
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Profile',
                      style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(CustomerChatScreen(
                        trainerId: trainer.id,
                        trainerName: trainer.name,
                        trainerPhoto: trainer.profileImage,
                        trainerPhone: trainer.whatsappNumber,
                      ));
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15, color: Colors.white),
                    label: const Text(
                      'Chat',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(trainer),
                    icon: const Icon(Icons.chat_bubble_rounded, size: 15, color: Colors.white),
                    label: const Text(
                      'WhatsApp',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_gymnastics_rounded, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            const Text(
              'No Trainers Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try changing your search term or specialty filter.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
