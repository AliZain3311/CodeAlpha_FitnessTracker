import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _email = 'alizain263311@gmail.com';

  static const String _phone = '+923000263311';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        title: const Text(
          'Help & Support',
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
          _buildWelcomeCard(),

          const SizedBox(height: 24),

          _buildSectionTitle('Frequently Asked Questions'),

          _buildFaqCard(
            icon: Icons.play_circle_outline_rounded,
            iconColor: const Color(0xFF2563EB),
            question: 'How does Real-Time Workout work?',
            answer:
                'Start a workout and FitTrack uses your device movement, GPS and step information to calculate workout progress. Distance is updated from valid movement instead of simply increasing while the phone is stationary.',
          ),

          _buildFaqCard(
            icon: Icons.directions_walk_rounded,
            iconColor: const Color(0xFF059669),
            question: 'How are steps counted?',
            answer:
                'FitTrack uses the device pedometer when available. During a workout, the app calculates session steps from the step count received by the device.',
          ),

          _buildFaqCard(
            icon: Icons.location_on_outlined,
            iconColor: const Color(0xFF7C3AED),
            question: 'Why does distance stay at zero?',
            answer:
                'Distance requires valid GPS movement. If the phone remains in one place, GPS movement is not added. Poor GPS accuracy, very small movement or unrealistic GPS jumps are also ignored.',
          ),

          _buildFaqCard(
            icon: Icons.local_fire_department_outlined,
            iconColor: const Color(0xFFEF4444),
            question: 'How are calories calculated?',
            answer:
                'FitTrack estimates workout calories using the tracked movement data. Calories should increase with meaningful workout activity rather than simply increasing because the workout screen is open.',
          ),

          _buildFaqCard(
            icon: Icons.flag_outlined,
            iconColor: const Color(0xFFF59E0B),
            question: 'How do I set a Fitness Goal?',
            answer:
                'Open Fitness Goals from the dashboard or drawer. You can define targets such as daily steps, calories, duration and distance. A Goal Workout becomes available when an active goal exists.',
          ),

          _buildFaqCard(
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF16A34A),
            question: 'What happens when I complete a goal?',
            answer:
                'After all active targets of a Goal Workout are reached, FitTrack records the completion and the completed goal can be viewed from All Goals.',
          ),

          _buildFaqCard(
            icon: Icons.bar_chart_rounded,
            iconColor: const Color(0xFF2563EB),
            question: 'What can I see in Statistics?',
            answer:
                'Statistics provides activity information for the currently logged-in user, including steps, calories, duration, distance, activity breakdown and recent activities.',
          ),

          _buildFaqCard(
            icon: Icons.pause_circle_outline_rounded,
            iconColor: const Color(0xFF667085),
            question: 'Can I pause a workout?',
            answer:
                'Yes. Pause stops active workout tracking temporarily. When you resume, the active workout continues without counting the paused period as workout duration.',
          ),

          const SizedBox(height: 22),

          _buildSectionTitle('Privacy & Data'),

          _buildPrivacyCard(),

          const SizedBox(height: 22),

          _buildSectionTitle('Need More Help?'),

          _buildContactCard(context),

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

  Widget _buildWelcomeCard() {
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How can we help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Find answers to common FitTrack questions.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
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

  Widget _buildFaqCard({
    required IconData icon,
    required Color iconColor,
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: iconColor.withOpacity(0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          title: Text(
            question,
            style: const TextStyle(
              color: Color(0xFF344054),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          iconColor: const Color(0xFF667085),
          collapsedIconColor: const Color(0xFF98A2B3),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: const Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.security_outlined, color: Color(0xFF2563EB), size: 23),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your fitness data is user-specific',
                      style: TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Activities, goals and statistics are filtered using the currently logged-in user account.',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 11,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFF059669),
                size: 23,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account access',
                      style: TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Only the currently authenticated local account is used when displaying personal fitness information.',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 11,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8ECF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Still need assistance?',
            style: TextStyle(
              color: Color(0xFF172033),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Contact FitTrack support using the information below.',
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 17),
          _contactRow(
            icon: Icons.email_outlined,
            title: 'Email',
            value: _email,
          ),
          const SizedBox(height: 12),
          _contactRow(
            icon: Icons.phone_outlined,
            title: 'Phone',
            value: _phone,
          ),
          const SizedBox(height: 17),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showContactInfo(context);
              },
              icon: const Icon(Icons.contact_support_outlined, size: 18),
              label: const Text('View Contact Information'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFFB9CBF7)),
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

  Widget _contactRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF344054),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showContactInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Contact FitTrack Support',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                _email,
                style: TextStyle(
                  color: Color(0xFF344054),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Phone',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                _phone,
                style: TextStyle(
                  color: Color(0xFF344054),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
