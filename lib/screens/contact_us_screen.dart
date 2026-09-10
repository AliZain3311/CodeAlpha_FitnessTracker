import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const String email = 'alizain263311@gmail.com';

  static const String phone = '+923000263311';

  Future<void> _sendEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: const {'subject': 'FitTrack Support'},
    );

    final bool launched = await launchUrl(emailUri);

    if (!launched && context.mounted) {
      _showMessage(context, 'Unable to open email application.');
    }
  }

  Future<void> _makeCall(BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    final bool launched = await launchUrl(phoneUri);

    if (!launched && context.mounted) {
      _showMessage(context, 'Unable to open phone application.');
    }
  }

  Future<void> _copyText(
    BuildContext context,
    String text,
    String label,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));

    if (!context.mounted) return;

    _showMessage(context, '$label copied to clipboard.');
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF172033),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        children: [
          _buildHeader(),

          const SizedBox(height: 24),

          _buildSectionTitle('Get in Touch'),

          _buildContactCard(
            icon: Icons.email_outlined,
            iconColor: const Color(0xFF2563EB),
            title: 'Email Support',
            value: email,
            subtitle: 'Send us your questions or feedback',
            primaryActionLabel: 'Send Email',
            primaryIcon: Icons.send_rounded,
            onPrimaryTap: () {
              _sendEmail(context);
            },
            onCopyTap: () {
              _copyText(context, email, 'Email');
            },
          ),

          const SizedBox(height: 14),

          _buildContactCard(
            icon: Icons.phone_outlined,
            iconColor: const Color(0xFF059669),
            title: 'Phone Support',
            value: phone,
            subtitle: 'Contact us for assistance',
            primaryActionLabel: 'Call Now',
            primaryIcon: Icons.call_rounded,
            onPrimaryTap: () {
              _makeCall(context);
            },
            onCopyTap: () {
              _copyText(context, phone, 'Phone number');
            },
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Support Information'),

          _buildInfoCard(),

          const SizedBox(height: 24),

          _buildTipCard(),

          const SizedBox(height: 25),

          const Center(
            child: Text(
              'FitTrack • Version 1.0.0',
              style: TextStyle(
                color: Color(0xFF98A2B3),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: const Color(0xFF2563EB).withOpacity(0.20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We are here to help',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Have a question, suggestion or need assistance? Get in touch with FitTrack support.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF98A2B3),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required String primaryActionLabel,
    required IconData primaryIcon,
    required VoidCallback onPrimaryTap,
    required VoidCallback onCopyTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECF3)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: iconColor.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      color: Color(0xFF344054),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onCopyTap,
                  tooltip: 'Copy',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.copy_outlined,
                    size: 18,
                    color: Color(0xFF667085),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPrimaryTap,
              icon: Icon(primaryIcon, size: 18),
              label: Text(primaryActionLabel),
              style: FilledButton.styleFrom(
                backgroundColor: iconColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: const Column(
        children: [
          _InfoRow(
            icon: Icons.question_answer_outlined,
            title: 'Questions',
            description: 'Ask about using FitTrack features.',
          ),
          SizedBox(height: 16),
          _InfoRow(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Suggestions',
            description: 'Share ideas that could improve the app.',
          ),
          SizedBox(height: 16),
          _InfoRow(
            icon: Icons.bug_report_outlined,
            title: 'Technical Issues',
            description: 'Report problems or unexpected behavior.',
          ),
          SizedBox(height: 16),
          _InfoRow(
            icon: Icons.feedback_outlined,
            title: 'Feedback',
            description: 'Tell us about your FitTrack experience.',
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD9E5FF)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tips_and_updates_outlined,
            color: Color(0xFF2563EB),
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Before contacting support',
                  style: TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'For workout tracking issues, make sure Location and Physical Activity permissions are enabled and your device location service is turned on.',
                  style: TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF344054),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
