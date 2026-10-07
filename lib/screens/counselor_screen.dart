import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/app_background.dart';

class CounselorScreen extends StatefulWidget {
  const CounselorScreen({super.key});

  @override
  State<CounselorScreen> createState() => _CounselorScreenState();
}

class _CounselorScreenState extends State<CounselorScreen> {
  // gform, facebook, tiktok url
  static const String _gformUrl = 'https://forms.gle/PwJ3dy86ZMFhCn1P7';
  static const String _facebookUrl =
      'https://www.facebook.com/share/1ECbxMqWFQ/?mibextid=wwXIfr';
  static const String _tiktokUrl =
      'https://www.tiktok.com/@upskkmj?_r=1&_t=ZS-9A7s9cTUwJa';

  Future<void> _openUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) debugPrint('Unable to open link: $urlString');
    } catch (error) {
      debugPrint('Unable to open link: $urlString: $error');
    }
  }

  void _showPosterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.white,
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: Image.asset(
                    'assets/icon/poster_kaunseling.jpeg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPosterCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _showPosterDialog,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Image.asset(
                    'assets/icon/poster_kaunseling.jpeg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Tap to view poster',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildSocialCard({
    required String title,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                iconWidget,
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C2C2C),
                    ),
                  ),
                ),
                Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Title: KMJ COUNSELOR
              const Text(
                'KMJ COUNSELOR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                  color: Colors.red,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 22),

              // Poster Card
              _buildPosterCard(),

              // Section: Borang Temujanji & Saluran Rasmi
              const Text(
                'Borang Temujanji & Saluran Rasmi',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'serif',
                  color: Color.fromARGB(255, 0, 0, 0),
                  letterSpacing: 1.0,
                ),
              ),

              // Google Form Card
              _buildSocialCard(
                title: 'Borang Temujanji Kaunseling',
                iconWidget: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F3FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assignment,
                    color: Color(0xFF1877F2),
                    size: 28,
                  ),
                ),
                onTap: () => _openUrl(_gformUrl),
              ),

              // Facebook Card
              _buildSocialCard(
                title: 'Facebook Rasmi UPsK KMJ',
                iconWidget: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F3FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.facebook,
                    color: Color(0xFF1877F2),
                    size: 28,
                  ),
                ),
                onTap: () => _openUrl(_facebookUrl),
              ),

              // TikTok Card
              _buildSocialCard(
                title: 'TikTok Rasmi UPsK KMJ',
                iconWidget: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.music_note,
                      color: Colors.black87,
                      size: 26,
                    ),
                  ),
                ),
                onTap: () => _openUrl(_tiktokUrl),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      ),
    );
  }
}