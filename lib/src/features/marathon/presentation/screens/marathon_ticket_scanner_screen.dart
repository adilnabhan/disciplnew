import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';

class MarathonTicketScannerScreen extends StatefulWidget {
  const MarathonTicketScannerScreen({super.key});

  @override
  State<MarathonTicketScannerScreen> createState() => _MarathonTicketScannerScreenState();
}

class _MarathonTicketScannerScreenState extends State<MarathonTicketScannerScreen> {
  final TextEditingController _ticketInputController = TextEditingController();
  bool _isVerifying = false;
  Map<String, dynamic>? _lastScanResult;
  final List<Map<String, dynamic>> _recentCheckIns = [];

  @override
  void dispose() {
    _ticketInputController.dispose();
    super.dispose();
  }

  Future<void> _verifyTicket(String code) async {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty || _isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      final res = await DioClient().dio.post(
        '${ApiUris.marathonInfo.replaceAll('marathon/info/', '')}marathon/verify-ticket-qr/',
        data: {'ticket_code': cleanCode},
      );

      if (mounted) {
        final data = res.data as Map<String, dynamic>;
        setState(() {
          _lastScanResult = data;
          if (data['valid'] == true && data['participant'] != null) {
            _recentCheckIns.insert(0, data['participant']);
          }
        });
        HapticFeedback.heavyImpact();
        _showResultDialog(data);
      }
    } on DioException catch (e) {
      final data = e.response?.data is Map<String, dynamic>
          ? e.response!.data as Map<String, dynamic>
          : {'valid': false, 'status': 'ERROR', 'message': e.message ?? 'Verification failed'};
      setState(() {
        _lastScanResult = data;
      });
      HapticFeedback.vibrate();
      _showResultDialog(data);
    } catch (e) {
      final data = {'valid': false, 'status': 'ERROR', 'message': e.toString()};
      _showResultDialog(data);
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _ticketInputController.clear();
        });
      }
    }
  }

  void _showResultDialog(Map<String, dynamic> data) {
    final bool isValid = data['valid'] == true;
    final String status = data['status'] ?? 'UNKNOWN';
    final String message = data['message'] ?? (isValid ? 'Entry Approved' : 'Entry Denied');
    final participant = data['participant'] as Map<String, dynamic>?;

    final Color statusColor = isValid
        ? const Color(0xFF00E676)
        : (status == 'ALREADY_CHECKED_IN' ? Colors.orangeAccent : Colors.redAccent);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF161622),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Icon(
                  isValid
                      ? Icons.check_circle_rounded
                      : (status == 'ALREADY_CHECKED_IN' ? Icons.history_rounded : Icons.cancel_rounded),
                  color: statusColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isValid
                    ? 'ENTRY APPROVED'
                    : (status == 'ALREADY_CHECKED_IN' ? 'ALREADY USED' : 'ENTRY DENIED'),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Participant Details Card
              if (participant != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Runner', participant['full_name'] ?? '-'),
                      const SizedBox(height: 6),
                      _buildDetailRow('Ticket #', participant['registration_number'] ?? '-'),
                      const SizedBox(height: 6),
                      _buildDetailRow('Category', participant['category'] ?? '-'),
                      const SizedBox(height: 6),
                      _buildDetailRow('T-Shirt', participant['tshirt_size'] ?? 'N/A'),
                      if (participant['checked_in_at'] != null) ...[
                        const SizedBox(height: 6),
                        _buildDetailRow('Checked In', participant['checked_in_at'].toString()),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // OK Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'SCAN NEXT ATHLETE',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161622),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'VENUE TICKET SCANNER',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.1),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scanner Viewfinder Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F1F30), Color(0xFF14141E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFFFFD700), size: 64),
                  const SizedBox(height: 12),
                  const Text(
                    'DISCIPL MARATHON 2026',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Scan attendee ticket QR code or enter ticket ID',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 20),

                  // Ticket ID Text Field
                  TextField(
                    controller: _ticketInputController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'e.g. MR-2026-00022 or Phone',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                      filled: true,
                      fillColor: Colors.black38,
                      prefixIcon: const Icon(Icons.confirmation_number_rounded, color: Color(0xFFFFD700), size: 20),
                      suffixIcon: _isVerifying
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Color(0xFFFFD700), strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF00E676)),
                              onPressed: () => _verifyTicket(_ticketInputController.text),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFFFD700)),
                      ),
                    ),
                    onSubmitted: (val) => _verifyTicket(val),
                  ),
                  const SizedBox(height: 14),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                      label: const Text(
                        'VERIFY & CHECK-IN',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                      ),
                      onPressed: _isVerifying ? null : () => _verifyTicket(_ticketInputController.text),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Recent Check-Ins Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'RECENT CHECK-INS',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E676).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_recentCheckIns.length} Checked In',
                    style: const TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Recent Check-In List
            if (_recentCheckIns.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Center(
                  child: Text(
                    'No check-ins yet for this session.\nScanned participants will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recentCheckIns.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final p = _recentCheckIns[idx];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: CyberWorkoutTheme.bgCardGlass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded, color: Color(0xFF00E676), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['full_name'] ?? 'Attendee',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                '${p['registration_number']} • ${p['category']}',
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Size: ${p['tshirt_size'] ?? "N/A"}',
                            style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
