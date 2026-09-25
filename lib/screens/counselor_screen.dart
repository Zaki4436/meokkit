import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CounselorScreen extends StatefulWidget {
  const CounselorScreen({super.key});

  @override
  State<CounselorScreen> createState() => _CounselorScreenState();
}

class _CounselorScreenState extends State<CounselorScreen> {
  Future<void> _makeCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      final launched = await launchUrl(uri);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to call $phoneNumber')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to call $phoneNumber')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final fullNumber =
        cleanNumber.startsWith('6') ? cleanNumber : '6$cleanNumber';
    final uri = Uri.parse('https://wa.me/$fullNumber');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open WhatsApp for $phone')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to open WhatsApp for $phone')),
        );
      }
    }
  }

  Widget _buildContactCard({
    required String title,
    required String subtitle,
    required String phone,
    String? whatsapp,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFFEBEE),
                radius: 22,
                child: Icon(
                  icon,
                  color: Colors.red,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Call Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makeCall(phone),
                  icon: const Icon(Icons.call, size: 18),
                  label: Text(
                    phone,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (whatsapp != null) ...[
                const SizedBox(width: 10),
                // WhatsApp Button
                OutlinedButton.icon(
                  onPressed: () => _openWhatsApp(whatsapp),
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('WhatsApp'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(
                      color: Colors.green.shade400,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Fixed Title (does not scroll)
            const Center(
              child: Text(
                'COUNSELOR\nCONTACT',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                  color: Colors.red,
                  letterSpacing: 1.0,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  children: [
                    // Contact 1: Talian Kasih
                    _buildContactCard(
                      title: 'Talian Kasih',
                      subtitle: 'KPWKM • Bantuan Krisis & Kaunseling 24 Jam',
                      phone: '15999',
                      whatsapp: '0192615999',
                      icon: Icons.support_agent,
                    ),

                    // Contact 2: Talian HEAL
                    _buildContactCard(
                      title: 'Talian HEAL (15555)',
                      subtitle: 'KKM • Talian Bantuan Krisis Kesihatan Mental',
                      phone: '15555',
                      icon: Icons.health_and_safety,
                    ),

                    // Contact 3: Befrienders
                    _buildContactCard(
                      title: 'Befrienders KL',
                      subtitle: 'Sokongan Emosi Percuma & Rahsia 24 Jam',
                      phone: '03-76272929',
                      icon: Icons.volunteer_activism,
                    ),

                    // Contact 4: Unit Kerjaya & Kaunseling UiTM
                    _buildContactCard(
                      title: 'Unit Kerjaya & Kaunseling UiTM',
                      subtitle: 'Perkhidmatan Kaunseling Pelajar & Staf',
                      phone: '03-55442000',
                      icon: Icons.school,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}