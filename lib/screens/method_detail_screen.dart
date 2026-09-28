import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/link.dart';
import '../models/method.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MethodDetailScreen extends StatefulWidget {
  final Method method;

  const MethodDetailScreen({
    super.key,
    required this.method,
  });

  @override
  State<MethodDetailScreen> createState() => _MethodDetailScreenState();
}

class _MethodDetailScreenState extends State<MethodDetailScreen> {
  bool loading = true;
  List<MethodLink> links = [];

  @override
  void initState() {
    super.initState();
    _loadLinks();
    _saveActivity();
  }

  Future<void> _loadLinks() async {
    final result = await ApiService.get(
      'getLink',
      params: {
        'method_id': widget.method.methodId,
      },
    );

    if (result['success'] == true) {
      final data = result['data'];
      final List<dynamic> linkData = data['links'] ?? [];

      links = linkData
          .map((item) => MethodLink.fromJson(item))
          .where((link) => link.linkUrl.isNotEmpty)
          .toList();
    }

    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  Future<void> _saveActivity() async {
    final user = await AuthService.getUser();
    if (user == null) return;

    try {
      await ApiService.post({
        'action': 'saveActivity',
        'user_id': user.userId,
        'method_id': widget.method.methodId,
        'method_name': widget.method.methodName,
      });
    } catch (_) {}
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open link.'),
        ),
      );
    }
  }

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
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(top: 4, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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

  String? _extractYoutubeId(String url) {
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    } else if (uri.host.contains('youtube.com')) {
      if (uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'];
      }
      final segments = uri.pathSegments;
      final liveOrEmbedIndex = segments.indexWhere(
        (s) => s == 'live' || s == 'embed' || s == 'v',
      );
      if (liveOrEmbedIndex != -1 && liveOrEmbedIndex + 1 < segments.length) {
        return segments[liveOrEmbedIndex + 1];
      }
    }
    return null;
  }

  Widget _buildDescriptionCard() {
    if (widget.method.description.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            widget.method.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYoutubeCard(
    MethodLink link,
    String videoId, {
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openLink(link.linkUrl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 16:9 Thumbnail with Overlay
              Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF2C2C2C),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.red,
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Dark gradient overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Red Play Button Icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  // YouTube badge at top-right
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.ondemand_video_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'YouTube',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Title and Action Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      link.linkName.isEmpty ? 'Video Activity' : link.linkName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.play_circle_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Tap to watch video',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey.shade400,
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(MethodLink link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openLink(link.linkUrl),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.sports_esports_rounded,
                    color: Color(0xFF673AB7),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE7F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'INTERACTIVE GAME',
                          style: TextStyle(
                            color: Color(0xFF673AB7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        link.linkName.isEmpty ? 'Mini Game' : link.linkName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to play online',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.open_in_new,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStandardLinkCard(MethodLink link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openLink(link.linkUrl),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: Colors.red,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'RESOURCE / LINK',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        link.linkName.isEmpty ? 'Activity Link' : link.linkName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.public,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Open external resource',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.open_in_new,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionBox({
    required String sectionTitle,
    required String sectionSubtitle,
    required IconData sectionIcon,
    Widget? videoCard,
    required Widget contactCard,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Header inside Box
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  sectionIcon,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sectionTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sectionSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Video Card (if available)
          if (videoCard != null) ...[
            videoCard,
            const SizedBox(height: 12),
          ],

          // Contact Card
          contactCard,
        ],
      ),
    );
  }

  Widget _buildActivityCard(MethodLink link) {
    final youtubeId = _extractYoutubeId(link.linkUrl);

    // Group Talian Kasih & Befrienders into distinct box sections
    final isBercakap = widget.method.methodId == '5' ||
        widget.method.methodName.toLowerCase().contains('bercakap');

    if (isBercakap) {
      final nameLower = link.linkName.toLowerCase();
      final urlLower = link.linkUrl.toLowerCase();

      // Talian Kasih Box Section (Video + Contact Card)
      if (nameLower.contains('kasih') || urlLower.contains('cqzzlpblghy')) {
        return _buildSectionBox(
          sectionTitle: 'Talian Kasih (15999)',
          sectionSubtitle: 'Video Panduan & Talian Bantuan 24 Jam',
          sectionIcon: Icons.support_agent,
          videoCard: youtubeId != null
              ? _buildYoutubeCard(link, youtubeId, margin: EdgeInsets.zero)
              : null,
          contactCard: _buildContactCard(
            title: 'Talian Kasih',
            subtitle: 'KPWKM • Bantuan Krisis & Kaunseling 24 Jam',
            phone: '15999',
            whatsapp: '0192615999',
            icon: Icons.support_agent,
            margin: EdgeInsets.zero,
          ),
        );
      }

      // Befrienders KL Box Section (Video + Contact Card)
      if (nameLower.contains('befriend') || urlLower.contains('so5iz8wgo8s')) {
        return _buildSectionBox(
          sectionTitle: 'Befrienders KL',
          sectionSubtitle: 'Video Panduan & Sokongan Emosi 24 Jam',
          sectionIcon: Icons.volunteer_activism,
          videoCard: youtubeId != null
              ? _buildYoutubeCard(link, youtubeId, margin: EdgeInsets.zero)
              : null,
          contactCard: _buildContactCard(
            title: 'Befrienders KL',
            subtitle: 'Sokongan Emosi Percuma & Rahsia 24 Jam',
            phone: '03-76272929',
            icon: Icons.volunteer_activism,
            margin: EdgeInsets.zero,
          ),
        );
      }
    }

    if (youtubeId != null) {
      return _buildYoutubeCard(link, youtubeId);
    }
    if (link.linkUrl.contains('poki.com') || link.linkUrl.contains('game')) {
      return _buildGameCard(link);
    }
    return _buildStandardLinkCard(link);
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
            const SizedBox(height: 6),

            // Method Name
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      widget.method.methodName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'serif',
                        color: Colors.red,
                        letterSpacing: 1.0,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                color: Colors.red,
                onRefresh: _loadLinks,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About this technique card
                      _buildDescriptionCard(),

                      // Activities Section Header
                      const Text(
                        'Activities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),

                      const SizedBox(height: 14),

                      if (loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: CircularProgressIndicator(color: Colors.red),
                          ),
                        )
                      else if (links.isEmpty)
                        if (widget.method.methodId == '5' ||
                            widget.method.methodName
                                .toLowerCase()
                                .contains('bercakap'))
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionBox(
                                sectionTitle: 'Talian Kasih (15999)',
                                sectionSubtitle:
                                    'KPWKM • Bantuan Krisis & Kaunseling 24 Jam',
                                sectionIcon: Icons.support_agent,
                                contactCard: _buildContactCard(
                                  title: 'Talian Kasih',
                                  subtitle:
                                      'KPWKM • Bantuan Krisis & Kaunseling 24 Jam',
                                  phone: '15999',
                                  whatsapp: '0192615999',
                                  icon: Icons.support_agent,
                                  margin: EdgeInsets.zero,
                                ),
                              ),
                              _buildSectionBox(
                                sectionTitle: 'Befrienders KL',
                                sectionSubtitle:
                                    'Sokongan Emosi Percuma & Rahsia 24 Jam',
                                sectionIcon: Icons.volunteer_activism,
                                contactCard: _buildContactCard(
                                  title: 'Befrienders KL',
                                  subtitle:
                                      'Sokongan Emosi Percuma & Rahsia 24 Jam',
                                  phone: '03-76272929',
                                  icon: Icons.volunteer_activism,
                                  margin: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          )
                        else
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.playlist_remove_rounded,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No activities recorded yet for this technique.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      else
                        ...links.map((link) => _buildActivityCard(link)),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}